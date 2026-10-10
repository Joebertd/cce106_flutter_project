class FoodLog {
  final String id;
  final String foodId;
  final String foodName;
  final int calories;
  final int protein;
  final double quantity;
  final String mealType;
  final DateTime eatenAt;

  const FoodLog({
    required this.id,
    required this.foodId,
    required this.foodName,
    required this.calories,
    required this.protein,
    required this.quantity,
    required this.mealType,
    required this.eatenAt,
  });

  factory FoodLog.fromMap(Map<String, dynamic> map) {
    final food = map['foods'] is Map<String, dynamic>
        ? map['foods'] as Map<String, dynamic>
        : <String, dynamic>{};
    return FoodLog(
      id: map['id'].toString(),
      foodId: map['food_id'].toString(),
      foodName: food['name'] ?? 'Food',
      calories: (food['calories'] ?? 0) as int,
      protein: (food['protein'] ?? 0) as int,
      quantity: ((map['quantity'] ?? 1) as num).toDouble(),
      mealType: map['meal_type'] ?? 'Meal',
      eatenAt: DateTime.parse(map['eaten_at'].toString()),
    );
  }
}
