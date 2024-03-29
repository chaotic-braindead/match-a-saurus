// ignore_for_file: prefer_const_constructors

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:memory_game/db/db.dart';
import 'package:memory_game/models/player.dart';
import 'package:memory_game/widgets/game.dart';
import 'package:memory_game/widgets/leaderboard.dart';
import 'package:memory_game/widgets/card_catalog.dart';
import 'package:memory_game/utils/size_config.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:memory_game/widgets/manual.dart';

bool isPaused = false;

final List<String> difficultyList = <String>[
  'Easy (3x4)',
  'Medium (4x5)',
  'Hard (6x6)'
];

final List<String> timerList = <String>[
  '30 seconds',
  '1 minute',
  '2 minutes',
];

class HomePage extends StatefulWidget {
  final AudioPlayer audioPlayer;
  const HomePage({super.key, required this.audioPlayer});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Player? currentPlayer;
  late TextEditingController _playerController;
  late TextEditingController _playerPassword;
  bool isLoginMode = true;
  bool isLoginSignUpDone = false;
  String userErrorMsg = "";
  String passwordErrorMsg = "";
  String _difficulty = difficultyList.first;
  String _timer = timerList[1];

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    currentPlayer = Database.playerBox?.get("currentPlayer");
    if (currentPlayer != null) {
      isLoginSignUpDone = true;
    }
    _playerController = TextEditingController(text: currentPlayer?.name);
    _playerPassword = TextEditingController(text: "");
    String? diff = Database.optionsBox?.get("difficulty");
    if (diff != null) {
      _difficulty = diff;
    } else {
      Database.optionsBox?.put("difficulty", difficultyList.first);
    }
    String? timer = Database.optionsBox?.get("timer");
    if (timer != null) {
      _timer = timer;
    } else {
      Database.optionsBox?.put("timer", timerList[1]);
    }
  }

  void _updateCurrentPlayer(Player newPlayer) async {
    await Database.playerBox?.put("currentPlayer", newPlayer);
    await Database.playerBox
        ?.put("personalBest", Player(name: newPlayer.name, score: 0));
    setState(() => currentPlayer?.name = _playerController.text);
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
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            fontSize: SizeConfig.fontSize * 2,
                                            fontFamily: "MadimiOne",
                                            color: const Color.fromRGBO(
                                                69, 141, 67, 1)),
                                      ),
                                      DropdownButton<String>(
                                          elevation: 0,
                                          dropdownColor: const Color.fromRGBO(
                                              252, 211, 184, 1),
                                          value: _difficulty,
                                          onChanged: (value) async {
                                            await Database.optionsBox
                                                ?.put("difficulty", value!);
                                            setState(
                                                () => _difficulty = value!);
                                          },
                                          items: difficultyList.map((value) {
                                            return DropdownMenuItem(
                                                value: value,
                                                child: Text(value,
                                                    style: TextStyle(
                                                        fontSize: SizeConfig
                                                                .fontSize *
                                                            1.8,
                                                        fontFamily: "MadimiOne",
                                                        color: const Color
                                                            .fromRGBO(147, 123,
                                                            107, 1))));
                                          }).toList())
                                    ]),
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Text(
                                        "Timer",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            fontSize: SizeConfig.fontSize * 2,
                                            fontFamily: "MadimiOne",
                                            color: const Color.fromRGBO(
                                                69, 141, 67, 1)),
                                      ),
                                      DropdownButton<String>(
                                          elevation: 0,
                                          dropdownColor: const Color.fromRGBO(
                                              252, 211, 184, 1),
                                          value: _timer,
                                          onChanged: (value) async {
                                            await Database.optionsBox
                                                ?.put("timer", value!);
                                            setState(() => _timer = value!);
                                          },
                                          items: timerList.map((value) {
                                            return DropdownMenuItem(
                                                value: value,
                                                child: Text(value,
                                                    style: TextStyle(
                                                        fontSize: SizeConfig
                                                                .fontSize *
                                                            1.8,
                                                        fontFamily: "MadimiOne",
                                                        color: const Color
                                                            .fromRGBO(147, 123,
                                                            107, 1))));
                                          }).toList())
                                    ]),
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        "Playing as",
                                        style: TextStyle(
                                            fontSize: SizeConfig.fontSize * 2,
                                            fontFamily: "MadimiOne",
                                            color: const Color.fromRGBO(
                                                69, 141, 67, 1)),
                                      ),
                                      SizedBox(
                                          width: 100,
                                          child: TextField(
                                            readOnly: true,
                                            style: TextStyle(
                                                fontSize:
                                                    SizeConfig.fontSize * 1.8,
                                                fontFamily: "MadimiOne",
                                                color: const Color.fromRGBO(
                                                    147, 123, 107, 1)),
                                            controller: _playerController,
                                          ))
                                    ]),
                              ],
                            ),
                          ]))),
              Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.fromLTRB(0, 295, 0, 0),
                  child: IconButton(
                    icon: Icon(Icons.check),
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
                      _updateCurrentPlayer(
                          Player(name: _playerController.text));
                      Navigator.of(context).pop();
                    },
                  )),
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
                              fit: BoxFit.fitWidth)),
                    ),
                  )),
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
      resizeToAvoidBottomInset: false,
      body: Container(
          decoration: BoxDecoration(
              color: Color.fromRGBO(212, 253, 210, 1),
              image: DecorationImage(
                  image: AssetImage("assets/bg-2.png"), fit: BoxFit.cover)),
          child: Stack(children: [
            Positioned(top: 40, right: 20, child: _helpBtn()),
            Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 25, 0, 0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
                                        borderRadius:
                                            BorderRadius.circular(15.0))),
                                child: const Text(
                                  "PLAY",
                                  style: TextStyle(
                                    fontSize: 29,
                                    fontFamily: 'MadimiOne',
                                    color: Color.fromRGBO(36, 107, 34, 1),
                                    shadows: [
                                      Shadow(
                                        // Adjust offsets and blurRadius for stroke thickness
                                        offset: Offset(3.0,
                                            3.0), // Adjust for stroke position
                                        blurRadius: 2.0,
                                        color: Color.fromRGBO(255, 220, 80,
                                            1), // Set your stroke color
                                      ),
                                    ],
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Game(
                                              audioPlayer:
                                                  widget.audioPlayer)));
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
                                        borderRadius:
                                            BorderRadius.circular(15.0))),
                                child: const Text(
                                  "OPTIONS",
                                  style: TextStyle(
                                    fontSize: 29,
                                    fontFamily: 'MadimiOne',
                                    color: Color.fromRGBO(36, 107, 34, 1),
                                    shadows: [
                                      Shadow(
                                        // Adjust offsets and blurRadius for stroke thickness
                                        offset: Offset(3.0,
                                            3.0), // Adjust for stroke position
                                        blurRadius: 2.0,
                                        color: Color.fromRGBO(255, 220, 80,
                                            1), // Set your stroke color
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
                                  width: 5.0,
                                  color: Color.fromRGBO(36, 107, 34, 1)),
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
                            // Redirect to card catalog
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CardCatalog(
                                        audioPlayer: widget.audioPlayer)));
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
                                  width: 5.0,
                                  color: Color.fromRGBO(36, 107, 34, 1)),
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
                            // Redirect to leaderboard
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        Leaderboard(score: 0)));
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
                                  width: 5.0,
                                  color: Color.fromRGBO(36, 107, 34, 1)),
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
                            _onWillPop();
                          },
                        ),
                      )
                    ]),
              ),
            ),
            Positioned(
              bottom: 10,
              left: 10,
              child: _logoutBtn(),
            ),
            IgnorePointer(
              ignoring:
                  isLoginSignUpDone, // ignores pointers to the overlay if login/signup is done
              child: SizedBox(
                height:
                    MediaQuery.of(context).size.height, // height of the screen
                width: MediaQuery.of(context).size.width, // width of the screen
                child: Opacity(
                  opacity: isLoginSignUpDone
                      ? 0.0
                      : 1.0, // make entire login/signup overlay disappear
                  child: Stack(
                    children: [
                      // black overlay background
                      Container(
                        color: Color.fromARGB(255, 42, 50, 44).withOpacity(0.7),
                      ),

                      // blur effect
                      BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Stack(
                          children: [
                            Center(
                              child: Image.asset(
                                isLoginMode
                                    ? "assets/login-box.png"
                                    : "assets/signup-box.png",
                                width: 330,
                              ),
                            ),
                            Container(
                              //color: Colors.black,
                              margin: EdgeInsets.fromLTRB(70,
                                  SizeConfig.blockSizeVertical * 33, 70, 50),
                              height: SizeConfig.blockSizeVertical * 41,
                              width: 249,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextField(
                                    style: TextStyle(
                                      fontSize: SizeConfig.fontSize * 1.8,
                                      fontFamily: "MadimiOne",
                                      color: const Color.fromRGBO(
                                          147, 123, 107, 1),
                                    ),
                                    controller: _playerController,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp("[a-zA-Z0-9]")),
                                      LengthLimitingTextInputFormatter(10),
                                    ],
                                    decoration: InputDecoration(
                                      hintText: "Username",
                                      helperText: userErrorMsg,
                                      prefixIcon: const Icon(
                                        Icons.person,
                                        color: Colors.green,
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          borderSide: BorderSide.none),
                                    ),
                                  ),
                                  TextField(
                                    style: TextStyle(
                                      fontSize: SizeConfig.fontSize * 1.8,
                                      fontFamily: "MadimiOne",
                                      color: const Color.fromRGBO(
                                          147, 123, 107, 1),
                                    ),
                                    controller: _playerPassword,
                                    obscureText: true,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp("[a-zA-Z0-9]")),
                                      LengthLimitingTextInputFormatter(10),
                                    ],
                                    decoration: InputDecoration(
                                      hintText: "Password",
                                      helperText: passwordErrorMsg,
                                      prefixIcon: const Icon(
                                        Icons.lock,
                                        color: Colors.green,
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          borderSide: BorderSide.none),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Login: Sign-Up button   ;   Sign-Up: Back to Login button
                                      ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            userErrorMsg = "";
                                            passwordErrorMsg = "";
                                            _playerController.text = "";
                                            _playerPassword.text = "";
                                            isLoginMode = !isLoginMode;
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: darkGreen,
                                          backgroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            side: BorderSide(
                                                color: darkGreen, width: 1.0),
                                          ),
                                        ),
                                        child: Text(
                                            isLoginMode ? "SIGN-UP" : "BACK"),
                                      ),

                                      // Login: Login button   ;   Sign-Up: Sign-up button
                                      ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            userErrorMsg = "";
                                            passwordErrorMsg = "";
                                          });
                                          if (_playerController.text.isEmpty) {
                                            setState(() => userErrorMsg =
                                                "Enter a username.");
                                            return;
                                          }
                                          if (_playerPassword.text.isEmpty) {
                                            setState(() => passwordErrorMsg =
                                                "Enter password.");
                                            return;
                                          }
                                          if (isLoginMode) {
                                            Database.firebase
                                                .collection("players")
                                                .doc(_playerController.text)
                                                .get()
                                                .then((user) {
                                              if (!user.exists) {
                                                setState(() {
                                                  userErrorMsg =
                                                      "Username does not exist.";
                                                });
                                                return;
                                              }
                                              if (user.data()?["password"] !=
                                                  _playerPassword.text) {
                                                setState(() {
                                                  passwordErrorMsg =
                                                      "Incorrect password.";
                                                });
                                                return;
                                              }
                                              Database.playerBox
                                                  ?.put(
                                                      "personalBest",
                                                      Player(
                                                          name: user
                                                              .data()?["name"],
                                                          score: user.data()?[
                                                              "score"]))
                                                  .whenComplete(() {
                                                setState(() =>
                                                    isLoginSignUpDone = true);
                                                _updateCurrentPlayer(Player(
                                                    name: _playerController
                                                        .text));
                                              });
                                            });
                                          } else {
                                            Database.firebase
                                                .collection("players")
                                                .doc(_playerController.text)
                                                .get()
                                                .then((user) {
                                              if (user.exists) {
                                                setState(() {
                                                  userErrorMsg =
                                                      "This username is already taken.";
                                                });
                                              } else {
                                                Database.firebase
                                                    .collection("players")
                                                    .doc(_playerController.text)
                                                    .set({
                                                  "name":
                                                      _playerController.text,
                                                  "score": 0,
                                                  "password":
                                                      _playerPassword.text
                                                });
                                                setState(() {
                                                  isLoginMode = true;
                                                  _playerController.text = "";
                                                  _playerPassword.text = "";
                                                });
                                              }
                                            });
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: darkGreen,
                                          backgroundColor: lightGreen1,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            side: BorderSide(
                                                color: darkGreen, width: 2.0),
                                          ),
                                        ),
                                        child: Text(
                                            isLoginMode ? "LOGIN" : "SIGN-UP"),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(top: 40, left: 20, child: _musicBtn()),
          ])),
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

  SizedBox _musicBtn() {
    return SizedBox(
        child: Container(
      height: 50,
      width: 50,
      decoration: BoxDecoration(
          border: Border.all(color: darkGreen, width: 3.0),
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
          icon: isPaused
              ? const Icon(Icons.music_off_outlined)
              : const Icon(Icons.music_note),
          color: darkGreen,
          iconSize: 25,
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
    ));
  }

  SizedBox _helpBtn() {
    return SizedBox(
      child: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          border:
              Border.all(color: Color.fromARGB(255, 134, 177, 138), width: 3.0),
          borderRadius: BorderRadius.circular(50),
        ),
        child: IconButton(
          icon: const Icon(Icons.question_mark),
          color: Color.fromARGB(255, 134, 177, 138),
          iconSize: 25,
          onPressed: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => Manual(
                          audioPlayer: widget.audioPlayer,
                        )));
          },
        ),
      ),
    );
  }

  IconButton _logoutBtn() {
    return IconButton(
        icon: const Icon(Icons.logout),
        color: Colors.white,
        onPressed: () {
          // Show a confirmation dialog
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Logout'),
                content: Text('Are you sure you want to logout?'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () async {
                      await Database.playerBox?.delete("currentPlayer");
                      setState(() {
                        currentPlayer = null;
                        userErrorMsg = "";
                        passwordErrorMsg = "";
                        _playerController.text = "";
                        _playerPassword.text = "";
                        Navigator.of(context).pop();
                        isLoginSignUpDone = false;
                      });
                    },
                    child: Text('Yes'),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        Navigator.of(context).pop();
                      });
                    },
                    child: Text('No'),
                  ),
                ],
              );
            },
          );
        });
  }
}
