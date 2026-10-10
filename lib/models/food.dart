class Food {
  final String id;
  final String name;
  final String description;
  final String? imagePath;
  final int calories;
  final int protein;
  final int prepTime;
  final List<String> ingredients;
  final List<String> steps;

  const Food({
    required this.id,
    required this.name,
    required this.description,
    this.imagePath,
    required this.calories,
    required this.protein,
    required this.prepTime,
    required this.ingredients,
    required this.steps,
  });

  factory Food.fromMap(Map<String, dynamic> map) {
    return Food(
      id: map['id'].toString(),
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      imagePath: map['image_path'],
      calories: (map['calories'] ?? 0) as int,
      protein: (map['protein'] ?? 0) as int,
      prepTime: (map['prep_time'] ?? 0) as int,
      ingredients: List<String>.from(map['ingredients'] ?? const []),
      steps: List<String>.from(map['steps'] ?? const []),
    );
  }
}
