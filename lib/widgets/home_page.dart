import 'package:flutter/material.dart';
import 'package:memory_game/db/db.dart';
import 'package:memory_game/models/player.dart';
import 'package:memory_game/widgets/game.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Player? currentPlayer;
  late TextEditingController _controller;
  @override 
  void setState(fn){
    if(mounted){
      super.setState(fn);
    }
  }
  @override 
  void initState(){
    super.initState();
    setState(() => currentPlayer = Database.playerBox?.get("currentPlayer", defaultValue: Player(name: "Guest")));
    setState(() => _controller = TextEditingController(text: currentPlayer?.name)); 
  }

  void _updateCurrentPlayer(Player newPlayer) async {
    print(newPlayer.name);
    if(newPlayer.name != "Guest"){
      await Database.playerBox?.put("currentPlayer", newPlayer);
      setState(() => currentPlayer?.name = _controller.text); 
    }
    Navigator.of(context).pop();
  }

  Widget _buildPopupDialog(BuildContext context) {
  return AlertDialog(
    title: const Text('Options'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [const Text("Playing as"),  SizedBox(width: 100, child:TextField(controller: _controller,))],)
      ],
    ),
    actions: <Widget>[
      ElevatedButton(
        onPressed: () {
          _updateCurrentPlayer(Player(name: _controller.text));
        },
        child: const Text("Save"),
      ),
    ],
  );
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("Memory Game")),
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [ElevatedButton(
              child: const Text("Play"),
              onPressed: () { 
                Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => const Game())
                );
              }),
                ElevatedButton(
                child: const Text("Options"),
                onPressed: () {
                  showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) => _buildPopupDialog(context),);
                }),
            ]
        ),
      ),
    );
  }
}
