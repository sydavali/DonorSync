import 'package:flutter/material.dart';

class EligibilityFormScreen extends StatefulWidget {
  // We will call this function after the user is confirmed to be eligible
  final Function onEligible;

  const EligibilityFormScreen({super.key, required this.onEligible});

  @override
  State<EligibilityFormScreen> createState() => _EligibilityFormScreenState();
}

class _EligibilityFormScreenState extends State<EligibilityFormScreen> {
  // A map to store the answer for each question (true for Yes, false for No)
  final Map<int, bool> _answers = {};
  final _formKey = GlobalKey<FormState>();

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      // If any question is not answered, show an error.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please answer all questions before submitting.')),
      );
      return;
    }

    // The key questions where a "No" answer means ineligibility
    const ineligibleOnNo = {7, 8, 11, 12, 13, 15, 18};
    bool isEligible = true;

    // Check each answer
    _answers.forEach((questionNumber, answer) {
      if (ineligibleOnNo.contains(questionNumber) && answer == false) {
        isEligible = false;
      }
    });

    if (isEligible) {
      // If eligible, call the function passed from the previous screen
      widget.onEligible();
    } else {
      // If not eligible, show the specific alert message
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Ineligibility Notice"),
          content: const Text(
              "You are temporarily ineligible to donate blood. Please try again later or consult your physician."),
          actions: [
            TextButton(
              child: const Text("Okay"),
              onPressed: () {
                Navigator.of(ctx).pop(); // Close the dialog
              },
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Donor Eligibility Form"),
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildQuestionRow(1, "Have you donated blood in the last 3 months (men) or 4 months (women)?"),
                _buildQuestionRow(2, "Are you currently under any medical treatment or medication?"),
                // Add all your other questions here following the pattern...
                _buildQuestionRow(7, "Have you ever tested positive for HIV, Hepatitis B, or Hepatitis C?"),
                _buildQuestionRow(8, "In the past 28 days, have you suffered from fever, flu, or infection?"),
                _buildQuestionRow(11, "Do you consume alcohol or tobacco within 24 hours before donation?"),
                _buildQuestionRow(12, "Are you currently pregnant, breastfeeding, or menstruating (for female donors)?"),
                _buildQuestionRow(13, "Have you had at least 6 hours of sleep in the past 24 hours?"),
                _buildQuestionRow(15, "Are you currently feeling dizzy, weak, or unwell?"),
                _buildQuestionRow(18, "Do you voluntarily agree to donate blood and confirm that all the above information is true?"),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text("Submit & Confirm Eligibility", style: TextStyle(fontSize: 16)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget to create a Yes/No question row cleanly
  Widget _buildQuestionRow(int questionNumber, String questionText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(questionText, style: const TextStyle(fontSize: 16)),
          FormField<bool>(
            builder: (FormFieldState<bool> state) {
              return Column(
                children: [
                  Row(
                    children: [
                      Radio<bool>(
                        value: true,
                        groupValue: _answers[questionNumber],
                        onChanged: (value) => setState(() => _answers[questionNumber] = value!),
                      ),
                      const Text("Yes"),
                      Radio<bool>(
                        value: false,
                        groupValue: _answers[questionNumber],
                        onChanged: (value) => setState(() => _answers[questionNumber] = value!),
                      ),
                      const Text("No"),
                    ],
                  ),
                  if (state.hasError)
                    Text(
                      state.errorText!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    )
                ],
              );
            },
            validator: (value) {
              if (_answers[questionNumber] == null) {
                return 'Please select an answer.';
              }
              return null;
            },
          ),
          const Divider(),
        ],
      ),
    );
  }
}