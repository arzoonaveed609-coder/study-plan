import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/study_provider.dart';

class AllPlansScreen extends StatelessWidget {
  const AllPlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final goals = context.watch<StudyProvider>().goals;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      appBar: AppBar(
        title: const Text(
          "All Plans",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),

      body: goals.isEmpty
          ? const Center(
        child: Text(
          "Abhi tak koi plan nahi bana.",
          style: TextStyle(color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: goals.length,

        itemBuilder: (context, index) {
          final goal = goals[index];

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),

            child: ListTile(
              leading: Icon(
                goal.isCompleted
                    ? Icons.check_circle
                    : Icons.menu_book,

                color: goal.isCompleted
                    ? Colors.green
                    : const Color(0xFF4A6CF7),
              ),

              title: Text(
                goal.subject,

                style: TextStyle(
                  fontWeight: FontWeight.w600,

                  decoration: goal.isCompleted
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),

              subtitle: Text(
                "${goal.topic} • "
                    "${goal.date.day}/${goal.date.month}/${goal.date.year} • "
                    "${goal.time}",
              ),

              trailing: Row(
                mainAxisSize: MainAxisSize.min,

                children: [
                  // Checkbox
                  Checkbox(
                    value: goal.isCompleted,

                    activeColor:
                    const Color(0xFF4A6CF7),

                    onChanged: (value) {
                      if (value != null) {
                        context
                            .read<StudyProvider>()
                            .toggleGoalCompletion(
                          goal.id,
                          value,
                        );
                      }
                    },
                  ),

                  // Delete button
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                    ),

                    tooltip: "Delete",

                    onPressed: () async {
                      final shouldDelete =
                      await showDialog<bool>(
                        context: context,

                        builder: (context) {
                          return AlertDialog(
                            title: const Text(
                              "Delete Study Goal?",
                            ),

                            content: Text(
                              'Do you want to delete "${goal.subject}"?',
                            ),

                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(
                                    context,
                                    false,
                                  );
                                },

                                child:
                                const Text("Cancel"),
                              ),

                              TextButton(
                                onPressed: () {
                                  Navigator.pop(
                                    context,
                                    true,
                                  );
                                },

                                child: const Text(
                                  "Delete",
                                  style: TextStyle(
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );

                      if (shouldDelete == true) {
                        await context
                            .read<StudyProvider>()
                            .deleteGoal(goal.id);
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}