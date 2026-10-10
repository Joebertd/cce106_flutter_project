import 'package:flutter/material.dart';

import '../models/food_log.dart';
import '../services/food_repository.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final repo = FoodRepository();
  late Future<List<FoodLog>> future;

  @override
  void initState() {
    super.initState();
    future = repo.getHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Food History')),
      body: FutureBuilder<List<FoodLog>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Could not load food history.'),
                    const SizedBox(height: 8),
                    SelectableText('${snapshot.error}', textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () => setState(() => future = repo.getHistory()),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            );
          }
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final logs = snapshot.data!;
          if (logs.isEmpty) return const Center(child: Text('No meals logged yet.'));
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: logs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final l = logs[i];
              return ListTile(
                tileColor: const Color(0xFF182238),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                title: Text(l.foodName),
                subtitle: Text('${l.mealType} • ${l.eatenAt.toLocal()}'),
                trailing: Text('${(l.calories * l.quantity).round()} kcal'),
              );
            },
          );
        },
      ),
    );
  }
}
