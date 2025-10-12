import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';
import 'profile_setup_screen.dart';
import 'requests_screen.dart';
import 'create_request_screen.dart';
import 'sent_requests_screen.dart';
import 'ai_assistant_screen.dart'; // ✅ Added import for AI Assistant screen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;

  Future<void> _handleRequestButton() async {
    setState(() => _isLoading = true);
    final user = FirebaseAuth.instance.currentUser!;
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    if (!mounted) return;

    if (doc.exists) {
      // Profile exists, so go to the broadcast form
      Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateRequestScreen()));
    } else {
      // Profile doesn't exist, go to setup
      Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileSetupScreen()));
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DonorSync Home'),
        backgroundColor: Colors.red,
        actions: [
          // ❗️ NEW: Button to open the AI Assistant
          IconButton(
            icon: const Icon(Icons.support_agent),
            tooltip: 'AI Assistant',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AiAssistantScreen()),
              );
            },
          ),
          // Existing buttons
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Sent Requests',
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const SentRequestsScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            tooltip: 'Request Pool',
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const RequestsScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton.icon(
                icon: _isLoading
                    ? Container()
                    : const Icon(Icons.bloodtype, size: 28),
                label: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Request Blood',
                    style: TextStyle(fontSize: 20)),
                onPressed: _isLoading ? null : _handleRequestButton,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.volunteer_activism, size: 28),
                label: const Text('Find Donors',
                    style: TextStyle(fontSize: 20)),
                onPressed: () {
                  // We can link this to the old donor list later
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
