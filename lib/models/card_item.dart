class CardItem {
  final String val;
  bool isTapped;
  CardItem({required this.val, this.isTapped = false});

  static List<CardItem> getCards(int max) {
    List<CardItem> cards = [];

    for (int i = 1; i <= max/2; i++) {
      cards.add(
        CardItem(val: "assets/cards/$i.png")
      );
      cards.add(
        CardItem(val: "assets/cards/$i.png")
      );
    }

    return cards;
  }
}