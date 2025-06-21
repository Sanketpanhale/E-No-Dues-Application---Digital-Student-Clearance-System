import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
class NodueDetailsPage extends StatelessWidget {
  final String docId;
  const NodueDetailsPage({super.key, required this.docId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("NoDue Details")),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('nodueforms').doc(docId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          if (!snapshot.data!.exists) return Center(child: Text("No data found for this ID."));
          final data = snapshot.data!.data() as Map<String, dynamic>;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: data.entries.map((entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${entry.key}: ", style: TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(child: Text("${entry.value}")),
                  ],
                ),
              )).toList(),
            ),
          );
        },
      ),
    );
  }
}
