class FriendsData {
  FriendsData({
    this.name = '',
    this.victoriesWith = 0,
    this.victoriesAgainst = 0,
    this.defeatsWith = 0,
    this.defeatsAgainst = 0,
    this.drawsWith = 0,
    this.drawsAgainst = 0
  });

  String name;
  int victoriesWith;
  int victoriesAgainst;
  int defeatsWith;
  int defeatsAgainst;
  int drawsWith;
  int drawsAgainst;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'victoriesWith': victoriesWith,
      'victoriesAgainst': victoriesAgainst,
      'defeatsWith': defeatsWith,
      'defeatsAgainst': defeatsAgainst,
      'drawsWith': drawsWith,
      'drawsAgainst': drawsAgainst
    };
  }

  factory FriendsData.fromMap(Map<String, dynamic> map) {
    return FriendsData(
        name: map['name'] ?? '',
        victoriesWith: map['victoriesWith'] ?? 0,
        victoriesAgainst: map['victoriesAgainst'] ?? 0,
        defeatsWith: map['defeatsWith'] ?? 0,
        defeatsAgainst: map['defeatsAgainst'] ?? 0,
        drawsWith: map['drawsWith'] ?? 0,
        drawsAgainst: map['drawsAgainst'] ?? 0,
    );
  }
}
