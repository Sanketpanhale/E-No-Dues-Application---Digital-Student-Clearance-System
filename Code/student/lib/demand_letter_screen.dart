import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class DemandLetterScreen extends StatefulWidget {
  const DemandLetterScreen({super.key});

  @override
  State<DemandLetterScreen> createState() => _DemandLetterScreenState();
}

class _DemandLetterScreenState extends State<DemandLetterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _classController = TextEditingController();
  final _rollNoController = TextEditingController();
  final _reasonController = TextEditingController();

  bool _isLoading = true;
  DocumentSnapshot? _existingRequest;

  @override
  void initState() {
    super.initState();
    _checkExistingRequest();
  }

  Future<void> _checkExistingRequest() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('demand_letters')
        .doc(user.uid)
        .get();

    setState(() {
      _isLoading = false;
      _existingRequest = doc.exists ? doc : null;
    });
  }

  Future<void> _applyForDemandLetter() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    setState(() => _isLoading = true);

    await FirebaseFirestore.instance
        .collection('demand_letters')
        .doc(user.uid)
        .set({
      'admissionYear': DateTime.now().year.toString(),
      'class': _classController.text.trim(),
      'rollNo': _rollNoController.text.trim(),
      'demandReason': _reasonController.text.trim(),
      'isApproved': false,
      'isRejected': false,
      'feedback': '',
      'name': user.displayName ?? user.email,
      'submittedAt': DateTime.now(),
      'approvedAt': '',
      'formId': '',
      'rejectionReason': '',
    });

    await _checkExistingRequest();
    setState(() => _isLoading = false);
  }

  Future<void> _downloadDemandLetterPdf() async {
    final data = _existingRequest!.data() as Map<String, dynamic>;
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Center(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(28),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.blueGrey, width: 2),
              borderRadius: pw.BorderRadius.circular(14),
            ),
            child: pw.Column(
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                pw.Text(
                    'SKN Sinhgad Institute of Technology, Kusgaon (Bk), Pune',
                    style: pw.TextStyle(
                        fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.Text('DEMAND LETTER',
                    style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        decoration: pw.TextDecoration.underline)),
                pw.SizedBox(height: 18),
                pw.Text(
                  'To whomsoever it may concern,\n\n'
                  'This is to certify that ${data['name']} (Roll No. ${data['rollNo']}), '
                  'of class ${data['class']} (Admission Year: ${data['admissionYear']}) has requested a demand letter for the following reason:\n\n'
                  '"${data['demandReason']}"',
                  style: pw.TextStyle(fontSize: 13),
                ),
                pw.SizedBox(height: 18),
                pw.Text(
                    'Date: ${DateTime.now().toLocal().toString().split(' ')[0]}',
                    style: pw.TextStyle(fontSize: 11)),
                pw.SizedBox(height: 40),
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(
                    'Principal',
                    style: pw.TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

    // If already requested, show status (and download option if approved)
    if (_existingRequest != null) {
      final data = _existingRequest!.data() as Map<String, dynamic>;
      final bool isApproved = data['isApproved'] ?? false;
      final bool isRejected = data['isRejected'] ?? false;
      final String feedback = data['feedback'] ?? '';

      return Scaffold(
        appBar: AppBar(title: const Text('Demand Letter Status')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                    'Status: ${isApproved ? "Approved" : isRejected ? "Rejected" : "Pending"}',
                    style: TextStyle(
                      fontSize: 22,
                      color: isApproved
                          ? Colors.green
                          : isRejected
                              ? Colors.red
                              : Colors.orange,
                    )),
                const SizedBox(height: 18),
                if (feedback.isNotEmpty)
                  Text("Feedback: $feedback", style: TextStyle(fontSize: 16)),
                const SizedBox(height: 18),
                if (isApproved)
                  ElevatedButton.icon(
                    icon: Icon(Icons.download),
                    label: Text('Download Demand Letter PDF'),
                    onPressed: _downloadDemandLetterPdf,
                  ),
                if (!isApproved && !isRejected)
                  const Text(
                    "Your demand letter request is waiting for approval.",
                    style: TextStyle(fontSize: 16),
                  ),
                if (isRejected)
                  const Text(
                    "Your demand letter request was rejected.",
                    style: TextStyle(fontSize: 16),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    // If not yet applied, show the form
    return Scaffold(
      appBar: AppBar(title: const Text('Apply for Demand Letter')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _classController,
                decoration: const InputDecoration(
                  labelText: 'Class',
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Enter class' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _rollNoController,
                decoration: const InputDecoration(
                  labelText: 'Roll No',
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Enter roll no' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason for Demand Letter',
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Enter reason' : null,
              ),
              const SizedBox(height: 22),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await _applyForDemandLetter();
                  }
                },
                child: const Text('Apply for Demand Letter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
