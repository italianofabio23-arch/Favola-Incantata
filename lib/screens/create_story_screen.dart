import 'package:flutter/material.dart';

import '../models/story_config.dart';
import '../widgets/magic_background.dart';
import 'story_reader_screen.dart';

class CreateStoryScreen extends StatefulWidget {
  const CreateStoryScreen({super.key});

  @override
  State<CreateStoryScreen> createState() => _CreateStoryScreenState();
}

class _CreateStoryScreenState extends State<CreateStoryScreen> {
  final _nameController = TextEditingController();

  String protagonist = 'Bambina';
  String setting = 'Foresta';
  String villain = 'Drago';
  final Set<String> friends = {'Cagnolino'};
  String voice = 'Nonna';
  String length = 'Normale';

  final protagonists = const {
    'Bambino': '👦',
    'Bambina': '👧',
    'Principe': '🤴',
    'Principessa': '👸',
    'Fantasmino buono': '👻',
    'Scimmietta': '🐒',
    'Fatina': '🧚',
    'Unicorno': '🦄',
  };

  final settings = const {
    'Castello': '🏰',
    'Foresta': '🌲',
    'Mondo di caramelle': '🍭',
    'Spazio': '🚀',
    'Casa nel bosco': '🏡',
    'Regno sottomarino': '🌊',
    'Isola misteriosa': '🏝️',
    'Regno di ghiaccio': '❄️',
  };

  final villains = const {
    'Strega': '🧙‍♀️',
    'Drago': '🐉',
    'Mago cattivo': '🧙‍♂️',
    'Faraone': '👑',
    'Orco': '👹',
    'Fantasma dispettoso': '👻',
  };

  final friendOptions = const {
    'Orso': '🐻',
    'Leone': '🦁',
    'Uccellini': '🐦',
    'Aquila': '🦅',
    'Amico': '🧒',
    'Amica': '👧',
    'Cagnolino': '🐶',
    'Gatto': '🐱',
    'Coniglietto': '🐰',
  };

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MagicBackground(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 16, 8),
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
                        Text(
                          '✨ Crea la tua favola',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                        ),
                        Text('Scegli gli ingredienti della tua storia', style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  TextField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: _inputDecoration('Come si chiama il protagonista?', 'Es. Sofia'),
                  ),
                  const SizedBox(height: 22),
                  _SectionTitle('Scegli il protagonista'),
                  _ChoiceGrid(
                    items: protagonists,
                    selected: {protagonist},
                    onTap: (value) => setState(() => protagonist = value),
                  ),
                  const SizedBox(height: 22),
                  _SectionTitle('Scegli l\'ambientazione'),
                  _ChoiceGrid(
                    items: settings,
                    selected: {setting},
                    onTap: (value) => setState(() => setting = value),
                  ),
                  const SizedBox(height: 22),
                  _SectionTitle('Scegli il cattivo'),
                  _ChoiceGrid(
                    items: villains,
                    selected: {villain},
                    onTap: (value) => setState(() => villain = value),
                  ),
                  const SizedBox(height: 22),
                  const _SectionTitle('Amici di viaggio · massimo 3'),
                  _ChoiceGrid(
                    items: friendOptions,
                    selected: friends,
                    onTap: (value) {
                      setState(() {
                        if (friends.contains(value)) {
                          friends.remove(value);
                        } else if (friends.length < 3) {
                          friends.add(value);
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 22),
                  const _SectionTitle('Voce narrante'),
                  Row(
                    children: [
                      Expanded(
                        child: _VoiceCard(
                          emoji: '👩',
                          title: 'Mamma',
                          subtitle: 'Dolce e rassicurante',
                          selected: voice == 'Mamma',
                          onTap: () => setState(() => voice = 'Mamma'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _VoiceCard(
                          emoji: '👵',
                          title: 'Nonna',
                          subtitle: 'Calma e lenta',
                          selected: voice == 'Nonna',
                          onTap: () => setState(() => voice = 'Nonna'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  const _SectionTitle('Durata della favola'),
                  SegmentedButton<String>(
  segments: const [
    ButtonSegment<String>(
      value: 'Breve',
      icon: Icon(Icons.bolt_rounded),
      label: Text('Breve'),
    ),
    ButtonSegment<String>(
      value: 'Normale',
      icon: Icon(Icons.auto_stories_rounded),
      label: Text('Normale'),
    ),
    ButtonSegment<String>(
      value: 'Lunga',
      icon: Icon(Icons.nightlight_round),
      label: Text('Lunga'),
    ),
  ],
  selected: {length},
  showSelectedIcon: false,
  style: ButtonStyle(
    foregroundColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? const Color(0xFF392300)
          : Colors.white,
    ),
    backgroundColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? const Color(0xFFFFD54F)
          : Colors.white.withValues(alpha: 0.10),
    ),
  ),
  onSelectionChanged: (value) {
    setState(() => length = value.first);
  },
),
                  const SizedBox(height: 28),
                Container(
  width: double.infinity,
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(24),
    boxShadow: const [
      BoxShadow(
        color: Color(0x99FFD54F),
        blurRadius: 22,
        spreadRadius: 2,
      ),
    ],
  ),
  child: FilledButton.icon(
    style: FilledButton.styleFrom(
      minimumSize: const Size.fromHeight(68),
      backgroundColor: const Color(0xFFFFD54F),
      foregroundColor: const Color(0xFF392300),
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    ),
    onPressed: () {
      final config = StoryConfig(
        childName: _nameController.text,
        protagonist: protagonist,
        setting: setting,
        villain: villain,
        friends: friends.toList(),
        voice: voice,
        length: length,
      );

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => StoryReaderScreen(config: config),
        ),
      );
    },
    icon: const Icon(
      Icons.auto_awesome_rounded,
      size: 30,
    ),
    label: const Text(
      '✨ Inizia la magica avventura',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w900,
      ),
    ),
  ),
),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: Colors.white.withValues(alpha: .08),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: .15)),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
    );
  }
}

class _ChoiceGrid extends StatelessWidget {
  const _ChoiceGrid({
    required this.items,
    required this.selected,
    required this.onTap,
  });

