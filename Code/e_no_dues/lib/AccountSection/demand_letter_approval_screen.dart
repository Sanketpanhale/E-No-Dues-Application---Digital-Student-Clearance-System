import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DemandLetterApprovalScreen extends StatefulWidget {
  const DemandLetterApprovalScreen({super.key});

  @override
  State<DemandLetterApprovalScreen> createState() =>
      _DemandLetterApprovalScreenState();
}

class _DemandLetterApprovalScreenState
    extends State<DemandLetterApprovalScreen> {
  final Map<String, TextEditingController> _controllers = {};

  @override
  void dispose() {
    for (var c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('demand_letters').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;
          if (docs.isEmpty)
            return const Center(
                child: Text('No demand letter requests found.'));

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              // Setup feedback controller per request
              _controllers[doc.id] ??=
                  TextEditingController(text: data['feedback'] ?? '');

              final isApproved = data['isApproved'] ?? false;
              final isRejected = data['isRejected'] ?? false;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Name: ${data['name'] ?? ''}",
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text("Class: ${data['class'] ?? ''}"),
                      Text("Roll No: ${data['rollNo'] ?? ''}"),
                      Text("Reason: ${data['demandReason'] ?? ''}"),
                      Text(
                          "Status: ${isApproved ? "Approved" : isRejected ? "Rejected" : "Pending"}",
                          style: TextStyle(
                            color: isApproved
                                ? Colors.green
                                : isRejected
                                    ? Colors.red
                                    : Colors.orange,
                            fontWeight: FontWeight.bold,
                          )),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _controllers[doc.id],
                        decoration: const InputDecoration(
                          labelText: "Feedback",
                          border: OutlineInputBorder(),
                        ),
                        minLines: 1,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.check, color: Colors.white),
                            label: const Text("Approve"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            onPressed: isApproved
                                ? null
                                : () async {
                                    await FirebaseFirestore.instance
                                        .collection('demand_letters')
                                        .doc(doc.id)
                                        .update({
                                      'isApproved': true,
                                      'isRejected': false,
                                      'feedback':
                                          _controllers[doc.id]!.text.trim(),
                                      'approvedAt': DateTime.now(),
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Request Approved!')),
                                    );
                                  },
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.close, color: Colors.white),
                            label: const Text("Reject"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: isRejected
                                ? null
                                : () async {
                                    await FirebaseFirestore.instance
                                        .collection('demand_letters')
                                        .doc(doc.id)
                                        .update({
                                      'isApproved': false,
                                      'isRejected': true,
                                      'feedback':
                                          _controllers[doc.id]!.text.trim(),
                                      'rejectionReason':
                                          _controllers[doc.id]!.text.trim(),
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Request Rejected!')),
                                    );
                                  },
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.save, color: Colors.white),
                            label: const Text("Update Feedback"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                            ),
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection('demand_letters')
                                  .doc(doc.id)
                                  .update({
                                'feedback': _controllers[doc.id]!.text.trim(),
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Feedback updated!')),
                              );
                            },
                          ),
                        ],
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
