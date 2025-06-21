import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PendingNoDueScreen extends StatelessWidget {
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

          // Ensure that if any field is null, it is treated as false
          return (requestData['librarianApproved'] ?? false) != true ||
              (requestData['departmentApproved'] ?? false) != true ||
              (requestData['hostelApproved'] ?? false) != true ||
              (requestData['accountApproved'] ?? false) != true;
        }).toList();

        if (forms.isEmpty) {
          return Center(child: Text('No Pending No Due Forms'));
        }

        return ListView.builder(
          itemCount: forms.length,
          itemBuilder: (context, index) {
            final formData = forms[index].data() as Map<String, dynamic>;

            return ListTile(
              title: Text(formData['name'] ?? 'No Name'),
              subtitle: Text(formData['email'] ?? 'No Email'),
              trailing: Text('Pending', style: TextStyle(color: Colors.red)),
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
                'Library Status: ${formData['librarianStatus']} (${(formData['librarianApproved'] ?? false) ? "Approved" : "Pending"})'),
            Text(
                'Department Status: ${formData['departmentStatus']} (${(formData['departmentApproved'] ?? false) ? "Approved" : "Pending"})'),
            Text(
                'Hostel Status: ${formData['hostelStatus']} (${(formData['hostelApproved'] ?? false) ? "Approved" : "Pending"})'),
            Text(
                'Account Status: ${formData['accountStatus']} (${(formData['accountApproved'] ?? false) ? "Approved" : "Pending"})'),
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
