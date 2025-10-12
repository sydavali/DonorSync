import 'package:flutter/material.dart';

class RequestBloodScreen extends StatelessWidget {
  final TextEditingController patientNameController = TextEditingController();
  final TextEditingController bloodGroupController = TextEditingController();
  final TextEditingController contactController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Request Blood')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: patientNameController,
                  decoration: InputDecoration(labelText: 'Patient Name'),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: bloodGroupController,
                  decoration: InputDecoration(labelText: 'Blood Group Needed'),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: contactController,
                  decoration: InputDecoration(labelText: 'Contact Number'),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text('Success'),
                        content: Text('Blood request submitted!'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('OK'),
                          )
                        ],
                      ),
                    );
                  },
                  child: Text('Submit Request'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