  final Map<String, String> items;
  final Set<String> selected;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.25,
      ),
      itemBuilder: (context, index) {
        final entry = items.entries.elementAt(index);
        final isSelected = selected.contains(entry.key);

        return InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () => onTap(entry.key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: isSelected
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFFFD54F),
                        Color(0xFFFFA000),
                      ],
                    )
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.16),
                        Colors.white.withValues(alpha: 0.07),
                      ],
                    ),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFFFF3B0)
                    : Colors.white.withValues(alpha: 0.25),
                width: isSelected ? 2.5 : 1,
              ),
              boxShadow: isSelected
                  ? const [
                      BoxShadow(
                        color: Color(0x88FFD54F),
                        blurRadius: 18,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          entry.value,
                          style: const TextStyle(
                            fontSize: 34,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          entry.key,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: isSelected
                                ? const Color(0xFF392300)
                                : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (isSelected)
                  const Positioned(
                    right: 8,
                    top: 8,
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF392300),
                      size: 24,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _VoiceCard extends StatelessWidget {
  const _VoiceCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 18,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: selected
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFFD54F),
                    Color(0xFFFFA000),
                  ],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.16),
                    Colors.white.withValues(alpha: 0.07),
                  ],
                ),
          border: Border.all(
            color: selected
                ? const Color(0xFFFFF3B0)
                : Colors.white.withValues(alpha: 0.25),
            width: selected ? 2.5 : 1,
          ),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: Color(0x88FFD54F),
                    blurRadius: 18,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    emoji,
                    style: const TextStyle(
                      fontSize: 42,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: selected
                          ? const Color(0xFF392300)
                          : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.2,
                      color: selected
                          ? const Color(0xFF5B3A00)
                          : Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
            ),

            if (selected)
              const Positioned(
                right: 0,
                top: 0,
                child: Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF392300),
                  size: 24,
                ),
              ),
          ],
        ),
      ),
    );
  }
}