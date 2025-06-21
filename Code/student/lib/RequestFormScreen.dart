import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:student/home_screen.dart';
import 'SuccessScreen.dart';

class RequestFormScreen extends StatefulWidget {
  @override
  _RequestFormScreenState createState() => _RequestFormScreenState();
}

class _RequestFormScreenState extends State<RequestFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Text editing controllers for all form fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _classController = TextEditingController();
  final TextEditingController _branchController = TextEditingController();
  final TextEditingController _admissionYearController =
      TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _placeOfBirthController = TextEditingController();
  final TextEditingController _nationalityController = TextEditingController();
  final TextEditingController _religionController = TextEditingController();
  final TextEditingController _casteController = TextEditingController();
  final TextEditingController _motherNameController = TextEditingController();
  final TextEditingController _previousCollegeController =
      TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFormData();
  }

  Future<void> _loadFormData() async {
    setState(() {
      _isLoading = true;
    });

    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String uid = user.uid;

      try {
        DocumentSnapshot formSnapshot = await FirebaseFirestore.instance
            .collection('nodueforms')
            .doc(uid)
            .get();

        if (formSnapshot.exists) {
          // If the form exists, navigate to SuccessScreen directly
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SuccessScreen()),
          );
          return; // Exit the method early
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading form data: $e')),
        );
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        String uid = user.uid;

        try {
          // Submit the main form data
          await FirebaseFirestore.instance
              .collection('nodueforms')
              .doc(uid)
              .set({
            'name': _nameController.text,
            'class': _classController.text,
            'branch': _branchController.text,
            'admissionYear': _admissionYearController.text,
            'birthDate': _birthDateController.text,
            'placeOfBirth': _placeOfBirthController.text,
            'nationality': _nationalityController.text,
            'religion': _religionController.text,
            'caste': _casteController.text,
            'motherName': _motherNameController.text,
            'previousCollege': _previousCollegeController.text,
            'reason': _reasonController.text,
            'mobile': _mobileController.text,
            'dateSubmitted': DateTime.now(),
            'email': _emailController.text,
          });

          // Create a new database entry for requester's additional fields
          await FirebaseFirestore.instance
              .collection('requesters')
              .doc(uid)
              .set({
            'accountApproved': false,
            'accountStatus': 'complete',
            'departmentApproved': true,
            'departmentStatus': 'submit file',
            'email': _emailController.text,
            'hostelApproved': true,
            'hostelStatus': 'complete fine',
            'librarianApproved': true,
            'librarianStatus': 'submit book',
            'name': _nameController.text,
          });

          setState(() {
            _isLoading = false;
          });

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SuccessScreen()),
          );

          _clearForm();
        } catch (e) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  void _clearForm() {
    _nameController.clear();
    _classController.clear();
    _branchController.clear();
    _admissionYearController.clear();
    _birthDateController.clear();
    _placeOfBirthController.clear();
    _nationalityController.clear();
    _religionController.clear();
    _casteController.clear();
    _motherNameController.clear();
    _previousCollegeController.clear();
    _reasonController.clear();
    _mobileController.clear();
    _emailController.clear();
    _passwordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Application for Transfer Certificate'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Date: ${DateTime.now().toLocal()}',
                            style: TextStyle(fontSize: 16)),
                        SizedBox(height: 20),
                        Text('To,', style: TextStyle(fontSize: 16)),
                        SizedBox(height: 5),
                        Text('The Principal,', style: TextStyle(fontSize: 16)),
                        Text('SKN Sinhgad Institute of Technology & Science',
                            style: TextStyle(fontSize: 16)),
                        Text('Kusgaon (Bk), Lonavala',
                            style: TextStyle(fontSize: 16)),
                        SizedBox(height: 20),
                        Text(
                          'Sub: Application for Transfer Certificate.',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 20),
                        _buildTextField(_nameController, 'Your Name'),
                        _buildTextField(_classController, 'Class'),
                        _buildTextField(_branchController, 'Branch'),
                        _buildTextField(
                            _admissionYearController, 'Admission Year'),
                        _buildTextField(_birthDateController, 'Birth Date'),
                        _buildTextField(
                            _placeOfBirthController, 'Place of Birth'),
                        _buildTextField(_nationalityController, 'Nationality'),
                        _buildTextField(_religionController, 'Religion'),
                        _buildTextField(_casteController, 'Caste & Sub Caste'),
                        _buildTextField(
                            _motherNameController, 'Mother\'s Name'),
                        _buildTextField(_previousCollegeController,
                            'Previous College Name'),
                        _buildTextField(
                            _reasonController, 'Reason for College Leaving'),
                        _buildTextField(_mobileController, 'Mobile No'),
                        _buildTextField(_emailController, 'Email'),
                        _buildTextField(_passwordController, 'Password',
                            obscureText: true),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _submitForm,
                          child: Text('Submit Application'),
                        ),
                        SizedBox(height: 20),
                        Text('Enclosed:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('1) Last Result Photo Copy'),
                        Text('2) Caste Certificate Photo Copy'),
                        Text('3) 12th/Diploma Leaving Certificate Photo Copy'),
                        Text('4) Birth Certificate/Domicile/Passport Copy'),
                        SizedBox(height: 20),
                        Text('NO DUES CERTIFICATE',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('1) Take signature of the following Sections:'),
                        Text('   - Library Student Section'),
                        Text('   - Scholarship Section'),
                        Text('   - Exam Section'),
                        Text('   - Account Section'),
                        Text('   - Hostel Office'),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your $label';
          }
          return null;
        },
      ),
    );
  }
}
