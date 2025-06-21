// dashboard_screen.dart
import 'package:e_no_dues/Admin/PendingNoDueScreen.dart';
import 'package:e_no_dues/Admin/add_management_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../login_screen.dart';
import 'add_students_screen.dart';
import 'completed_nodue_screen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    AddStudentsScreen(),
    AddManagementScreen(),
    CompletedNoDueScreen(),
    PendingNoDueScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Function to handle logout
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person_add,
              color: Colors.pink[200],
            ),
            label: 'Add Students',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.group_add,
              color: Colors.pink[200],
            ),
            label: 'Add Management',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.check_circle,
              color: Colors.pink[200],
            ),
            label: 'Completed No Due',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.pending,
              color: Colors.pink[200],
            ),
            label: 'Pending No Due',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.lightBlue,
        onTap: _onItemTapped,
      ),
    );
  }
}
