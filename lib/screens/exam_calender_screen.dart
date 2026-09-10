import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExamCalendarScreen extends StatefulWidget {
  const ExamCalendarScreen({super.key});

  @override
  State<ExamCalendarScreen> createState() => _ExamCalendarScreenState();
}

class _ExamCalendarScreenState extends State<ExamCalendarScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _showExamDialog({DocumentSnapshot? exam}) async {
    final subjectController = TextEditingController(
      text: exam != null ? (exam['subject'] ?? '') : '',
    );

    final classController = TextEditingController(
      text: exam != null ? (exam['className'] ?? '') : '',
    );

    final timeController = TextEditingController(
      text: exam != null ? (exam['time'] ?? '') : '',
    );

    DateTime selectedDate = exam != null && exam['date'] is Timestamp
        ? (exam['date'] as Timestamp).toDate()
        : DateTime.now();

    bool isSaving = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> saveExam() async {
              final subject = subjectController.text.trim();
              final className = classController.text.trim();
              final time = timeController.text.trim();

              if (subject.isEmpty ||
                  className.isEmpty ||
                  time.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill all exam details.'),
                  ),
                );
                return;
              }

              setDialogState(() {
                isSaving = true;
              });

              try {
                if (exam == null) {
                  await _firestore.collection('exams').add({
                    'subject': subject,
                    'className': className,
                    'date': Timestamp.fromDate(selectedDate),
                    'time': time,
                    'createdAt': FieldValue.serverTimestamp(),
                  });
                } else {
                  await _firestore
                      .collection('exams')
                      .doc(exam.id)
                      .update({
                    'subject': subject,
                    'className': className,
                    'date': Timestamp.fromDate(selectedDate),
                    'time': time,
                    'updatedAt': FieldValue.serverTimestamp(),
                  });
                }

                if (mounted) {
                  Navigator.pop(dialogContext);

                  ScaffoldMessenger.of(this.context).showSnackBar(
                    SnackBar(
                      content: Text(
                        exam == null
                            ? 'Exam added successfully!'
                            : 'Exam updated successfully!',
                      ),
                    ),
                  );
                }
              } catch (e) {
                setDialogState(() {
                  isSaving = false;
                });

                if (mounted) {
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    SnackBar(
                      content: Text('Error saving exam: $e'),
                    ),
                  );
                }
              }
            }

            return AlertDialog(
              title: Text(
                exam == null ? 'Add New Exam' : 'Edit Exam',
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: subjectController,
                      decoration: InputDecoration(
                        labelText: 'Subject',
                        prefixIcon: const Icon(
                          Icons.menu_book_outlined,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    TextField(
                      controller: classController,
                      decoration: InputDecoration(
                        labelText: 'Class',
                        hintText: 'e.g. 5-A',
                        prefixIcon: const Icon(
                          Icons.class_outlined,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    InkWell(
                      onTap: isSaving
                          ? null
                          : () async {
                        final pickedDate =
                        await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2025),
                          lastDate: DateTime(2035),
                        );

                        if (pickedDate != null) {
                          setDialogState(() {
                            selectedDate = pickedDate;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Exam Date',
                          prefixIcon: const Icon(
                            Icons.calendar_today_outlined,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          '${selectedDate.day.toString().padLeft(2, '0')}/'
                              '${selectedDate.month.toString().padLeft(2, '0')}/'
                              '${selectedDate.year}',
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    TextField(
                      controller: timeController,
                      decoration: InputDecoration(
                        labelText: 'Exam Time',
                        hintText: 'e.g. 09:00 AM',
                        prefixIcon: const Icon(
                          Icons.access_time_outlined,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              actions: [
                TextButton(
                  onPressed: isSaving
                      ? null
                      : () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Cancel'),
                ),

                ElevatedButton(
                  onPressed: isSaving ? null : saveExam,
                  child: isSaving
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                      : Text(
                    exam == null ? 'Add Exam' : 'Update',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    subjectController.dispose();
    classController.dispose();
    timeController.dispose();
  }

  Future<void> _deleteExam(DocumentSnapshot exam) async {
    final subject = exam['subject'] ?? 'this exam';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Exam'),
          content: Text(
            'Are you sure you want to delete "$subject"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await _firestore
          .collection('exams')
          .doc(exam.id)
          .delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Exam deleted successfully!'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting exam: $e'),
          ),
        );
      }
    }
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) {
      return 'Date not available';
    }

    final date = timestamp.toDate();

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day/$month/$year';
  }

  Widget _examCard(DocumentSnapshot exam) {
    final data = exam.data() as Map<String, dynamic>;

    final subject = data['subject'] ?? 'Unknown Subject';
    final className = data['className'] ?? 'Class not specified';
    final time = data['time'] ?? 'Time not specified';

    final Timestamp? date = data['date'] is Timestamp
        ? data['date'] as Timestamp
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 65,
              decoration: BoxDecoration(
                color: const Color(0xFFE6F4F5),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.calendar_month_outlined,
                color: Color(0xFF0B5D6B),
                size: 30,
              ),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF183B4E),
                    ),
                  ),

                  const SizedBox(height: 7),

                  Row(
                    children: [
                      const Icon(
                        Icons.school_outlined,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        className,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 5),

                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 15,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _formatDate(date),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.access_time_outlined,
                        size: 15,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        time,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _showExamDialog(exam: exam);
                } else if (value == 'delete') {
                  _deleteExam(exam);
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined),
                      SizedBox(width: 10),
                      Text('Edit'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline),
                      SizedBox(width: 10),
                      Text('Delete'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: const BoxDecoration(
                color: Color(0xFFE6F4F5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.event_note_outlined,
                size: 55,
                color: Color(0xFF0B5D6B),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'No Exams Yet',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: Color(0xFF183B4E),
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Add an exam to create the school examination calendar.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        title: const Text(
          'Exam Calendar',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF0B5D6B),
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showExamDialog();
        },
        backgroundColor: const Color(0xFF0B5D6B),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Exam'),
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
              20,
              22,
              20,
              22,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0B5D6B),
                  Color(0xFF174A63),
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Examination Calendar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Manage upcoming school examinations.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('exams')
                  .orderBy('date')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'Error loading exams:\n${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF0B5D6B),
                    ),
                  );
                }

                final exams = snapshot.data?.docs ?? [];

                if (exams.isEmpty) {
                  return _emptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    20,
                    20,
                    100,
                  ),
                  itemCount: exams.length,
                  itemBuilder: (context, index) {
                    return _examCard(exams[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}