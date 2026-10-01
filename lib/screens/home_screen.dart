import 'package:flutter/material.dart';

import '../widgets/magic_background.dart';
import '../widgets/magic_book.dart';
import 'create_story_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MagicBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 18,
            ),
            child: Column(
              children: [
                const Spacer(),

                // Titolo
                const Text(
                  '✨ Favola Incantata ✨',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFFFE082),
                    letterSpacing: 1.2,
                    shadows: [
                      Shadow(
                        blurRadius: 18,
                        color: Color(0xAAFFD54F),
                      ),
                      Shadow(
                        blurRadius: 6,
                        color: Colors.black54,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  'Ogni bambino ha una storia speciale da vivere...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.92),
                  ),
                ),

                const SizedBox(height: 28),

                // Libro incantato
                const MagicBook(),

                const SizedBox(height: 30),

                // Pulsante principale
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x88FFD54F),
                        blurRadius: 22,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(64),
                      backgroundColor: const Color(0xFFFFC107),
                      foregroundColor: const Color(0xFF29145F),
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CreateStoryScreen(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.auto_stories_rounded,
                      size: 30,
                    ),
                    label: const Text(
                      'Crea la tua favola',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Piccole caratteristiche
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _MiniFeature(
                      icon: '🌙',
                      label: 'Magica',
                    ),
                    _MiniFeature(
                      icon: '🎙️',
                      label: 'Narrata',
                    ),
                    _MiniFeature(
                      icon: '📖',
                      label: 'Animata',
                    ),
                  ],
                ),

                const Spacer(),

                Text(
                  'Una nuova avventura ti aspetta...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: Colors.white.withValues(alpha: 0.65),
                  ),
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniFeature extends StatelessWidget {
  const _MiniFeature({
    required this.icon,
    required this.label,
  });

  final String icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          icon,
          style: const TextStyle(fontSize: 28),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}