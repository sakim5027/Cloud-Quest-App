import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'screens/sign_in_screen.dart';
import 'screens/challenge_screen.dart';
import 'services/reward_service.dart';

class CloudQuestApp extends StatelessWidget {
  const CloudQuestApp({super.key});

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
                  key: ValueKey(user.uid),
                  user: user,
                  onComplete: () async {
                    try {
                      final result = await completeChallenge();

                      debugPrint('Reward result: $result');
                    } catch (e) {
                      debugPrint('Reward error: $e');
                    }
                  },
                );
        },
      ),
    );
  }
}
