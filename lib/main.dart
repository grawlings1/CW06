import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cw06/login_screen.dart';
import 'package:cw06/task_list_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(CW06());
}

class CW06 extends StatelessWidget {
  const CW06({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CW06 Task Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;
          return user == null ? LoginScreen() : TaskListScreen();
        }
        return Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
