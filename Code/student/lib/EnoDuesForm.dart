import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:student/SuccessScreen.dart';

class EnoDuesForm extends StatefulWidget {
  @override
  _EnoDuesFormState createState() => _EnoDuesFormState();
}

class _EnoDuesFormState extends State<EnoDuesForm> {
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
  bool _isUpdate = false; // Track if the form is for updating

  @override
  void initState() {
    super.initState();
    _loadFormData();
  }

  // Function to load form data if it exists
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
          // Fill the form with existing data
          Map<String, dynamic> data =
              formSnapshot.data() as Map<String, dynamic>;
          _nameController.text = data['name'] ?? '';
          _classController.text = data['class'] ?? '';
          _branchController.text = data['branch'] ?? '';
          _admissionYearController.text = data['admissionYear'] ?? '';
          _birthDateController.text = data['birthDate'] ?? '';
          _placeOfBirthController.text = data['placeOfBirth'] ?? '';
          _nationalityController.text = data['nationality'] ?? '';
          _religionController.text = data['religion'] ?? '';
          _casteController.text = data['caste'] ?? '';
          _motherNameController.text = data['motherName'] ?? '';
          _previousCollegeController.text = data['previousCollege'] ?? '';
          _reasonController.text = data['reason'] ?? '';
          _mobileController.text = data['mobile'] ?? '';
          _emailController.text = data['email'] ?? '';

          setState(() {
            _isUpdate = true; // Enable update mode
          });
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

  // Function to submit or update the form
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        String uid = user.uid;

        try {
          // Save or update form data in Firestore
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

          setState(() {
            _isLoading = false;
          });

          // Navigate to SuccessScreen after successful submission or update
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

  // Function to clear the form fields
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Application for Transfer Certificate'),
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
                      Text('Date: ${DateTime.now().toLocal()}'),
                      SizedBox(height: 20),
                      Text('To,', style: TextStyle(fontSize: 16)),
                      SizedBox(height: 5),
                      Text('The Principal,'),
                      Text('SKN Sinhgad Institute of Technology & Science'),
                      Text('Kusgaon (Bk), Lonavala'),
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
                      _buildTextField(_motherNameController, 'Mother\'s Name'),
                      _buildTextField(
                          _previousCollegeController, 'Previous College Name'),
                      _buildTextField(
                          _reasonController, 'Reason for College Leaving'),
                      _buildTextField(_mobileController, 'Mobile No'),
                      _buildTextField(_emailController, 'Email'),
                      _buildTextField(_passwordController, 'Password',
                          obscureText: true),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _submitForm,
                        child: Text(_isUpdate
                            ? 'Update Application'
                            : 'Submit Application'),
                      ),
                      SizedBox(height: 20),
                      Text('Enclosed:'),
                      Text('1) Last Result Photo Copy'),
                      Text('2) Caste Certificate Photo Copy'),
                      Text('3) 12th/Diploma Leaving Certificate Photo Copy'),
                      Text('4) Birth Certificate/Domicile/Passport Copy'),
                      SizedBox(height: 20),
                      Text('NO DUES CERTIFICATE'),
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
    );
  }

  // Helper function to build text fields
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
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }
}
