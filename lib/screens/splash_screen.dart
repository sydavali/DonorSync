// Step 1: All imports go at the VERY TOP of the file.
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';
import 'login_screen.dart';

// Step 2: Define the main widget class.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

// Step 3: Define the state class that holds all the logic.
class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate(); // Start the navigation logic when the screen loads.
  }

  // This function waits 2 seconds, then checks if the user is logged in.
  Future<void> _navigate() async {
    // Wait for 2 seconds to show the splash screen.
    await Future.delayed(const Duration(seconds: 2));

    // Check if a user is currently signed in with Firebase.
    final user = FirebaseAuth.instance.currentUser;

    // This makes sure we don't try to navigate if the screen is already gone.
    if (!mounted) return;

    if (user != null) {
      // If user exists, go to the HomeScreen.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      // If no user, go to the LoginScreen.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  // This builds the UI of your splash screen.
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bloodtype, size: 80, color: Colors.red),
            SizedBox(height: 20),
            Text(
              "DonorSync",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            SizedBox(height: 12),
            CircularProgressIndicator(color: Colors.red),
          ],
        ),
      ),
    );
  }
}