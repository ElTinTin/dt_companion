enum Character {
  pyromancer,
  monk,
  shadowthief,
  samurai,
  artificer,
  barbarian,
  cursedpirate,
  gunslinger,
  huntress,
  ninja,
  paladin,
  seraph,
  tactician,
  treant,
  vampire,
  blackpanther,
  blackwidow,
  captainmarvel,
  drstrange,
  loki,
  scarletwitch,
  spiderman,
  thor,
  moonelf
}

extension CharacterExtension on Character {
  String get displayName {
    switch (this) {
      case Character.pyromancer:
        return "Pyromancer";
      case Character.monk:
        return "Monk";
      case Character.shadowthief:
        return "Shadow Thief";
      case Character.samurai:
        return "Samurai";
      case Character.artificer:
        return "Artificer";
      case Character.barbarian:
        return "Barbarian";
      case Character.cursedpirate:
        return "Cursed Pirate";
      case Character.gunslinger:
        return "Gunslinger";
      case Character.huntress:
        return "Huntress";
      case Character.ninja:
        return "Ninja";
      case Character.paladin:
        return "Paladin";
      case Character.seraph:
        return "Seraph";
      case Character.tactician:
        return "Tactician";
      case Character.treant:
        return "Treant";
      case Character.vampire:
        return "Vampire";
      case Character.blackpanther:
        return "Black Panther";
      case Character.blackwidow:
        return "Black Widow";
      case Character.captainmarvel:
        return "Captain Marvel";
      case Character.drstrange:
        return "Dr. Strange";
      case Character.loki:
        return "Loki";
      case Character.scarletwitch:
        return "Scarlet Witch";
      case Character.spiderman:
        return "Spider-Man";
      case Character.thor:
        return "Thor";
      case Character.moonelf:
        return "Moon Elf";
      default:
        return "";
    }
  }
}

class HeroesListData {
  HeroesListData(
      {this.name = '',
      this.imagePath = '',
      this.victories = 0,
      this.defeats = 0,
      this.draws = 0});

  String name;
  String imagePath;
  int victories;
  int defeats;
  int draws;

  factory HeroesListData.fromMap(Map<String, dynamic> map) {
    return HeroesListData(
      name: map['name'] ?? '',
      imagePath: map['imagePath'] ?? '',
      victories: map['victories'] ?? 0,
      defeats: map['defeats'] ?? 0,
      draws: map['draws'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imagePath': imagePath,
      'victories': victories,
      'defeats': defeats,
      'draws': draws,
    };
  }
}
