import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SentRequestsScreen extends StatelessWidget {
  const SentRequestsScreen({super.key});

  // Helper to get a status-specific color and icon
  Widget _getStatusIcon(String status) {
    switch (status) {
      case 'accepted':
        return const Icon(Icons.check_circle, color: Colors.green);
      case 'denied':
        return const Icon(Icons.cancel, color: Colors.red);
      default: // pending
        return const Icon(Icons.hourglass_top, color: Colors.orange);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text("Please log in.")));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Sent Requests"),
        backgroundColor: Colors.red,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // This is the key: we filter where 'requesterId' matches our ID
        stream: FirebaseFirestore.instance
            .collection('requests')
            .where('requesterId', isEqualTo: currentUser.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong!"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("You have not sent any blood requests."),
            );
          }

          final requests = snapshot.data!.docs;

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final requestData = requests[index].data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: ListTile(
                  leading: _getStatusIcon(requestData['status'] ?? 'pending'),
                  title: Text(
                    // Show "Waiting for a donor" if no one has accepted yet
                    "Request to: ${requestData['donorName'] ?? 'Waiting for a donor'}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("Status: ${(requestData['status'] ?? 'pending').toUpperCase()}"),
                  trailing: Text(
                    "Blood Group: ${requestData['bloodGroup']}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}