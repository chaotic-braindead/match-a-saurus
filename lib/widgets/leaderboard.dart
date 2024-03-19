import 'package:flutter/material.dart';
import 'package:memory_game/db/db.dart';
import 'package:memory_game/models/player.dart';
import 'package:memory_game/utils/size_config.dart';
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
  late bool _isLoading;
  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    _currentPlayer = Database.playerBox
        ?.get("currentPlayer", defaultValue: Player(name: "Guest"));
    _currentPlayer?.score = widget.score;
    _scores = [];
    _getLeaderboard();
    _pb = Database.playerBox?.get("personalBest");
    if (_pb == null) {
      _pb = _currentPlayer;
      Database.playerBox?.put("personalBest", _currentPlayer!);
    }
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
      setState(() {
        _scores.add(PlayerWidget(
            player: _currentPlayer!,
            color: const Color.fromRGBO(255, 188, 152, 1)));
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/bg-1.png"), fit: BoxFit.cover)),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AppBar(
                toolbarHeight: 80,
                titleSpacing: 20,
                title: Image.asset(
                  "assets/logo-title.png",
                  width: 115,
                ),
                backgroundColor: Colors.transparent),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20),
              child: SizedBox(
                width: SizeConfig.screenWidth,
                height: SizeConfig.screenHeight,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 45, top: 110),
                  decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("assets/leaderboard.png"))),
                  child: Stack(
                    children: [
                      (_isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ListView.separated(
                              padding: EdgeInsets.fromLTRB(
                                  SizeConfig.blockSizeHorizontal * 16.25,
                                  SizeConfig.blockSizeVertical * 13.5,
                                  SizeConfig.blockSizeHorizontal * 17.5,
                                  0),
                              itemCount: _scores.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 5),
                              itemBuilder: (context, index) {
                                if (_scores[index].player.score! == 0) {
                                  return Container();
                                }

                                return Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          index != 10
                                              ? _scores[index].player.name
                                              : "You",
                                          style: TextStyle(
                                            fontSize: index != 10
                                                ? SizeConfig.fontSize * 2.35
                                                : SizeConfig.fontSize * 2.75,
                                            fontFamily: 'MadimiOne',
                                            fontWeight: index != 10
                                                ? FontWeight.normal
                                                : FontWeight.bold,
                                            color: const Color.fromRGBO(
                                                36, 107, 34, 1),
                                          ),
                                        ),
                                        Text(
                                          _scores[index]
                                              .player
                                              .score
                                              .toString(),
                                          style: TextStyle(
                                            fontSize: index != 10
                                                ? SizeConfig.fontSize * 2.35
                                                : SizeConfig.fontSize * 2.75,
                                            fontFamily: 'MadimiOne',
                                            fontWeight: index != 10
                                                ? FontWeight.normal
                                                : FontWeight.bold,
                                            color: const Color.fromRGBO(
                                                148, 126, 109, 1),
                                          ),
                                        )
                                      ],
                                    ),
                                    (index == 9 && widget.score == 0) ||
                                            index == 10
                                        ? Container(
                                            margin:
                                                const EdgeInsets.only(top: 20),
                                            decoration: const BoxDecoration(
                                                border: Border(
                                                    top: BorderSide(
                                                        width: 5.0,
                                                        color: Color.fromRGBO(
                                                            69, 141, 67, 1)))),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: (Row(children: [
                                                Text("Personal Best:",
                                                    style: TextStyle(
                                                        fontSize: SizeConfig
                                                                .fontSize *
                                                            2.7,
                                                        fontFamily: "MadimiOne",
                                                        color: const Color
                                                            .fromRGBO(
                                                            69, 141, 67, 1))),
                                                const Spacer(),
                                                Text((_pb?.score!).toString(),
                                                    style: TextStyle(
                                                        fontSize: SizeConfig
                                                                .fontSize *
                                                            2.7,
                                                        fontFamily: "MadimiOne",
                                                        color: const Color
                                                            .fromRGBO(
                                                            147, 123, 107, 1)))
                                              ])),
                                            ),
                                          )
                                        : const SizedBox()
                                  ],
                                );
                              },
                            )),
                      Positioned(
                        bottom: SizeConfig.blockSizeHorizontal + 10,
                        left: (SizeConfig.screenWidth / 2) - 70 * 0.75,
                        child: SizedBox(
                          height: 70,
                          width: 70,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                elevation: 0.0,
                                backgroundColor: Color.fromARGB(0, 0, 0, 0),
                                animationDuration: Duration()),
                            onPressed: () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const HomePage()));
                            },
                            child: const Text(
                              "",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 40,
                                fontFamily: 'MadimiOne',
                                color: Color.fromRGBO(36, 107, 34, 1),
                                shadows: [
                                  Shadow(
                                    // Adjust offsets and blurRadius for stroke thickness
                                    offset: Offset(3.0, 3.0),
                                    color: Color.fromRGBO(255, 220, 80,
                                        1), // Set your stroke color
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    ));
  }

  Stack _buildLeaderboard(BuildContext context) {
    return Stack(children: [
      AlertDialog(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Color.fromARGB(0, 179, 25, 25),
        content: SizedBox(
            width: 999,
            child: Container(
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("assets/rectangle-bg.png"),
                        fit: BoxFit.fill)),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
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
              SizeConfig.safeBlockVertical * 0,
              SizeConfig.safeBlockHorizontal * 15,
              0),
          child: ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                      const Color.fromRGBO(190, 255, 188, 1)),
                  minimumSize: MaterialStateProperty.all(const Size(65, 65)),
                  shape: MaterialStateProperty.all(const CircleBorder(
                      side: BorderSide(
                          width: 4, color: Color.fromRGBO(36, 107, 34, 1))))),
              onPressed: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => const HomePage()));
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
    ]);
  }
}
