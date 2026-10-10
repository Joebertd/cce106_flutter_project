import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  bool busy = false;

  Future<void> signup() async {
    if (email.text.trim().isEmpty || password.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Use a valid email and a password of at least 6 characters.')),
      );
      return;
    }
    setState(() => busy = true);
    try {
      final res = await Supabase.instance.client.auth.signUp(
        email: email.text.trim(),
        password: password.text,
        data: {'full_name': name.text.trim()},
      );
      if (mounted) {
        final message = res.session == null
            ? 'Account created. Check your email to confirm the account.'
            : 'Account created successfully.';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
        if (res.session != null) Navigator.pop(context);
      }
    } on AuthException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.all(28),
            children: [
              const Text('Sign Up', style: TextStyle(fontSize: 40, fontWeight: FontWeight.w800)),
              const SizedBox(height: 24),
              TextField(controller: name, decoration: const InputDecoration(hintText: 'Full name')),
              const SizedBox(height: 16),
              TextField(controller: email, decoration: const InputDecoration(hintText: 'Email')),
              const SizedBox(height: 16),
              TextField(controller: password, obscureText: true, decoration: const InputDecoration(hintText: 'Password')),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: busy ? null : signup,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF9C0CC2),
                  minimumSize: const Size.fromHeight(60),
                  shape: const StadiumBorder(),
                ),
                child: busy ? const CircularProgressIndicator() : const Text('Create Account', style: TextStyle(fontSize: 20)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
