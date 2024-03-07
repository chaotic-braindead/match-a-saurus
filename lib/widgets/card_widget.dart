import "package:memory_game/models/card_item.dart";
import 'package:flutter/material.dart';

class CardWidget extends StatefulWidget {
  final CardItem card;
  final Function(CardItem) onTap;
  const CardWidget({required this.card, required this.onTap, super.key});
  @override 
  State<CardWidget> createState () => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget> {
  @override
  Widget build(BuildContext context) {
   return GestureDetector(
      onTap: () {
        widget.onTap(widget.card);
      },
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: (widget.card.isTapped) ? Colors.green : Colors.grey),
        child: widget.card.isTapped ? Text(widget.card.val) : null,
      ),
    );
  }
}