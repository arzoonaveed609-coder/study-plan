import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_plan/screens/topic_screen.dart';

import '../providers/study_provider.dart';
import 'create_goal_screen.dart';
import 'study_session_screen.dart';
import 'all_plans_screen.dart';
import 'progress_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StudyProvider>();
    final todaysGoals = provider.todaysGoals;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ==================================================
              // STUDY SPACE BANNER
              // ==================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF4A6CF7),
                      Color(0xFFEC4899),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Your Study Space 🚀",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      todaysGoals.isEmpty
                          ? "Create your first study goal for today"
                          : "${provider.completedTodayCount} of ${todaysGoals.length} goals completed today",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 12),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: provider.todaysProgressPercent,
                        backgroundColor: Colors.white24,
                        color: Colors.white,
                        minHeight: 6,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      "${(provider.todaysProgressPercent * 100).round()}% complete",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ==================================================
              // STUDY TOOLS
              // ==================================================

              const Text(
                "Study Tools",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.5,
                children: [

                  // ---------------- FOCUS TIMER ----------------

                  _ToolTile(
                    icon: Icons.timer_outlined,
                    label: "Focus Timer",
                    onTap: () {
                      if (todaysGoals.isNotEmpty) {
                        context
                            .read<StudyProvider>()
                            .setActiveSession(
                          todaysGoals.first,
                        );

                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                            const StudySessionScreen(),
                          ),
                        );
                      }
                    },
                  ),

                  // ---------------- AI PLANS ----------------

                  _ToolTile(
                    icon: Icons.event_note_outlined,
                    label: "AI Plans",
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                          const AllPlansScreen(),
                        ),
                      );
                    },
                  ),

                  // ---------------- TOPICS ----------------

                  _ToolTile(
                    icon: Icons.topic_outlined,
                    label: "Topics",
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                          const TopicsScreen(),
                        ),
                      );
                    },
                  ),

                  // ---------------- PROGRESS ----------------

                  _ToolTile(
                    icon: Icons.bar_chart_outlined,
                    label: "Progress",
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                          const ProgressScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ==================================================
              // STUDY GOAL
              // ==================================================

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                        const CreateGoalScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Study Goal"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    const Color(0xFF4A6CF7),
                    foregroundColor: Colors.white,
                    padding:
                    const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ==================================================
              // TODAY'S STUDY PLANS
              // ==================================================

              Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Today's Study Plan",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  IconButton(
                    icon: const Icon(
                      Icons.add_circle,
                      color: Color(0xFF4A6CF7),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                          const CreateGoalScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 4),

              // ==================================================
              // EMPTY PLAN
              // ==================================================

              if (todaysGoals.isEmpty)
                Padding(
                  padding:
                  const EdgeInsets.symmetric(
                    vertical: 24,
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        const Text(
                          "Today's plan is empty",
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),

                        const SizedBox(height: 4),

                        const Text(
                          "Add a subject, topic and time to create your study plan.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                          ),
                        ),

                        const SizedBox(height: 12),

                        OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                const CreateGoalScreen(),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.flag_outlined,
                          ),
                          label: const Text(
                            "Create Study Goal",
                          ),
                        ),
                      ],
                    ),
                  ),
                )

              // ==================================================
              // ADDED PLANS
              // ==================================================

              else
                ListView.builder(
                  shrinkWrap: true,
                  physics:
                  const NeverScrollableScrollPhysics(),
                  itemCount: todaysGoals.length,
                  itemBuilder:
                      (context, index) {
                    final goal =
                    todaysGoals[index];

                    return Card(
                      margin:
                      const EdgeInsets.symmetric(
                        vertical: 6,
                      ),
                      child: ListTile(

                        // ---------------- CHECKBOX ----------------

                        leading: Checkbox(
                          value: goal.isCompleted,
                          activeColor:
                          const Color(0xFF4A6CF7),

                          // Goal manually complete
                          // nahi ho sakta jab tak
                          // Focus Timer complete na ho.
                          onChanged:
                          goal.isFocusTimerCompleted
                              ? (value) {
                            if (value != null) {
                              context
                                  .read<
                                  StudyProvider>()
                                  .toggleGoalCompletion(
                                goal.id,
                                value,
                              );
                            }
                          }
                              : null,
                        ),

                        // ---------------- SUBJECT ----------------

                        title: Text(
                          goal.subject,
                          style: TextStyle(
                            fontWeight:
                            FontWeight.bold,
                            decoration:
                            goal.isCompleted
                                ? TextDecoration
                                .lineThrough
                                : TextDecoration
                                .none,
                          ),
                        ),

                        // ---------------- TOPIC + TIME ----------------

                        subtitle: Text(
                          "${goal.topic} • ${goal.time}",
                          style: TextStyle(
                            color:
                            goal.isCompleted
                                ? Colors.grey
                                : Colors.black87,
                          ),
                        ),

                        // ---------------- PLAY / COMPLETED ----------------

                        trailing: goal.isCompleted
                            ? const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        )
                            : IconButton(
                          icon: const Icon(
                            Icons
                                .play_circle_fill,
                            color:
                            Color(0xFF4A6CF7),
                          ),
                          onPressed: () {
                            context
                                .read<
                                StudyProvider>()
                                .setActiveSession(
                              goal,
                            );

                            Navigator.of(
                              context,
                            ).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                const StudySessionScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// STUDY TOOL TILE
// ============================================================

class _ToolTile extends StatelessWidget {
final IconData icon;
final String label;
final VoidCallback onTap;

const _ToolTile({
required this.icon,
required this.label,
required this.onTap,
});

@override
Widget build(BuildContext context)
{
return
InkWell
(
onTap
:
onTap
,
borderRadius
:
BorderRadius
.
circular
(
12
)
,
child
:
Container
(
decoration
:
BoxDecoration
(
color
:
Colors
.
white
,
borderRadius
:
BorderRadius
.
circular
(
12
)
,
border
:
Border
.
all
(
color
:
Colors
.
grey
.
shade200
,
)
,
)
,
child
:
Row
(
mainAxisAlignment
:
MainAxisAlignment
.
center
,
children
:
[
Icon
(
icon
,
color
:
const
Color
(
0xFF4A6CF7
)
,
)
,

const
SizedBox
(
width
:
8
)
,

Text
(
label
,
style
:
const
TextStyle
(
fontSize
:
13
,
)
,
)
,
]
,
),
),
);
}
}