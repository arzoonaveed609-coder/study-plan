import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../providers/study_provider.dart';
import '../models/study_goal.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  // ------------------------------------------------------------
  // DAILY PROGRESS DATA
  // ------------------------------------------------------------

  List<_DayStat> _buildDailyStats(List<StudyGoal> allGoals) {
    if (allGoals.isEmpty) return [];

    final Map<DateTime, List<StudyGoal>> grouped = {};

    for (final goal in allGoals) {
      final day = DateTime(
        goal.date.year,
        goal.date.month,
        goal.date.day,
      );

      grouped.putIfAbsent(day, () => []).add(goal);
    }

    final dates = grouped.keys.toList()..sort();

    return dates.map((date) {
      final dayGoals = grouped[date]!;

      final completed =
          dayGoals.where((goal) => goal.isCompleted).length;

      final total = dayGoals.length;

      final percentage =
      total == 0 ? 0.0 : (completed / total) * 100;

      return _DayStat(
        date: date,
        completed: completed,
        total: total,
        percent: percentage,
      );
    }).toList();
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return "${date.day} ${months[date.month - 1]}";
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StudyProvider>();

    final allGoals = provider.goals;

    final totalGoals = allGoals.length;

    final completedGoals =
        allGoals.where((goal) => goal.isCompleted).length;

    final dailyStats = _buildDailyStats(allGoals);

    final screenWidth = MediaQuery.of(context).size.width;

    final chartWidth = dailyStats.length <= 5
        ? screenWidth - 48
        : dailyStats.length * 75.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      appBar: AppBar(
        title: const Text(
          "Progress",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // --------------------------------------------------
            // TODAY'S PROGRESS
            // --------------------------------------------------

            const Text(
              "Today's Progress",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.grey.shade200,
                ),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [

                      const Text(
                        "Completed today",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),

                      Text(
                        "${(provider.todaysProgressPercent * 100).round()}%",
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A6CF7),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: provider.todaysProgressPercent,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade200,
                      color: const Color(0xFF4A6CF7),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "${provider.completedTodayCount} of "
                        "${provider.todaysGoals.length} goals completed",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --------------------------------------------------
            // OVERALL STATS
            // --------------------------------------------------

            const Text(
              "Overall Stats",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [

                Expanded(
                  child: _StatCard(
                    number: totalGoals,
                    title: "Total Goals",
                    icon: Icons.flag_outlined,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _StatCard(
                    number: completedGoals,
                    title: "Completed",
                    icon: Icons.check_circle_outline,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // --------------------------------------------------
            // PROGRESS GRAPH
            // --------------------------------------------------

            const Text(
              "Progress Over Time",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              dailyStats.isEmpty
                  ? "No study activity yet."
                  : "Daily goal completion percentage",
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 16),

            if (dailyStats.isEmpty)

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.grey.shade200,
                  ),
                ),
                child: const Text(
                  "Create and complete study goals "
                      "to see your progress here.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
              )

            else

              Container(
                padding: const EdgeInsets.fromLTRB(
                  8,
                  20,
                  16,
                  12,
                ),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.grey.shade200,
                  ),
                ),

                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,

                  child: SizedBox(
                    width: chartWidth,
                    height: 280,

                    child: LineChart(
                      LineChartData(

                        minY: 0,
                        maxY: 100,

                        // ------------------------------------------------
                        // TOUCH TOOLTIP
                        // ------------------------------------------------

                        lineTouchData: LineTouchData(
                          handleBuiltInTouches: true,

                          touchTooltipData:
                          LineTouchTooltipData(
                            getTooltipItems: (spots) {
                              return spots.map((spot) {
                                final index =
                                spot.x.toInt();

                                if (index < 0 ||
                                    index >=
                                        dailyStats.length) {
                                  return null;
                                }

                                final stat =
                                dailyStats[index];

                                return LineTooltipItem(
                                  "${_formatDate(stat.date)}\n"
                                      "${stat.completed}/${stat.total} completed\n"
                                      "${stat.percent.round()}%",

                                  const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight:
                                    FontWeight.w500,
                                  ),
                                );
                              }).toList();
                            },
                          ),
                        ),

                        // ------------------------------------------------
                        // CLEAN DOTTED GRID
                        // ------------------------------------------------

                        gridData: FlGridData(
                          show: true,

                          drawVerticalLine: false,

                          horizontalInterval: 25,

                          getDrawingHorizontalLine:
                              (value) {
                            return FlLine(
                              color: Colors.grey.shade300,
                              strokeWidth: 1,
                              dashArray: [4, 6],
                            );
                          },
                        ),

                        // ------------------------------------------------
                        // NO BORDER
                        // ------------------------------------------------

                        borderData: FlBorderData(
                          show: false,
                        ),

                        // ------------------------------------------------
                        // AXIS TITLES
                        // ------------------------------------------------

                        titlesData: FlTitlesData(

                          topTitles:
                          const AxisTitles(
                            sideTitles:
                            SideTitles(
                              showTitles: false,
                            ),
                          ),

                          rightTitles:
                          const AxisTitles(
                            sideTitles:
                            SideTitles(
                              showTitles: false,
                            ),
                          ),

                          leftTitles:
                          AxisTitles(
                            sideTitles:
                            SideTitles(
                              showTitles: true,
                              reservedSize: 38,
                              interval: 25,

                              getTitlesWidget:
                                  (value, meta) {
                                return Text(
                                  "${value.toInt()}%",
                                  style:
                                  const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            ),
                          ),

                          bottomTitles:
                          AxisTitles(
                            sideTitles:
                            SideTitles(
                              showTitles: true,
                              reservedSize: 32,
                              interval: 1,

                              getTitlesWidget:
                                  (value, meta) {
                                final index =
                                value.toInt();

                                if (index < 0 ||
                                    index >=
                                        dailyStats.length) {
                                  return const SizedBox
                                      .shrink();
                                }

                                return Padding(
                                  padding:
                                  const EdgeInsets
                                      .only(
                                    top: 8,
                                  ),
                                  child: Text(
                                    _formatDate(
                                      dailyStats[index]
                                          .date,
                                    ),
                                    style:
                                    const TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        // ------------------------------------------------
                        // PROFESSIONAL LINE
                        // ------------------------------------------------

                        lineBarsData: [

                          LineChartBarData(

                            spots: List.generate(
                              dailyStats.length,
                                  (index) {
                                return FlSpot(
                                  index.toDouble(),
                                  dailyStats[index]
                                      .percent,
                                );
                              },
                            ),

                            isCurved: true,

                            curveSmoothness: 0.25,

                            color:
                            const Color(0xFF4A6CF7),

                            barWidth: 2.5,

                            isStrokeCapRound: true,

                            // Small clean dots
                            dotData: FlDotData(
                              show: true,

                              getDotPainter:
                                  (
                                  spot,
                                  percent,
                                  bar,
                                  index,
                                  ) {
                                return FlDotCirclePainter(
                                  radius: 3.5,

                                  color:
                                  const Color(
                                    0xFF4A6CF7,
                                  ),

                                  strokeWidth: 2,

                                  strokeColor:
                                  Colors.white,
                                );
                              },
                            ),

                            // Very subtle background
                            belowBarData:
                            BarAreaData(
                              show: true,

                              color:
                              const Color(
                                0xFF4A6CF7,
                              ).withOpacity(0.04),

                              gradient:
                              LinearGradient(
                                begin:
                                Alignment.topCenter,
                                end:
                                Alignment.bottomCenter,
                                colors: [
                                  const Color(
                                    0xFF4A6CF7,
                                  ).withOpacity(0.08),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 10),

            if (dailyStats.length > 5)
              const Text(
                "Swipe left/right to view more days",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                ),
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// STAT CARD
// ================================================================

class _StatCard extends StatelessWidget {
  final int number;
  final String title;
  final IconData icon;

  const _StatCard({
    required this.number,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),

      child: Column(
        children: [

          Icon(
            icon,
            size: 22,
            color: const Color(0xFF4A6CF7),
          ),

          const SizedBox(height: 8),

          Text(
            "$number",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// DAILY STAT MODEL
// ================================================================

class _DayStat {
  final DateTime date;
  final int completed;
  final int total;
  final double percent;

  _DayStat({
    required this.date,
    required this.completed,
    required this.total,
    required this.percent,
  });
}