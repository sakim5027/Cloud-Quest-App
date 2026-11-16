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

  // Handle sign-in or registration
  Future<void> submit(bool isRegister) async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    // Basic input validation
    if (email.isEmpty || !email.contains('@')) {
      setState(() {
        errorMessage = 'Please enter a valid email.';
      });
      return;
    }

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
      if (isRegister) {
        await register(email, password);
      } else {
        await signIn(email, password);
      }
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;

      setState(() {
        if (error.code == 'email-already-in-use') {
          errorMessage = 'This email is already registered.';
        } else if (error.code == 'weak-password') {
          errorMessage = 'Please choose a stronger password.';
        } else if (error.code == 'invalid-email') {
          errorMessage = 'Please enter a valid email.';
        } else {
          errorMessage =
              'Unable to authenticate. Please check your information.';
        }
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage = 'Something went wrong. Please try again.';
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
      appBar: AppBar(title: const Text('Cloud Quest - Sign In')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 30),

            const Icon(Icons.school, size: 70, color: Colors.deepPurple),

            const SizedBox(height: 20),

            const Text(
              'Welcome to Cloud Quest!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 30),

            // Email input
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // Password input
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // Display authentication errors
            if (errorMessage.isNotEmpty)
              Text(errorMessage, style: const TextStyle(color: Colors.red)),

            const SizedBox(height: 16),

            // Sign-in button
            ElevatedButton(
              onPressed: isLoading ? null : () => submit(false),
              child: const Text('Sign In'),
            ),

            const SizedBox(height: 10),

            // Registration button
            OutlinedButton(
              onPressed: isLoading ? null : () => submit(true),
              child: const Text('Create Account'),
            ),

            if (isLoading) const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}
