import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:memory_game/models/card_item.dart';
import 'package:memory_game/widgets/card_widget.dart';

class Game extends StatefulWidget {
  const Game({super.key});
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
    startTimer();
    score = 0;
  }

  static List<CardItem> _shuffleCards(List<CardItem> cards) {
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

  void startTimer(){
    counter = 60;
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if(counter > 0){
        setState(() {
          counter--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _handleTap(CardItem card){
    if(counter == 0){
      return;
    }
    setState(() {
      card.isTapped = true;
      tappedCard ??= card;
      if(tappedCard == card){
        return;
      }
      if(tappedCard?.val == card.val){
        ++score;
        validPairs.add(tappedCard!);
        validPairs.add(card);
        tappedCard = null;
      }
      else{
        Timer(Duration(milliseconds: 200), () {
            tappedCard?.isTapped = false;
            card.isTapped = false;
            tappedCard = null;
          });
      }
    });
    if(validPairs.length == cards.length){
      timer.cancel();
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: counter != 0 ? Text("Time: $counter Score: $score") : const Text("Time's up!"),
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