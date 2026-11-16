import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'screens/sign_in_screen.dart';
import 'screens/challenge_screen.dart';
import 'services/reward_service.dart';

class CloudQuestApp extends StatefulWidget {
  const CloudQuestApp({super.key});

  @override
  State<CloudQuestApp> createState() => _CloudQuestAppState();
}

class _CloudQuestAppState extends State<CloudQuestApp> {
  int refreshCount = 0;
  bool isCompleting = false;

  Future<void> _completeChallenge() async {
    if (isCompleting) return;

    setState(() {
      isCompleting = true;
    });

    try {
      final result = await completeChallenge();
      debugPrint('Reward result: $result');

      if (!mounted) return;

      setState(() {
        refreshCount++;
      });
    } catch (e) {
      debugPrint('Reward error: $e');
    } finally {
      if (mounted) {
        setState(() {
          isCompleting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cloud Quest',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError) {
            return const Scaffold(
              body: Center(child: Text('Unable to check sign-in status.')),
            );
          }

          final user = snapshot.data;

          return user == null
              ? const SignInScreen()
              : ChallengeScreen(
                  key: ValueKey('${user.uid}_$refreshCount'),
                  user: user,
                  onComplete: _completeChallenge,
                  isCompleting: isCompleting,
                );
        },
      ),
    );
  }
}
