import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:student/EnoDuesForm.dart';
import 'package:student/home_screen.dart';

class SuccessScreen extends StatefulWidget {
  @override
  _SuccessScreenState createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  bool _allApproved = false;
  bool _isLoading = true;
  String? _email;
  Map<String, dynamic>? _requestData;

  @override
  void initState() {
    super.initState();
    _getApprovalStatus();
  }

  Future<void> _getApprovalStatus() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _email = user.email;

        // Fetch the requester's document from Firestore
        DocumentSnapshot requesterDoc = await FirebaseFirestore.instance
            .collection('requesters')
            .doc(user.uid)
            .get();

        // Log if the document exists or not
        if (requesterDoc.exists) {
          setState(() {
            _requestData = requesterDoc.data() as Map<String, dynamic>?;

            // Check if all approvals are true
            _allApproved = _requestData!['accountApproved'] == true &&
                _requestData!['departmentApproved'] == true &&
                _requestData!['hostelApproved'] == true &&
                _requestData!['librarianApproved'] == true;
            _isLoading = false; // Set loading to false when data is fetched
          });
        } else {
          print('No requester document found for user: ${user.uid}');
          // Handle the case where the document does not exist
          setState(() {
            _isLoading = false; // Stop loading if document not found
            _requestData = null; // Clear requestData
          });
        }
      } else {
        print('User not logged in');
        setState(() {
          _isLoading = false; // Stop loading if no user
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false; // Stop loading on error
      });
      print('Error fetching request status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Navigate to home screen when back button is pressed
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
        return false; // Prevent default back button action
      },
      child: Scaffold(
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_allApproved)
                      const Column(
                        children: [
                          Icon(Icons.check_circle,
                              size: 100, color: Colors.green),
                          SizedBox(height: 20),
                          Text(
                            'Form approved successfully!',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          const Icon(Icons.error, size: 100, color: Colors.red),
                          const SizedBox(height: 20),
                          const Text(
                            'Approval pending',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          _buildApprovalStatusRow(
                              'Account',
                              _requestData?['accountApproved'],
                              _requestData?['accountStatus']),
                          _buildApprovalStatusRow(
                              'Department',
                              _requestData?['departmentApproved'],
                              _requestData?['departmentStatus']),
                          _buildApprovalStatusRow(
                              'Hostel',
                              _requestData?['hostelApproved'],
                              _requestData?['hostelStatus']),
                          _buildApprovalStatusRow(
                              'Librarian',
                              _requestData?['librarianApproved'],
                              _requestData?['librarianStatus']),
                        ],
                      ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EnoDuesForm()),
                        );
                      },
                      child: const Text('Edit Form'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  // Helper method to build approval status rows
  Widget _buildApprovalStatusRow(
      String title, bool? isApproved, String? status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$title Approved: ${isApproved == true ? "Yes" : "No"}',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(width: 10),
          // Show remarks only if not approved
          if (isApproved == false)
            Text(
              '(${status ?? "No remarks"})',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
        ],
      ),
    );
  }
}
