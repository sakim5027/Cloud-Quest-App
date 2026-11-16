import 'package:firebase_auth/firebase_auth.dart';

final auth = FirebaseAuth.instance;

// Register a new user
Future<UserCredential> register(String email, String password) =>
    auth.createUserWithEmailAndPassword(email: email, password: password);

// Sign in an existing user
Future<UserCredential> signIn(String email, String password) =>
    auth.signInWithEmailAndPassword(email: email, password: password);

// Sign out
Future<void> logOut() => auth.signOut();
