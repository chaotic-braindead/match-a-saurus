import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:memory_game/models/card_item.dart';
import 'package:memory_game/models/player.dart';
import 'package:memory_game/widgets/card_widget.dart';
import 'package:memory_game/widgets/leaderboard.dart';

class Game extends StatefulWidget {
  String currentPlayer;
  Game({super.key, required this.currentPlayer});
  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> { 
  late List<CardItem> cards;
  late List<CardItem> validPairs;
  late CardItem? tappedCard;
  late int counter;
  late Timer timer;
  late int score;
  
  @override
  void initState(){
    super.initState();
    cards = _getRandomCards(12);
    tappedCard = null;
    validPairs = [];
    _startTimer();
    score = 0;
  }

  List<CardItem> _shuffleCards(List<CardItem> cards) {
    Random rng = Random();
    for(int i = cards.length-1; i >= 1; --i){
      int newIdx = rng.nextInt(i);
      CardItem temp = cards[i];
      cards[i] = cards[newIdx];
      cards[newIdx] = temp;
    }
    return cards;
  }
  List<CardItem> _getRandomCards(int max) {
    Random rng = Random();
    List<String> alpha = [];
    List<CardItem> cards = [];
    for(int i = 65; i <= 90; ++i){
      alpha.add(String.fromCharCode(i));
    }
    for(int i = 0; i < max/2; ++i){
      int n = rng.nextInt(alpha.length);
      cards.add(CardItem(val: alpha[n]));
      cards.add(CardItem(val: alpha[n]));
      alpha.removeAt(n);
    }
    return _shuffleCards(cards);
  }

  @override 
  void setState(fn) {
    if(mounted){
      super.setState(fn);
    }
  }

  void _startTimer(){
    counter = 60;
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if(counter > 0){
        setState(() {
          counter--;
        });
      } else {
        timer.cancel();
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Leaderboard(player: Player(name: widget.currentPlayer, score: score))));
      }
    });
  }

  void _handleTap(CardItem card){
    if(counter == 0){
      return;
    }
    card.isTapped = true;
    setState(() {
      tappedCard ??= card;
      if(tappedCard == card){
        return;
      }
      if(tappedCard?.val == card.val){
        score += counter;
        validPairs.add(tappedCard!);
        validPairs.add(card);
        tappedCard = null;
      }
      else{
        Timer(const Duration(milliseconds: 200), () {
            tappedCard?.isTapped = false;
            card.isTapped = false;
            tappedCard = null;
          });
      }
    });
    if(validPairs.length == cards.length){
      timer.cancel();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Leaderboard(player: Player(name: widget.currentPlayer, score: score))));
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: (counter != 0) ? Text("Time: $counter Score: $score") : const Text("Time's up!")),
        backgroundColor: counter != 0 ? Colors.blue : Colors.red,
        ),
      body: GridView.count(
        padding: const EdgeInsets.all(20),
        crossAxisCount: 3,
        mainAxisSpacing: 20.0,
        crossAxisSpacing: 20.0,
        children: cards.map((card) => CardWidget(
          card: card,
          onTap: _handleTap,
          )).toList()
        ),
    );
  }
}