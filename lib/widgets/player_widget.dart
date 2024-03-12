import 'package:flutter/material.dart';
import 'package:memory_game/models/player.dart';
import 'package:memory_game/utils/size_config.dart';

class PlayerWidget extends StatelessWidget {
  final Player player;
  Color color;
  @override
  PlayerWidget(
      {super.key, required this.player, this.color = Colors.transparent});
  @override
  Widget build(BuildContext context) {
    return Container(
        color: color,
        child: Row(children: [
          Text(
            player.name,
            style: TextStyle(
                fontSize: SizeConfig.fontSize * 2.35,
                fontFamily: "MadimiOne",
                color: const Color.fromRGBO(69, 141, 67, 1)),
          ),
          const Spacer(),
          Text(player.score.toString(),
              style: TextStyle(
                  fontSize: SizeConfig.fontSize * 2.35,
                  fontFamily: "MadimiOne",
                  color: const Color.fromRGBO(147, 123, 107, 1)))
        ]));
  }
}
