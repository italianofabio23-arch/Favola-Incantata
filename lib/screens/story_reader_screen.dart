import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

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
  late final List<StoryPageData> _pages;

  int _pageIndex = 0;
  bool _isSpeaking = false;
  bool _autoContinue = true;
  bool _forward = true;

  @override
  void initState() {
    super.initState();
    _pages = StoryBuilder.build(widget.config);
    _setupTts();
  }

  Future<void> _setupTts() async {
    await _tts.setLanguage('it-IT');
    await _tts.setVolume(1.0);
    await _applyVoiceStyle();

    _tts.setStartHandler(() {
      if (mounted) setState(() => _isSpeaking = true);
    });

    _tts.setCompletionHandler(() async {
      if (!mounted) return;
      setState(() => _isSpeaking = false);
      if (_autoContinue && _pageIndex < _pages.length - 1) {
        await Future<void>.delayed(const Duration(milliseconds: 650));
        if (!mounted) return;
        _goToPage(_pageIndex + 1, speakAfterTurn: true);
      }
    });

    _tts.setCancelHandler(() {
      if (mounted) setState(() => _isSpeaking = false);
    });
  }


Future<void> _applyVoiceStyle() async {
  await _tts.setLanguage('it-IT');

  final isNonna = widget.config.voice == 'Nonna';

  await _tts.setSpeechRate(
    isNonna ? 0.38 : 0.46,
  );
  await _tts.setPitch(1.0);

  final availableVoices = await _tts.getVoices;

  if (availableVoices is List) {
    final italianVoices = availableVoices
        .where((voice) =>
            voice is Map &&
            '${voice['locale']}'.toLowerCase().startsWith('it'))
        .toList();

    for (final voice in italianVoices) {
      final name = '${voice['name']}'.toLowerCase();

      if (name.contains('female') ||
          name.contains('femminile')) {
        await _tts.setVoice({
          'name': '${voice['name']}',
          'locale': '${voice['locale']}',
        });
        break;
      }
    }
  }
}


  Future<void> _speakCurrentPage() async {
    await _tts.stop();
    await _applyVoiceStyle();
    final page = _pages[_pageIndex];
    await _tts.speak('${page.title}. ${page.text}');
  }

  Future<void> _toggleSpeak() async {
    if (_isSpeaking) {
      await _tts.stop();
      if (mounted) setState(() => _isSpeaking = false);
    } else {
      await _speakCurrentPage();
    }
  }

  Future<void> _goToPage(int index, {bool speakAfterTurn = false}) async {
    if (index < 0 || index >= _pages.length) return;
    await _tts.stop();
    if (!mounted) return;
    setState(() {
      _forward = index > _pageIndex;
      _pageIndex = index;
      _isSpeaking = false;
    });
    if (speakAfterTurn) {
      await Future<void>.delayed(const Duration(milliseconds: 900));
      if (mounted) await _speakCurrentPage();
    }
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
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 850),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    final rotate = Tween<double>(
                      begin: _forward ? math.pi / 2.6 : -math.pi / 2.6,
                      end: 0,
                    ).animate(animation);
                    return AnimatedBuilder(
                      animation: rotate,
                      child: child,
                      builder: (context, child) {
                        return Transform(
                          alignment: _forward ? Alignment.centerLeft : Alignment.centerRight,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.0015)
                            ..rotateY(rotate.value),
                          child: child,
                        );
                      },
                    );
                  },
                  child: _OpenBook(
                    key: ValueKey(_pageIndex),
                    page: page,
                    pageNumber: _pageIndex + 1,
                    totalPages: _pages.length,
                  ),
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
                        onPressed: _pageIndex == 0 ? null : () => _goToPage(_pageIndex - 1),
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
                        onPressed: _pageIndex == _pages.length - 1 ? null : () => _goToPage(_pageIndex + 1),
                        icon: const Icon(Icons.skip_next_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('🎙️ ${widget.config.voice}', style: const TextStyle(fontSize: 12, color: Colors.white70)),
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
