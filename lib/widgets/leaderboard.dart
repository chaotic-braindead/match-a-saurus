import 'package:flutter/material.dart';
import 'package:memory_game/db/db.dart';
import 'package:memory_game/models/player.dart';
import 'package:memory_game/utils/size_config.dart';
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
      _pb = _currentPlayer;
      Database.playerBox?.put("personalBest", _currentPlayer!);
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
          wid.color = const Color.fromRGBO(255, 188, 152, 1);
          return;
        }
      }
      setState(() => _scores.add(PlayerWidget(
          player: _currentPlayer!,
          color: const Color.fromRGBO(255, 188, 152, 1))));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        titleSpacing: 20,
        title: Image.asset(
          "assets/logo-title.png",
          width: 115,
        ),
        backgroundColor: const Color.fromRGBO(245, 255, 242, 1),
      ),
      body: Container(
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/game-bg.png"), fit: BoxFit.fill)),
          child: Stack(children: [
            AlertDialog(
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              content: SizedBox(
                  width: 999,
                  child: Container(
                      decoration: const BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage("assets/rectangle-bg.png"),
                              fit: BoxFit.fill)),
                      child: ListView(
                          padding: EdgeInsets.fromLTRB(
                              SizeConfig.blockSizeHorizontal * 6.25,
                              SizeConfig.blockSizeVertical * 6,
                              SizeConfig.blockSizeHorizontal * 7.5,
                              0),
                          children: [
                            Column(children: _scores),
                            Row(children: [
                              Text("Personal Best",
                                  style: TextStyle(
                                      fontSize: SizeConfig.fontSize * 2.35,
                                      fontFamily: "MadimiOne",
                                      color: const Color.fromRGBO(
                                          69, 141, 67, 1))),
                              const Spacer(),
                              Text((_pb?.score!).toString(),
                                  style: TextStyle(
                                      fontSize: SizeConfig.fontSize * 2.35,
                                      fontFamily: "MadimiOne",
                                      color: const Color.fromRGBO(
                                          147, 123, 107, 1)))
                            ])
                          ]))),
            ),
            Container(
                alignment: Alignment.center,
                margin: EdgeInsets.fromLTRB(
                    SizeConfig.safeBlockHorizontal * 15,
                    SizeConfig.safeBlockVertical * 70,
                    SizeConfig.safeBlockHorizontal * 15,
                    0),
                child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            const Color.fromRGBO(190, 255, 188, 1)),
                        minimumSize:
                            MaterialStateProperty.all(const Size(65, 65)),
                        shape: MaterialStateProperty.all(const CircleBorder(
                            side: BorderSide(
                                width: 4,
                                color: Color.fromRGBO(36, 107, 34, 1))))),
                    onPressed: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HomePage()));
                    },
                    child: Text(
                      "X",
                      style: TextStyle(
                          color: const Color.fromRGBO(36, 107, 34, 1),
                          fontFamily: "MadimiOne",
                          fontSize: 3.25 * SizeConfig.fontSize,
                          shadows: const [
                            Shadow(
                                // bottomLeft
                                offset: Offset(2.5, 3),
                                color: Color.fromRGBO(255, 221, 83, 1)),
                          ]),
                    ))),
            Container(
                margin: EdgeInsets.fromLTRB(
                    SizeConfig.safeBlockHorizontal * 25,
                    SizeConfig.safeBlockVertical * 5,
                    SizeConfig.safeBlockHorizontal * 15,
                    0),
                child: DefaultTextStyle(
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: "MadimiOne",
                      height: 0.65,
                      fontSize: 4.5 * SizeConfig.fontSize,
                      color: Colors.white,
                      shadows: const [
                        Shadow(
                            offset: Offset(5.75, 6.25),
                            color: Color.fromRGBO(255, 188, 152, 1)),
                        Shadow(
                            // bottomLeft
                            offset: Offset(-2.5, -2.5),
                            color: Color.fromRGBO(29, 103, 27, 1)),
                        Shadow(
                            // bottomRight
                            offset: Offset(2.5, -2.5),
                            color: Color.fromRGBO(29, 103, 27, 1)),
                        Shadow(
                            // topRight
                            offset: Offset(2.5, 2.5),
                            color: Color.fromRGBO(29, 103, 27, 1)),
                        Shadow(
                            // topLeft
                            offset: Offset(-2.5, 2.5),
                            color: Color.fromRGBO(29, 103, 27, 1)),
                      ]),
                  child: const Text("high scores"),
                )),
            Container(
                margin: EdgeInsets.fromLTRB(SizeConfig.screenWidth - (50 * 2),
                    SizeConfig.screenHeight - (95 * 2), 0, 0),
                decoration: const BoxDecoration(
                    image: DecorationImage(
                  scale: 7,
                  image: AssetImage("assets/logo-dino.png"),
                )))
          ])),
    );
  }
}
