// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
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
    String? diff = Database.optionsBox?.get("difficulty");
    if(diff != null){
      setState(() => _difficulty = diff);
    } 
    else{
      Database.optionsBox?.put("difficulty", difficultyList.first);
    }
  }

  void _updateCurrentPlayer(Player newPlayer) async {
    if(newPlayer.name != "Guest"){
      await Database.playerBox?.put("currentPlayer", newPlayer);
      setState(() => currentPlayer?.name = _controller.text); 
    }
    Navigator.of(context).pop();
  }

  Widget _buildPopupDialog(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
      title: const Text('Options'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [const Text("Difficulty"),  
                        SizedBox(
                          width: 100, 
                          child: DropdownButton<String>(
                                value: _difficulty,
                                onChanged: (value) async { 
                                  await Database.optionsBox?.put("difficulty", value!);
                                  setState(() => _difficulty = value!); 
                                },
                                items: difficultyList.map((value) {
                                  return DropdownMenuItem(value: value, child: Text(value));
                                }).toList()
                          )
                        )
                      ]
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [const Text("Playing as"),  SizedBox(width: 100, child:TextField(controller: _controller,))]),
          
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
            image: AssetImage("assets/dinos-compiled.png"),
            fit: BoxFit.cover
          )
        ),
        child: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _homeTitle(),
                Column(
                  children: [
                    SizedBox(height: 20,),
                    SizedBox(
                      width: 185,
                      height: 140,
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("assets/logo-dino.png"),
                            fit: BoxFit.cover
                          )
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 250,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          side: BorderSide (
                            width: 5.0,
                            color:Color.fromRGBO(36, 107, 34, 1)
                          )
                        ),
                        child: const Text(
                          "PLAY",
                          style: TextStyle(
                            fontSize: 29,
                            fontFamily: 'MadimiOne',
                            color: Color.fromRGBO(36, 107, 34, 1),
                            shadows: [
                              Shadow( // Adjust offsets and blurRadius for stroke thickness
                                offset: Offset(3.0, 3.0), // Adjust for stroke position
                                blurRadius: 2.0,
                                color: Color.fromRGBO(255, 220, 80, 1), // Set your stroke color
                              ),
                            ],
                            ),
                          ),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context, MaterialPageRoute(builder: (context) => const Game())
                          );
                        }
                      ),
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      width: 250,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          side: BorderSide (
                            width: 5.0,
                            color:Color.fromRGBO(36, 107, 34, 1)
                          )
                        ),
                      child: const Text(
                        "Options",
                        style: TextStyle(
                            fontSize: 29,
                            fontFamily: 'MadimiOne',
                            color: Color.fromRGBO(36, 107, 34, 1),
                            shadows: [
                              Shadow( // Adjust offsets and blurRadius for stroke thickness
                                offset: Offset(3.0, 3.0), // Adjust for stroke position
                                blurRadius: 2.0,
                                color: Color.fromRGBO(255, 220, 80, 1), // Set your stroke color
                              ),
                            ],
                            ),
                        ),
                      onPressed: () {
                        showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) => _buildPopupDialog(context),);
                      }),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: 250,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                          side: BorderSide (
                            width: 5.0,
                            color:Color.fromRGBO(36, 107, 34, 1)
                          )
                        ),
                    child: const Text(
                      "Exit",
                      style: TextStyle(
                            fontSize: 29,
                            fontFamily: 'MadimiOne',
                            color: Color.fromRGBO(36, 107, 34, 1),
                            shadows: [
                              Shadow( // Adjust offsets and blurRadius for stroke thickness
                                offset: Offset(3.0, 3.0), // Adjust for stroke position
                                blurRadius: 2.0,
                                color: Color.fromRGBO(255, 220, 80, 1), // Set your stroke color
                              ),
                            ],
                            ),
                      ),
                    onPressed: () {
                      _onWillPop();
                    },
                  ),
                )
              ]
          ),
        ),
      ),
    );
  }

Stack _homeTitle() {
    return Stack(
  children: <Widget>[
         Text(
          'match a\nsaurus',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 70,
            fontFamily: 'MadimiOne',
            height: 1.0,
            shadows: const [
              Shadow( // Adjust offsets and blurRadius for stroke thickness
                offset: Offset(13.0, 9.0), // Adjust for stroke position
                blurRadius: 2.0,
                color: Color.fromRGBO(255, 188, 152, 1), // Set your stroke color
              ),
            ],
            
          ),
        ),
        
        Text(
          'match a\nsaurus',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 72,
            fontFamily: 'MadimiOne',
            height: 1.0,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 12
              ..color = Color.fromRGBO(36, 107, 34, 1),
             shadows: const [
              Shadow( // Adjust offsets and blurRadius for stroke thickness
                offset: Offset(0.0, 1.0), // Adjust for stroke position
                blurRadius: 2.0,
                color: Color.fromRGBO(36, 107, 34, 1), // Set your stroke color
              ),
            ],
            
          ),
        ),

        Text(
          'match a\nsaurus',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 70,
            fontFamily: 'MadimiOne',
            height: 1.0,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 12
              ..color = Color.fromRGBO(36, 107, 34, 1),
             shadows: const [
              Shadow( // Adjust offsets and blurRadius for stroke thickness
                offset: Offset(10.0, 1.0), // Adjust for stroke position
                blurRadius: 2.0,
                color: Color.fromRGBO(36, 107, 34, 1), // Set your stroke color
              ),
            ],
            
          ),
        ),
       
        Text(
          'match a\nsaurus',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 70,
            fontFamily: 'MadimiOne',
            height: 1.0,
            color: const Color.fromARGB(255, 255, 255, 255),
            
          ),
        ),
      ],
    );
  }
}


//   Stack _homeTitle() {
//     return Stack(
//       children: const <Widget>[
//         // Stroked text as border.
//         Text(
//           "match a\nsaurus",
//           textAlign: TextAlign.center,
//           style: TextStyle(
//             fontSize: 70,
//             fontFamily: 'MadimiOne',
//             color: Color.fromRGBO(36, 107, 34, 1),
//             height: 1.0,
//             shadows: [
//               Shadow( // Adjust offsets and blurRadius for stroke thickness
//                 offset: Offset(5.0, 2.0), // Adjust for stroke position
//                 blurRadius: 2.0,
//                 color: Color.fromRGBO(255, 220, 80, 1), // Set your stroke color
//               ),
//             ],
//           ),
//         ),
//         // Solid text as fill.
//         Text(
//           "match a\nsaurus",
//           textAlign: TextAlign.center,
//           style: TextStyle(
//             fontSize: 70,
//             fontFamily: 'MadimiOne',
//             color: Color.fromRGBO(36, 107, 34, 1),
//             height: 1.0,
//             shadows: [
//               Shadow( // Adjust offsets and blurRadius for stroke thickness
//                 offset: Offset(5.0, 2.0), // Adjust for stroke position
//                 blurRadius: 2.0,
//                 color: Color.fromRGBO(255, 220, 80, 1), // Set your stroke color
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
