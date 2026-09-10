import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'admin_notice_screen.dart';
//import 'admin_notices_screen.dart';
//import 'exam_calendar_screen.dart';
import 'exam_calender_screen.dart';
import 'notification_screen.dart';
import 'parent_student_linking_screen.dart';
import 'school_report_screen.dart';
//import 'notifications_screen.dart';
import 'profile_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  final Color primaryColor = const Color(0xFF0B5D6B);
  final Color darkColor = const Color(0xFF172033);

  // Students count
  Stream<int> studentsCount() {
    return FirebaseFirestore.instance
        .collection('students')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Parents count
  Stream<int> parentsCount() {
    return FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'parent')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Teachers count
  Stream<int> teachersCount() {
    return FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'teacher')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Notices count
  Stream<int> noticesCount() {
    return FirebaseFirestore.instance
        .collection('notices')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                  const NotificationsScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Welcome Section
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
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome Admin 👋',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 7),
                  Text(
                    'Manage your school from one place.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // Statistics
            const Text(
              'School Statistics',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Color(0xFF172033),
              ),
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: StreamBuilder<int>(
                    stream: studentsCount(),
                    builder: (context, snapshot) {
                      return _statCard(
                        icon: Icons.school_outlined,
                        title: 'Students',
                        value: snapshot.data?.toString() ?? '0',
                      );
                    },
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: StreamBuilder<int>(
                    stream: teachersCount(),
                    builder: (context, snapshot) {
                      return _statCard(
                        icon: Icons.person_outline,
                        title: 'Teachers',
                        value: snapshot.data?.toString() ?? '0',
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: StreamBuilder<int>(
                    stream: parentsCount(),
                    builder: (context, snapshot) {
                      return _statCard(
                        icon: Icons.family_restroom,
                        title: 'Parents',
                        value: snapshot.data?.toString() ?? '0',
                      );
                    },
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: StreamBuilder<int>(
                    stream: noticesCount(),
                    builder: (context, snapshot) {
                      return _statCard(
                        icon: Icons.campaign_outlined,
                        title: 'Notices',
                        value: snapshot.data?.toString() ?? '0',
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Admin Controls
            const Text(
              'Admin Controls',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Color(0xFF172033),
              ),
            ),

            const SizedBox(height: 14),

            _menuCard(
              context,
              icon: Icons.campaign_outlined,
              title: 'School Notices',
              subtitle: 'Post and manage school notices',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                    const AdminNoticesScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            _menuCard(
              context,
              icon: Icons.calendar_month_outlined,
              title: 'Exam Calendar',
              subtitle: 'Add and manage upcoming exams',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                    const ExamCalendarScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            _menuCard(
              context,
              icon: Icons.link,
              title: 'Parent–Student Linking',
              subtitle: 'Connect parents with students',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                    const ParentStudentLinkingScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            _menuCard(
              context,
              icon: Icons.analytics_outlined,
              title: 'School Report',
              subtitle: 'View school statistics and activity',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                    const SchoolReportScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF7F8),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: primaryColor,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            value,
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: Color(0xFF172033),
            ),
          ),

          const SizedBox(height: 3),

          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required VoidCallback onTap,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(17),
      child: Container(
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
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF7F8),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: primaryColor,
                size: 26,
              ),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF172033),
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios,
              size: 17,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}