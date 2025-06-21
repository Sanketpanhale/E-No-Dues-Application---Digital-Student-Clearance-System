import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class BonafideScreen extends StatefulWidget {
  const BonafideScreen({super.key});

  @override
  State<BonafideScreen> createState() => _BonafideScreenState();
}

class _BonafideScreenState extends State<BonafideScreen> {
  final _formKey = GlobalKey<FormState>();
  final _purposeController = TextEditingController();
  final _classController = TextEditingController();
  bool _isLoading = true;
  DocumentSnapshot? _existingApplication;

  @override
  void initState() {
    super.initState();
    _checkExistingApplication();
  }

  Future<void> _checkExistingApplication() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection('bonafide_requests')
        .where('name', isEqualTo: user.email) // Or use UID if stored
        .get();
    setState(() {
      _isLoading = false;
      _existingApplication = query.docs.isNotEmpty ? query.docs.first : null;
    });
  }

  Future<void> _applyForBonafide() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    setState(() => _isLoading = true);
    await FirebaseFirestore.instance.collection('bonafide_requests').add({
      'name': user.email, // or user.displayName/uid
      'class': _classController.text.trim(),
      'purpose': _purposeController.text.trim(),
      'status': 'pending',
      'timestamp': DateTime.now(),
    });
    await _checkExistingApplication();
    setState(() => _isLoading = false);
  }

  Future<void> _downloadBonafidePdf() async {
    final user = FirebaseAuth.instance.currentUser!;
    final data = _existingApplication!.data() as Map<String, dynamic>;
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Center(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey, width: 2),
              borderRadius: pw.BorderRadius.circular(10),
            ),
            child: pw.Column(
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                pw.Text('SKN Sinhgad Institute of Technology',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    )),
                pw.SizedBox(height: 12),
                pw.Text('BONAFIDE CERTIFICATE',
                    style: pw.TextStyle(
                      fontSize: 18,
                      decoration: pw.TextDecoration.underline,
                      fontWeight: pw.FontWeight.bold,
                    )),
                pw.SizedBox(height: 18),
                pw.Text(
                  'This is to certify that Mr/Ms. ${user.email} is/was a bonafide student of class ${data['class']} at our institute for the purpose of "${data['purpose']}".',
                  style: pw.TextStyle(fontSize: 14),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 24),
                pw.Text(
                  'Date: ${DateTime.now().toLocal()}',
                  style: pw.TextStyle(fontSize: 12),
                ),
                pw.SizedBox(height: 40),
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(
                    'Principal',
                    style: pw.TextStyle(fontSize: 16),
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
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));

    // If already applied, show status (and download option if approved)
    if (_existingApplication != null) {
      final data = _existingApplication!.data() as Map<String, dynamic>;
      return Scaffold(
        appBar: AppBar(title: const Text('Bonafide Application Status')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Status: ${data['status']}',
                    style: const TextStyle(fontSize: 22)),
                const SizedBox(height: 30),
                if (data['status'] == 'approved')
                  ElevatedButton.icon(
                    icon: const Icon(Icons.download),
                    label: const Text('Download Bonafide PDF'),
                    onPressed: _downloadBonafidePdf,
                  ),
                if (data['status'] == 'pending')
                  const Text(
                    "Your bonafide request is pending approval.",
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
      appBar: AppBar(title: const Text('Apply for Bonafide')),
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
                validator: (val) => val == null || val.isEmpty ? 'Enter class' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _purposeController,
                decoration: const InputDecoration(
                  labelText: 'Purpose',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Enter purpose' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await _applyForBonafide();
                  }
                },
                child: const Text('Apply for Bonafide'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
