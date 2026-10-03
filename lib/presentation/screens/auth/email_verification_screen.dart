import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({required this.email, super.key});

  final String email;

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isChecking = false;
  bool _isResending = false;

  Future<void> _checkStatus() async {
    if (_isChecking) return;
    setState(() => _isChecking = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      await user?.reload();
      if (!mounted) return;
      if (FirebaseAuth.instance.currentUser?.emailVerified == true) {
        _showMessage('Email verified. Loading your kitchen.');
      } else {
        _showMessage('Your email is not verified yet. Check your inbox.');
      }
    } on FirebaseAuthException catch (error) {
      _showMessage(error.message ?? 'Could not check verification status.');
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  Future<void> _resendVerification() async {
    if (_isResending) return;
    setState(() => _isResending = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showMessage('Sign in again to request a verification email.');
        return;
      }
      await user.sendEmailVerification();
      _showMessage('Verification email sent to ${widget.email}.');
    } on FirebaseAuthException catch (error) {
      _showMessage(error.message ?? 'Could not resend the verification email.');
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  Future<void> _returnToSignIn() async {
    await FirebaseAuth.instance.signOut();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    const forest = Color(0xFF284C3B);
    const orange = Color(0xFFBE6B3F);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          TextButton.icon(
            onPressed: _returnToSignIn,
            icon: const Icon(Icons.logout),
            label: const Text('Sign out'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(26),
                  child: Column(
                    children: [
                      Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF1E9),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: const Icon(
                          Icons.mark_email_read_outlined,
                          size: 34,
                          color: orange,
                        ),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        'Verify your email',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: forest,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'We sent a verification link to',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFF686E67)),
                      ),
                      const SizedBox(height: 5),
                      SelectableText(
                        widget.email,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: forest,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 25),
                      FilledButton.icon(
                        onPressed: _isChecking ? null : _checkStatus,
                        icon: _isChecking
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.verified_outlined),
                        label: const Text('Check Verification Status'),
                        style: FilledButton.styleFrom(
                          backgroundColor: forest,
                          minimumSize: const Size.fromHeight(50),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: _isResending ? null : _resendVerification,
                        icon: _isResending
                            ? const SizedBox.square(
                                dimension: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.forward_to_inbox_outlined),
                        label: const Text('Resend Code'),
                        style: TextButton.styleFrom(foregroundColor: orange),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
