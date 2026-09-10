import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SchoolReportScreen extends StatelessWidget {
  const SchoolReportScreen({super.key});

  final Color primaryColor = const Color(0xFF0B5D6B);
  final Color darkColor = const Color(0xFF172033);

  Stream<int> collectionCount(String collection) {
    return FirebaseFirestore.instance
        .collection(collection)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Stream<int> roleCount(String role) {
    return FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: role)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Stream<int> upcomingExamsCount() {
    final today = DateTime.now();

    return FirebaseFirestore.instance
        .collection('exams')
        .where(
      'date',
      isGreaterThanOrEqualTo: Timestamp.fromDate(today),
    )
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Stream<int> pendingLeavesCount() {
    return FirebaseFirestore.instance
        .collection('leaveRequests')
        .where('status', isEqualTo: 'Pending')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Stream<int> linkedParentCount() {
    return FirebaseFirestore.instance
        .collection('students')
        .snapshots()
        .map((snapshot) {
      final parentUids = <String>{};

      for (final doc in snapshot.docs) {
        final data = doc.data();

        final uid = data['parentUid'];

        if (uid != null && uid.toString().isNotEmpty) {
          parentUids.add(uid.toString());
        }
      }

      return parentUids.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'School Report',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
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
                    Icons.analytics_outlined,
                    color: Colors.white,
                    size: 42,
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'School Overview',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Live information from your school database.',
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

            const SizedBox(height: 25),

            const Text(
              'School Statistics',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Color(0xFF172033),
              ),
            ),

            const SizedBox(height: 14),

            StreamBuilder<int>(
              stream: collectionCount('students'),
              builder: (context, snapshot) {
                return _reportCard(
                  icon: Icons.school_outlined,
                  title: 'Students',
                  value: snapshot.data?.toString() ?? '0',
                );
              },
            ),

            const SizedBox(height: 12),

            StreamBuilder<int>(
              stream: roleCount('parent'),
              builder: (context, snapshot) {
                return _reportCard(
                  icon: Icons.family_restroom,
                  title: 'Parents',
                  value: snapshot.data?.toString() ?? '0',
                );
              },
            ),

            const SizedBox(height: 12),

            StreamBuilder<int>(
              stream: roleCount('teacher'),
              builder: (context, snapshot) {
                return _reportCard(
                  icon: Icons.person_outline,
                  title: 'Teachers',
                  value: snapshot.data?.toString() ?? '0',
                );
              },
            ),

            const SizedBox(height: 12),

            StreamBuilder<int>(
              stream: linkedParentCount(),
              builder: (context, snapshot) {
                return _reportCard(
                  icon: Icons.link,
                  title: 'Linked Parent Accounts',
                  value: snapshot.data?.toString() ?? '0',
                );
              },
            ),

            const SizedBox(height: 28),

            const Text(
              'Activity Overview',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Color(0xFF172033),
              ),
            ),

            const SizedBox(height: 14),

            StreamBuilder<int>(
              stream: collectionCount('notices'),
              builder: (context, snapshot) {
                return _reportCard(
                  icon: Icons.campaign_outlined,
                  title: 'Published Notices',
                  value: snapshot.data?.toString() ?? '0',
                );
              },
            ),

            const SizedBox(height: 12),

            StreamBuilder<int>(
              stream: upcomingExamsCount(),
              builder: (context, snapshot) {
                return _reportCard(
                  icon: Icons.calendar_month_outlined,
                  title: 'Upcoming Exams',
                  value: snapshot.data?.toString() ?? '0',
                );
              },
            ),

            const SizedBox(height: 12),

            StreamBuilder<int>(
              stream: pendingLeavesCount(),
              builder: (context, snapshot) {
                return _reportCard(
                  icon: Icons.assignment_outlined,
                  title: 'Pending Leave Requests',
                  value: snapshot.data?.toString() ?? '0',
                );
              },
            ),

            const SizedBox(height: 12),

            StreamBuilder<int>(
              stream: collectionCount('homework'),
              builder: (context, snapshot) {
                return _reportCard(
                  icon: Icons.menu_book_outlined,
                  title: 'Homework Posted',
                  value: snapshot.data?.toString() ?? '0',
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _reportCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
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
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF7F8),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: primaryColor,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF172033),
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0B5D6B),
            ),
          ),
        ],
      ),
    );
  }
}