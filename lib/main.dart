import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:memory_game/db/db.dart';
import 'package:memory_game/firebase_options.dart';
import 'package:memory_game/models/player.dart';
import 'package:memory_game/utils/size_config.dart';
import 'package:memory_game/widgets/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:audioplayers/audioplayers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(PlayerAdapter());
  }
  await Database.initHive();
  runApp(const MemoryGame());
}

class MemoryGame extends StatefulWidget {
  const MemoryGame({Key? key}) : super(key: key);

  @override
  _MemoryGameState createState() => _MemoryGameState();
}

class _MemoryGameState extends State<MemoryGame> {
  final AudioPlayer audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _playMusic();
  }

 Future<void> _playMusic() async {
  audioPlayer.onPlayerComplete.listen((event) {
    audioPlayer.play(
      AssetSource('bgmusic.mp3'),
    );
  });
  await audioPlayer.play(AssetSource('bgmusic.mp3'));
}

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return MaterialApp(
      title: 'match a saurus',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromRGBO(118, 251, 116, 1),
        ),
        useMaterial3: true,
      ),
      home: HomePage(audioPlayer: audioPlayer),
    );
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }
}