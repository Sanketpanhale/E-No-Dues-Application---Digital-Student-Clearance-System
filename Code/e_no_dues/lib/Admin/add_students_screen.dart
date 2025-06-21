// ignore_for_file: use_build_context_synchronously, use_key_in_widget_constructors, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddStudentsScreen extends StatefulWidget {
  @override
  _AddStudentsScreenState createState() => _AddStudentsScreenState();
}

class _AddStudentsScreenState extends State<AddStudentsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Form Controllers for adding a student
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  bool _isPasswordVisible = false;

  // Add student function to Firebase Auth and Firestore
  Future<void> _addStudent() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (_nameController.text.isNotEmpty &&
          _emailController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty &&
          _yearController.text.isNotEmpty) {
        // Step 1: Create user in Firebase Auth
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Step 2: Save student details to Firestore
        await _firestore
            .collection('students')
            .doc(userCredential.user!.uid)
            .set({
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'passoutYear': _yearController.text.trim(),
          'uid': userCredential.user!.uid,
          'password': _passwordController.text.trim(),
          'isVerified': false, // Initially set to false
        });

        // Clear the form after adding
        _nameController.clear();
        _emailController.clear();
        _passwordController.clear();
        _yearController.clear();

        // Close the dialog
        Navigator.pop(context);
      } else {
        throw Exception('All fields must be filled!');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add student: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Function to verify/unverify a student
  Future<void> _toggleVerification(String studentId, bool isVerified) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Update the verification status in Firestore
      await _firestore.collection('students').doc(studentId).update({
        'isVerified': !isVerified,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student verification status updated.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update verification status: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Function to delete a student with confirmation
  Future<void> _deleteStudent(String studentId, String studentEmail) async {
    bool shouldDelete = await _showDeleteConfirmationDialog();
    if (shouldDelete) {
      setState(() {
        _isLoading = true;
      });
      try {
        // Delete the student from Firestore
        await _firestore.collection('students').doc(studentId).delete();

        // Find the user by email and delete from Firebase Auth
        User? user =
            (await _auth.fetchSignInMethodsForEmail(studentEmail)).isNotEmpty
                ? await _auth
                    .signInWithEmailAndPassword(
                      email: studentEmail,
                      password: _passwordController.text.trim(),
                    )
                    .then((value) => value.user)
                : null;

        if (user != null) {
          await user.delete();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Student deleted successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete student: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Function to show a confirmation dialog before deleting a student
  Future<bool> _showDeleteConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Student'),
            content:
                const Text('Are you sure you want to delete this student?'),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.pop(context, false),
              ),
              TextButton(
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
        ) ??
        false;
  }

  // Function to display the form in a popup dialog for adding a student
  void _showAddStudentDialog() {
    _nameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _yearController.clear();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Add Student',
            style: TextStyle(color: Colors.black),
          ),
          content: _buildStudentForm(),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.black),
              ),
            ),
            TextButton(
              onPressed: _isLoading ? null : _addStudent,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  // Function to build the student form for both add and edit
  Widget _buildStudentForm() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              labelStyle: TextStyle(color: Colors.black),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF888BF4)),
              ),
            ),
          ),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              labelStyle: TextStyle(color: Colors.black),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF888BF4)),
              ),
            ),
          ),
          TextField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Password',
              labelStyle: const TextStyle(color: Colors.black),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: const Color(0xFF888BF4),
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF888BF4)),
              ),
            ),
            obscureText: !_isPasswordVisible,
          ),
          TextField(
            controller: _yearController,
            decoration: const InputDecoration(
              labelText: 'Passout Year',
              labelStyle: TextStyle(color: Colors.black),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF888BF4)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('students').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final students = snapshot.data!.docs;

          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 4,
                child: ListTile(
                  title: Text(
                    student['name'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  subtitle: Text(
                    student['email'],
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      student['isVerified']
                          ? Icons.check_circle
                          : Icons.check_circle_outline,
                      color: student['isVerified'] ? Colors.green : Colors.grey,
                    ),
                    onPressed: () {
                      _toggleVerification(student.id, student['isVerified']);
                    },
                  ),
                  onLongPress: () {
                    _deleteStudent(student.id, student['email']);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddStudentDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
