import 'package:flutter/material.dart';
import 'package:memory_game/widgets/home_page.dart';

void main() {
  runApp(const MemoryGame());
}

class MemoryGame extends StatelessWidget {
  const MemoryGame({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memory Game',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}