import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:memory_game/db/db.dart';
import 'package:memory_game/models/player.dart';
import 'package:memory_game/utils/size_config.dart';
import 'package:memory_game/widgets/game.dart';
import 'package:memory_game/widgets/leaderboard.dart';

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
    currentPlayer = Database.playerBox
        ?.get("currentPlayer", defaultValue: Player(name: "Guest"));
    _controller = TextEditingController(text: currentPlayer?.name);
    String? diff = Database.optionsBox?.get("difficulty");
    if (diff != null) {
      _difficulty = diff;
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
                  child: Text("options",
                      style: TextStyle(
                          fontFamily: "MadimiOne",
                          height: 0.65,
                          fontSize: 6.15 * SizeConfig.fontSize,
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
                          ]))),
            ])),
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/background.png"),
                  fit: BoxFit.fitHeight)),
          child: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              SizedBox(height: SizeConfig.blockSizeVertical * 20),
              SizedBox(
                  width: 260,
                  child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Game()));
                      },
                      style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all(RoundedRectangleBorder(
                        side: const BorderSide(
                            width: 3.5, color: Color.fromRGBO(36, 107, 34, 1)),
                        // Change your radius here
                        borderRadius: BorderRadius.circular(15),
                      ))),
                      child: const FittedBox(
                          child: Text("PLAY",
                              style: TextStyle(
                                  color: Color.fromRGBO(36, 107, 34, 1),
                                  fontFamily: "MadimiOne",
                                  fontSize: 35,
                                  shadows: [
                                    Shadow(
                                        // bottomLeft
                                        offset: Offset(2.5, 3),
                                        color: Color.fromRGBO(255, 221, 83, 1)),
                                  ]))))),
              const SizedBox(height: 10),
              SizedBox(
                  width: 260,
                  height: 50,
                  child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const Leaderboard(score: 0)));
                      },
                      style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all(RoundedRectangleBorder(
                        side: const BorderSide(
                            width: 3.5, color: Color.fromRGBO(36, 107, 34, 1)),
                        // Change your radius here
                        borderRadius: BorderRadius.circular(15),
                      ))),
                      child: FittedBox(
                          child: Text("LEADERBOARD",
                              style: TextStyle(
                                  color: const Color.fromRGBO(36, 107, 34, 1),
                                  fontFamily: "MadimiOne",
                                  fontSize: SizeConfig.fontSize * 6,
                                  shadows: const [
                                    Shadow(
                                        // bottomLeft
                                        offset: Offset(2.5, 3),
                                        color: Color.fromRGBO(255, 221, 83, 1)),
                                  ]))))),
              const SizedBox(height: 10),
              SizedBox(
                  width: 260,
                  height: 50,
                  child: ElevatedButton(
                      style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all(RoundedRectangleBorder(
                        side: const BorderSide(
                            width: 3.5, color: Color.fromRGBO(36, 107, 34, 1)),
                        // Change your radius here
                        borderRadius: BorderRadius.circular(15),
                      ))),
                      child: const FittedBox(
                          child: Text("OPTIONS",
                              style: TextStyle(
                                  color: Color.fromRGBO(36, 107, 34, 1),
                                  fontFamily: "MadimiOne",
                                  fontSize: 28,
                                  shadows: [
                                    Shadow(
                                        // bottomLeft
                                        offset: Offset(2.5, 3),
                                        color: Color.fromRGBO(255, 221, 83, 1)),
                                  ]))),
                      onPressed: () {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) =>
                              _buildOptionsDialog(context),
                        );
                      })),
            ]),
          ),
        ));
  }
}
