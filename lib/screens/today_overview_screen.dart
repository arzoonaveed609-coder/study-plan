import 'package:flutter/material.dart';

class TodaysOverviewScreen extends StatelessWidget {
  const TodaysOverviewScreen({super.key});

  final Color primaryColor = const Color(0xFF0B5D6B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        title: const Text(
          "Today's Overview",
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

            // Date Card
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

              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),

                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),

                    child: const Icon(
                      Icons.calendar_today_outlined,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),

                  const SizedBox(width: 16),

                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Today's Information",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 5),

                      Text(
                        'Monday, 10 September 2026',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              "Today's Summary",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 14),

            // Attendance
            _infoCard(
              icon: Icons.fact_check_outlined,
              title: 'Attendance',
              value: 'Present',
              subtitle: 'Your child is present today',
              iconColor: Colors.green,
            ),

            // Homework
            _infoCard(
              icon: Icons.menu_book_outlined,
              title: 'Homework',
              value: '3 Tasks',
              subtitle: 'Homework tasks assigned today',
              iconColor: Colors.orange,
            ),

            // Notices
            _infoCard(
              icon: Icons.campaign_outlined,
              title: 'School Notices',
              value: '2 New',
              subtitle: 'New announcements from school',
              iconColor: Colors.blue,
            ),

            // Exams
            _infoCard(
              icon: Icons.event_note_outlined,
              title: 'Upcoming Exams',
              value: '1 Exam',
              subtitle: 'An examination is coming soon',
              iconColor: Colors.purple,
            ),

            // Leave
            _infoCard(
              icon: Icons.event_busy_outlined,
              title: 'Leave Request',
              value: 'No Active Request',
              subtitle: 'You have no pending leave request',
              iconColor: Colors.redAccent,
            ),

            const SizedBox(height: 10),

            // Important Reminder
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: primaryColor.withOpacity(0.15),
                ),
              ),

              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),

                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: Icon(
                      Icons.notifications_active_outlined,
                      color: primaryColor,
                    ),
                  ),

                  const SizedBox(width: 14),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Parent Reminder',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 5),

                        Text(
                          'Please check your child’s homework, '
                              'attendance and school notices regularly.',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),

      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),

        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 10,
          ),

          leading: Container(
            padding: const EdgeInsets.all(11),

            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),

            child: Icon(
              icon,
              color: iconColor,
              size: 27,
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

          trailing: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}