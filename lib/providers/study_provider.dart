import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/study_goal.dart';

class StudyProvider extends ChangeNotifier {
  // ============================================================
  // FIREBASE
  // ============================================================

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // ============================================================
  // LOGIN STATE
  // ============================================================

  String? _userEmail;

  bool get isLoggedIn => _userEmail != null;

  String? get userEmail => _userEmail;

  // ============================================================
  // LOGIN
  // ============================================================

  Future<String?> login(
      String email,
      String password,
      ) async {
    try {
      final credential =
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      _userEmail =
          credential.user?.email ?? email.trim();

      await loadGoals();

      notifyListeners();

      return null;
    } on FirebaseAuthException catch (e) {
      return _mapAuthError(e);
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  // ============================================================
  // SIGN UP
  // ============================================================

  Future<String?> signup(
      String email,
      String password,
      ) async {
    try {
      final credential =
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;

      if (user == null) {
        return 'Account could not be created.';
      }

      _userEmail =
          user.email ?? email.trim();

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set({
        'email': user.email ?? email.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      _goals.clear();

      notifyListeners();

      return null;
    } on FirebaseAuthException catch (e) {
      return _mapAuthError(e);
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> logout() async {
    await _auth.signOut();

    _userEmail = null;

    _goals.clear();

    resetSession();

    notifyListeners();
  }

  // ============================================================
  // FIREBASE AUTH ERROR
  // ============================================================

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email. Please create an account first.';

      case 'wrong-password':
        return 'Incorrect password. Please try again.';

      case 'invalid-credential':
        return 'Email or password is incorrect.';

      case 'invalid-email':
        return 'Please enter a valid email address.';

      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';

      case 'user-disabled':
        return 'This account has been disabled.';

      case 'email-already-in-use':
        return 'This email is already registered. Please login instead.';

      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';

      case 'operation-not-allowed':
        return 'Email/Password sign-in is not enabled in Firebase Console.';

      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';

      default:
        return 'Something went wrong (${e.code}). Please try again.';
    }
  }

  // ============================================================
  // STUDY GOALS
  // ============================================================

  final List<StudyGoal> _goals = [];

  List<StudyGoal> get goals => _goals;

  // ============================================================
  // CURRENT USER GOALS REFERENCE
  // ============================================================

  CollectionReference<Map<String, dynamic>>?
  get _goalsCollection {
    final user = _auth.currentUser;

    if (user == null) {
      return null;
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('goals');
  }

  // ============================================================
  // LOAD GOALS FROM FIREBASE
  // ============================================================

  Future<void> loadGoals() async {
    final collection = _goalsCollection;

    if (collection == null) {
      _goals.clear();
      notifyListeners();
      return;
    }

    try {
      final snapshot = await collection.get();

      _goals.clear();

      for (final document in snapshot.docs) {
        final data = document.data();

        DateTime goalDate;

        final dateValue = data['date'];

        if (dateValue is Timestamp) {
          goalDate = dateValue.toDate();
        } else if (dateValue is String) {
          goalDate =
              DateTime.tryParse(dateValue) ??
                  DateTime.now();
        } else {
          goalDate = DateTime.now();
        }

        final goal = StudyGoal(
          id: data['id']?.toString() ?? document.id,
          subject: data['subject']?.toString() ?? '',
          topic: data['topic']?.toString() ?? '',
          date: goalDate,
          time: data['time']?.toString() ?? '',
          durationMinutes:
          (data['durationMinutes'] as num?)?.toInt() ??
              25,
          priority:
          data['priority']?.toString() ?? 'Medium',
          isCompleted:
          data['isCompleted'] == true,
          isFocusTimerCompleted:
          data['isFocusTimerCompleted'] == true,
        );

        _goals.add(goal);
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading goals: $e');
    }
  }

  // ============================================================
  // TODAY'S GOALS
  // ============================================================

  List<StudyGoal> get todaysGoals {
    final now = DateTime.now();

    return _goals
        .where(
          (goal) =>
      goal.date.year == now.year &&
          goal.date.month == now.month &&
          goal.date.day == now.day,
    )
        .toList();
  }

  int get completedTodayCount =>
      todaysGoals
          .where((goal) => goal.isCompleted)
          .length;

  double get todaysProgressPercent {
    if (todaysGoals.isEmpty) {
      return 0;
    }

    return completedTodayCount /
        todaysGoals.length;
  }

  // ============================================================
  // ADD GOAL
  // ============================================================

  Future<void> addGoal(StudyGoal goal) async {
    final collection = _goalsCollection;

    if (collection == null) {
      debugPrint(
        'No logged-in user. Goal was not saved.',
      );
      return;
    }

    try {
      await collection.doc(goal.id).set({
        'id': goal.id,
        'subject': goal.subject,
        'topic': goal.topic,
        'date': Timestamp.fromDate(goal.date),
        'time': goal.time,
        'durationMinutes': goal.durationMinutes,
        'priority': goal.priority,
        'isCompleted': false,
        'isFocusTimerCompleted': false,
        'createdAt':
        FieldValue.serverTimestamp(),
      });

      goal.isCompleted = false;
      goal.isFocusTimerCompleted = false;

      _goals.add(goal);

      notifyListeners();
    } catch (e) {
      debugPrint('Error adding goal: $e');
    }
  }

  // ============================================================
  // DELETE GOAL
  // ============================================================

  Future<void> deleteGoal(String id) async {
    final collection = _goalsCollection;

    if (collection == null) {
      return;
    }

    final index = _goals.indexWhere(
          (goal) => goal.id == id,
    );

    if (index == -1) {
      return;
    }

    try {
      await collection.doc(id).delete();

      _goals.removeAt(index);

      if (_activeSession?.id == id) {
        resetSession();
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting goal: $e');
    }
  }

  // ============================================================
  // COMPLETE / UNCOMPLETE GOAL
  // ============================================================

  Future<void> toggleGoalCompletion(
      String id,
      bool completed,
      ) async {
    final collection = _goalsCollection;

    if (collection == null) {
      return;
    }

    final index = _goals.indexWhere(
          (goal) => goal.id == id,
    );

    if (index == -1) {
      return;
    }

    final goal = _goals[index];

    // TRUE sirf Focus Timer complete hone ke baad
    if (completed &&
        !goal.isFocusTimerCompleted) {
      debugPrint(
        'Goal cannot be completed before Focus Timer finishes.',
      );
      return;
    }

    try {
      await collection.doc(id).update({
        'isCompleted': completed,
      });

      goal.isCompleted = completed;

      notifyListeners();
    } catch (e) {
      debugPrint(
        'Error updating goal completion: $e',
      );
    }
  }

  // ============================================================
  // MARK GOAL COMPLETED
  // ============================================================

  Future<void> markGoalCompleted(
      String id,
      ) async {
    final index = _goals.indexWhere(
          (goal) => goal.id == id,
    );

    if (index == -1) {
      return;
    }

    if (!_goals[index].isFocusTimerCompleted) {
      debugPrint(
        'Cannot mark goal completed. Focus Timer not finished.',
      );
      return;
    }

    await toggleGoalCompletion(
      id,
      true,
    );
  }

  // ============================================================
  // TIMER COMPLETION
  // ============================================================

  Future<void> _completeFocusTimerForGoal(
      String id,
      ) async {
    final index = _goals.indexWhere(
          (goal) => goal.id == id,
    );

    if (index == -1) {
      return;
    }

    final goal = _goals[index];

    if (goal.isFocusTimerCompleted) {
      return;
    }

    // ==========================================================
    // FIRST UPDATE LOCAL STATE
    // ==========================================================

    goal.isFocusTimerCompleted = true;

    goal.isCompleted = true;

    _focusSessionJustCompleted = true;

    // Is notifyListeners() ki wajah se
    // All Plans screen immediately ✓ show karegi.
    notifyListeners();

    // ==========================================================
    // THEN SAVE TO FIREBASE
    // ==========================================================

    final collection = _goalsCollection;

    if (collection == null) {
      return;
    }

    try {
      await collection.doc(id).update({
        'isFocusTimerCompleted': true,
        'isCompleted': true,
      });
    } catch (e) {
      debugPrint(
        'Error saving focus timer completion: $e',
      );
    }
  }

  // ============================================================
  // FOCUS TIMER STATE
  // ============================================================

  StudyGoal? _activeSession;

  StudyGoal? get activeSession =>
      _activeSession;

  StudyGoal? get activeGoal =>
      _activeSession;

  int _totalMinutesForSession = 0;

  int get totalMinutesForSession =>
      _totalMinutesForSession;

  int _remainingSeconds = 0;

  int get remainingSeconds =>
      _remainingSeconds;

  bool _isRunning = false;

  bool get isRunning => _isRunning;

  Timer? _timer;

  // ============================================================
  // COMPLETION SIGNAL FOR STUDY SESSION SCREEN
  // ============================================================

  bool _focusSessionJustCompleted = false;

  bool get focusSessionJustCompleted =>
      _focusSessionJustCompleted;

  // ============================================================
  // TIMER DURATION LOCK
  // ============================================================

  bool _sessionHasStarted = false;

  bool get canEditSessionDuration =>
      !_sessionHasStarted && !_isRunning;

  // ============================================================
  // FORMATTED TIMER
  // ============================================================

  String get formattedTime {
    final hours =
        _remainingSeconds ~/ 3600;

    final minutes =
        (_remainingSeconds % 3600) ~/ 60;

    final seconds =
        _remainingSeconds % 60;

    final secStr =
    seconds.toString().padLeft(2, '0');

    if (hours > 0) {
      final minStr =
      minutes.toString().padLeft(2, '0');

      return "${hours}h ${minStr}m ${secStr}s";
    } else if (minutes > 0) {
      return "${minutes}m ${secStr}s";
    } else {
      return "${seconds}s";
    }
  }

  // ============================================================
  // SET ACTIVE SESSION
  // ============================================================

  void setActiveSession(
      StudyGoal goal,
      ) {
    _timer?.cancel();

    _timer = null;

    _activeSession = goal;

    _totalMinutesForSession =
        goal.durationMinutes;

    _remainingSeconds =
        goal.durationMinutes * 60;

    _isRunning = false;

    _sessionHasStarted = false;

    _focusSessionJustCompleted = false;

    notifyListeners();
  }

  // ============================================================
  // CUSTOM TIMER DURATION
  // ============================================================

  void setCustomDuration(
      int minutes,
      ) {
    if (_isRunning ||
        _sessionHasStarted) {
      return;
    }

    if (minutes < 1) {
      minutes = 1;
    }

    _totalMinutesForSession =
        minutes;

    _remainingSeconds =
        minutes * 60;

    notifyListeners();
  }

  // ============================================================
  // START FOCUS SESSION
  // ============================================================

  void startFocusSession() {
    if (_isRunning) {
      return;
    }

    if (_remainingSeconds <= 0) {
      return;
    }

    if (_activeSession == null) {
      debugPrint(
        'No active goal selected.',
      );
      return;
    }

    // Once timer starts, duration cannot be changed.
    _sessionHasStarted = true;

    _isRunning = true;

    _focusSessionJustCompleted = false;

    notifyListeners();

    _timer?.cancel();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
          (timer) async {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;

          // ====================================================
          // FULL TIMER COMPLETED
          // ====================================================

          if (_remainingSeconds == 0) {
            _isRunning = false;

            timer.cancel();

            _timer = null;

            final goalId =
                _activeSession?.id;

            if (goalId != null) {
              await _completeFocusTimerForGoal(
                goalId,
              );
            }

            return;
          }

          notifyListeners();
        }
      },
    );
  }

  // ============================================================
  // PAUSE FOCUS SESSION
  // ============================================================

  void pauseFocusSession() {
    _timer?.cancel();

    _timer = null;

    _isRunning = false;

    // Pause se completion nahi hogi.
    notifyListeners();
  }

  // ============================================================
  // RESET SESSION
  // ============================================================

  void resetSession() {
    _timer?.cancel();

    _timer = null;

    _isRunning = false;

    _remainingSeconds = 0;

    _totalMinutesForSession = 0;

    _activeSession = null;

    _sessionHasStarted = false;

    _focusSessionJustCompleted = false;

    notifyListeners();
  }

  // ============================================================
  // END SESSION
  // ============================================================

  void endSession() {
    resetSession();
  }

  // ============================================================
  // AI CHAT STATE
  // ============================================================

  final List<Map<String, String>>
  _chatMessages = [];

  List<Map<String, String>>
  get chatMessages => _chatMessages;

  bool _isChatLoading = false;

  bool get isChatLoading =>
      _isChatLoading;

  static const String _openRouterApiKey = '';

  // ============================================================
  // LOAD CHAT HISTORY
  // ============================================================

  Future<void> loadChatHistory() async {
    final prefs =
    await SharedPreferences.getInstance();

    final savedMessages =
    prefs.getString('chat_history');

    if (savedMessages != null) {
      final List<dynamic> decoded =
      jsonDecode(savedMessages);

      _chatMessages
        ..clear()
        ..addAll(
          decoded.map(
                (message) =>
            Map<String, String>.from(
              message,
            ),
          ),
        );

      notifyListeners();
    }
  }

  // ============================================================
  // SAVE CHAT HISTORY
  // ============================================================

  Future<void> _saveChatHistory() async {
    final prefs =
    await SharedPreferences.getInstance();

    await prefs.setString(
      'chat_history',
      jsonEncode(_chatMessages),
    );
  }

  // ============================================================
  // CALL OPENROUTER AI
  // ============================================================

  Future<String> _callAi(
      List<Map<String, String>>
      last10Messages,
      ) async {
    if (_openRouterApiKey.trim().isEmpty) {
      throw Exception(
        'OpenRouter API key is not configured.',
      );
    }

    final response = await http.post(
      Uri.parse(
        'https://openrouter.ai/api/v1/chat/completions',
      ),
      headers: {
        'Content-Type':
        'application/json',
        'Authorization':
        'Bearer $_openRouterApiKey',
      },
      body: jsonEncode({
        'model':
        'openai/gpt-4o-mini',
        'messages':
        last10Messages,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'API Error: ${response.statusCode}\n'
            '${response.body}',
      );
    }

    final data =
    jsonDecode(response.body);

    final content =
    data['choices']?[0]?['message']
    ?['content'];

    if (content == null) {
      throw Exception(
        'AI returned an empty response.',
      );
    }

    return content.toString();
  }

  // ============================================================
  // SEND CHAT MESSAGE
  // ============================================================

  Future<void> sendChatMessage(
      String text,
      ) async {
    if (text.trim().isEmpty ||
        _isChatLoading) {
      return;
    }

    _chatMessages.add({
      'role': 'user',
      'content': text.trim(),
    });

    _isChatLoading = true;

    notifyListeners();

    await _saveChatHistory();

    try {
      final last10Messages =
      _chatMessages.length > 10
          ? _chatMessages.sublist(
        _chatMessages.length - 10,
      )
          : List<
          Map<String, String>
      >.from(
        _chatMessages,
      );

      final aiReply =
      await _callAi(
        last10Messages,
      );

      _chatMessages.add({
        'role': 'assistant',
        'content': aiReply,
      });
    } catch (e) {
      _chatMessages.add({
        'role': 'assistant',
        'content': 'Error: $e',
      });
    } finally {
      _isChatLoading = false;

      notifyListeners();

      await _saveChatHistory();
    }
  }

  // ============================================================
  // CLEAR CHAT
  // ============================================================

  Future<void> clearChat() async {
    final prefs =
    await SharedPreferences.getInstance();

    await prefs.remove(
      'chat_history',
    );

    _chatMessages.clear();

    notifyListeners();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _timer?.cancel();

    super.dispose();
  }
}