import 'package:flutter/material.dart';

import '../models/food.dart';
import '../models/food_log.dart';
import '../models/profile.dart';
import '../services/food_repository.dart';
import '../widgets/food_card.dart';
import 'food_detail_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final repo = FoodRepository();
  List<Food> foods = [];
  List<FoodLog> logs = [];
  Profile? profile;
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
      final results = await Future.wait([
        repo.getFoods(),
        repo.getTodayLogs(),
        repo.getProfile(),
      ], eagerError: true).timeout(const Duration(seconds: 15));
      foods = results[0] as List<Food>;
      logs = results[1] as List<FoodLog>;
      profile = results[2] as Profile?;
    } catch (error) {
      loadError = _formatError(error);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  String _formatError(Object error) {
    return error.toString();
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  Widget build(BuildContext context) {
    final calories = logs.fold<double>(0, (s, e) => s + e.calories * e.quantity);
    final protein = logs.fold<double>(0, (s, e) => s + e.protein * e.quantity);
    final goal = profile?.calorieGoal ?? 2000;
    final name = (profile?.fullName ?? 'Food lover').split(' ').first;

    return RefreshIndicator(
      onRefresh: load,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: const Color(0xFF0D1320),
            title: Text('$name 👋', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
            actions: [
              IconButton(
                tooltip: 'History',
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())),
                icon: const Icon(Icons.history),
              ),
            ],
          ),
          if (loading)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
          else if (loadError != null)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.cloud_off, size: 42),
                      const SizedBox(height: 12),
                      const Text('Could not load your diary.'),
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
              ),
            )
          else ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 18),
                child: Card(
                  color: const Color(0xFF182238),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Today's nutrition", style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 16),
                        LinearProgressIndicator(value: (calories / goal).clamp(0, 1).toDouble(), minHeight: 10),
                        const SizedBox(height: 10),
                        Text('${calories.round()} / $goal kcal'),
                        const SizedBox(height: 8),
                        Text('${protein.round()} g protein'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 12),
                child: Text('${foods.length} Best Food', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList.builder(
                itemCount: foods.length,
                itemBuilder: (_, i) => FoodCard(
                  food: foods[i],
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => FoodDetailScreen(food: foods[i])),
                  ).then((_) => load()),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
