import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_no_dues/noduce_details.dart';
import 'package:flutter/material.dart';

class DepartmentFormDetailsScreen extends StatefulWidget {
  final String formId;
  final Map<String, dynamic> formData;

  const DepartmentFormDetailsScreen({
    super.key,
    required this.formId,
    required this.formData,
  });

  @override
  _DepartmentFormDetailsScreenState createState() =>
      _DepartmentFormDetailsScreenState();
}

class _DepartmentFormDetailsScreenState
    extends State<DepartmentFormDetailsScreen> {
  final _noteController = TextEditingController();

  final List<String> _verifiers = [
    'Lab 1',
    'Lab 2',
    'Lab 3',
    'Lab 4',
    'Lab 5',
    'Lab 6',
    'Lab 7',
    'Lab 8',
    'T&P',
    'TG & Project Guide'
  ];

  Map<String, bool> _verificationStatus = {};
  Map<String, bool> _notRequired = {};

  bool _departmentVerified = false;

  @override
  void initState() {
    super.initState();
    for (var v in _verifiers) {
      _verificationStatus[v] = widget.formData[v] ?? false;
      _notRequired[v] = widget.formData['${v}_notRequired'] ?? false;
    }
    _departmentVerified = widget.formData['departmentApproved'] ?? false;
    _noteController.text = widget.formData['departmentNote'] ?? '';
  }

  int get _doneCount => _verifiers
      .where((v) => _verificationStatus[v]! || _notRequired[v]!)
      .length;

  bool get _canDepartmentVerify => _doneCount == _verifiers.length;

  Future<void> _updateFormStatus() async {
    Map<String, dynamic> updateData = {
      'departmentApproved': _departmentVerified,
      'departmentStatus': _departmentVerified ? 'Verified' : 'Not Verified',
      'departmentNote': _noteController.text.trim(),
    };
    for (var v in _verifiers) {
      updateData[v] = _verificationStatus[v];
      updateData['${v}_notRequired'] = _notRequired[v];
    }

    try {
      await FirebaseFirestore.instance
          .collection('requesters')
          .doc(widget.formId)
          .update(updateData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Form status updated!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void _showStudentFormDialog() {
    showDialog(
        context: context,
        builder: (context) {
          final data = widget.formData;
          return AlertDialog(
            title: Text('Student Form Details'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: data.entries
                    .map((e) => Text('${e.key}: ${e.value}'))
                    .toList(),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context), child: Text('Close'))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Department Form Details")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Name: ${widget.formData['name'] ?? 'N/A'}',
                  style: TextStyle(fontWeight: FontWeight.bold)),

              SizedBox(height: 20),
              ElevatedButton.icon(
                icon: Icon(Icons.remove_red_eye),
                label: Text('View NoDue Details'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          NodueDetailsPage(docId: widget.formId),
                    ),
                  );
                },
              ),
              SizedBox(height: 16),

              // Top boolean toggle for full department verification
              Row(
                children: [
                  Text('Department Verified: ',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  Switch(
                    value: _departmentVerified,
                    activeColor: Colors.green,
                    inactiveThumbColor: Colors.red,
                    onChanged: _canDepartmentVerify
                        ? (val) {
                            setState(() => _departmentVerified = val);
                          }
                        : null,
                  ),
                  Text(
                    _departmentVerified ? 'YES' : 'NO',
                    style: TextStyle(
                        color: _departmentVerified ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              if (!_canDepartmentVerify)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    "All labs/T&P/TG must be verified or marked as not required.",
                    style: TextStyle(color: Colors.orange, fontSize: 13),
                  ),
                ),
              SizedBox(height: 12),

              // PROGRESS BAR
              LinearProgressIndicator(
                value: _doneCount / _verifiers.length,
                minHeight: 12,
                backgroundColor: Colors.grey.shade300,
              ),
              SizedBox(height: 8),
              Text('Completed: $_doneCount / ${_verifiers.length}',
                  style: TextStyle(fontSize: 14)),
              SizedBox(height: 12),

              ..._verifiers.map((ver) => Card(
                    margin: EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: Icon(
                          (_verificationStatus[ver]! || _notRequired[ver]!)
                              ? Icons.check_circle
                              : Icons.cancel,
                          color:
                              (_verificationStatus[ver]! || _notRequired[ver]!)
                                  ? Colors.green
                                  : Colors.red),
                      title: Text(ver),
                      subtitle: Row(
                        children: [
                          Checkbox(
                            value: _notRequired[ver]!,
                            onChanged: (val) {
                              setState(() {
                                _notRequired[ver] = val ?? false;
                                if (_notRequired[ver]!)
                                  _verificationStatus[ver] = false;
                              });
                            },
                          ),
                          Text("Not Required"),
                        ],
                      ),
                      trailing: Switch(
                        value: _verificationStatus[ver]!,
                        onChanged: _notRequired[ver]!
                            ? null
                            : (val) {
                                setState(() => _verificationStatus[ver] = val);
                              },
                      ),
                    ),
                  )),

              SizedBox(height: 16),
              // FEEDBACK / NOTE
              TextField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: 'Add Feedback / Note (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16),

              // VERIFY BUTTON
              ElevatedButton.icon(
                icon: Icon(Icons.verified),
                label: Text('Update Department Status'),
                onPressed: _canDepartmentVerify ? _updateFormStatus : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _canDepartmentVerify ? Colors.green : Colors.grey,
                ),
              ),

              SizedBox(height: 16),

              // VIEW FORM BUTTON
              // OutlinedButton.icon(
              //   icon: Icon(Icons.remove_red_eye),
              //   label: Text('View Student Form'),
              //   onPressed: _showStudentFormDialog,
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
