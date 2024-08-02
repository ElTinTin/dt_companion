enum Character {
  artificer,
  barbarian,
  blackpanther,
  blackwidow,
  captainmarvel,
  cursedpirate,
  cyclops,
  deadpool,
  drstrange,
  gambit,
  gunslinger,
  huntress,
  iceman,
  jeangrey,
  krampus,
  loki,
  monk,
  moonelf,
  ninja,
  paladin,
  psylocke,
  pyromancer,
  rogue,
  samurai,
  santa,
  scarletwitch,
  seraph,
  shadowthief,
  spiderman,
  storm,
  tactician,
  thor,
  treant,
  vampire,
  wolverine
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
      case Character.santa:
        return "Santa";
      case Character.krampus:
        return "Krampus";
      case Character.cyclops:
        return "Cyclops";
      case Character.deadpool:
        return "Deadpool";
      case Character.gambit:
        return "Gambit";
      case Character.iceman:
        return "Iceman";
      case Character.jeangrey:
        return "Jean Grey";
      case Character.psylocke:
        return "Psylocke";
      case Character.rogue:
        return "Rogue";
      case Character.storm:
        return "Storm";
      case Character.wolverine:
        return "Wolverine";
    }
  }
  static Character? fromDisplayName(String displayName) {
    return _displayNameMap[displayName];
  }

  static final Map<String, Character> _displayNameMap = {
    "Artificer": Character.artificer,
    "Barbarian": Character.barbarian,
    "Black Panther": Character.blackpanther,
    "Black Widow": Character.blackwidow,
    "Captain Marvel": Character.captainmarvel,
    "Cursed Pirate": Character.cursedpirate,
    "Cyclops": Character.cyclops,
    "Deadpool": Character.deadpool,
    "Dr. Strange": Character.drstrange,
    "Gambit": Character.gambit,
    "Gunslinger": Character.gunslinger,
    "Huntress": Character.huntress,
    "Iceman": Character.iceman,
    "Jean Grey": Character.jeangrey,
    "Krampus": Character.krampus,
    "Loki": Character.loki,
    "Monk": Character.monk,
    "Moon Elf": Character.moonelf,
    "Ninja": Character.ninja,
    "Paladin": Character.paladin,
    "Psylocke": Character.psylocke,
    "Pyromancer": Character.pyromancer,
    "Rogue": Character.rogue,
    "Samurai": Character.samurai,
    "Santa": Character.santa,
    "Scarlet Witch": Character.scarletwitch,
    "Seraph": Character.seraph,
    "Shadow Thief": Character.shadowthief,
    "Spider-Man": Character.spiderman,
    "Storm": Character.storm,
    "Tactician": Character.tactician,
    "Thor": Character.thor,
    "Treant": Character.treant,
    "Vampire": Character.vampire,
    "Wolverine": Character.wolverine,
  };
}

extension CharacterStringExtension on Character {
  String get nameWithoutEnum {
    return toString().split('.').last;
  }
}

class HeroesData {
  HeroesData(
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

  factory HeroesData.fromMap(Map<String, dynamic> map) {
    return HeroesData(
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

  int get totalGamesPlayed => victories + defeats + draws;
}
