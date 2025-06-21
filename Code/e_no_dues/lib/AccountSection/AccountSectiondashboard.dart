import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_no_dues/AccountSection/FormDetailsScreen.dart';
import 'package:e_no_dues/AccountSection/demand_letter_approval_screen.dart';
import 'package:e_no_dues/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AccountSectionDashboard extends StatefulWidget {
  const AccountSectionDashboard({super.key});

  @override
  State<AccountSectionDashboard> createState() =>
      _AccountSectionDashboardState();
}

class _AccountSectionDashboardState extends State<AccountSectionDashboard> {
  int _selectedIndex = 0;

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  Widget _buildRequestersView(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('requesters').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        final forms = snapshot.data!.docs;

        return ListView.builder(
          itemCount: forms.length,
          itemBuilder: (context, index) {
            final form = forms[index];
            final formData = form.data() as Map<String, dynamic>;
            final uid = form.id;

            return Card(
              child: ListTile(
                title: Text(formData['name'] ?? 'Unknown'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AccountFormDetailsScreen(
                        formId: uid,
                        formData: formData,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildRequestersView(context),
      DemandLetterApprovalScreen(), // <-- Show the approval screen as a page
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0
            ? "Account Section Dashboard"
            : "Demand Letter Approval"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_turned_in),
            label: "Demand Letters",
          ),
        ],
      ),
    );
  }
}
