import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/challenge_service.dart';
import '../services/coach_service.dart';

class ChallengeScreen extends StatefulWidget {
  const ChallengeScreen({
    super.key,
    required this.user,
    required this.onComplete,
    this.isCompleting = false,
  });

  final User user;
  final VoidCallback onComplete;
  final bool isCompleting;

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  final questionController = TextEditingController();

  bool isLoading = false;
  String coachReply = '';

  // Ask the Quest Coach for a hint
  Future<void> _getHint() async {
    if (questionController.text.trim().isEmpty) {
      setState(() {
        coachReply = 'Please enter a question.';
      });
      return;
    }

    setState(() {
      isLoading = true;
      coachReply = '';
    });

    try {
      final reply = await getQuestHint(questionController.text);

      if (!mounted) return;

      setState(() {
        coachReply = reply;
      });
    } on FirebaseFunctionsException catch (error) {
      debugPrint('Quest Coach request failed: ${error.code}');

      if (!mounted) return;

      setState(() {
        coachReply = 'The coach is unavailable. Try again.';
      });
    } catch (error) {
      debugPrint('Quest Coach error: $error');

      if (!mounted) return;

      setState(() {
        coachReply = 'Something went wrong. Try again.';
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
    questionController.dispose();
    super.dispose();
  }

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
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Unable to load challenge.'));
          }

          final data = snapshot.data!;

          final challenge = data['challenge'] as Map<String, dynamic>?;

          final progress = data['progress'] as Map<String, dynamic>?;

          if (challenge == null) {
            return const Center(
              child: Text("Today's challenge is not available."),
            );
          }

          final title = challenge['title'] ?? '';
          final prompt = challenge['prompt'] ?? '';

          final completed = progress?['completed'] == true;
          final points = progress?['points'] ?? 0;
          final badge = progress?['badgeId'] ?? 'None';

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Signed in as ${widget.user.email ?? widget.user.uid}'),

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

              // Complete challenge button
              FilledButton(
                onPressed: completed || widget.isCompleting
                    ? null
                    : widget.onComplete,
                child: Text(
                  completed
                      ? 'Completed!'
                      : widget.isCompleting
                      ? 'Completing...'
                      : 'Complete challenge',
                ),
              ),

              const SizedBox(height: 20),

              // Quest Coach question
              TextField(
                controller: questionController,
                maxLength: 300,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Ask the Quest Coach for a hint',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 10),

              // Get hint button
              OutlinedButton(
                onPressed: isLoading ? null : _getHint,
                child: Text(isLoading ? 'Thinking...' : 'Get hint'),
              ),

              const SizedBox(height: 16),

              // Display the AI response
              if (coachReply.isNotEmpty)
                Text(coachReply, style: const TextStyle(fontSize: 16)),
            ],
          );
        },
      ),
    ),
  );
}
