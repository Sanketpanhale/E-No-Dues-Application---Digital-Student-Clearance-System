import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BonafideApprovalScreen extends StatefulWidget {
  const BonafideApprovalScreen({super.key});

  @override
  State<BonafideApprovalScreen> createState() => _BonafideApprovalScreenState();
}

class _BonafideApprovalScreenState extends State<BonafideApprovalScreen> {
  final Map<String, TextEditingController> _controllers = {};

  @override
  void dispose() {
    // Dispose all feedback controllers
    for (var c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bonafide_requests')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) return Center(child: Text('No requests found'));

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              // Setup feedback controller per request
              _controllers[doc.id] ??=
                  TextEditingController(text: data['feedback'] ?? '');

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Name: ${data['name']}",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("Class: ${data['class']}"),
                      Text("Purpose: ${data['purpose']}"),
                      Text("Status: ${data['status']}",
                          style: TextStyle(
                            color: data['status'] == 'approved'
                                ? Colors.green
                                : Colors.orange,
                            fontWeight: FontWeight.bold,
                          )),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text("Approve: "),
                          Switch(
                            value: data['status'] == 'approved',
                            onChanged: (val) {
                              setState(() {
                                // Instantly update status in Firestore
                                FirebaseFirestore.instance
                                    .collection('bonafide_requests')
                                    .doc(doc.id)
                                    .update({
                                  'status': val ? 'approved' : 'pending'
                                });
                              });
                            },
                            activeColor: Colors.green,
                          ),
                        ],
                      ),
                      TextField(
                        controller: _controllers[doc.id],
                        decoration: InputDecoration(
                          labelText: "Feedback",
                          border: OutlineInputBorder(),
                        ),
                        minLines: 1,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        icon: Icon(Icons.save),
                        label: Text("Update Feedback"),
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection('bonafide_requests')
                              .doc(doc.id)
                              .update({
                            'feedback': _controllers[doc.id]?.text.trim(),
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Feedback updated!')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
