class CardItem {
  final String val;
  bool isTapped;
  CardItem({required this.val, this.isTapped = false});

  static List<CardItem> getCards(int max) {
    List<CardItem> cards = [];
    List<int> indexes = [];

    for (int i = 1; i <= 18; i++) {
      indexes.add(i);
    }

    indexes.shuffle();

    for (int i = 1; i <= max/2; i++) {
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