import 'dart:async';
import 'package:flutter/material.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFEAF7F8),
              Color(0xFFF5F7FB),
              Color(0xFFDCEAF5),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -80,
              right: -60,
              child: _circle(
                180,
                const Color(0x330B5D6B),
              ),
            ),

            Positioned(
              bottom: -70,
              left: -50,
              child: _circle(
                160,
                const Color(0x332B8A9A),
              ),
            ),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 105,
                    height: 105,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x22000000),
                          blurRadius: 25,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      size: 58,
                      color: Color(0xFF0B5D6B),
                    ),
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    'School Parent',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF12343B),
                    ),
                  ),

                  const Text(
                    'APP',
                    style: TextStyle(
                      fontSize: 14,
                      letterSpacing: 5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0B5D6B),
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'Connecting School & Families',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF607D85),
                    ),
                  ),

                  const SizedBox(height: 35),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _featureIcon(Icons.menu_book_rounded),
                      const SizedBox(width: 20),
                      _featureIcon(Icons.auto_graph_rounded),
                      const SizedBox(width: 20),
                      _featureIcon(Icons.groups_rounded),
                    ],
                  ),
                ],
              ),
            ),

            const Positioned(
              bottom: 35,
              left: 0,
              right: 0,
              child: Text(
                'Smart • Simple • Connected',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF607D85),
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  Widget _featureIcon(IconData icon) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: const Color(0xFF0B5D6B),
        size: 25,
      ),
    );
  }
}