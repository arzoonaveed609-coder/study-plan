import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminNoticesScreen extends StatefulWidget {
  const AdminNoticesScreen({super.key});

  @override
  State<AdminNoticesScreen> createState() => _AdminNoticesScreenState();
}

class _AdminNoticesScreenState extends State<AdminNoticesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _showNoticeDialog({DocumentSnapshot? notice}) async {
    final titleController = TextEditingController(
      text: notice != null ? (notice['title'] ?? '') : '',
    );

    final bodyController = TextEditingController(
      text: notice != null ? (notice['body'] ?? '') : '',
    );

    String audience =
    notice != null ? (notice['audience'] ?? 'All') : 'All';

    bool isSaving = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> saveNotice() async {
              final title = titleController.text.trim();
              final body = bodyController.text.trim();

              if (title.isEmpty || body.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter title and notice details.'),
                  ),
                );
                return;
              }

              setDialogState(() {
                isSaving = true;
              });

              try {
                if (notice == null) {
                  await _firestore.collection('notices').add({
                    'title': title,
                    'body': body,
                    'audience': audience,
                    'createdAt': FieldValue.serverTimestamp(),
                  });
                } else {
                  await _firestore
                      .collection('notices')
                      .doc(notice.id)
                      .update({
                    'title': title,
                    'body': body,
                    'audience': audience,
                    'updatedAt': FieldValue.serverTimestamp(),
                  });
                }

                if (mounted) {
                  Navigator.pop(dialogContext);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        notice == null
                            ? 'Notice added successfully!'
                            : 'Notice updated successfully!',
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
                      content: Text('Error saving notice: $e'),
                    ),
                  );
                }
              }
            }

            return AlertDialog(
              title: Text(
                notice == null ? 'Add New Notice' : 'Edit Notice',
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Notice Title',
                        prefixIcon: const Icon(Icons.title),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: bodyController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Notice Details',
                        alignLabelWithHint: true,
                        prefixIcon: const Icon(Icons.description_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: audience,
                      decoration: InputDecoration(
                        labelText: 'Audience',
                        prefixIcon: const Icon(Icons.groups_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'All',
                          child: Text('All Parents'),
                        ),
                        DropdownMenuItem(
                          value: '5-A',
                          child: Text('Class 5-A'),
                        ),
                        DropdownMenuItem(
                          value: '3-B',
                          child: Text('Class 3-B'),
                        ),
                      ],
                      onChanged: isSaving
                          ? null
                          : (value) {
                        if (value != null) {
                          setDialogState(() {
                            audience = value;
                          });
                        }
                      },
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
                  onPressed: isSaving ? null : saveNotice,
                  child: isSaving
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                      : Text(
                    notice == null ? 'Add Notice' : 'Update',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
    bodyController.dispose();
  }

  Future<void> _deleteNotice(DocumentSnapshot notice) async {
    final title = notice['title'] ?? 'this notice';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Notice'),
          content: Text(
            'Are you sure you want to delete "$title"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await _firestore
          .collection('notices')
          .doc(notice.id)
          .delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notice deleted successfully!'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting notice: $e'),
          ),
        );
      }
    }
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) {
      return 'Recently added';
    }

    final date = timestamp.toDate();

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day/$month/$year';
  }

  Widget _noticeCard(DocumentSnapshot notice) {
    final data = notice.data() as Map<String, dynamic>;

    final title = data['title'] ?? 'Untitled Notice';
    final body = data['body'] ?? '';
    final audience = data['audience'] ?? 'All';

    final Timestamp? timestamp = data['createdAt'] is Timestamp
        ? data['createdAt'] as Timestamp
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F4F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.campaign_outlined,
                    color: Color(0xFF0B5D6B),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF183B4E),
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showNoticeDialog(notice: notice);
                    } else if (value == 'delete') {
                      _deleteNotice(notice);
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

            const SizedBox(height: 14),

            Text(
              body,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                const Icon(
                  Icons.groups_outlined,
                  size: 17,
                  color: Colors.grey,
                ),
                const SizedBox(width: 5),
                Text(
                  audience,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 15,
                  color: Colors.grey,
                ),
                const SizedBox(width: 5),
                Text(
                  _formatDate(timestamp),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
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
              decoration: BoxDecoration(
                color: const Color(0xFFE6F4F5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_none_outlined,
                size: 55,
                color: Color(0xFF0B5D6B),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Notices Yet',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: Color(0xFF183B4E),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add a school notice to keep parents and students informed.',
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
          'Admin Notices',
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
          _showNoticeDialog();
        },
        backgroundColor: const Color(0xFF0B5D6B),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Notice'),
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
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
                  'Manage Notices',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Create and manage important school announcements.',
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
                  .collection('notices')
                  .orderBy(
                'createdAt',
                descending: true,
              )
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'Error loading notices:\n${snapshot.error}',
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

                final notices = snapshot.data?.docs ?? [];

                if (notices.isEmpty) {
                  return _emptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    20,
                    20,
                    100,
                  ),
                  itemCount: notices.length,
                  itemBuilder: (context, index) {
                    return _noticeCard(notices[index]);
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