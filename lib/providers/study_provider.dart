import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
//import 'package:shared_preferences/shared_preferences.dart';

import '../models/study_goal.dart';

class StudyProvider extends ChangeNotifier {
  // ============================================================
  // LOGIN STATE
  // ============================================================

  String? _userEmail;

  bool get isLoggedIn => _userEmail != null;
  String? get userEmail => _userEmail;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      _userEmail = credential.user?.email ?? email.trim();

      // IMPORTANT:
      // Study Goals Firebase se load nahi honge.
      // Har fresh app session mein goals empty honge.
      _goals.clear();

      notifyListeners();

      return null;
    } on FirebaseAuthException catch (e) {
      return _mapAuthError(e);
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  Future<String?> signup(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      _userEmail = credential.user?.email ?? email.trim();

      _goals.clear();

      notifyListeners();

      return null;
    } on FirebaseAuthException catch (e) {
      return _mapAuthError(e);
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  Future<void> logout() async {
    await _auth.signOut();

    _userEmail = null;

    // Current goals bhi clear kar do
    _goals.clear();

    // Active timer/session bhi clear
    resetSession();

    notifyListeners();
  }

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
      todaysGoals.where((goal) => goal.isCompleted).length;

  double get todaysProgressPercent {
    if (todaysGoals.isEmpty) {
      return 0;
    }

    return completedTodayCount / todaysGoals.length;
  }

  // ============================================================
  // ADD GOAL
  // ============================================================

  // IMPORTANT:
  // Goal sirf app ke current session mein save hoga.
  // Firebase Firestore mein save NAHI hoga.

  Future<void> addGoal(StudyGoal goal) async {
    _goals.add(goal);

    notifyListeners();
  }

  // ============================================================
  // DELETE GOAL
  // ============================================================

  Future<void> deleteGoal(String id) async {
    final index = _goals.indexWhere(
          (goal) => goal.id == id,
    );

    if (index == -1) {
      return;
    }

    _goals.removeAt(index);

    notifyListeners();
  }

  // ============================================================
  // COMPLETE / UNCOMPLETE GOAL
  // ============================================================

  Future<void> toggleGoalCompletion(
      String id,
      bool completed,
      ) async {
    final index = _goals.indexWhere(
          (goal) => goal.id == id,
    );

    if (index == -1) {
      return;
    }

    _goals[index].isCompleted = completed;

    notifyListeners();
  }

  // ============================================================
  // MARK GOAL COMPLETED
  // ============================================================

  Future<void> markGoalCompleted(String id) async {
    await toggleGoalCompletion(id, true);
  }

  // ============================================================
  // FOCUS TIMER STATE
  // ============================================================

  StudyGoal? _activeSession;

  StudyGoal? get activeSession => _activeSession;

  StudyGoal? get activeGoal => _activeSession;

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
  // FORMATTED TIMER
  // ============================================================

  String get formattedTime {
    final hours = _remainingSeconds ~/ 3600;

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

  void setActiveSession(StudyGoal goal) {
    _activeSession = goal;

    _totalMinutesForSession =
        goal.durationMinutes;

    _remainingSeconds =
        goal.durationMinutes * 60;

    _isRunning = false;

    _timer?.cancel();

    notifyListeners();
  }

  // ============================================================
  // CUSTOM TIMER DURATION
  // ============================================================

  void setCustomDuration(int minutes) {
    if (_isRunning) {
      return;
    }

    if (minutes < 1) {
      minutes = 1;
    }

    _totalMinutesForSession = minutes;

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

    _isRunning = true;

    notifyListeners();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
          (timer) {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;

          notifyListeners();
        } else {
          _isRunning = false;

          timer.cancel();

          if (_activeSession != null) {
            markGoalCompleted(
              _activeSession!.id,
            );
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

    _isRunning = false;

    notifyListeners();
  }

  // ============================================================
  // RESET SESSION
  // ============================================================

  void resetSession() {
    _timer?.cancel();

    _isRunning = false;

    _remainingSeconds = 0;

    _totalMinutesForSession = 0;

    _activeSession = null;

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

  final List<Map<String, String>> _chatMessages = [];

  List<Map<String, String>> get chatMessages =>
      _chatMessages;

  bool _isChatLoading = false;

  bool get isChatLoading =>
      _isChatLoading;

  // IMPORTANT:
  // API key ko directly app ke code mein rakhna secure nahi hai.
  static const String _openRouterApiKey = '';

  get SharedPreferences => null;

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
            Map<String, String>.from(message),
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
      List<Map<String, String>> last10Messages,
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
        'Content-Type': 'application/json',
        'Authorization':
        'Bearer $_openRouterApiKey',
      },
      body: jsonEncode({
        'model': 'openai/gpt-4o-mini',
        'messages': last10Messages,
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
    data['choices']?[0]?['message']?['content'];

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
          : List<Map<String, String>>.from(
        _chatMessages,
      );

      final aiReply =
      await _callAi(last10Messages);

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

    await prefs.remove('chat_history');

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