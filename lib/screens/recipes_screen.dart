import 'package:flutter/material.dart';

import '../models/food.dart';
import '../services/food_repository.dart';
import '../widgets/food_card.dart';
import 'add_food_screen.dart';
import 'food_detail_screen.dart';

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  final repo = FoodRepository();
  List<Food> foods = [];
  bool loading = true;
  Object? loadError;

  Future<void> load() async {
    if (mounted) {
      setState(() {
        loading = true;
        loadError = null;
      });
    }
    try {
      foods = await repo.getFoods();
    } catch (error) {
      loadError = error;
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recipes')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddFoodScreen()),
        ).then((_) => load()),
        icon: const Icon(Icons.add),
        label: const Text('Add Food'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : loadError != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.cloud_off, size: 42),
                        const SizedBox(height: 12),
                        const Text('Could not load recipes.'),
                        const SizedBox(height: 8),
                        SelectableText('$loadError', textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: load,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Try again'),
                        ),
                      ],
                    ),
                  ),
                )
              : foods.isEmpty
                  ? const Center(child: Text('No foods found. Pull down to refresh.'))
          : RefreshIndicator(
              onRefresh: load,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: foods.length,
                itemBuilder: (_, i) => FoodCard(
                  food: foods[i],
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => FoodDetailScreen(food: foods[i])),
                  ),
                ),
              ),
            ),
    );
  }
}
