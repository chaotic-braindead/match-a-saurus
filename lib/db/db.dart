import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:memory_game/models/player.dart';

class Database {
  static FirebaseFirestore firebase = FirebaseFirestore.instance;
  static Box<Player>? playerBox;
  static Box<String>? optionsBox;
  static Future<void> initHive() async {
    if (playerBox != null) {
      return;
    }
    playerBox = await Hive.openBox<Player>("player");
    optionsBox = await Hive.openBox<String>("options");
  }
}
