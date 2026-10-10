import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/profile.dart';
import '../services/food_repository.dart';
import '../services/supabase_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final repo = FoodRepository();
  final name = TextEditingController();
  final calories = TextEditingController();
  final protein = TextEditingController();
  Uint8List? avatarBytes;
  String? avatarType;
  Profile? profile;
  bool loading = true;
  bool saving = false;
  Object? loadError;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    if (mounted) {
      setState(() {
        loading = true;
        loadError = null;
      });
    }
    try {
      profile = await repo.getProfile();
      name.text = profile?.fullName ?? '';
      calories.text = '${profile?.calorieGoal ?? 2000}';
      protein.text = '${profile?.proteinGoal ?? 100}';
    } catch (error) {
      loadError = error;
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> pickAvatar() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;
    avatarBytes = await picked.readAsBytes();
    avatarType = picked.mimeType ?? 'image/jpeg';
    setState(() {});
  }

  Future<void> save() async {
    setState(() => saving = true);
    try {
      String? path;
      if (avatarBytes != null) {
        path = await SupabaseService.uploadImage(
          bucket: 'avatars',
          bytes: avatarBytes!,
          contentType: avatarType!,
        );
      }
      await repo.updateProfile(
        fullName: name.text,
        calorieGoal: int.tryParse(calories.text) ?? 2000,
        proteinGoal: int.tryParse(protein.text) ?? 100,
        avatarPath: path,
      );
      await load();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated.')));
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile update failed: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  void dispose() {
    name.dispose();
    calories.dispose();
    protein.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Could not load profile settings.'),
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
      );
    }

    final avatarUrl = profile?.avatarPath == null
        ? null
        : SupabaseService.publicImageUrl('avatars', profile!.avatarPath!);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: GestureDetector(
              onTap: pickAvatar,
              child: CircleAvatar(
                radius: 64,
                backgroundImage: avatarBytes != null
                    ? MemoryImage(avatarBytes!)
                    : avatarUrl != null
                        ? NetworkImage(avatarUrl)
                        : const AssetImage('assets/images/profile_image.png') as ImageProvider,
                child: const Align(
                  alignment: Alignment.bottomRight,
                  child: CircleAvatar(radius: 20, child: Icon(Icons.edit, size: 18)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          TextField(controller: name, decoration: const InputDecoration(labelText: 'Full name')),
          const SizedBox(height: 16),
          TextField(controller: calories, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Daily calorie goal')),
          const SizedBox(height: 16),
          TextField(controller: protein, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Daily protein goal (g)')),
          const SizedBox(height: 24),
          FilledButton(onPressed: saving ? null : save, child: saving ? const CircularProgressIndicator() : const Text('Save Profile')),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => SupabaseService.signOut(),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
