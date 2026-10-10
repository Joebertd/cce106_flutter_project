import 'package:flutter/material.dart';

import '../models/food.dart';
import '../services/supabase_service.dart';

class FoodDetailScreen extends StatefulWidget {
  final Food food;
  const FoodDetailScreen({super.key, required this.food});

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  String meal = 'Meal';
  double quantity = 1;

  Future<void> log() async {
    try {
      await SupabaseService.client.from('food_logs').insert({
        'user_id': SupabaseService.client.auth.currentUser!.id,
        'food_id': widget.food.id,
        'quantity': quantity,
        'meal_type': meal,
        'eaten_at': DateTime.now().toIso8601String(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Food added to today\'s diary.')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not log food: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final image = widget.food.imagePath == null
        ? null
        : SupabaseService.publicImageUrl('food-images', widget.food.imagePath!);
    final localAsset = _localAssetFor(widget.food.name);

    return Scaffold(
      appBar: AppBar(title: const Text('Food Details')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: image == null
                ? Image.asset(localAsset, height: 240, fit: BoxFit.cover)
                : Image.network(image, height: 240, fit: BoxFit.cover),
          ),
          const SizedBox(height: 20),
          Text(widget.food.name, style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(widget.food.description, style: TextStyle(color: Colors.grey.shade400, fontSize: 17)),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            children: [
              Chip(label: Text('${widget.food.calories} kcal')),
              Chip(label: Text('${widget.food.protein} g protein')),
              Chip(label: Text('${widget.food.prepTime} min')),
            ],
          ),
          const SizedBox(height: 18),
          const Text('Ingredients', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ...widget.food.ingredients.map((e) => ListTile(leading: const Icon(Icons.check), title: Text(e))),
          const Text('Steps', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ...widget.food.steps.asMap().entries.map((e) => ListTile(leading: CircleAvatar(child: Text('${e.key + 1}')), title: Text(e.value))),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: meal,
            decoration: const InputDecoration(labelText: 'Meal type'),
            items: const ['Breakfast', 'Lunch', 'Dinner', 'Snack', 'Meal']
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (v) => setState(() => meal = v ?? 'Meal'),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Text('Quantity'),
              Expanded(
                child: Slider(
                  min: 0.5,
                  max: 5,
                  divisions: 9,
                  value: quantity,
                  label: quantity.toString(),
                  onChanged: (v) => setState(() => quantity = v),
                ),
              ),
              Text(quantity.toStringAsFixed(1)),
            ],
          ),
          FilledButton.icon(
            onPressed: log,
            icon: const Icon(Icons.add),
            label: const Text('Add to Diary'),
          ),
        ],
      ),
    );
  }
}


String _localAssetFor(String name) {
  final key = name.toLowerCase();
  if (key.contains('spaghetti')) return 'assets/images/spaghetti.png';
  if (key.contains('parmesan')) return 'assets/images/chicken.png';
  if (key.contains('caesar')) return 'assets/images/salad.png';
  if (key.contains('taco')) return 'assets/images/tacos.png';
  if (key.contains('alfredo')) return 'assets/images/alfredo.png';
  if (key.contains('pizza')) return 'assets/images/pizza.png';
  if (key.contains('hamburger')) return 'assets/images/burger.png';
  if (key.contains('cookie')) return 'assets/images/cookies.png';
  if (key.contains('fried rice')) return 'assets/images/rice.png';
  return 'assets/images/dish.png';
}
