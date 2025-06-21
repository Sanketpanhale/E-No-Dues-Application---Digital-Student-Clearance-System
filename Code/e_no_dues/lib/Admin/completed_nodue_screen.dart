import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CompletedNoDueScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('requesters').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final forms = snapshot.data!.docs.where((doc) {
          final requestData = doc.data() as Map<String, dynamic>;

          // Check if all departments have approved
          return requestData['librarianApproved'] == true &&
              requestData['departmentApproved'] == true &&
              requestData['hostelApproved'] == true &&
              requestData['accountApproved'] == true;
        }).toList();

        if (forms.isEmpty) {
          return Center(child: Text('No Completed No Due Forms'));
        }

        return ListView.builder(
          itemCount: forms.length,
          itemBuilder: (context, index) {
            final formData = forms[index].data() as Map<String, dynamic>;

            return ListTile(
              title: Text(formData['name'] ?? 'No Name'),
              subtitle: Text(formData['email'] ?? 'No Email'),
              trailing: Text('Verified', style: TextStyle(color: Colors.green)),
              onTap: () {
                _showFormDetails(context, formData);
              },
            );
          },
        );
      },
    );
  }

  // Function to show form details
  void _showFormDetails(BuildContext context, Map<String, dynamic> formData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('No Due Details'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Name: ${formData['name']}'),
            Text('Email: ${formData['email']}'),
            Text('Branch: ${formData['branch']}'),
            Text(
                'Library Status: ${formData['librarianStatus']} (${formData['librarianApproved'] ? "Approved" : "Pending"})'),
            Text(
                'Department Status: ${formData['departmentStatus']} (${formData['departmentApproved'] ? "Approved" : "Pending"})'),
            Text(
                'Hostel Status: ${formData['hostelStatus']} (${formData['hostelApproved'] ? "Approved" : "Pending"})'),
            Text(
                'Account Status: ${formData['accountStatus']} (${formData['accountApproved'] ? "Approved" : "Pending"})'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}
