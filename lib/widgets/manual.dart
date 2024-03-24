import 'package:audioplayers/src/audioplayer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:memory_game/widgets/card_catalog.dart';
import 'package:memory_game/widgets/home_page.dart';

class Manual extends StatefulWidget {
  final AudioPlayer audioPlayer;
  const Manual({super.key, required this.audioPlayer});
  @override
  State<Manual> createState() => _ManualState();
}

class _ManualState extends State<Manual> {
  @override
  Widget build(BuildContext context) {
    return Stack(
          children: [
            // Background Image
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/bg-1.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Main Column
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 38, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(
                      "assets/logo-title.png",
                      width: 115,
                    ),
                      Container(
                       // margin: const EdgeInsets.symmetric(horizontal: 25),
                        decoration: BoxDecoration(
                            border: Border.all(color: darkGreen, width: 4.0),
                            borderRadius: BorderRadius.circular(50),
                            color: lightGreen1,
                            boxShadow: [
                              BoxShadow(
                                color: lightPink.withOpacity(1),
                                offset: const Offset(1.85, 3),
                              )
                            ]),
                        child: IconButton(
                          icon: const Icon(Icons.close),
                          color: darkGreen,
                          iconSize: 30,
                          onPressed: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HomePage(audioPlayer: widget.audioPlayer,)));
                          },
                        ),
                      )
                    ],
                  ),
                ),
                      
                
                // how to play title
                Expanded(
                  flex: 9,
                  child: Center(
                    child: Image.asset(
                      'assets/how-to-play-text.png',
                      width: 250.0,
                      height: 200.0,
                    ),
                  ),
                ),

                // rectangle container
                Expanded(
                  flex: 60,
                  child: Center(
                    child: Container(
                    margin: const EdgeInsets.fromLTRB(30,0,30,40),
                    decoration: BoxDecoration(
                      border: Border.all(color: darkGreen, width: 4.0),
                      borderRadius: BorderRadius.circular(10),
                      color: lightGreen2.withOpacity(0.5),
                    ),
                    child: ListView(
                      scrollDirection: Axis.vertical,
                      children: <Widget>[
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // basic mechanics
                            const Padding(
                              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                              child: Text(
                                    "BASIC MECHANICS",
                                    style: TextStyle(
                                        fontFamily: "MadimiOne",
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: darkGreen),
                                  ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 300, // Adjust width as needed
                                  height: 200, // Adjust height as needed
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage("assets/help-pic-1.png"),
                                      fit: BoxFit.fitWidth,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // adjusting difficulty and speed
                            const Padding(
                              padding: EdgeInsets.fromLTRB(20, 15, 20, 0),
                              child: Text(
                                    "ADJUSTING DIFFICULTY AND SPEED",
                                    style: TextStyle(
                                        fontFamily: "MadimiOne",
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: darkGreen),
                                  ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 300, // Adjust width as needed
                                  height: 200, // Adjust height as needed
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage("assets/help-pic-2.png"),
                                      fit: BoxFit.fitWidth,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // scoring
                            const Padding(
                              padding: EdgeInsets.fromLTRB(20, 15, 20, 0),
                              child: Text(
                                    "SCORING",
                                    style: TextStyle(
                                        fontFamily: "MadimiOne",
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: darkGreen),
                                  ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 300, // Adjust width as needed
                                  height: 180, // Adjust height as needed
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage("assets/help-pic-3.png"),
                                      fit: BoxFit.fitWidth,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),

                  ),
                    
                  ),
                )

                
              ],
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: _musicBtn(),
            )
          ],
        );
  }

  SizedBox _musicBtn() {
    return SizedBox(
     
      child: Container(
              height: 50,
              width: 50,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
