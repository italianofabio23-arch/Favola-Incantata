import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FavolaIncantataApp());
}

class FavolaIncantataApp extends StatelessWidget {
  const FavolaIncantataApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Favola Incantata',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF061A3A),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF8C75A),
          brightness: Brightness.dark,
        ),
        fontFamily: 'serif',
      ),
      home: const HomeScreen(),
    );
  }
}
