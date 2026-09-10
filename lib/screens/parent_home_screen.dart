import 'package:flutter/material.dart';
import 'package:study_plan/screens/today_overview_screen.dart';

import 'attendence_screen.dart';
import 'child_switch_screen.dart';
import 'fee_remainder_screen.dart';
//import 'todays_overview_screen.dart';
//import 'attendance_screen.dart';
import 'homework_screen.dart';
import 'school_notices_screen.dart';
import 'exam_timetable_screen.dart';
import 'results_screen.dart';
import 'leave_request_screen.dart';
import 'leave_status_screen.dart';
//import 'fee_reminder_screen.dart';

class ParentHomeScreen extends StatelessWidget {
  const ParentHomeScreen({super.key});

  static const Color primaryColor = Color(0xFF0B5D6B);
  static const Color backgroundColor = Color(0xFFF5F7FA);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Parent Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
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
            // Welcome Card
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
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, Parent!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Stay connected with your child\'s school activities.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Child Switch
            _menuCard(
              context,
              icon: Icons.child_care,
              title: 'Switch Child',
              subtitle: 'Select and manage your child',
              screen: const ChildSwitchScreen(),
            ),

            // Today's Overview
            _menuCard(
              context,
              icon: Icons.dashboard_outlined,
              title: 'Today\'s Overview',
              subtitle: 'View your child\'s daily summary',
              screen: const TodaysOverviewScreen(),
            ),

            // Attendance
            _menuCard(
              context,
              icon: Icons.calendar_month,
              title: 'Attendance',
              subtitle: 'Check attendance record',
              screen: const AttendanceScreen(),
            ),

            // Homework
            _menuCard(
              context,
              icon: Icons.menu_book,
              title: 'Homework',
              subtitle: 'View assigned homework',
              screen: const HomeworkScreen(),
            ),

            // School Notices
            _menuCard(
              context,
              icon: Icons.notifications_outlined,
              title: 'School Notices',
              subtitle: 'View important school announcements',
              screen: const SchoolNoticesScreen(),
            ),

            // Exam Timetable
            _menuCard(
              context,
              icon: Icons.event_note,
              title: 'Exam Timetable',
              subtitle: 'Check upcoming examination schedule',
              screen: const ExamTimetableScreen(),
            ),

            // Results
            _menuCard(
              context,
              icon: Icons.bar_chart,
              title: 'Results',
              subtitle: 'View your child\'s academic results',
              screen: const ResultsScreen(),
            ),

            // Leave Request
            _menuCard(
              context,
              icon: Icons.edit_calendar,
              title: 'Leave Request',
              subtitle: 'Submit a leave request',
              screen: const LeaveRequestScreen(),
            ),

            // Leave Status
            _menuCard(
              context,
              icon: Icons.fact_check_outlined,
              title: 'Leave Status',
              subtitle: 'Check submitted leave requests',
              screen: const LeaveStatusScreen(),
            ),

            // Fee Reminder
            _menuCard(
              context,
              icon: Icons.payments_outlined,
              title: 'Fee Reminder',
              subtitle: 'Check fee due dates and payment status',
              screen: const FeeReminderScreen(),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _menuCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required Widget screen,
      }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.arrow_forward,
            color: primaryColor,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(
          Icons.chevron_right,
          color: primaryColor,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => screen,
            ),
          );
        },
      ),
    );
  }
}