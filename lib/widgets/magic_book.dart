import 'package:flutter/material.dart';

class MagicBook extends StatefulWidget {
  const MagicBook({super.key});

  @override
  State<MagicBook> createState() => _MagicBookState();
}

class _MagicBookState extends State<MagicBook> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final lift = 5 * _controller.value;
        return Transform.translate(
          offset: Offset(0, -lift),
          child: child,
        );
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 290,
            height: 190,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(90),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x99FFD66B),
                  blurRadius: 70,
                  spreadRadius: 8,
                ),
              ],
            ),
          ),
          const Icon(
            Icons.menu_book_rounded,
            size: 230,
            color: Color(0xFFFFE7A1),
            shadows: [
              Shadow(color: Color(0xFFFFB83E), blurRadius: 18),
            ],
          ),
          const Positioned(top: 18, left: 35, child: Text('✨', style: TextStyle(fontSize: 34))),
          const Positioned(top: 5, right: 35, child: Text('⭐', style: TextStyle(fontSize: 30))),
          const Positioned(bottom: 14, right: 52, child: Text('✨', style: TextStyle(fontSize: 26))),
        ],
      ),
    );
  }
}
