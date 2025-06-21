import 'package:e_no_dues/Hostel/Hosteldashboard.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Admin/dashboard_screen.dart';
import 'Department/DepartmentDashboard.dart';
import 'Librarian/LibrarianDashboard.dart';
import 'AccountSection/AccountSectiondashboard.dart';
import 'login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SKN E No Dues',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: _checkUserLoggedIn(),
    );
  }

  Widget _checkUserLoggedIn() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('management')
            .doc(user.uid)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          if (snapshot.hasData && snapshot.data != null) {
            String role = snapshot.data!['role'];

            switch (role) {
              case 'Admin':
                return DashboardScreen();
              case 'Department':
                return DepartmentDashboard();
              case 'Account Section':
                return AccountSectionDashboard();
              case 'Librarian':
                return LibrarianDashboard();
              case 'Hostel':
                return HostelDashboard();
              default:
                return LoginScreen();
            }
          } else {
            return LoginScreen();
          }
        },
      );
    }
    return LoginScreen();
  }
}
