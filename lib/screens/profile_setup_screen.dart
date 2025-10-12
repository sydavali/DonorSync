import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// ❗️ NEW: Import Firebase packages
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>(); // Key for form validation
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  String? _selectedBloodGroup;
  bool _isLoading = false; // To show a loading indicator

  final List<String> _bloodGroups = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
  ];

  // ❗️ NEW: The function to save data to Firestore
  Future<void> _saveProfile() async {
    // First, validate the form
    if (!_formKey.currentState!.validate()) {
      return; // If form is not valid, do nothing
    }

    setState(() {
      _isLoading = true; // Show loading spinner
    });

    try {
      // Get the current logged-in user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("No user logged in.");
      }

      // Create a reference to the user's document in the 'users' collection
      final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

      // Prepare the data to be saved
      final userData = {
        'uid': user.uid,
        'email': user.email,
        'name': _nameController.text.trim(),
        'age': int.tryParse(_ageController.text.trim()) ?? 0,
        'weight': int.tryParse(_weightController.text.trim()) ?? 0,
        'contactNumber': _contactController.text.trim(),
        'location': _locationController.text.trim(),
        'bloodGroup': _selectedBloodGroup,
        'isDonorAvailable': true, // Default value
        'lastDonationDate': null, // Default value
      };

      // Save the data
      await userDocRef.set(userData);

      // Show a success message and navigate back
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile saved successfully!")),
        );
        Navigator.of(context).pop(); // Go back to the home screen
      }
    } catch (e) {
      // Show an error message if something goes wrong
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to save profile: ${e.toString()}")),
        );
      }
    } finally {
      setState(() {
        _isLoading = false; // Hide loading spinner
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Complete Your Profile"),
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        // ❗️ NEW: Wrap with a Form widget
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ... all your TextFields and Dropdown remain the same ...
                // I will just show the changes for brevity, but use the full code
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: "Full Name", border: OutlineInputBorder(), prefixIcon: Icon(Icons.person)),
                  validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _ageController,
                  decoration: const InputDecoration(labelText: "Age", border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) => value!.isEmpty ? 'Please enter your age' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _weightController,
                  decoration: const InputDecoration(labelText: "Weight (in kg)", border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) => value!.isEmpty ? 'Please enter your weight' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _contactController,
                  decoration: const InputDecoration(labelText: "Contact Number", border: OutlineInputBorder(), prefixIcon: Icon(Icons.phone)),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) => value!.isEmpty ? 'Please enter your contact number' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(labelText: "City / Area", border: OutlineInputBorder(), prefixIcon: Icon(Icons.location_pin)),
                  validator: (value) => value!.isEmpty ? 'Please enter your location' : null,
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _selectedBloodGroup,
                  decoration: const InputDecoration(labelText: "Blood Group", border: OutlineInputBorder()),
                  hint: const Text("Select your blood group"),
                  items: _bloodGroups.map((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
                  onChanged: (newValue) => setState(() => _selectedBloodGroup = newValue),
                  validator: (value) => value == null ? 'Please select a blood group' : null,
                ),
                const SizedBox(height: 40),

                // ❗️ NEW: Updated button to handle loading state
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile, // Call the save function
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Save Profile", style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}