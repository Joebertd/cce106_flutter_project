class Profile {
  final String id;
  final String? fullName;
  final String? avatarPath;
  final int calorieGoal;
  final int proteinGoal;

  const Profile({
    required this.id,
    this.fullName,
    this.avatarPath,
    this.calorieGoal = 2000,
    this.proteinGoal = 100,
  });

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'].toString(),
      fullName: map['full_name'],
      avatarPath: map['avatar_path'],
      calorieGoal: (map['daily_calorie_goal'] ?? 2000) as int,
      proteinGoal: (map['daily_protein_goal'] ?? 100) as int,
    );
  }
}
