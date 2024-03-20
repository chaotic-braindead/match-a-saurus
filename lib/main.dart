import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:memory_game/db/db.dart';
import 'package:memory_game/firebase_options.dart';
import 'package:memory_game/models/player.dart';
import 'package:memory_game/utils/size_config.dart';
import 'package:memory_game/widgets/home_page.dart';
import 'package:firebase_core/firebase_core.dart';

Future main() async {
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

class MemoryGame extends StatelessWidget {
  const MemoryGame({super.key});
  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return MaterialApp(
      title: 'match a saurus',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromRGBO(118, 251, 116, 1)),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
