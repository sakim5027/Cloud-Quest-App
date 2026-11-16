import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/auth_service.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  String errorMessage = '';

  Future<void> _signIn() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      await signIn(emailController.text.trim(), passwordController.text);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Sign in failed: ${e.code}';
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _register() async {
    String email = emailController.text.trim();
    String password = passwordController.text;

    // Check email
    if (email.isEmpty || !email.contains('@')) {
      setState(() {
        errorMessage = 'Please enter a valid email.';
      });
      return;
    }

    // Check password
    if (password.length < 6) {
      setState(() {
        errorMessage = 'Password must be at least 6 characters.';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      await register(email, password);
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Error: $e');

      if (!mounted) return;
      setState(() {
        errorMessage = 'Registration failed: ${e.code}';
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cloud Quest')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Welcome to Cloud Quest!',
              style: TextStyle(fontSize: 24),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),

            const SizedBox(height: 20),

            if (errorMessage.isNotEmpty)
              Text(errorMessage, style: const TextStyle(color: Colors.red)),

            ElevatedButton(
              onPressed: isLoading ? null : _signIn,
              child: const Text('Sign In'),
            ),

            ElevatedButton(
              onPressed: isLoading ? null : _register,
              child: const Text('Create Account'),
            ),

            if (isLoading) const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}
