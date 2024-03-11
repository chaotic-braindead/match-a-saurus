import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:memory_game/db/db.dart';
import 'package:memory_game/models/player.dart';
import 'package:memory_game/widgets/game.dart';

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

  Widget _buildPopupDialog(BuildContext context) {
    return StatefulBuilder(builder: (context, setState) {
      return AlertDialog(
          title: const Text('Options'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                const Text("Difficulty"),
                SizedBox(
                    width: 100,
                    child: DropdownButton<String>(
                        value: _difficulty,
                        onChanged: (value) async {
                          await Database.optionsBox?.put("difficulty", value!);
                          setState(() => _difficulty = value!);
                        },
                        items: difficultyList.map((value) {
                          return DropdownMenuItem(
                              value: value, child: Text(value));
                        }).toList()))
              ]),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                const Text("Playing as"),
                SizedBox(
                    width: 100,
                    child: TextField(
                      controller: _controller,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp("[a-zA-Z0-9]")),
                        LengthLimitingTextInputFormatter(10)
                      ],
                    ))
              ]),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                _updateCurrentPlayer(Player(name: _controller.text));
              },
              child: const Text("Save"),
            ),
          ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/background.png"), fit: BoxFit.fill)),
      child: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const SizedBox(height: 190),
          SizedBox(
              width: 260,
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => const Game()));
                  },
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    side: const BorderSide(
                        width: 3.5, color: Color.fromRGBO(36, 107, 34, 1)),
                    // Change your radius here
                    borderRadius: BorderRadius.circular(15),
                  ))),
                  child: const Text("PLAY",
                      style: TextStyle(
                          color: Color.fromRGBO(36, 107, 34, 1),
                          fontFamily: "MadimiOne",
                          fontSize: 35,
                          shadows: [
                            Shadow(
                                // bottomLeft
                                offset: Offset(2.5, 3),
                                color: Color.fromRGBO(255, 221, 83, 1)),
                          ])))),
          const SizedBox(height: 10),
          SizedBox(
              width: 260,
              height: 50,
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => const Game()));
                  },
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    side: const BorderSide(
                        width: 3.5, color: Color.fromRGBO(36, 107, 34, 1)),
                    // Change your radius here
                    borderRadius: BorderRadius.circular(15),
                  ))),
                  child: const Text("VIEW HIGH SCORES",
                      style: TextStyle(
                          color: Color.fromRGBO(36, 107, 34, 1),
                          fontFamily: "MadimiOne",
                          fontSize: 25,
                          shadows: [
                            Shadow(
                                // bottomLeft
                                offset: Offset(2.5, 3),
                                color: Color.fromRGBO(255, 221, 83, 1)),
                          ])))),
          const SizedBox(height: 10),
          SizedBox(
              width: 260,
              height: 50,
              child: ElevatedButton(
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    side: const BorderSide(
                        width: 3.5, color: Color.fromRGBO(36, 107, 34, 1)),
                    // Change your radius here
                    borderRadius: BorderRadius.circular(15),
                  ))),
                  child: const Text("OPTIONS",
                      style: TextStyle(
                          color: Color.fromRGBO(36, 107, 34, 1),
                          fontFamily: "MadimiOne",
                          fontSize: 28,
                          shadows: [
                            Shadow(
                                // bottomLeft
                                offset: Offset(2.5, 3),
                                color: Color.fromRGBO(255, 221, 83, 1)),
                          ])),
                  onPressed: () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) =>
                          _buildPopupDialog(context),
                    );
                  })),
        ]),
      ),
    ));
  }
}
