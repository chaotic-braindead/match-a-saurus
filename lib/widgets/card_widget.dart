import "package:memory_game/models/card_item.dart";
import 'package:flutter/material.dart';

class CardWidget extends StatefulWidget {
  final CardItem card;
  final Function(CardItem)? onTap;
  const CardWidget({required this.card, this.onTap, super.key});
  @override 
  State<CardWidget> createState () => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget> {
  @override
  Widget build(BuildContext context) {
   return GestureDetector(
      onTap: () {
        if(widget.onTap != null){
          widget.onTap!(widget.card);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.fastOutSlowIn,
        alignment: Alignment.center,
        padding: EdgeInsets.all((widget.card.isTapped) ? 200 : 200),
        decoration: BoxDecoration (
          borderRadius: BorderRadius.circular(10),
          image: DecorationImage(
            image: AssetImage((widget.card.isTapped) ? widget.card.val : "assets/logo-card.png"),
            fit: BoxFit.contain
          ),
          color: const Color.fromRGBO(69, 141, 67, 1)
        ),
      ),
    );
  }
}