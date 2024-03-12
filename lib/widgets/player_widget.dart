import 'package:flutter/material.dart';
import 'package:memory_game/models/player.dart';

class PlayerWidget extends StatelessWidget {
  final Player player;
  Color color;
  PlayerWidget({super.key, required this.player, this.color=Colors.white});
  @override 

  @override
  Widget build(BuildContext context) {
    return Container(color: color, child: Row(
      children: [Text(player.name), const Spacer(), Text(player.score.toString())])
      );
  }
}