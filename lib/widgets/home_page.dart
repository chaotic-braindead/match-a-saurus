import 'package:flutter/material.dart';
import 'package:memory_game/db/db.dart';
import 'package:memory_game/widgets/game.dart';
import 'package:memory_game/widgets/options.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String currentPlayer;
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
    Database.instance.collection("players").limit(1).get().then((event) {
      if(event.docs.isNotEmpty){
        setState(() => currentPlayer = event.docs[0].data()["name"]);
      }
      else{
        setState(() => currentPlayer = "Guest");
      }
      setState(() => _controller = TextEditingController(text: currentPlayer));
      }
    );
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
          children: [const Text("Player"), const Spacer(), SizedBox(width: 100, child:TextField(controller: _controller,))],)
      ],
    ),
    actions: <Widget>[
      ElevatedButton(
        onPressed: () {
          setState(() { currentPlayer = _controller.text; });
          Navigator.of(context).pop();
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
                  context, MaterialPageRoute(builder: (context) => Game(currentPlayer: currentPlayer))
                );
              }),
                ElevatedButton(
                child: const Text("Options"),
                onPressed: () {
                  showDialog(
                  context: context,
                  builder: (BuildContext context) => _buildPopupDialog(context),);
                }),
            ]
        ),
      ),
    );
  }
}
