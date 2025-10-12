import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'eligibility_form_screen.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {

  Future<void> _acceptRequest(String requestId) async {
    final donor = FirebaseAuth.instance.currentUser!;
    final donorDoc = await FirebaseFirestore.instance.collection('users').doc(donor.uid).get();

    // Update the request with the donor's info to "lock" it
    await FirebaseFirestore.instance.collection('requests').doc(requestId).update({
      'status': 'accepted',
      'donorId': donor.uid,
      'donorName': donorDoc.data()!['name'],
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(backgroundColor: Colors.green, content: Text("Request accepted! The requester has been notified.")),
      );
    }
  }

  // FutureBuilder fetches the current donor's profile just once
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      appBar: AppBar(title: const Text("Available Requests"), backgroundColor: Colors.red),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get(),
        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData) return const Center(child: CircularProgressIndicator());

          final donorBloodGroup = userSnapshot.data!['bloodGroup'];

          // StreamBuilder listens for matching requests in real-time
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('requests')
                .where('status', isEqualTo: 'pending')
                .where('bloodGroup', isEqualTo: donorBloodGroup)
                .snapshots(),
            builder: (context, requestSnapshot) {
              if (requestSnapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              if (!requestSnapshot.hasData || requestSnapshot.data!.docs.isEmpty) {
                return const Center(child: Text("No pending requests for your blood group."));
              }

              final requests = requestSnapshot.data!.docs;
              return ListView.builder(
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final requestData = requests[index].data() as Map<String, dynamic>;
                  final requestId = requests[index].id;

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Request from: ${requestData['requesterName']}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text("Location: ${requestData['location']}"),
                          Text("Hospital: ${requestData['hospital']}"),
                          const Divider(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                child: const Text("Accept"),
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(
                                    builder: (context) => EligibilityFormScreen(
                                      onEligible: () {
                                        _acceptRequest(requestId);
                                        Navigator.of(context).pop(); // Close the form
                                      },
                                    ),
                                  ));
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}