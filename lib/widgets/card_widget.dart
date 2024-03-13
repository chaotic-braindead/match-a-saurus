import 'dart:math';

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
        decoration: BoxDecoration(
          color: (widget.card.isTapped) ? Colors.white : Color.fromRGBO(69, 141, 67, 1)),
        child: widget.card.isTapped ? Text(widget.card.val) : null,
      ),
    );
  }
}