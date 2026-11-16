import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  print('Firebase initialized successfully!');
  print('Firebase Project: ${Firebase.app().options.projectId}');

  runApp(const CloudQuestApp());
}
