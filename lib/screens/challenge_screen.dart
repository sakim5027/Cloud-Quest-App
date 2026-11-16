import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/challenge_service.dart';

class ChallengeScreen extends StatelessWidget {
  const ChallengeScreen({
    super.key,
    required this.user,
    required this.onComplete,
  });

  final User user;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Cloud Quest'),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () async {
            await logOut();
          },
        ),
      ],
    ),

    body: SafeArea(
      child: FutureBuilder<Map<String, Object?>>(
        future: loadToday(),
        builder: (context, snapshot) {
          // While loading Firestore data
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // If Firestore returns an error
          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading challenge: ${snapshot.error}'),
            );
          }

          // Get challenge and progress
          final data = snapshot.data!;

          final challenge = data['challenge'] as Map<String, dynamic>?;

          final progress = data['progress'] as Map<String, dynamic>?;

          // If today's challenge does not exist
          if (challenge == null) {
            return const Center(
              child: Text("Today's challenge is not available."),
            );
          }

          // Get challenge information
          final title = challenge['title'] ?? '';
          final prompt = challenge['prompt'] ?? '';

          // Get learner progress
          final completed = progress?['completed'] == true;
          final points = progress?['points'] ?? 0;
          final badge = progress?['badgeId'] ?? 'None';

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Signed in as ${user.email ?? user.uid}'),

              const SizedBox(height: 20),

              Text(
                "Today's challenge",
                style: Theme.of(context).textTheme.headlineSmall,
              ),

              const SizedBox(height: 16),

              Text(
                '$title',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text('$prompt'),

              const SizedBox(height: 20),

              Text('Points: $points'),
              Text('Badge: $badge'),

              const SizedBox(height: 16),

              FilledButton(
                onPressed: completed ? null : onComplete,
                child: Text(completed ? 'Completed!' : 'Complete challenge'),
              ),

              const SizedBox(height: 20),

              const TextField(
                maxLength: 300,
                decoration: InputDecoration(
                  labelText: 'Ask the Quest Coach for a hint',
                ),
              ),

              OutlinedButton(onPressed: () {}, child: const Text('Get hint')),
            ],
          );
        },
      ),
    ),
  );
}
