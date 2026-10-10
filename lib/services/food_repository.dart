import '../models/food.dart';
import '../models/food_log.dart';
import '../models/profile.dart';
import 'supabase_service.dart';

class FoodRepository {
  Future<List<Food>> getFoods() async {
    final rows = await supabase
        .from('foods')
        .select()
        .order('created_at', ascending: true);
    return rows.map<Food>((e) => Food.fromMap(e)).toList();
  }

  Future<Food> addFood({
    required String name,
    required String description,
    required int calories,
    required int protein,
    required int prepTime,
    required List<String> ingredients,
    required List<String> steps,
    String? imagePath,
  }) async {
    final userId = supabase.auth.currentUser?.id;
    final row = await supabase.from('foods').insert({
      'name': name,
      'description': description,
      'calories': calories,
      'protein': protein,
      'prep_time': prepTime,
      'ingredients': ingredients,
      'steps': steps,
      'image_path': imagePath,
      'created_by': userId,
    }).select().single();
    return Food.fromMap(row);
  }

  Future<void> logFood({
    required String foodId,
    required double quantity,
    required String mealType,
    DateTime? eatenAt,
  }) async {
    await supabase.from('food_logs').insert({
      'food_id': foodId,
      'user_id': supabase.auth.currentUser!.id,
      'quantity': quantity,
      'meal_type': mealType,
      'eaten_at': (eatenAt ?? DateTime.now()).toIso8601String(),
    });
  }

  Future<List<FoodLog>> getTodayLogs() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));

    final rows = await supabase
        .from('food_logs')
        .select('id, food_id, quantity, meal_type, eaten_at, foods(name, calories, protein)')
        .eq('user_id', supabase.auth.currentUser!.id)
        .gte('eaten_at', start.toIso8601String())
        .lt('eaten_at', end.toIso8601String())
        .order('eaten_at', ascending: false);

    return rows.map<FoodLog>((e) => FoodLog.fromMap(e)).toList();
  }

  Future<List<FoodLog>> getHistory() async {
    final rows = await supabase
        .from('food_logs')
        .select('id, food_id, quantity, meal_type, eaten_at, foods(name, calories, protein)')
        .eq('user_id', supabase.auth.currentUser!.id)
        .order('eaten_at', ascending: false)
        .limit(100);
    return rows.map<FoodLog>((e) => FoodLog.fromMap(e)).toList();
  }

  Future<Profile?> getProfile() async {
    final id = supabase.auth.currentUser?.id;
    if (id == null) return null;

    final row = await supabase.from('profiles').select().eq('id', id).maybeSingle();
    if (row != null) return Profile.fromMap(row);

    final created = await supabase.from('profiles').insert({
      'id': id,
      'full_name': supabase.auth.currentUser!.userMetadata?['full_name'] ?? '',
      'daily_calorie_goal': 2000,
      'daily_protein_goal': 100,
    }).select().single();
    return Profile.fromMap(created);
  }

  Future<void> updateProfile({
    required String fullName,
    required int calorieGoal,
    required int proteinGoal,
    String? avatarPath,
  }) async {
    final values = <String, dynamic>{
      'full_name': fullName.trim(),
      'daily_calorie_goal': calorieGoal,
      'daily_protein_goal': proteinGoal,
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (avatarPath != null) values['avatar_path'] = avatarPath;

    await supabase.from('profiles').update(values).eq(
          'id',
          supabase.auth.currentUser!.id,
        );
  }
}
