import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_no_dues/login_screen.dart';
import 'package:e_no_dues/noduce_details.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Lab8 extends StatelessWidget {
  const Lab8({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lab 8 Verification"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: "Logout",
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('requesters').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;

          if (docs.isEmpty) return Center(child: Text('No users found'));

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final name = data['name'] ?? 'No Name';

              return ListTile(
                title: Text(name),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch(
                      value: data.containsKey('Lab 8')
                          ? data['Lab 8'] as bool
                          : false,
                      onChanged: (val) async {
                        await FirebaseFirestore.instance
                            .collection('requesters')
                            .doc(doc.id)
                            .update({'Lab 8': val});
                      },
                      activeColor: Colors.green,
                    ),
                    IconButton(
                      icon: Icon(Icons.details, color: Colors.blue),
                      tooltip: 'View NoDue Details',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                NodueDetailsPage(docId: doc.id),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
