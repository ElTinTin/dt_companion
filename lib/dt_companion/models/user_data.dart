class UserData {
  UserData({
        this.name = '',
      });

  String name;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
    };
  }

  factory UserData.fromMap(Map<String, dynamic> map) {
    return UserData(
      name: map['name'] ?? '',
    );
  }
}
