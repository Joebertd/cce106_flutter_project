import 'package:flutter/material.dart';

import '../models/food.dart';
import '../services/supabase_service.dart';

class FoodCard extends StatelessWidget {
  final Food food;
  final VoidCallback onTap;

  const FoodCard({super.key, required this.food, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final image = food.imagePath == null
        ? null
        : SupabaseService.publicImageUrl('food-images', food.imagePath!);
    final localAsset = _localAssetFor(food.name);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF182238),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            ClipOval(
              child: image == null
                  ? Image.asset(
                      localAsset,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    )
                  : Image.network(
                      image,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Image.asset(
                        localAsset,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${food.calories}cal   ${food.protein}protein',
                    style: const TextStyle(color: Color(0xFFFFE49A), fontSize: 16),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    food.name,
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    food.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 15, height: 1.35),
                  ),
                ],
              ),
            ),
          ],
        ),
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
