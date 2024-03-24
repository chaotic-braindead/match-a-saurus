// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers/src/audioplayer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:memory_game/db/db.dart';
import 'package:memory_game/models/card_item.dart';
import 'package:memory_game/models/player.dart';
import 'package:memory_game/widgets/card_catalog.dart';
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
  final AudioPlayer audioPlayer;
  const Game({super.key, required this.audioPlayer});
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
  int _flips = 0;
  late int? _bestScore;
  late Player? _currentPlayer;
  late Player? _pb;
  late String? _difficulty;
  late double _multiplier;
  late double _divider;
  bool _enableTaps = true;

  late double deviceWidth;
  late double deviceHeight;

  @override
  void initState() {
    super.initState();
    _currentPlayer = Database.playerBox
        ?.get("currentPlayer", defaultValue: Player(name: "Guest"));
    _pb = Database.playerBox?.get("personalBest");

    _difficulty = Database.optionsBox?.get("difficulty")!;
    int? score = Database.playerBox?.get("personalBest")?.score;
    if (score != null) {
      _bestScore = score;
    } else {
      _bestScore = 0;
    }

    if (_difficulty!.contains("Easy")) {
      _multiplier = 1;
      _rows = 3;
      _cols = 4;
    } else if (_difficulty!.contains("Medium")) {
      _multiplier = 1.25;
      _rows = 4;
      _cols = 5;
    } else {
      _multiplier = 1.5;
      _rows = 6;
      _cols = 6;
    }
    _cards = _getRandomCards(_rows * _cols);
    _tappedCard = null;
    _validPairs = [];

    String? timerOption = Database.optionsBox?.get("timer")!.split(" ")[0];
    int time = int.parse(timerOption!);
    if (time > 3) {
      _startTimer(time);
      _divider = 0.2;
    } else {
      if(time == 1){
        _divider = 1.5;
      } else {
        _divider = 2.75;
      }
      _startTimer(time * 60);
    }
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

  void _addScore() async {
    if (_pb == null || (_currentPlayer?.score)! > (_pb?.score)!) {
      _pb = _currentPlayer;
      await Database.playerBox?.put("personalBest", _currentPlayer!);
    }
    if (_currentPlayer?.name == "Guest") {
      return;
    }
    var value = await Database.firebase
        .collection("players")
        .doc(_currentPlayer?.name)
        .get();

    if (!value.exists) {
      await Database.firebase
          .collection("players")
          .doc(_currentPlayer?.name)
          .set(_currentPlayer!.toJson());
      return;
    }
    if ((_currentPlayer?.score!)! > value.data()?["score"]) {
      await Database.firebase
          .collection("players")
          .doc(_currentPlayer?.name)
          .update(_currentPlayer!.toJson());
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
        _currentPlayer?.score = _score;
        _addScore();
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
    setState(() => ++_flips);

    if (_tappedCard?.val == card.val) {
      setState(() {
        _score += ((_counter / _divider)*_multiplier).truncate();
        //_score = (_score * _multiplier).truncate();
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
      _currentPlayer?.score = _score;
      _addScore();
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) =>
              _buildGameOverDialog(context, "you win!"));
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
                                builder: (context) => HomePage(audioPlayer: widget.audioPlayer,)));
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
                                builder: (context) => Game(audioPlayer: widget.audioPlayer,)));
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
                                        builder: (context) =>  Game(audioPlayer: widget.audioPlayer,)));
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
                                Navigator.push(
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
                    MaterialPageRoute(builder: (context) =>  HomePage(audioPlayer: widget.audioPlayer,)));
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
                    msg == "timer ran out!"
                        ? 22 * SizeConfig.safeBlockVertical
                        : 24 * SizeConfig.safeBlockVertical,
                    SizeConfig.safeBlockHorizontal * 25,
                    0),
                child: SizedBox(
                  width: 250,
                  height: 90,
                  child: Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: msg == "timer ran out!"
                                ? AssetImage("assets/timer-ran-out.png")
                                : AssetImage("assets/you-win-text.png"),
                            fit: BoxFit.fitWidth)),
                  ),
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
        // SCORE container
        Container(
          margin: EdgeInsets.fromLTRB(
              SizeConfig.blockSizeHorizontal * 65, 45, 0, 0),
          child: SizedBox(
            width: 120,
            height: 80,
            child: Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/score-bg.png"))),
              child: Center(
                child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: FittedBox(
                      child: Text(
                        _score.toString(),
                        style: const TextStyle(
                            fontFamily: "MadimiOne",
                            fontSize: 27,
                            color: Colors.white,
                            shadows: shadows),
                      ),
                    )),
              ),
            ),
          ),
        ),
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
              "${_difficulty!.split(" ")[0]} Level",
              textAlign: TextAlign.left,
              style: TextStyle(
                  fontFamily: "MadimiOne",
                  fontSize: SizeConfig.fontSize * 2.15,
                  color: Colors.white,
                  shadows: shadows),
            )),

        Container(
            margin: const EdgeInsets.fromLTRB(27, 55, 0, 0),
            width: 130,
            child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  "Your high score: $_bestScore",
                  style: const TextStyle(
                      fontFamily: "MadimiOne",
                      fontSize: 12,
                      color: Color.fromRGBO(117, 187, 115, 1)),
                ))),
        Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            //color: Colors.red,
            margin: (_rows == 4) || (_rows == 3) ? EdgeInsets.fromLTRB(40, 143, 40, 0): EdgeInsets.fromLTRB(20, 155, 20, 0),
            child: GridView.count(
                shrinkWrap: true,
                //padding: (_rows == 4) || (_rows == 3) ? EdgeInsets.fromLTRB(50, 140, 40, 0): EdgeInsets.fromLTRB(30, 145, 30, 0),
                childAspectRatio: _rows == 6 ? 0.78 : 0.87,
                crossAxisCount: _rows,
                mainAxisSpacing: _rows == 6 ? 5.0 : 4.0,
                crossAxisSpacing: _rows == 6 ? 8.0 : 8.0,
                children: _cards
                    .map((card) => CardWidget(
                          card: card,
                          onTap: _enableTaps ? _handleTap : null,
                        ))
                    .toList()),
          ),
          SizedBox(height: SizeConfig.blockSizeVertical),
          Container(
              width: 130,
              height: 30,
              margin: (_rows == 4) || (_rows == 3) ? EdgeInsets.fromLTRB(2, 12, 2, 2) : EdgeInsets.fromLTRB(2, 20, 2, 2),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  border:
                      Border.all(color: const Color.fromRGBO(72, 132, 76, 1)),
                  color: const Color.fromRGBO(112, 204, 118, 1),
                  borderRadius: BorderRadius.circular(40)),
              child: Text(
                "Flips: $_flips",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: "MadimiOne",
                    fontSize: _multiplier == 1
                        ? SizeConfig.fontSize * 2
                        : SizeConfig.fontSize * 2.25,
                    color: Colors.white,
                    shadows: shadows),
              ))
        ]),
        Positioned(
              bottom: 0,
              right: 0,
              child: _musicBtn(),
            )
      ]),
    );
  }

  SizedBox _musicBtn() {
    return SizedBox(
     
      child: Container(
              height: 40,
              width: 40,
              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              decoration: BoxDecoration(
                  border: Border.all(color: darkGreen, width: 2.5),
                  borderRadius: BorderRadius.circular(50),
                  color: lightGreen1,
                  boxShadow: [
                    BoxShadow(
                      color: lightPink.withOpacity(1),
                      offset: const Offset(1.85, 3),
                    )
                  ]),
              child: Center(
                child: IconButton(
                  icon: isPaused ? const Icon(Icons.music_off_outlined) : const Icon(Icons.music_note),
                  color: darkGreen,
                  iconSize: 20,
                  onPressed: () {
                    if (isPaused) {
                      widget.audioPlayer.resume();
                    } else {
                      widget.audioPlayer.pause();
                    }
                    setState(() {
                      isPaused = !isPaused;
                    });
                  },
                ),
              ),
            )
    );
  }
}
