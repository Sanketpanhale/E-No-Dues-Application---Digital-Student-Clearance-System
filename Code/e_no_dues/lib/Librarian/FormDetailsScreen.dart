import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_no_dues/noduce_details.dart';
import 'package:flutter/material.dart';

class FormDetailsScreen extends StatefulWidget {
  final String formId;
  final Map<String, dynamic> formData;

  const FormDetailsScreen(
      {super.key, required this.formId, required this.formData});

  @override
  _FormDetailsScreenState createState() => _FormDetailsScreenState();
}

class _FormDetailsScreenState extends State<FormDetailsScreen> {
  final _noteController = TextEditingController();
  bool _isVerified = false;

  Future<void> _updateFormStatus() async {
    String note = _noteController.text.trim();
    String uid = widget.formId;

    try {
      // Determine the verification status based on the note's content
      bool verificationStatus = note.isEmpty;

      // Update Firestore with the appropriate status and note
      await FirebaseFirestore.instance
          .collection('requesters')
          .doc(uid)
          .update({
        'librarianStatus': note.isNotEmpty ? note : 'Verified',
        'librarianApproved': verificationStatus,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Form updated successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update form')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Form Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Name: ${widget.formData['name'] ?? 'N/A'}'),

              SizedBox(height: 20),
              ElevatedButton.icon(
                icon: Icon(Icons.remove_red_eye),
                label: Text('View NoDue Details'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          NodueDetailsPage(docId: widget.formId),
                    ),
                  );
                },
              ),
              SizedBox(height: 20),
              // Note TextField
              TextField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: 'Add a Note (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onChanged: (value) {
                  // Automatically update verification status based on note presence
                  setState(() {
                    _isVerified = value.trim().isEmpty;
                  });
                },
              ),
              SizedBox(height: 20),
              // Verification Switch
              SwitchListTile(
                title: Text('Verified'),
                value: _isVerified,
                onChanged: (value) {
                  setState(() {
                    _isVerified = value;
                  });
                },
              ),
              SizedBox(height: 20),
              // Verification Button
              ElevatedButton(
                onPressed: _updateFormStatus,
                child: Text('Update Form'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
