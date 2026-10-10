import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/food_repository.dart';
import '../services/supabase_service.dart';

class AddFoodScreen extends StatefulWidget {
  const AddFoodScreen({super.key});

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  final repo = FoodRepository();
  final name = TextEditingController();
  final description = TextEditingController();
  final calories = TextEditingController();
  final protein = TextEditingController();
  final prepTime = TextEditingController();
  final ingredients = TextEditingController();
  final steps = TextEditingController();

  Uint8List? imageBytes;
  String? imageType;
  bool busy = false;

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;
    imageBytes = await picked.readAsBytes();
    imageType = picked.mimeType ?? 'image/jpeg';
    setState(() {});
  }

  Future<void> save() async {
    if (name.text.trim().isEmpty) return;
    setState(() => busy = true);
    try {
      String? path;
      if (imageBytes != null) {
        path = await SupabaseService.uploadImage(
          bucket: 'food-images',
          bytes: imageBytes!,
          contentType: imageType!,
        );
      }

      await repo.addFood(
        name: name.text.trim(),
        description: description.text.trim(),
        calories: int.tryParse(calories.text) ?? 0,
        protein: int.tryParse(protein.text) ?? 0,
        prepTime: int.tryParse(prepTime.text) ?? 0,
        ingredients: ingredients.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        steps: steps.text.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        imagePath: path,
      );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Save failed: $e')));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  void dispose() {
    for (final c in [name, description, calories, protein, prepTime, ingredients, steps]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Food')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          GestureDetector(
            onTap: pickImage,
            child: Container(
              height: 190,
              decoration: BoxDecoration(
                color: const Color(0xFF182238),
                borderRadius: BorderRadius.circular(28),
              ),
              alignment: Alignment.center,
              child: imageBytes == null
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Icon(Icons.add_photo_alternate, size: 50), SizedBox(height: 8), Text('Add food image')],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Image.memory(imageBytes!, width: double.infinity, height: 190, fit: BoxFit.cover),
                    ),
            ),
          ),
          const SizedBox(height: 20),
          TextField(controller: name, decoration: const InputDecoration(hintText: 'Food name')),
          const SizedBox(height: 14),
          TextField(controller: description, decoration: const InputDecoration(hintText: 'Description')),
          const SizedBox(height: 14),
          TextField(controller: calories, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'Calories')),
          const SizedBox(height: 14),
          TextField(controller: protein, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'Protein (g)')),
          const SizedBox(height: 14),
          TextField(controller: prepTime, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'Prep time (minutes)')),
          const SizedBox(height: 14),
          TextField(controller: ingredients, decoration: const InputDecoration(hintText: 'Ingredients, comma separated')),
          const SizedBox(height: 14),
          TextField(controller: steps, maxLines: 5, decoration: const InputDecoration(hintText: 'Steps, one per line')),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: busy ? null : save,
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(58)),
            child: busy ? const CircularProgressIndicator() : const Text('Add Food'),
          ),
        ],
      ),
    );
  }
}
