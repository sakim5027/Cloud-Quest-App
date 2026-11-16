import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/auth_service.dart';

class ChallengeScreen extends StatelessWidget {
  const ChallengeScreen({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Signed in as ${user.email ?? user.uid}'),

            const SizedBox(height: 20),

            const Text(
              "Today's Challenge",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            const Text('Challenge will load from Firestore.'),

            const SizedBox(height: 20),

            const Text('Points: 0'),

            const Text('Badge: Not earned yet'),
          ],
        ),
      ),
    );
  }
}
