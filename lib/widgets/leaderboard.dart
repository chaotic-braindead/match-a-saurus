import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:memory_game/db/db.dart';
import 'package:memory_game/models/player.dart';
import 'package:memory_game/widgets/game.dart';
import 'package:memory_game/widgets/home_page.dart';
import 'package:memory_game/widgets/player_widget.dart';

class Leaderboard extends StatefulWidget {
  Player player;
  Leaderboard({super.key, required this.player});
  @override
  State<Leaderboard> createState() => _LeaderboardState();
}

class _LeaderboardState extends State<Leaderboard> {
  late List<PlayerWidget> scores;
  
  @override
  void setState(fn){
    if(mounted){
      super.setState(fn);
    }
  }

  void initState(){
    super.initState();
    scores = [];
    _addScore();
  }

  void _addScore(){
    if(widget.player.name == "Guest"){
      setState(() {scores.add(PlayerWidget(player: widget.player, color: Colors.blue)); });
      return;
    }
    Database.instance.collection("players").doc(widget.player.name).get()
      .then((value) {
        if(value.exists){
          if(widget.player.score > value.data()?["score"]){
            Database.instance.collection("players").doc(widget.player.name).update(widget.player.toJson());
          }
        }
        else{
           Database.instance.collection("players").doc(widget.player.name).set(widget.player.toJson());
        }
      }).whenComplete(() => _getLeaderboard());
    // Database.instance.collection("players").doc(widget.player.name).set(widget.player.toJson());
    
  }
  void _getLeaderboard(){
    Database.instance.collection("players").orderBy("score", descending: true).limit(10).get().then((event) => {
      for(var doc in event.docs){
        setState(() => scores.add(PlayerWidget(player: Player(name: doc.data()["name"], score: doc.data()["score"]))))
      }
    }).whenComplete((){ 
      for(var wid in scores){
        if(wid.player == widget.player){
          wid.color = Colors.blue;
          return;
        }
      }
      setState(() => scores.add(PlayerWidget(player: widget.player, color: Colors.blue))); 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("High Scores")),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [Column(children: scores),
              const Spacer(), 
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                    ElevatedButton(
                      onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Game(currentPlayer: widget.player.name,))), 
                      child: const Text("Play Again")),
                    ElevatedButton(
                      onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage())),
                      child: const Text("Back to Home"),
                    )
                ]
              )
            ]
          )
        ),
    );
  }
  
}