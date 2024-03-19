class CardItem {
  final String val;
  bool isTapped;
  CardItem({required this.val, this.isTapped = false});

  static List<CardItem> getCards(int max) {
    List<CardItem> cards = [];
    List<int> indexes = List.generate(18, (i) => i + 1); 

    indexes.shuffle();

    for (int i = 0; i < max / 2; i++) { 
      cards.add(
        CardItem(val: "assets/cards/${indexes[i]}.png")
      );
      cards.add(
        CardItem(val: "assets/cards/${indexes[i]}.png")
      );
    }

    return cards;
  }
}