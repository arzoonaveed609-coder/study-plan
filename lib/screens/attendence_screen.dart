import 'package:flutter/material.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  final Color primaryColor = const Color(0xFF0B5D6B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        title: const Text(
          'Attendance',
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

            // Attendance Summary
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

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text(
                    'Attendance Summary',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 18),

                  Row(
                    children: [

                      // Percentage
                      Expanded(
                        child: Column(
                          children: [
                            const Text(
                              '92%',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Attendance',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        width: 1,
                        height: 55,
                        color: Colors.white30,
                      ),

                      // Present
                      Expanded(
                        child: Column(
                          children: [
                            const Text(
                              '23',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Present',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        width: 1,
                        height: 55,
                        color: Colors.white30,
                      ),

                      // Absent
                      Expanded(
                        child: Column(
                          children: [
                            const Text(
                              '2',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Absent',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Attendance Record',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 14),

            // Present
            _attendanceCard(
              date: '10 September 2026',
              day: 'Thursday',
              status: 'Present',
              icon: Icons.check_circle_outline,
              statusColor: Colors.green,
            ),

            // Present
            _attendanceCard(
              date: '9 September 2026',
              day: 'Wednesday',
              status: 'Present',
              icon: Icons.check_circle_outline,
              statusColor: Colors.green,
            ),

            // Absent
            _attendanceCard(
              date: '8 September 2026',
              day: 'Tuesday',
              status: 'Absent',
              icon: Icons.cancel_outlined,
              statusColor: Colors.red,
            ),

            // Present
            _attendanceCard(
              date: '7 September 2026',
              day: 'Monday',
              status: 'Present',
              icon: Icons.check_circle_outline,
              statusColor: Colors.green,
            ),

            // Present
            _attendanceCard(
              date: '4 September 2026',
              day: 'Friday',
              status: 'Present',
              icon: Icons.check_circle_outline,
              statusColor: Colors.green,
            ),

            // Absent
            _attendanceCard(
              date: '3 September 2026',
              day: 'Thursday',
              status: 'Absent',
              icon: Icons.cancel_outlined,
              statusColor: Colors.red,
            ),

            const SizedBox(height: 10),

            // Attendance Note
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
                      Icons.info_outline,
                      color: primaryColor,
                    ),
                  ),

                  const SizedBox(width: 14),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Attendance Information',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),

                        SizedBox(height: 5),

                        Text(
                          'Parents can check their child’s '
                              'attendance record and monitor '
                              'regular attendance.',
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

  Widget _attendanceCard({
    required String date,
    required String day,
    required String status,
    required IconData icon,
    required Color statusColor,
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
            vertical: 9,
          ),

          leading: Container(
            padding: const EdgeInsets.all(11),

            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),

            child: Icon(
              icon,
              color: statusColor,
              size: 27,
            ),
          ),

          title: Text(
            date,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          subtitle: Text(day),

          trailing: Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}