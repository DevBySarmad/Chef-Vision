import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../auth/auth_screen.dart';
import '../auth/email_verification_screen.dart';
import '../home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scale = Tween<double>(
      begin: 0.82,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = FirebaseAuth.instance;
    return StreamBuilder<User?>(
      stream: auth.userChanges(),
      initialData: auth.currentUser,
      builder: (context, snapshot) {
        if (snapshot.hasError) return const AuthScreen();
        if (snapshot.connectionState == ConnectionState.waiting &&
            snapshot.data == null) {
          return _buildSplash();
        }
        final user = snapshot.data;
        if (user == null) return const AuthScreen();
        if (!user.emailVerified) {
          return EmailVerificationScreen(email: user.email ?? '');
        }
        return const HomeScreen();
      },
    );
  }

  Widget _buildSplash() {
    const forest = Color(0xFF284C3B);
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5EF),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            Expanded(
              flex: 3,
              child: Center(
                child: FadeTransition(
                  opacity: _fade,
                  child: ScaleTransition(
                    scale: _scale,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 94,
                          height: 94,
                          decoration: BoxDecoration(
                            color: forest,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x263B5947),
                                blurRadius: 25,
                                offset: Offset(0, 12),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.restaurant_menu_rounded,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 22),
                        const Text(
                          'Chef Vision',
                          style: TextStyle(
                            color: forest,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'A little inspiration for your kitchen',
                          style: TextStyle(color: Color(0xFF70766F)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.only(bottom: 38),
              child: SpinKitPulse(color: Color(0xFFBE6B3F), size: 34),
            ),
          ],
        ),
      ),
    );
  }
}
