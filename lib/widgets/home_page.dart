// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:memory_game/db/db.dart';
import 'package:memory_game/models/player.dart';
import 'package:memory_game/widgets/game.dart';
import 'package:memory_game/widgets/leaderboard.dart';
import 'package:memory_game/widgets/card_catalog.dart';
import 'package:memory_game/utils/size_config.dart';

final List<String> difficultyList = <String>['Easy', 'Medium', 'Hard'];

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Player? currentPlayer;
  late TextEditingController _controller;
  String _difficulty = difficultyList.first;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() => currentPlayer = Database.playerBox
        ?.get("currentPlayer", defaultValue: Player(name: "Guest")));
    setState(
        () => _controller = TextEditingController(text: currentPlayer?.name));
    String? diff = Database.optionsBox?.get("difficulty");
    if (diff != null) {
      setState(() => _difficulty = diff);
    } else {
      Database.optionsBox?.put("difficulty", difficultyList.first);
    }
  }

  void _updateCurrentPlayer(Player newPlayer) async {
    if (newPlayer.name != "Guest") {
      await Database.playerBox?.put("currentPlayer", newPlayer);
      setState(() => currentPlayer?.name = _controller.text);
    }
    Navigator.of(context).pop();
  }

  Widget _buildOptionsDialog(BuildContext context) {
    return StatefulBuilder(builder: (context, setState) {
      return Stack(children: [
        AlertDialog(
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            content: Stack(children: [
              SizedBox(
                  width: 999,
                  child: Container(
                      decoration: const BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage("assets/rectangle-bg.png"))),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        "Difficulty",
                                        style: TextStyle(
                                            fontSize:
                                                SizeConfig.fontSize * 2.25,
                                            fontFamily: "MadimiOne",
                                            color: const Color.fromRGBO(
                                                69, 141, 67, 1)),
                                      ),
                                      SizedBox(
                                          width: 100,
                                          child: DropdownButton<String>(
                                              elevation: 0,
                                              dropdownColor:
                                                  const Color.fromRGBO(
                                                      252, 211, 184, 1),
                                              value: _difficulty,
                                              onChanged: (value) async {
                                                await Database.optionsBox
                                                    ?.put("difficulty", value!);
                                                setState(
                                                    () => _difficulty = value!);
                                              },
                                              items:
                                                  difficultyList.map((value) {
                                                return DropdownMenuItem(
                                                    value: value,
                                                    child: Text(value,
                                                        style: TextStyle(
                                                            fontSize: SizeConfig
                                                                    .fontSize *
                                                                2.25,
                                                            fontFamily:
                                                                "MadimiOne",
                                                            color: const Color
                                                                .fromRGBO(147,
                                                                123, 107, 1))));
                                              }).toList()))
                                    ]),
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        "Playing as",
                                        style: TextStyle(
                                            fontSize:
                                                SizeConfig.fontSize * 2.25,
                                            fontFamily: "MadimiOne",
                                            color: const Color.fromRGBO(
                                                69, 141, 67, 1)),
                                      ),
                                      SizedBox(
                                          width: 100,
                                          child: TextField(
                                            style: TextStyle(
                                                fontSize:
                                                    SizeConfig.fontSize * 2.25,
                                                fontFamily: "MadimiOne",
                                                color: const Color.fromRGBO(
                                                    147, 123, 107, 1)),
                                            controller: _controller,
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(
                                                  RegExp("[a-zA-Z0-9]")),
                                              LengthLimitingTextInputFormatter(
                                                  10)
                                            ],
                                          ))
                                    ]),
                              ],
                            ),
                          ]))),
              Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.fromLTRB(0, 295, 0, 0),
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
                        _updateCurrentPlayer(Player(name: _controller.text));
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
                  alignment: Alignment.center,
                  margin: EdgeInsets.fromLTRB(
                      0, 0, 0, SizeConfig.blockSizeVertical * 37),
                  child: SizedBox(
                    width: 200,
                    height: 100,
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/select-diff-text.png"),
                          fit: BoxFit.fitWidth
                        )
                      ),
                    ),
                  )
                  ),
            ])),
      ]);
    });
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Are you sure?'),
            content: const Text('Do you want to exit the App'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                  SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                },
                child: const Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }

  // Page Layout
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            color: Color.fromRGBO(212, 253, 210, 1),
            image: DecorationImage(
                image: AssetImage("assets/bg-2.png"), fit: BoxFit.cover)),
        child: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            _homeTitle(),
            Column(
              children: [
                SizedBox(
                  width: 185,
                  height: 140,
                  child: Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage("assets/logo-dino.png"),
                            fit: BoxFit.cover)),
                  ),
                ),
                SizedBox(
                  width: 250,
                  height: 50,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          side: BorderSide(
                              width: 5.0,
                              color: Color.fromRGBO(36, 107, 34, 1)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0))),
                      child: const Text(
                        "PLAY",
                        style: TextStyle(
                          fontSize: 29,
                          fontFamily: 'MadimiOne',
                          color: Color.fromRGBO(36, 107, 34, 1),
                          shadows: [
                            Shadow(
                              // Adjust offsets and blurRadius for stroke thickness
                              offset: Offset(
                                  3.0, 3.0), // Adjust for stroke position
                              blurRadius: 2.0,
                              color: Color.fromRGBO(
                                  255, 220, 80, 1), // Set your stroke color
                            ),
                          ],
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Game()));
                      }),
                ),
                SizedBox(height: 15),
                SizedBox(
                  width: 250,
                  height: 50,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          side: BorderSide(
                              width: 5.0,
                              color: Color.fromRGBO(36, 107, 34, 1)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0))),
                      child: const Text(
                        "OPTIONS",
                        style: TextStyle(
                          fontSize: 29,
                          fontFamily: 'MadimiOne',
                          color: Color.fromRGBO(36, 107, 34, 1),
                          shadows: [
                            Shadow(
                              // Adjust offsets and blurRadius for stroke thickness
                              offset: Offset(
                                  3.0, 3.0), // Adjust for stroke position
                              blurRadius: 2.0,
                              color: Color.fromRGBO(
                                  255, 220, 80, 1), // Set your stroke color
                            ),
                          ],
                        ),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) =>
                              _buildOptionsDialog(context),
                        );
                      }),
                ),
              ],
            ),
            SizedBox(height: 15),
            SizedBox(
              width: 250,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    side: BorderSide(
                        width: 5.0, color: Color.fromRGBO(36, 107, 34, 1)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0))),
                child: const Text(
                  "CARD CATALOG",
                  style: TextStyle(
                    fontSize: 25,
                    fontFamily: 'MadimiOne',
                    color: Color.fromRGBO(36, 107, 34, 1),
                    shadows: [
                      Shadow(
                        // Adjust offsets and blurRadius for stroke thickness
                        offset: Offset(3.0, 3.0), // Adjust for stroke position
                        blurRadius: 2.0,
                        color: Color.fromRGBO(
                            255, 220, 80, 1), // Set your stroke color
                      ),
                    ],
                  ),
                ),
                onPressed: () {
                  // Redirect to card catalog
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CardCatalog()));
                },
              ),
            ),
            SizedBox(height: 15),
            SizedBox(
              width: 250,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    side: BorderSide(
                        width: 5.0, color: Color.fromRGBO(36, 107, 34, 1)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0))),
                child: const Text(
                  "VIEW HIGH SCORES",
                  style: TextStyle(
                    fontSize: 22,
                    fontFamily: 'MadimiOne',
                    color: Color.fromRGBO(36, 107, 34, 1),
                    shadows: [
                      Shadow(
                        // Adjust offsets and blurRadius for stroke thickness
                        offset: Offset(3.0, 3.0), // Adjust for stroke position
                        blurRadius: 2.0,
                        color: Color.fromRGBO(
                            255, 220, 80, 1), // Set your stroke color
                      ),
                    ],
                  ),
                ),
                onPressed: () {
                  // Redirect to leaderboard
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Leaderboard(score: 0)));
                },
              ),
            ),
            SizedBox(height: 15),
            SizedBox(
              width: 250,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    side: BorderSide(
                        width: 5.0, color: Color.fromRGBO(36, 107, 34, 1)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0))),
                child: const Text(
                  "EXIT",
                  style: TextStyle(
                    fontSize: 29,
                    fontFamily: 'MadimiOne',
                    color: Color.fromRGBO(36, 107, 34, 1),
                    shadows: [
                      Shadow(
                        // Adjust offsets and blurRadius for stroke thickness
                        offset: Offset(3.0, 3.0), // Adjust for stroke position
                        blurRadius: 2.0,
                        color: Color.fromRGBO(
                            255, 220, 80, 1), // Set your stroke color
                      ),
                    ],
                  ),
                ),
                onPressed: () {
                  _onWillPop();
                },
              ),
            )
          ]),
        ),
      ),
    );
  }

  SizedBox _homeTitle() {
    return SizedBox(
      width: 300,
      height: 175,
      child: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/logo-title.png"), fit: BoxFit.cover)),
      ),
    );
  }
}
