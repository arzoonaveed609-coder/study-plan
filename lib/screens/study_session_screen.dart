import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/study_provider.dart';
import 'circular_duration_picker.dart';
//import '../widgets/circular_duration_picker.dart';

class StudySessionScreen extends StatelessWidget {
  const StudySessionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StudyProvider>();
    final goal = provider.activeGoal;

    final bool hasTimeSet = provider.totalMinutesForSession > 0;

    final int displayMinutesTotal = hasTimeSet
        ? (provider.isRunning
        ? (provider.remainingSeconds / 60).ceil()
        : provider.totalMinutesForSession)
        : 0;

    final String centerLabel = hasTimeSet ? provider.formattedTime : "Set time";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Study Session',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 24),

            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.menu_book, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 12),

            Text(
              goal?.subject ?? 'General Study',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              goal?.topic ?? 'Focus Session',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),

            const SizedBox(height: 12),

            if (!provider.isRunning)
              const Text(
                "Drag the hour hand and minute hand to set your time",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),

            const SizedBox(height: 20),

// ---------------- Clock Dial with two hands ----------------
            SizedBox(
              width: 280,
              height: 280,
              child: CircularDurationPicker(
                totalMinutes: hasTimeSet
                    ? (provider.isRunning
                    ? displayMinutesTotal
                    : provider.totalMinutesForSession)
                    : 0,
                enabled: !provider.isRunning,
                centerLabel: centerLabel,
                onMinutesSelected: (minutes) {
                  context.read<StudyProvider>().setCustomDuration(minutes);
                },
              ),
            ),

            const SizedBox(height: 20),

// ---------------- Time display (clock ke NEECHE, clean) ----------------
            Text(
              centerLabel,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 4),

            if (!provider.isRunning && hasTimeSet)
              Text(
                "${provider.totalMinutesForSession ~/ 60}h ${provider.totalMinutesForSession % 60}m selected",
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),

            const SizedBox(height: 32),

            // ---------------- Start / Pause Button ----------------
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: !hasTimeSet
                    ? null
                    : () {
                  final p = context.read<StudyProvider>();
                  if (p.isRunning) {
                    p.pauseFocusSession();
                  } else {
                    p.startFocusSession();
                  }
                },
                icon: Icon(
                  provider.isRunning ? Icons.pause : Icons.play_arrow,
                  size: 20,
                ),
                label: Text(
                  provider.isRunning ? 'Pause' : 'Start Focus Session',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            TextButton(
              onPressed: hasTimeSet
                  ? () {
                context.read<StudyProvider>().resetSession();
              }
                  : null,
              child: const Text(
                'Reset Session',
                style: TextStyle(color: Colors.grey),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}