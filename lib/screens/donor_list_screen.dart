// ❗️ FIX: Corrected import order for best practice
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'donor_detail_screen.dart'; // Import the new detail screen

class DonorListScreen extends StatefulWidget {
  const DonorListScreen({super.key});

  @override
  State<DonorListScreen> createState() => _DonorListScreenState();
}

class _DonorListScreenState extends State<DonorListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toUpperCase().trim();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Available Donors"),
        backgroundColor: Colors.red,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by Blood Group (e.g., O+)',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toUpperCase().trim();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _searchQuery.isEmpty
                  ? FirebaseFirestore.instance.collection('users').snapshots()
                  : FirebaseFirestore.instance
                  .collection('users')
                  .where('bloodGroup', isGreaterThanOrEqualTo: _searchQuery)
                  .where('bloodGroup', isLessThanOrEqualTo: '$_searchQuery\uf8ff')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No donors found."));
                }

                final donors = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: donors.length,
                  itemBuilder: (context, index) {
                    final donorData = donors[index].data() as Map<String, dynamic>;
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          child: Text(
                            donorData['bloodGroup'] ?? 'N/A',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(donorData['name'] ?? 'No Name'),
                        subtitle: Text(donorData['location'] ?? 'No Location'),
                        trailing: const Icon(Icons.chevron_right),
                        // ❗️ FIX: Added navigation logic to the onTap function
                        onTap: () {
                          // Navigate to the detail screen, passing the donor's data
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DonorDetailScreen(donorData: donorData),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}