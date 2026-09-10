import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'admin_dahboard_screen.dart';
import 'parent_home_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  bool isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> selectRole(String role) async {
    final User? user = _auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login first.'),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Get existing user data
      final userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      final existingData = userDoc.data();

      // Save / update user information in Firestore
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(
        {
          'uid': user.uid,
          'name': existingData?['name'] ?? '',
          'email': user.email ?? existingData?['email'] ?? '',
          'phone': existingData?['phone'] ?? '',
          'role': role,
          'createdAt': existingData?['createdAt'] ??
              FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      if (!mounted) return;

      // Stop loading before navigation
      setState(() {
        isLoading = false;
      });

      // =========================
      // ADMIN MODE
      // =========================
      if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const AdminDashboardScreen(),
          ),
        );
      }

      // =========================
      // PARENT MODE
      // =========================
      else if (role == 'parent') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const ParentHomeScreen(),
          ),
        );
      }

      // =========================
      // TEACHER MODE
      // =========================
      else if (role == 'teacher') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Teacher role saved successfully!',
            ),
          ),
        );
      }
    } on FirebaseException catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Firebase error: ${e.message ?? e.code}',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error saving role: $e',
          ),
        ),
      );
    }
  }

  Widget _roleCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 30,
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF183B4E),
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        title: const Text(
          'Select Your Role',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF0B5D6B),
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFEAF7F8),
              Color(0xFFF5F7FB),
              Color(0xFFDCEAF5),
            ],
          ),
        ),

        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              Center(
                child: Container(
                  width: 78,
                  height: 78,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.manage_accounts_outlined,
                    size: 42,
                    color: Color(0xFF0B5D6B),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              const Center(
                child: Text(
                  'Welcome!',
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF183B4E),
                  ),
                ),
              ),

              const SizedBox(height: 7),

              const Center(
                child: Text(
                  'Select your account role to continue',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // ADMIN
              _roleCard(
                title: 'Admin',
                subtitle: 'Manage school notices, exams & reports',
                icon: Icons.admin_panel_settings_outlined,
                iconColor: const Color(0xFF0B5D6B),
                onTap: isLoading
                    ? null
                    : () => selectRole('admin'),
              ),

              // PARENT
              _roleCard(
                title: 'Parent',
                subtitle: 'View children, attendance & homework',
                icon: Icons.family_restroom_outlined,
                iconColor: const Color(0xFF3B7A57),
                onTap: isLoading
                    ? null
                    : () => selectRole('parent'),
              ),

              // TEACHER
              _roleCard(
                title: 'Teacher',
                subtitle: 'Manage attendance, homework & marks',
                icon: Icons.school_outlined,
                iconColor: const Color(0xFF7A5C3B),
                onTap: isLoading
                    ? null
                    : () => selectRole('teacher'),
              ),

              if (isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF0B5D6B),
                    ),
                  ),
                ),

              const SizedBox(height: 15),

              const Center(
                child: Text(
                  'School Parent App • Smart • Simple • Connected',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}