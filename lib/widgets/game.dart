// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:memory_game/db/db.dart';
import 'package:memory_game/models/card_item.dart';
import 'package:memory_game/widgets/card_widget.dart';
import 'package:memory_game/widgets/home_page.dart';
import 'package:memory_game/widgets/leaderboard.dart';
import 'package:memory_game/utils/size_config.dart';

const shadows = [
  Shadow(
      // bottomLeft
      offset: Offset(-1.5, -1.5),
      color: Color.fromRGBO(117, 187, 115, 1)),
  Shadow(
      // bottomRight
      offset: Offset(1.5, -1.5),
      color: Color.fromRGBO(117, 187, 115, 1)),
  Shadow(
      // topRight
      offset: Offset(1.5, 1.5),
      color: Color.fromRGBO(117, 187, 115, 1)),
  Shadow(
      // topLeft
      offset: Offset(-1.5, 1.5),
      color: Color.fromRGBO(117, 187, 115, 1)),
];

class Game extends StatefulWidget {
  const Game({super.key});
  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {
  late List<CardItem> _cards;
  late List<CardItem> _validPairs;
  late CardItem? _tappedCard;
  late int _counter;
  late Timer _timer;
  late int _rows;
  late int _cols;
  int _score = 0;
  late int? _bestScore;
  late String? _difficulty;
  late int _multiplier;
  bool _enableTaps = true;

  late double deviceWidth;
  late double deviceHeight;

  @override
  void initState() {
    super.initState();
    _difficulty = Database.optionsBox?.get("difficulty");
    int? score = Database.playerBox?.get("personalBest")?.score;
    if (score != null) {
      _bestScore = score;
    } else {
      _bestScore = 0;
    }
    switch (_difficulty) {
      case "Easy":
        _multiplier = 1;
        _rows = 3;
        _cols = 4;
        break;
      case "Medium":
        _multiplier = 2;
        _rows = 4;
        _cols = 5;
        break;
      case "Hard":
        _multiplier = 3;
        _rows = 6;
        _cols = 6;
        break;
      default:
        throw Exception("Must not be reached");
    }
    _cards = _getRandomCards(_rows * _cols);
    _tappedCard = null;
    _validPairs = [];
    _startTimer(60);
  }

  List<CardItem> _shuffleCards(List<CardItem> cards) {
    Random rng = Random();
    for (int i = cards.length - 1; i >= 1; --i) {
      int newIdx = rng.nextInt(i);
      CardItem temp = cards[i];
      cards[i] = cards[newIdx];
      cards[newIdx] = temp;
    }
    return cards;
  }

  List<CardItem> _getRandomCards(int max) {
    return _shuffleCards(CardItem.getCards(_rows * _cols));
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void _startTimer(int time) {
    _counter = time;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_counter > 0) {
        setState(() {
          --_counter;
        });
      } else {
        timer.cancel();
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) =>
                _buildGameOverDialog(context, "timer ran out!"));
      }
    });
  }

    void _handleTap(CardItem card) {
    if (_counter == 0 || card.isTapped) {
      return;
    }
    card.isTapped = true;
    setState(() => _tappedCard ??= card);
    if (_tappedCard == card) {
      return;
    }
    if (_tappedCard?.val == card.val) {
      setState(() {
        _score += _counter;
        _score *= _multiplier;
        _validPairs.add(_tappedCard!);
        _validPairs.add(card);
        _tappedCard = null;
      });
      if (_score > _bestScore!) {
        _bestScore = _score;
      }
    } else {
      setState(() => _enableTaps = false);
      Timer(const Duration(milliseconds: 500), () {
        card.isTapped = false;
        setState(() {
          _tappedCard?.isTapped = false;
          _tappedCard = null;
          _enableTaps = true;
        });
      });
    }
    if (_validPairs.length == _cards.length) {
      _timer.cancel();
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) =>
              _buildGameOverDialog(context, "you win!"));
      //Navigator.pushReplacement(context,
      //  MaterialPageRoute(builder: (context) => Leaderboard(score: _score)));
    }
  }

  String _secondsToMinutes(int s) {
    int minutes = (s / 60).truncate();
    int seconds = (s % 60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  AlertDialog _buildPauseDialog(BuildContext context) {
    double dialogWidth = MediaQuery.of(context).size.width - 20;
    return AlertDialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(0),
        content: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: deviceWidth,
              width: deviceWidth,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/game-paused-bg.png"),
                      fit: BoxFit.contain)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 30),
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
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const HomePage()));
                      },
                      child: const Text(
                        "back to main menu",
                        style: TextStyle(
                          fontSize: 22,
                          fontFamily: 'MadimiOne',
                          color: Color.fromRGBO(36, 107, 34, 1),
                          shadows: [
                            Shadow(
                              offset: Offset(3.0, 3.0),
                              blurRadius: 2.0,
                              color: Color.fromRGBO(255, 220, 80, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
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
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Game()));
                      },
                      child: const Text(
                        "restart game",
                        style: TextStyle(
                          fontSize: 22,
                          fontFamily: 'MadimiOne',
                          color: Color.fromRGBO(36, 107, 34, 1),
                          shadows: [
                            Shadow(
                              offset: Offset(3.0, 3.0),
                              blurRadius: 2.0,
                              color: Color.fromRGBO(255, 220, 80, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  )
                ],
              ),
            ),
            Positioned(
              bottom: 12,
              left: (deviceWidth - (dialogWidth / 3)) / 2,
              child: SizedBox(
                height: 70,
                width: 70,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      elevation: 0.0, backgroundColor: Colors.transparent),
                  onPressed: () {
                    _startTimer(_counter);
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    "",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      fontFamily: 'MadimiOne',
                      color: Color.fromRGBO(36, 107, 34, 1),
                      shadows: [
                        Shadow(
                          // Adjust offsets and blurRadius for stroke thickness
                          offset: Offset(3.0, 3.0),
                          color: Color.fromRGBO(
                              255, 220, 80, 1), // Set your stroke color
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  Widget _buildGameOverDialog(BuildContext context, String msg) {
    return Stack(children: [
      AlertDialog(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        content: SizedBox(
            width: 999,
            child: Container(
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("assets/rectangle-bg.png"))),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("score:",
                          style: TextStyle(
                              color: const Color.fromRGBO(36, 107, 34, 1),
                              fontFamily: "MadimiOne",
                              fontSize: 3.5 * SizeConfig.fontSize,
                              shadows: const [
                                Shadow(
                                    offset: Offset(1.5, 2),
                                    color: Color.fromRGBO(255, 221, 83, 1)),
                              ])),
                      Text("$_score",
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: "MadimiOne",
                              fontSize: 6 * SizeConfig.fontSize,
                              shadows: const [
                                Shadow(
                                    offset: Offset(-2.5, 2.5),
                                    color: Color.fromRGBO(36, 107, 34, 1)),
                                Shadow(
                                    offset: Offset(2.5, -2.5),
                                    color: Color.fromRGBO(36, 107, 34, 1)),
                                Shadow(
                                    offset: Offset(-2.5, -2.5),
                                    color: Color.fromRGBO(36, 107, 34, 1)),
                                Shadow(
                                    offset: Offset(2.5, 2.5),
                                    color: Color.fromRGBO(36, 107, 34, 1)),
                              ])),
                      // const SizedBox(height: 20),
                      SizedBox(
                          width: SizeConfig.safeBlockHorizontal * 50,
                          child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const Game()));
                              },
                              style: ButtonStyle(
                                  shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                side: const BorderSide(
                                    width: 3.5,
                                    color: Color.fromRGBO(36, 107, 34, 1)),
                                // Change your radius here
                                borderRadius: BorderRadius.circular(15),
                              ))),
                              child: FittedBox(
                                  child: Text("PLAY AGAIN!",
                                      style: TextStyle(
                                          color: const Color.fromRGBO(
                                              36, 107, 34, 1),
                                          fontFamily: "MadimiOne",
                                          fontSize: 3 * SizeConfig.fontSize,
                                          shadows: const [
                                            Shadow(
                                                // bottomLeft
                                                offset: Offset(2.5, 3),
                                                color: Color.fromRGBO(
                                                    255, 221, 83, 1)),
                                          ]))))),
                      SizedBox(height: SizeConfig.blockSizeVertical),
                      SizedBox(
                          width: SizeConfig.safeBlockHorizontal * 50,
                          child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            Leaderboard(score: _score)));
                              },
                              style: ButtonStyle(
                                  shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                side: const BorderSide(
                                    width: 3.5,
                                    color: Color.fromRGBO(36, 107, 34, 1)),
                                // Change your radius here
                                borderRadius: BorderRadius.circular(15),
                              ))),
                              child: FittedBox(
                                  child: Text("VIEW LEADERBOARD",
                                      style: TextStyle(
                                          color: const Color.fromRGBO(
                                              36, 107, 34, 1),
                                          fontFamily: "MadimiOne",
                                          fontSize: SizeConfig.fontSize * 3,
                                          shadows: const [
                                            Shadow(
                                                // bottomLeft
                                                offset: Offset(2.5, 2),
                                                color: Color.fromRGBO(
                                                    255, 221, 83, 1)),
                                          ])))))
                    ]))),
      ),
      Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.fromLTRB(0, 295, 0, 0),
          child: ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                      const Color.fromRGBO(190, 255, 188, 1)),
                  minimumSize: MaterialStateProperty.all(const Size(65, 65)),
                  shape: MaterialStateProperty.all(const CircleBorder(
                      side: BorderSide(
                          width: 4, color: Color.fromRGBO(36, 107, 34, 1))))),
              onPressed: () {
                Navigator.of(context).pop();
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
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Container(
                margin: EdgeInsets.fromLTRB(
                    SizeConfig.safeBlockHorizontal * 25,
                    msg == "timer ran out!" ? 25.8 * SizeConfig.safeBlockVertical : 29 * SizeConfig.safeBlockVertical, // 28
                    SizeConfig.safeBlockHorizontal * 25,
                    0),
                child: DefaultTextStyle(
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: "MadimiOne",
                      height: 0.8,
                      fontSize: msg == "timer ran out!" ? 5.8 * SizeConfig.fontSize : 6.2 * SizeConfig.fontSize,
                      color: Colors.white,
                      shadows: const [
                        Shadow(
                            offset: Offset(5.75, 6.25),
                            color: Color.fromRGBO(255, 188, 152, 1)),
                        Shadow(
                            // bottomLeft
                            offset: Offset(-3.5, -3.5),
                            color: Color.fromRGBO(29, 103, 27, 1)),
                        Shadow(
                            // bottomRight
                            offset: Offset(3.5, -3.5),
                            color: Color.fromRGBO(29, 103, 27, 1)),
                        Shadow(
                            // topRight
                            offset: Offset(3.5, 3.5),
                            color: Color.fromRGBO(29, 103, 27, 1)),
                        Shadow(
                            // topLeft
                            offset: Offset(-3.5, 3.5),
                            color: Color.fromRGBO(29, 103, 27, 1)),
                      ]),
                  child: Text(msg),
                )),
          ),
        ],
      ),
    ]);
  }
  
  @override
 Widget build(BuildContext context) {
    deviceWidth = MediaQuery.of(context).size.width;
    deviceHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        titleSpacing: 20,
        title: Image.asset(
          "assets/logo-title.png",
          width: 115,
        ),
        shape: const Border(
            bottom:
                BorderSide(color: Color.fromRGBO(69, 141, 67, 1), width: 6)),
        elevation: 5,
        shadowColor: const Color.fromRGBO(255, 185, 148, 1),
        backgroundColor: const Color.fromRGBO(113, 220, 110, 1),
        actions: [
          IconButton(
            onPressed: () {
              _timer.cancel();
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) =>
                      _buildPauseDialog(context));
            },
            icon: Image.asset(
              "assets/pause-btn.png",
            ),
            padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
          )
        ],
      ),
      body: Stack(children: [
        Container(
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/bg-1.png"), fit: BoxFit.fill)),
        ),
        // score container
        Container(
          width: 120,
          height: 70,
          margin: EdgeInsets.fromLTRB(
              SizeConfig.blockSizeHorizontal * 65, 45, 0, 0),
          decoration: BoxDecoration(
              border: Border.all(
                  width: 3.5, color: const Color.fromRGBO(117, 187, 115, 1)),
              boxShadow: const [
                BoxShadow(
                    offset: Offset(2.25, 2.25),
                    color: Color.fromRGBO(255, 188, 153, 1)),
              ],
              color: const Color.fromRGBO(187, 237, 182, 1),
              borderRadius: BorderRadius.circular(18)),
          child: Center(
              child: Text(
            _score.toString(),
            style: const TextStyle(
                fontFamily: "MadimiOne",
                fontSize: 35,
                color: Colors.white,
                shadows: shadows),
          )),
        ),
        Container(
            margin: EdgeInsets.fromLTRB(
                SizeConfig.blockSizeHorizontal * 70, 28, 0, 0),
            child: const Text(
              "SCORE:",
              style: TextStyle(
                  fontFamily: "MadimiOne",
                  fontSize: 25,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                        // bottomLeft
                        offset: Offset(-2.5, -2.5),
                        color: Color.fromRGBO(117, 187, 115, 1)),
                    Shadow(
                        // bottomRight
                        offset: Offset(2.5, -2.5),
                        color: Color.fromRGBO(117, 187, 115, 1)),
                    Shadow(
                        // topRight
                        offset: Offset(2.5, 2.5),
                        color: Color.fromRGBO(117, 187, 115, 1)),
                    Shadow(
                        // topLeft
                        offset: Offset(-2.5, 2.5),
                        color: Color.fromRGBO(117, 187, 115, 1)),
                  ]),
            )),
        // timer container
        Container(
            width: 130,
            height: 40,
            margin: const EdgeInsets.fromLTRB(25, 75, 0, 0),
            decoration: BoxDecoration(
                border:
                    Border.all(color: const Color.fromRGBO(117, 187, 115, 1)),
                color: const Color.fromRGBO(187, 237, 182, 1),
                borderRadius: BorderRadius.circular(40)),
            child: Center(
                child: Text(
              _secondsToMinutes(_counter),
              style: const TextStyle(
                  fontFamily: "MadimiOne",
                  color: Colors.white,
                  fontSize: 25,
                  shadows: shadows),
            ))),
        Container(
            margin: const EdgeInsets.fromLTRB(27, 30, 0, 0),
            width: 130,
            child: Text(
              "$_difficulty Level",

              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontFamily: "MadimiOne",
                  fontSize: 20,
                  color: Colors.white,
                  shadows: shadows),
            )),
        Container(
            margin: const EdgeInsets.fromLTRB(27, 30, 0, 0),
            width: 130,
            child: Text(
              "$_difficulty Level",
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontFamily: "MadimiOne",
                  fontSize: 20,
                  color: Colors.white,
                  shadows: shadows),
            )),
        Container(
            margin: const EdgeInsets.fromLTRB(27, 55, 0, 0),
            width: 130,
            child: Text(
              "Your high score: $_bestScore",
              style: const TextStyle(
                  fontFamily: "MadimiOne",
                  fontSize: 12,
                  color: Color.fromRGBO(117, 187, 115, 1)),
            )),
        GridView.count(
            padding: const EdgeInsets.fromLTRB(20, 145, 20, 20),
            childAspectRatio: _rows == 6 ? 0.8 : 0.93,
            crossAxisCount: _rows,
            mainAxisSpacing: _rows == 6 ? 20.0 : 5.0,
            crossAxisSpacing: _rows == 6 ? 10.0 : 10.0,
            children: _cards
                .map((card) => CardWidget(
                      card: card,
                      onTap: _enableTaps ? _handleTap : null,
                    ))
                .toList())
      ]),
    );
  }
}

 //     Container(
      //       child: GridView.count(
      //         padding: const EdgeInsets.all(20),
      //         childAspectRatio: _rows == 6 ? 0.63 : 0.8,
      //         crossAxisCount: _rows,
      //         mainAxisSpacing: _rows == 6 ? 35.0 : 20.0,
      //         crossAxisSpacing: _rows == 6? 10.0 : 20.0,
      //         children: _cards.map((card) => CardWidget(
      //           card: card,
      //           onTap: _enableTaps ? _handleTap : null,
      //           )).toList()
      //         ),
      //     ),
      //   // score container
      //   