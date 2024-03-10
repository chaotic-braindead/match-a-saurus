import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:memory_game/models/card_item.dart';
import 'package:memory_game/widgets/card_widget.dart';
import 'package:memory_game/widgets/home_page.dart';
import 'package:memory_game/widgets/leaderboard.dart';

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
  bool enableTaps = true;
  
  @override
  void initState(){
    super.initState();
    cards = _getRandomCards(12);
    tappedCard = null;
    validPairs = [];
    _startTimer(60);
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

  void _startTimer(int time){
    counter = time;
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if(counter > 0){
        setState(() {
         --counter;
        });
      } else {
        timer.cancel();
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Leaderboard(score: score)));
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
    });
    if(tappedCard == card){
      return;
    }
    if(tappedCard?.val == card.val){
      setState(() {
        score += counter;
        validPairs.add(tappedCard!);
        validPairs.add(card);
        tappedCard = null;
      });
    }
    else{
      setState(() => enableTaps = false);
      Timer(const Duration(milliseconds: 500), () {
          tappedCard?.isTapped = false;
          card.isTapped = false;
          tappedCard = null;
          setState(() => enableTaps = true);
        });
    }
    if(validPairs.length == cards.length){
      timer.cancel();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Leaderboard(score: score)));
    }
  }

  Widget _buildPopupDialog(BuildContext context) {
  return AlertDialog(
    title: const Center(child: Text('Paused')),
    actions: <Widget>[
      Center(child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [ElevatedButton(
          onPressed: () {
            _startTimer(counter);
            Navigator.of(context).pop();
          },
          child: const Text("Play")),
          ElevatedButton(
          onPressed: () {
           Navigator.pop(context);
           Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
          },
          child: const Text("Quit")),
        ])),
    ],
  );
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: (counter != 0) ? Text("Time: $counter Score: $score") : const Text("Time's up!")),
        backgroundColor: counter != 0 ? Colors.blue : Colors.red,
        actions: [IconButton(icon: Icon(Icons.pause), onPressed: () { 
              timer.cancel();
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) => _buildPopupDialog(context)
              );
            }) 
          ],
        ),
      body: GridView.count(
        padding: const EdgeInsets.all(20),
        crossAxisCount: 3,
        mainAxisSpacing: 20.0,
        crossAxisSpacing: 20.0,
        children: cards.map((card) => CardWidget(
          card: card,
          onTap: enableTaps ? _handleTap : null,
          )).toList()
        ),
    );
  }
}