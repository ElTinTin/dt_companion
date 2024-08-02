class FriendsData {
  FriendsData({this.name = '', this.victories = 0, this.defeats = 0});

  String name;
  int victories;
  int defeats;

  Map<String, dynamic> toMap() {
    return {'name': name, 'victories': victories, 'defeats': defeats};
  }

  factory FriendsData.fromMap(Map<String, dynamic> map) {
    return FriendsData(
        name: map['name'] ?? '',
        victories: map['victories'] ?? 0,
        defeats: map['defeats'] ?? 0);
  }
}
