import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class HighScores extends StatefulWidget {
  const HighScores({super.key});
  @override
  State<StatefulWidget> createState() => _HighScoresState();
}

class _HighScoresState extends State<HighScores> {
  late Map<String, String> scores;
  @override 
  void initState(){
  
  }
  @override
  void setState(fn){
    if(mounted){
      super.setState(fn);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("High Scores")
      ),
      body: GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 20.0,
        crossAxisSpacing: 20.0,
        children: const [Text("Name"), Text("1")]),
    );
  }
  
}