import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:page_flip/page_flip.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/story_config.dart';
import '../services/story_builder.dart';
import '../widgets/magic_background.dart';

class StoryReaderScreen extends StatefulWidget {
  const StoryReaderScreen({
    super.key,
    required this.config,
  });

  final StoryConfig config;

  @override
  State<StoryReaderScreen> createState() => _StoryReaderScreenState();
}

class _StoryReaderScreenState extends State<StoryReaderScreen> {
  final FlutterTts _tts = FlutterTts();
  final GlobalKey<PageFlipWidgetState> _flipKey = GlobalKey<PageFlipWidgetState>();
  bool _resumeAfterFlip = false;
  Future<dynamic>? _flipStopFuture;
  late final List<StoryPageData> _pages;

  int _pageIndex = 0;
  bool _isSpeaking = false;
  bool _autoContinue = true;
  bool _forward = true;
  bool _isTurning = false;
  bool _previewing = false;
  int _speechVersion = 0;
  late final Future<void> _ttsSetup;
  final List<Map<String, String>> _italianVoices = [];
  Map<String, String>? _selectedVoice;

  @override
  void initState() {
    super.initState();
    _pages = StoryBuilder.build(widget.config);
    _ttsSetup = _setupTts();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _cacheNextImage(0);
    });
  }

  // Decodifica in anticipo un'illustrazione alla dimensione del telefono.
  // Evita picchi di memoria durante l'animazione di cambio pagina.
  void _cacheNextImage(int current) {
    final next = current + 1;
    if (next >= _pages.length) return;
    final asset = _pages[next].imageAsset;
    if (asset != null) {
      precacheImage(ResizeImage(AssetImage(asset), width: 1080), context);
    }
  }

  Future<void> _setupTts() async {
    _tts.setStartHandler(() {
      if (mounted && !_previewing) setState(() => _isSpeaking = true);
    });

    _tts.setCompletionHandler(() {
      if (!mounted) return;
      if (_previewing) {
        _previewing = false;
        return;
      }
      // Ignora le notifiche arrivate dopo uno stop o durante il cambio pagina.
      if (!_isSpeaking || _isTurning) return;
      final version = _speechVersion;
      final completedPage = _pageIndex;
      setState(() => _isSpeaking = false);
      if (!_autoContinue || completedPage >= _pages.length - 1) return;
      Future<void>.delayed(const Duration(milliseconds: 400), () {
        if (!mounted || !_autoContinue || _isTurning ||
            version != _speechVersion || _pageIndex != completedPage) return;
        _goToPage(completedPage + 1, speakAfterTurn: true);
      });
    });

    // Lo stato viene gia' gestito dallo stop: un callback di cancel in
    // ritardo non deve fermare la narrazione della pagina successiva.
    _tts.setCancelHandler(() {});
    _tts.setErrorHandler((message) {
      debugPrint('TTS error: $message');
      if (mounted) setState(() => _isSpeaking = false);
    });

    try {
      await _tts.setLanguage('it-IT');
      await _tts.setVolume(1.0);
      final raw = await _tts.getVoices;
      if (raw is List) {
        for (final item in raw) {
          if (item is! Map) continue;
          final name = '${item['name'] ?? ''}';
          final locale = '${item['locale'] ?? ''}';
          if (name.isEmpty ||
              !locale.toLowerCase().replaceAll('_', '-').startsWith('it')) {
            continue;
          }
          _italianVoices.add({'name': name, 'locale': locale});
        }
      }

      final prefs = await SharedPreferences.getInstance();
      final prefKey = widget.config.voice.toLowerCase() == 'nonna'
          ? 'favola_voice_nonna'
          : 'favola_voice_mamma';
      final savedName = prefs.getString('${prefKey}_name');
      final savedLocale = prefs.getString('${prefKey}_locale');
      for (final voice in _italianVoices) {
        if (voice['name'] == savedName && voice['locale'] == savedLocale) {
          _selectedVoice = voice;
          break;
        }
      }
      if (_selectedVoice == null) {
        // Android spesso NON dichiara il genere nel nome della voce.
        final markedFemale = _italianVoices.where((voice) {
          final name = voice['name']!.toLowerCase();
          return name.contains('female') || name.contains('femminile');
        }).toList();
        if (markedFemale.isNotEmpty) {
          _selectedVoice = widget.config.voice == 'Nonna' &&
                  markedFemale.length > 1
              ? markedFemale[1]
              : markedFemale.first;
        }
      }
      await _applyVoiceStyle();
    } catch (error) {
      debugPrint('TTS setup: $error');
    }
    if (mounted) setState(() {});
  }

  Future<void> _applyVoiceStyle() async {
    final isNonna = widget.config.voice == 'Nonna';
    await _tts.setSpeechRate(isNonna ? 0.38 : 0.46);
    await _tts.setPitch(isNonna ? 0.96 : 1.08);
    if (_selectedVoice != null) await _tts.setVoice(_selectedVoice!);
  }

  Future<void> _stopReading() async {
    ++_speechVersion;
    if (mounted) setState(() => _isSpeaking = false);
    await _tts.stop();
  }

  Future<void> _speakCurrentPage() async {
    if (_isTurning || _previewing) return;
    final version = ++_speechVersion;
    await _ttsSetup;
    if (!mounted || version != _speechVersion) return;
    try {
      // Non interrogare l'elenco di tutte le voci a ogni pagina.
      await _applyVoiceStyle();
      if (!mounted || version != _speechVersion) return;
      final page = _pages[_pageIndex];
      await _tts.speak('${page.title}. ${page.text}');
    } catch (error) {
      debugPrint('TTS speak: $error');
      if (mounted) setState(() => _isSpeaking = false);
    }
  }

  Future<void> _toggleSpeak() async {
    if (_isSpeaking) {
      await _stopReading();
    } else {
      await _speakCurrentPage();
    }
  }

  Future<void> _goToPage(int index, {bool speakAfterTurn = false}) async {
    if (_isTurning || !mounted || index < 0 ||
        index >= _pages.length ||
        (index - _pageIndex).abs() != 1) return;

    final flip = _flipKey.currentState;
    if (flip == null) return;

    _isTurning = true;
    _resumeAfterFlip = speakAfterTurn;
    final version = ++_speechVersion;
    final needsStop = _isSpeaking || _previewing;
    _previewing = false;
    setState(() => _isSpeaking = false);

    if (needsStop) await _tts.stop();

    if (!mounted || version != _speechVersion) {
      _isTurning = false;
      _resumeAfterFlip = false;
      return;
    }

    try {
      if (index > _pageIndex) {
        await flip.nextPage();
      } else {
        await flip.previousPage();
      }
    } catch (error) {
      debugPrint("Errore sfoglio: $error");
      _isTurning = false;
      _resumeAfterFlip = false;
    }
  }

  Future<void> _previewVoice(Map<String, String> voice) async {
    await _stopReading();
    _previewing = true;
    try {
      await _tts.setLanguage('it-IT');
      await _tts.setVoice(voice);
      await _tts.setSpeechRate(widget.config.voice == 'Nonna' ? 0.38 : 0.46);
      await _tts.speak('Ciao, sono la voce della tua favola magica.');
    } catch (error) {
      _previewing = false;
      debugPrint('Voice preview: $error');
    }
  }

  Future<void> _chooseNarratorVoice() async {
    await _ttsSetup;
    if (!mounted) return;
    if (_italianVoices.isEmpty) {
      showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Nessuna voce italiana trovata'),
          content: const Text(
            'Installa o aggiorna Servizi vocali di Google nelle '
            'impostazioni del telefono e scarica una voce italiana.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }
    await _stopReading();
    final choice = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: SizedBox(
          height: MediaQuery.of(sheetContext).size.height * 0.60,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Scegli una voce italiana: ascolta le anteprime '
                  'e seleziona quella che preferisci.',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _italianVoices.length,
                  itemBuilder: (context, index) {
                    final voice = _italianVoices[index];
                    return ListTile(
                      title: Text('Voce ${index + 1}'),
                      subtitle: Text(voice['name'] ?? ''),
                      trailing: IconButton(
                        icon: const Icon(Icons.volume_up_rounded),
                        tooltip: 'Ascolta',
                        onPressed: () => _previewVoice(voice),
                      ),
                      onTap: () => Navigator.pop(sheetContext, voice),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
    _previewing = false;
    await _tts.stop();
    if (!mounted) return;
    if (choice != null) {
      setState(() => _selectedVoice = choice);
      try {
        final prefs = await SharedPreferences.getInstance();
        final prefKey = widget.config.voice.toLowerCase() == 'nonna'
            ? 'favola_voice_nonna'
            : 'favola_voice_mamma';
        await prefs.setString('${prefKey}_name', choice['name']!);
        await prefs.setString('${prefKey}_locale', choice['locale']!);
      } catch (error) {
        debugPrint('Saving narrator voice: $error');
      }
    }
    await _applyVoiceStyle();
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_pageIndex];
    final progress = (_pageIndex + 1) / _pages.length;

    return Scaffold(
      body: MagicBackground(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 12, 4),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('✨ La favola prende vita', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800)),
                        Text('Ascolta, guarda le immagini e gira pagina', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.favorite_border_rounded)),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
                child: PageFlipWidget(
                  key: _flipKey,
                  onFlipStart: () {
                    if (_isTurning) return;
                    _isTurning = true;
                    _resumeAfterFlip = _isSpeaking;
                    ++_speechVersion;
                    _previewing = false;
                    setState(() => _isSpeaking = false);
                    _flipStopFuture = _tts.stop();
                  },
                  onPageFlipped: (index) async {
                    if (!mounted) return;
                    setState(() => _pageIndex = index);
                    _cacheNextImage(index);
                    final pending = _flipStopFuture;
                    _flipStopFuture = null;
                    if (pending != null) await pending;
                    final resume = _resumeAfterFlip;
                    _resumeAfterFlip = false;
                    _isTurning = false;
                    if (mounted && resume) await _speakCurrentPage();
                  },
                  duration: const Duration(milliseconds: 780),
                  backgroundColor: const Color(0xFFF8EFD8),
                  children: [
                    for (int i = 0; i < _pages.length; i++)
                      _OpenBook(
                        key: ValueKey(i),
                        page: _pages[i],
                        pageNumber: i + 1,
                        totalPages: _pages.length,
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 2, 18, 18),
              child: Column(
                children: [
                  Text(
                    page.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFFFFE49A)),
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(99),
                    backgroundColor: Colors.white12,
                    color: const Color(0xFFFFD56B),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton.filledTonal(
                        onPressed: _pageIndex == 0 ? null : () => _goToPage(_pageIndex - 1, speakAfterTurn: _isSpeaking),
                        icon: const Icon(Icons.skip_previous_rounded),
                      ),
                      const SizedBox(width: 18),
                      SizedBox(
                        width: 66,
                        height: 66,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            shape: const CircleBorder(),
                            backgroundColor: const Color(0xFFFFD56B),
                            foregroundColor: const Color(0xFF342100),
                            padding: EdgeInsets.zero,
                          ),
                          onPressed: _toggleSpeak,
                          child: Icon(_isSpeaking ? Icons.stop_rounded : Icons.play_arrow_rounded, size: 34),
                        ),
                      ),
                      const SizedBox(width: 18),
                      IconButton.filledTonal(
                        onPressed: _pageIndex == _pages.length - 1 ? null : () => _goToPage(_pageIndex + 1, speakAfterTurn: _isSpeaking),
                        icon: const Icon(Icons.skip_next_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        onPressed: _chooseNarratorVoice,
                        icon: const Icon(Icons.record_voice_over_rounded,
                            color: Color(0xFFFFD56B), size: 18),
                        label: Text('${widget.config.voice}: scegli voce',
                            style: const TextStyle(fontSize: 11,
                                color: Colors.white70)),
                      ),
                      Row(
                        children: [
                          const Text('Auto pagina', style: TextStyle(fontSize: 12, color: Colors.white70)),
                          Switch(
                            value: _autoContinue,
                            onChanged: (value) => setState(() => _autoContinue = value),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OpenBook extends StatelessWidget {
  const _OpenBook({
    super.key,
    required this.page,
    required this.pageNumber,
    required this.totalPages,
  });

  final StoryPageData page;
  final int pageNumber;
  final int totalPages;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 680;
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8EFD8),
            borderRadius: BorderRadius.circular(26),
            boxShadow: const [
              BoxShadow(color: Color(0x77FFD56B), blurRadius: 35, spreadRadius: 3),
              BoxShadow(color: Colors.black54, blurRadius: 18, offset: Offset(0, 10)),
            ],
            border: Border.all(color: const Color(0xFFD8B45E), width: 2),
          ),
          child: isWide
              ? Row(
                  children: [
                    Expanded(child: _SceneIllustration(page: page)),
                    Container(width: 2, color: const Color(0xFFD8C79E)),
                    Expanded(child: _StoryText(page: page, pageNumber: pageNumber, totalPages: totalPages)),
                  ],
                )
              : Column(
                  children: [
                    Expanded(flex: 5, child: _SceneIllustration(page: page)),
                    Container(height: 2, color: const Color(0xFFD8C79E)),
                    Expanded(flex: 4, child: _StoryText(page: page, pageNumber: pageNumber, totalPages: totalPages)),
                  ],
                ),
        );
      },
    );
  }
}

class _SceneIllustration extends StatelessWidget {
  const _SceneIllustration({required this.page});

  final StoryPageData page;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(24),
        bottomLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      ),
      child: Image.asset(
        page.imageAsset!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        cacheWidth: 1080,
        filterQuality: FilterQuality.low,
        gaplessPlayback: true,
      ),
    );
  }
}

class _StoryText extends StatelessWidget {
  const _StoryText({
    required this.page,
    required this.pageNumber,
    required this.totalPages,
  });

  final StoryPageData page;
  final int pageNumber;
  final int totalPages;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(painter: _PaperLinesPainter()),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 34),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  page.title,
                  style: const TextStyle(
                    color: Color(0xFF6A4217),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  page.text,
                  style: const TextStyle(
                    color: Color(0xFF3A2A1A),
                    height: 1.5,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          right: 14,
          bottom: 10,
          child: Text(
            '$pageNumber / $totalPages',
            style: const TextStyle(color: Color(0xFF8A704E), fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _PaperLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x0F7A5B35)
      ..strokeWidth = 1;
    for (double y = 42; y < size.height; y += 28) {
      canvas.drawLine(Offset(12, y), Offset(size.width - 12, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
