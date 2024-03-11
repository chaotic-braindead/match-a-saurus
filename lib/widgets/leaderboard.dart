import 'package:flutter/material.dart';
import 'package:memory_game/db/db.dart';
import 'package:memory_game/models/player.dart';
import 'package:memory_game/widgets/game.dart';
import 'package:memory_game/widgets/home_page.dart';
import 'package:memory_game/widgets/player_widget.dart';

class Leaderboard extends StatefulWidget {
  final int score;
  const Leaderboard({super.key, required this.score});
  @override
  State<Leaderboard> createState() => _LeaderboardState();
}

class _LeaderboardState extends State<Leaderboard> {
  late List<PlayerWidget> scores;
  late Player? currentPlayer;
  late Player? pb;
  @override
  void setState(fn){
    if(mounted){
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() { 
      currentPlayer = Database.playerBox?.get("currentPlayer", defaultValue: Player(name: "Guest")); 
      currentPlayer?.score = widget.score;
    });
    scores = [];
    _addScore();
    setState(() => pb = Database.playerBox?.get("personalBest"));
    if(pb == null || (currentPlayer?.score)! > (pb?.score)!){
      Database.playerBox?.put("personalBest", currentPlayer!).then((value){
        setState(() => pb = currentPlayer!);
      });
    }
  }

  void _addScore(){
    if(currentPlayer?.name == "Guest"){
      _getLeaderboard();
      return;
    }
    Database.firebase.collection("players").doc(currentPlayer?.name).get()
      .then((value) {
        if(!value.exists){
          Database.firebase.collection("players").doc(currentPlayer?.name).set(currentPlayer!.toJson());
          return;
        }
        if((currentPlayer?.score!)! > value.data()?["score"]){
          Database.firebase.collection("players").doc(currentPlayer?.name).update(currentPlayer!.toJson());
        }
      }).whenComplete(() => _getLeaderboard());
  }
  void _getLeaderboard(){
    Database.firebase.collection("players").orderBy("score", descending: true).limit(10).get().then((event) => {
      for(var doc in event.docs){
        setState(() => scores.add(PlayerWidget(player: Player(name: doc.data()["name"], score: doc.data()["score"]))))
      }
    }).whenComplete((){ 
      for(var wid in scores){
        if(wid.player == currentPlayer!){
          wid.color = Colors.blue;
          return;
        }
      }

     if (widget.score > 0) {
        setState(() => scores.add(PlayerWidget(player: currentPlayer!, color: Colors.blue)));
      }
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
              Row(children: [const Text("Personal Best"), const Spacer(), Text((pb?.score!).toString())],),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                    ElevatedButton(
                      onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Game())), 
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