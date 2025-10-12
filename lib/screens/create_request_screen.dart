import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateRequestScreen extends StatefulWidget {
  const CreateRequestScreen({super.key});

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hospitalController = TextEditingController();
  final _unitsController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final currentUser = FirebaseAuth.instance.currentUser!;

    try {
      // Get the requester's own profile to find their blood group and name
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
      if (!userDoc.exists) {
        throw Exception("Your profile is not complete.");
      }
      final userData = userDoc.data()!;

      // Create ONE central request document
      await FirebaseFirestore.instance.collection('requests').add({
        'requesterId': currentUser.uid,
        'requesterName': userData['name'],
        'bloodGroup': userData['bloodGroup'],
        'location': userData['location'],
        'hospital': _hospitalController.text.trim(),
        'unitsNeeded': int.tryParse(_unitsController.text.trim()) ?? 1,
        'notes': _notesController.text.trim(),
        'status': 'pending', // IMPORTANT: No donorId yet
        'createdAt': FieldValue.serverTimestamp(),
        'donorId': null, // IMPORTANT
        'donorName': null,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(backgroundColor: Colors.green, content: Text("Your request has been broadcasted!")),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to create request: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Blood Request"), backgroundColor: Colors.red),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _hospitalController,
                decoration: const InputDecoration(labelText: "Hospital Name", border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Please enter hospital name' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _unitsController,
                decoration: const InputDecoration(labelText: "Blood Units Needed", border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Please enter number of units' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: "Additional Notes (Optional)", border: OutlineInputBorder()),
                maxLines: 3,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Broadcast Request", style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}