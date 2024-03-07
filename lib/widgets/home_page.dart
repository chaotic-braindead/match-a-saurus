
import 'package:flutter/material.dart';
import 'package:memory_game/widgets/game.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Memory Game"),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text("Play"),
          onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (context) => const Game())
          ),
        ),
      ),
    );
  }
}
