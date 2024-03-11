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
  late List<PlayerWidget> _scores;
  late Player? _currentPlayer;
  late Player? _pb;
  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    _currentPlayer = Database.playerBox
        ?.get("currentPlayer", defaultValue: Player(name: "Guest"));
    _currentPlayer?.score = widget.score;
    _scores = [];
    _addScore();
    _pb = Database.playerBox?.get("personalBest");
    if (_pb == null || (_currentPlayer?.score)! > (_pb?.score)!) {
      Database.playerBox
          ?.put("personalBest", _currentPlayer!)
          .then((value) => _pb = _currentPlayer!);
    }
  }

  void _addScore() {
    if (_currentPlayer?.name == "Guest") {
      _getLeaderboard();
      return;
    }
    Database.firebase
        .collection("players")
        .doc(_currentPlayer?.name)
        .get()
        .then((value) {
      if (!value.exists) {
        Database.firebase
            .collection("players")
            .doc(_currentPlayer?.name)
            .set(_currentPlayer!.toJson());
        return;
      }
      if ((_currentPlayer?.score!)! > value.data()?["score"]) {
        Database.firebase
            .collection("players")
            .doc(_currentPlayer?.name)
            .update(_currentPlayer!.toJson());
      }
    }).whenComplete(() => _getLeaderboard());
  }

  void _getLeaderboard() {
    Database.firebase
        .collection("players")
        .orderBy("score", descending: true)
        .limit(10)
        .get()
        .then((event) => {
              for (var doc in event.docs)
                {
                  setState(() => _scores.add(PlayerWidget(
                      player: Player(
                          name: doc.data()["name"],
                          score: doc.data()["score"]))))
                }
            })
        .whenComplete(() {
      for (var wid in _scores) {
        if (wid.player == _currentPlayer!) {
          wid.color = Colors.blue;
          return;
        }
      }
      setState(() => _scores
          .add(PlayerWidget(player: _currentPlayer!, color: Colors.blue)));
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
          child: Column(children: [
            Column(children: _scores),
            Row(
              children: [
                const Text("Personal Best"),
                const Spacer(),
                Text((_pb?.score!).toString())
              ],
            ),
            Row(mainAxisSize: MainAxisSize.min, children: [
              ElevatedButton(
                  onPressed: () => Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => const Game())),
                  child: const Text("Play Again")),
              ElevatedButton(
                onPressed: () => Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => const HomePage())),
                child: const Text("Back to Home"),
              )
            ])
          ])),
    );
  }
}
