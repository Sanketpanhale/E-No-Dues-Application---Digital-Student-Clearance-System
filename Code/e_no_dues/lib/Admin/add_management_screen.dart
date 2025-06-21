import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddManagementScreen extends StatefulWidget {
  @override
  _AddManagementScreenState createState() => _AddManagementScreenState();
}

class _AddManagementScreenState extends State<AddManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase Auth instance
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedRole;
  bool _isPasswordVisible = false; // Variable to track password visibility

  final List<String> _roles = [
    'Admin',
    'Librarian',
    'Account Section',
    'Department',
    'Hostel',
    'Lab 1',
    'Lab 2',
    'Lab 3',
    'Lab 4',
    'Lab 5',
    'Lab 6',
    'Lab 7',
    'Lab 8',
    'T&P', // Training & Placement
    'TG & Project Guide', // Department Library
  ];

  // Add Management with Firebase Authentication
  Future<void> _addManagement() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (_nameController.text.isNotEmpty &&
          _emailController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty &&
          _selectedRole != null) {
        // Step 1: Create a new user in Firebase Authentication
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Step 2: Store user details in Firestore under 'management' collection
        await _firestore
            .collection('management')
            .doc(userCredential.user?.uid)
            .set({
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'role': _selectedRole,
        });

        _clearFields();
        Navigator.pop(context);
      } else {
        throw Exception('All fields must be filled!');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add management team: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearFields() {
    _nameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _selectedRole = null;
  }

  Future<void> _deleteManagement(String docId) async {
    bool confirmed = await _showDeleteConfirmationDialog();
    if (confirmed) {
      await _firestore.collection('management').doc(docId).delete();
    }
  }

  Future<bool> _showDeleteConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Confirm Delete'),
              content: Text(
                  'Are you sure you want to delete this management member?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  void _showAddManagementDialog() {
    _showManagementDialog();
  }

  void _showManagementDialog(
      {String? docId,
      String? name,
      String? email,
      String? password,
      String? role}) {
    // Set the controllers with existing data if available (edit mode)
    _nameController.text = name ?? '';
    _emailController.text = email ?? '';
    _passwordController.text = password ?? '';
    _selectedRole = role;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            docId == null ? 'Add Management Team' : 'Edit Management Team',
            style: TextStyle(color: Colors.black),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(
                  controller: _nameController,
                  label: 'Name',
                ),
                SizedBox(height: 10),
                _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                ),
                SizedBox(height: 10),
                _buildPasswordField(),
                SizedBox(height: 10),
                _buildDropdown(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _clearFields();
              },
              child: Text('Cancel', style: TextStyle(color: Colors.black)),
            ),
            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      if (docId == null) {
                        _addManagement();
                      } else {
                        _editManagement(docId);
                      }
                    },
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text(docId == null ? 'Add' : 'Update'),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.blue[50]),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(
      {required TextEditingController controller, required String label}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.black),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.lightBlue),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      decoration: InputDecoration(
        labelText: 'Password',
        labelStyle: TextStyle(color: Colors.black),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.lightBlue),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.black,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible =
                  !_isPasswordVisible; // Toggle password visibility
            });
          },
        ),
      ),
      obscureText: !_isPasswordVisible, // Show or hide password
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedRole,
      onChanged: (String? newValue) {
        setState(() {
          _selectedRole = newValue;
        });
      },
      items: _roles.map<DropdownMenuItem<String>>((String role) {
        return DropdownMenuItem<String>(
          value: role,
          child: Text(role, style: TextStyle(color: Colors.black)),
        );
      }).toList(),
      decoration: InputDecoration(
        labelText: 'Role',
        labelStyle: TextStyle(color: Colors.black),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.lightBlue),
        ),
      ),
    );
  }

  // Edit Management with Firebase Authentication for updating password
  Future<void> _editManagement(String docId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (_nameController.text.isNotEmpty &&
          _emailController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty &&
          _selectedRole != null) {
        // Step 1: Update the user's details in Firestore
        await _firestore.collection('management').doc(docId).update({
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'role': _selectedRole,
        });

        // Step 2: Update the password in Firebase Authentication
        User? user = _auth.currentUser; // Get current user
        if (user != null) {
          await user.updatePassword(_passwordController.text.trim());
        }

        _clearFields();
        Navigator.pop(context);
      } else {
        throw Exception('All fields must be filled!');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update management team: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _errorMessage != null
          ? Center(
              child: Text(
                'Error: $_errorMessage',
                style: TextStyle(color: Colors.red),
              ),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('management').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final managementMembers = snapshot.data?.docs ?? [];

                if (managementMembers.isEmpty) {
                  return Center(child: Text('No management members available'));
                }

                return ListView.builder(
                  itemCount: managementMembers.length,
                  itemBuilder: (context, index) {
                    final member = managementMembers[index];
                    final data = member.data() as Map<String, dynamic>?;

                    final name = data?.containsKey('name') == true
                        ? data!['name'] as String
                        : 'No name provided';
                    final email = data?.containsKey('email') == true
                        ? data!['email'] as String
                        : 'No email provided';
                    final role = data?.containsKey('role') == true
                        ? data!['role'] as String
                        : 'No role provided';

                    return Card(
                      child: ListTile(
                        title:
                            Text(name, style: TextStyle(color: Colors.black)),
                        subtitle: Text('Email: $email\nRole: $role',
                            style: TextStyle(color: Colors.black)),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteManagement(member.id),
                        ),
                        onTap: () => _showManagementDialog(
                          docId: member.id,
                          name: name,
                          email: email,
                          password: data!['password'],
                          role: role,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddManagementDialog,
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
