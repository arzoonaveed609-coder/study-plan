import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ParentStudentLinkingScreen extends StatefulWidget {
  const ParentStudentLinkingScreen({super.key});

  @override
  State<ParentStudentLinkingScreen> createState() =>
      _ParentStudentLinkingScreenState();
}

class _ParentStudentLinkingScreenState
    extends State<ParentStudentLinkingScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController parentEmailController =
  TextEditingController();
  final TextEditingController parentUidController =
  TextEditingController();
  final TextEditingController studentNameController =
  TextEditingController();
  final TextEditingController classController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    parentEmailController.dispose();
    parentUidController.dispose();
    studentNameController.dispose();
    classController.dispose();
    super.dispose();
  }

  Future<void> linkParentStudent() async {
    final parentEmail = parentEmailController.text.trim();
    final parentUid = parentUidController.text.trim();
    final studentName = studentNameController.text.trim();
    final className = classController.text.trim();

    if (parentEmail.isEmpty ||
        parentUid.isEmpty ||
        studentName.isEmpty ||
        className.isEmpty) {
      _showMessage('Please fill all fields.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Create/update parent profile in Firestore.
      await _firestore.collection('users').doc(parentUid).set(
        {
          'uid': parentUid,
          'name': 'Parent',
          'email': parentEmail,
          'phone': '',
          'role': 'parent',
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      // Create student link.
      await _firestore.collection('students').add({
        'studentName': studentName,
        'className': className,
        'parentEmail': parentEmail,
        'parentUid': parentUid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      parentEmailController.clear();
      parentUidController.clear();
      studentNameController.clear();
      classController.clear();

      _showMessage('Parent and student linked successfully!');
    } catch (e) {
      _showMessage('Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> deleteStudent(String documentId) async {
    try {
      await _firestore.collection('students').doc(documentId).delete();

      _showMessage('Student link deleted.');
    } catch (e) {
      _showMessage('Unable to delete link.');
    }
  }

  String formatDate(dynamic value) {
    if (value == null) return 'Recently';

    if (value is Timestamp) {
      final date = value.toDate();

      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';
    }

    return 'Recently';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        title: const Text(
          'Parent–Student Linking',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF0B5D6B),
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF0B5D6B),
                    Color(0xFF164E63),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.link,
                    color: Colors.white,
                    size: 38,
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Link Parent & Student',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Connect a parent account with a student.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Parent Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF172033),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: parentEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Parent Email',
                hintText: 'parent@school.pk',
                prefixIcon: const Icon(Icons.email_outlined),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: parentUidController,
              decoration: InputDecoration(
                labelText: 'Parent UID',
                hintText: 'Paste Firebase Authentication UID',
                prefixIcon: const Icon(Icons.fingerprint),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Parent UID is copied once from Firebase Authentication → Users.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Student Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF172033),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: studentNameController,
              decoration: InputDecoration(
                labelText: 'Student Name',
                hintText: 'e.g. Ali',
                prefixIcon: const Icon(Icons.person_outline),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: classController,
              decoration: InputDecoration(
                labelText: 'Class',
                hintText: 'e.g. 5-A',
                prefixIcon: const Icon(Icons.school_outlined),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : linkParentStudent,
                icon: isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Icon(Icons.link),
                label: Text(
                  isLoading ? 'Linking...' : 'Link Parent & Student',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0B5D6B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              'Linked Students',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF172033),
              ),
            ),

            const SizedBox(height: 12),

            StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('students')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),

              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(30),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      'Unable to load linked students.',
                    ),
                  );
                }

                final students = snapshot.data?.docs ?? [];

                if (students.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 45,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'No students linked yet.',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final doc = students[index];
                    final data =
                    doc.data() as Map<String, dynamic>;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor:
                            const Color(0xFFE0F2F1),
                            child: const Icon(
                              Icons.person,
                              color: Color(0xFF0B5D6B),
                            ),
                          ),

                          const SizedBox(width: 14),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['studentName'] ??
                                      'Student',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                Text(
                                  'Class: ${data['className'] ?? '-'}',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),

                                const SizedBox(height: 3),

                                Text(
                                  data['parentEmail'] ??
                                      'No email',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),

                                const SizedBox(height: 3),

                                Text(
                                  'Linked: ${formatDate(data['createdAt'])}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          IconButton(
                            onPressed: () {
                              deleteStudent(doc.id);
                            },
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}