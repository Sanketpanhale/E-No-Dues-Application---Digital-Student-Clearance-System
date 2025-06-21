// login_screen.dart
import 'package:e_no_dues/AccountSection/AccountSectiondashboard.dart';
import 'package:e_no_dues/Department/DepartmentDashboard.dart';
import 'package:e_no_dues/Hostel/Hosteldashboard.dart';
import 'package:e_no_dues/Librarian/LibrarianDashboard.dart';
import 'package:e_no_dues/labs/tgp.dart';
import 'package:e_no_dues/labs/T&P.dart';
import 'package:e_no_dues/labs/lab1.dart';
import 'package:e_no_dues/labs/lab2.dart';
import 'package:e_no_dues/labs/lab3.dart';
import 'package:e_no_dues/labs/lab4.dart';
import 'package:e_no_dues/labs/lab5.dart';
import 'package:e_no_dues/labs/lab6.dart';
import 'package:e_no_dues/labs/lab7.dart';
import 'package:e_no_dues/labs/lab8.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore package
import 'Admin/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _login() async {
    try {
      // Sign in with Firebase Auth
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Get the user's role from Firestore
      String uid = userCredential.user!.uid;
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('management')
          .doc(uid)
          .get();

      if (userDoc.exists) {
        String role = userDoc['role']; // Fetch the role from Firestore

        // Navigate based on the user role
        if (role == 'Admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DashboardScreen()),
          );
        } else if (role == 'Department') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DepartmentDashboard()),
          );
        } else if (role == 'Account Section') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AccountSectionDashboard()),
          );
        } else if (role == 'Librarian') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LibrarianDashboard()),
          );
        } else if (role == 'Hostel') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HostelDashboard()),
          );
        } else if (role == 'Lab 1') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Lab1()),
          );
        } else if (role == 'Lab 2') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Lab2()),
          );
        } else if (role == 'Lab 3') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Lab3()),
          );
        } else if (role == 'Lab 4') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Lab4()),
          );
        } else if (role == 'Lab 5') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Lab5()),
          );
        } else if (role == 'Lab 6') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Lab6()),
          );
        } else if (role == 'Lab 7') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Lab7()),
          );
        } else if (role == 'Lab 8') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Lab8()),
          );
        } else if (role == 'T&P') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Tp()),
          );
        } else if (role == 'TG & Project Guide') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => TGP()),
          );
        } else {
          // Handle other roles (e.g., 'Librarian', 'Account Section', 'Hostel')
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Access Denied for this role')),
          );
        }
      } else {
        // If user document does not exist in Firestore
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User role not found')),
        );
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login Failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('Welcome To SKN E no Dues'),
        ),
        automaticallyImplyLeading: false, // Removes back button in the AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              // Add logo image with adjusted height
              Image.asset(
                'assets/singhgad_logo.png', // Ensure the path is correct
                height: 300, // Increased the height of the logo
                width: 300,
              ),
              SizedBox(height: 40),

              // Email TextField with circular corners and light grey background
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.lightBlue, // Customize border color
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200], // Light grey background color
                ),
              ),
              SizedBox(height: 20),

              // Password TextField with circular corners and light grey background
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.lightBlue, // Customize border color
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200], // Light grey background color
                ),
                obscureText: true,
              ),
              SizedBox(height: 40),

              // Login Button with full width, circular corners, and custom color
              SizedBox(
                width: double.infinity, // Makes the button full width
                child: ElevatedButton(
                  onPressed: _login,
                  child: Text('Login', style: TextStyle(color: Colors.black)),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.all(16),
                    backgroundColor: Colors.pink[200],
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12), // Circular corners
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
