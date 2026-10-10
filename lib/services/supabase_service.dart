import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

SupabaseClient get supabase => Supabase.instance.client;

class SupabaseService {
  static SupabaseClient get client => supabase;

  static Future<bool> signInWithGoogle() {
    return supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'com.example.food_diary://auth/callback',
    );
  }

  static Future<String> uploadImage({
    required String bucket,
    required Uint8List bytes,
    required String contentType,
  }) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('Sign in before uploading an image.');
    }

    if (!contentType.toLowerCase().startsWith('image/')) {
      throw ArgumentError.value(contentType, 'contentType', 'Must be an image MIME type.');
    }

    final subtype = contentType.toLowerCase().split('/').last;
    final extension = switch (subtype) {
      'jpeg' || 'jpg' => 'jpg',
      'png' => 'png',
      'webp' => 'webp',
      'gif' => 'gif',
      'heic' => 'heic',
      'heif' => 'heif',
      _ => throw ArgumentError.value(contentType, 'contentType', 'Unsupported image type.'),
    };
    final path = '$userId/${DateTime.now().microsecondsSinceEpoch}.$extension';

    await supabase.storage.from(bucket).uploadBinary(
      path,
      bytes,
      fileOptions: FileOptions(
        contentType: contentType,
        cacheControl: '3600',
        upsert: false,
      ),
    );
    return path;
  }

  static String publicImageUrl(String bucket, String path) {
    return supabase.storage.from(bucket).getPublicUrl(path);
  }

  static Future<void> signOut() => supabase.auth.signOut();
}
