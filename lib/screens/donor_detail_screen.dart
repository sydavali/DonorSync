import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ❗️ CONVERTED to a StatefulWidget to handle loading state
class DonorDetailScreen extends StatefulWidget {
  final Map<String, dynamic> donorData;

  const DonorDetailScreen({super.key, required this.donorData});

  @override
  State<DonorDetailScreen> createState() => _DonorDetailScreenState();
}

class _DonorDetailScreenState extends State<DonorDetailScreen> {
  bool _isLoading = false;

  // ❗️ NEW: Function to create the blood request
  Future<void> _createBloodRequest() async {
    setState(() {
      _isLoading = true;
    });

    final requester = FirebaseAuth.instance.currentUser;
    if (requester == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You must be logged in to make a request.")),
      );
      return;
    }

    try {
      // Create a new document in the 'requests' collection
      await FirebaseFirestore.instance.collection('requests').add({
        'requesterId': requester.uid,
        'requesterName': requester.displayName ?? 'Anonymous Requester', // Fetches current user's name
        'donorId': widget.donorData['uid'],
        'donorName': widget.donorData['name'],
        'bloodGroup': widget.donorData['bloodGroup'],
        'status': 'pending', // Initial status
        'createdAt': Timestamp.now(), // Current server time
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text("Blood request sent successfully!"),
          ),
        );
        // Go back to the donor list after making a request
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to send request: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.donorData['name'] ?? 'Donor Details'),
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // All the info cards remain the same...
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        child: Text(
                          widget.donorData['bloodGroup'] ?? 'N/A',
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.donorData['name'] ?? 'Not Provided',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildInfoCard(
              title: 'Personal Information',
              details: {
                'Age': widget.donorData['age']?.toString() ?? 'Not Provided',
                'Weight': "${widget.donorData['weight']?.toString() ?? 'N/A'} kg",
              },
            ),
            _buildInfoCard(
              title: 'Contact & Location',
              details: {
                'Contact': widget.donorData['contactNumber'] ?? 'Not Provided',
                'Location': widget.donorData['location'] ?? 'Not Provided',
              },
            ),
          ],
        ),
      ),
      // ❗️ NEW: A bottom navigation bar for the action button
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          icon: _isLoading ? Container() : const Icon(Icons.bloodtype_outlined),
          label: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text("Request Blood", style: TextStyle(fontSize: 18)),
          onPressed: _isLoading ? null : _createBloodRequest,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }

  // Helper widget remains the same
  Widget _buildInfoCard({required String title, required Map<String, String> details}) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            const Divider(height: 20, thickness: 1),
            ...details.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w500)),
                  Text(entry.value),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}