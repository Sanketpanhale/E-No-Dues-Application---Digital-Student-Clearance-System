import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_no_dues/noduce_details.dart';
import 'package:flutter/material.dart';

class AccountFormDetailsScreen extends StatefulWidget {
  final String formId;
  final Map<String, dynamic> formData;

  const AccountFormDetailsScreen({
    super.key,
    required this.formId,
    required this.formData,
  });

  @override
  _AccountFormDetailsScreenState createState() =>
      _AccountFormDetailsScreenState();
}

class _AccountFormDetailsScreenState extends State<AccountFormDetailsScreen> {
  final _noteController = TextEditingController();
  bool _isVerified = false;

  Future<void> _updateFormStatus() async {
    String note = _noteController.text.trim();
    String uid = widget.formId;

    try {
      bool verificationStatus = note.isEmpty;

      await FirebaseFirestore.instance
          .collection('requesters')
          .doc(uid)
          .update({
        'accountStatus': note.isNotEmpty ? note : 'Verified',
        'accountApproved': verificationStatus,
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
        title: Text("Account Form Details"),
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
              TextField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: 'Add a Note (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onChanged: (value) {
                  setState(() {
                    _isVerified = value.trim().isEmpty;
                  });
                },
              ),
              SizedBox(height: 20),
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
