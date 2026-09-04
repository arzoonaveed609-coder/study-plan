import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/study_goal.dart';
import '../providers/study_provider.dart' hide StudyGoal;
import 'login_screen.dart';


class CreateGoalScreen extends StatefulWidget {
  const CreateGoalScreen({super.key});

  @override
  State<CreateGoalScreen> createState() => _CreateGoalScreenState();
}

class _CreateGoalScreenState extends State<CreateGoalScreen> {
  // Subject aur Topic ab TextEditingController ki jagah simple String state
  // variables mein store honge, kyunki Autocomplete widget apna controller
  // khud manage karta hai.
  String _subject = "";
  String _topic = "";

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  int _durationMinutes = 25;
  String _priority = "Medium";

  // ---- Subjects ki list jisme se dropdown suggestions aayengi ----
  final List<String> _subjectsList = [
    "Math",
    "Mathematics",
    "Mechanics",
    "English",
    "Economics",
    "Environmental Science",
    "Computer Science",
    "Chemistry",
    "Civics",
    "Physics",
    "Physical Education",
    "Biology",
    "Business Studies",
    "History",
    "Geography",
    "Urdu",
    "Islamiyat",
    "Accounting",
    "Arts",
    "General Knowledge",
  ];

  // ---- Har Subject ke against related Topics/Chapters ----
  final Map<String, List<String>> _topicsMap = {
    "Math": ["Algebra", "Geometry", "Trigonometry", "Calculus", "Probability", "Statistics"],
    "Mathematics": ["Algebra", "Geometry", "Trigonometry", "Calculus", "Probability", "Statistics"],
    "English": ["Grammar", "Essay Writing", "Comprehension", "Literature", "Vocabulary", "Tenses"],
    "Computer Science": [
      "Programming Basics",
      "Data Structures",
      "Algorithms",
      "Networking",
      "Databases",
      "OOP Concepts",
    ],
    "Physics": ["Motion", "Force and Laws", "Work and Energy", "Electricity", "Optics", "Waves"],
    "Chemistry": [
      "Atomic Structure",
      "Periodic Table",
      "Chemical Bonding",
      "Acids and Bases",
      "Organic Chemistry",
    ],
    "Biology": ["Cell Structure", "Genetics", "Human Body Systems", "Ecology", "Photosynthesis"],
    "History": [
      "World War I",
      "World War II",
      "Ancient Civilizations",
      "Freedom Movement",
      "Mughal Empire",
    ],
    "Geography": ["Maps", "Climate", "Natural Resources", "Population", "Landforms"],
    "Urdu": ["Grammar", "Nazm", "Ghazal", "Essay", "Afsana"],
    "Islamiyat": ["Quran", "Hadith", "Seerat-un-Nabi", "Fiqh", "Islamic History"],
    "Economics": ["Demand and Supply", "Inflation", "GDP", "Market Structures"],
    "Business Studies": ["Marketing", "Finance", "Human Resource", "Entrepreneurship"],
    "Civics": ["Fundamental Rights", "Government Structure", "Democracy"],
    "Accounting": ["Journal Entries", "Ledger", "Trial Balance", "Final Accounts"],
    "Arts": ["Drawing", "Painting", "Sketching", "Art History"],
  };

  // Agar subject match na ho to sab topics ki combined list dikhayenge
  List<String> get _allTopics =>
      _topicsMap.values.expand((list) => list).toSet().toList();

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  void _addGoal() {
    if (_subject.trim().isEmpty) return;

    final goal = StudyGoal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      subject: _subject.trim(),
      topic: _topic.trim(),
      date: _selectedDate,
      time: _selectedTime.format(context),
      durationMinutes: _durationMinutes,
      priority: _priority,
    );

    // context.read -> sirf ek dafa call karke goal add karna hai
    context.read<StudyProvider>().addGoal(goal);
    Navigator.of(context).pop();
  }

  // ---- Reusable dropdown-list UI jo Autocomplete options dikhata hai ----
  Widget _buildOptionsView(
      BuildContext context,
      AutocompleteOnSelected<String> onSelected,
      Iterable<String> options,
      ) {
    return Align(
      alignment: Alignment.topLeft,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(10),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 220, minWidth: 280),
          child: ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: options.length,
            itemBuilder: (context, index) {
              final option = options.elementAt(index);
              return ListTile(
                dense: true,
                title: Text(option),
                onTap: () => onSelected(option),
              );
            },
          ),
        ),
      ),
    );
  }

  // ---- Subject ka Autocomplete field ----
  Widget _buildSubjectField() {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        final query = textEditingValue.text.trim();
        if (query.isEmpty) return const Iterable<String>.empty();
        return _subjectsList.where(
              (subject) => subject.toLowerCase().contains(query.toLowerCase()),
        );
      },
      onSelected: (String selection) {
        setState(() {
          _subject = selection;
          _topic = ""; // subject change hone par topic reset kar dena behtar hai
        });
      },
      optionsViewBuilder: _buildOptionsView,
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        // Field ka current text hamesha humare _subject state se sync rahega
        if (controller.text != _subject && !focusNode.hasFocus) {
          controller.text = _subject;
        }
        return TextField(
          controller: controller,
          focusNode: focusNode,
          onChanged: (value) => setState(() => _subject = value),
          decoration: InputDecoration(
            hintText: "e.g. Math",
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      },
    );
  }

  // ---- Topic/Chapter ka Autocomplete field (subject se related) ----
  Widget _buildTopicField() {
    return Autocomplete<String>(
      // Key isliye di hai taake jab subject badle to yeh field naya
      // "mount" ho aur purana typed topic clear ho jaye.
      key: ValueKey(_subject),
      optionsBuilder: (TextEditingValue textEditingValue) {
        final query = textEditingValue.text.trim().toLowerCase();
        if (query.isEmpty) return const Iterable<String>.empty();
        final available = _topicsMap[_subject] ?? _allTopics;
        return available.where((t) => t.toLowerCase().contains(query));
      },
      onSelected: (String selection) {
        setState(() => _topic = selection);
      },
      optionsViewBuilder: _buildOptionsView,
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          onChanged: (value) => setState(() => _topic = value),
          decoration: InputDecoration(
            hintText: "e.g. Algebra",
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text("Create Study Goal"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [Color(0xFF4A6CF7), Color(0xFFEC4899)],
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.flag, color: Colors.white),
                  SizedBox(height: 8),
                  Text(
                    "Create your study goal",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Set your subject, topic, time and priority to build your study plan.",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text("Subject", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            _buildSubjectField(),
            const SizedBox(height: 16),

            const Text("Topic / Chapter", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            _buildTopicField(),
            const SizedBox(height: 16),

            const Text("Study Duration", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(
                        "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}"),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickTime,
                    icon: const Icon(Icons.access_time, size: 16),
                    label: Text(_selectedTime.format(context)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            const Text("Duration (minutes)", style: TextStyle(fontWeight: FontWeight.w600)),
            Slider(
              value: _durationMinutes.toDouble(),
              min: 5,
              max: 120,
              divisions: 23,
              label: "$_durationMinutes min",
              onChanged: (v) => setState(() => _durationMinutes = v.round()),
            ),
            const SizedBox(height: 8),

            const Text("Priority", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _priority,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              items: ["Low", "Medium", "High"]
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (v) => setState(() => _priority = v!),
            ),
            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: _addGoal,
              icon: const Icon(Icons.check),
              label: const Text("Add to Today Plan"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A6CF7),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

