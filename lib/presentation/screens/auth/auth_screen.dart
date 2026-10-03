import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;
  bool _passwordVisible = false;
  bool _isLoading = false;

  FirebaseAuth get _auth => FirebaseAuth.instance;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _isLoading) return;
    setState(() => _isLoading = true);
    try {
      final credential = _isSignUp
          ? await _auth.createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            )
          : await _auth.signInWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            );
      final user = credential.user;
      if (user == null) return;
      if (_isSignUp) await user.sendEmailVerification();
    } on FirebaseAuthException catch (error) {
      _showMessage(_authError(error));
    } catch (error) {
      _showMessage('Could not complete sign in: $error');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _continueWithGoogle() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      if (kIsWeb) {
        await _auth.signInWithPopup(GoogleAuthProvider());
      } else {
        final google = GoogleSignIn.instance;
        await google.initialize();
        final account = await google.authenticate();
        final tokens = account.authentication;
        final oauthCredential = GoogleAuthProvider.credential(
          idToken: tokens.idToken,
        );
        await _auth.signInWithCredential(oauthCredential);
      }
    } on FirebaseAuthException catch (error) {
      _showMessage(_authError(error));
    } catch (error) {
      _showMessage('Google sign in could not be completed: $error');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _forgotPassword() async {
    final controller = TextEditingController(
      text: _emailController.text.trim(),
    );
    final email = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset password'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'Email address'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Send link'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (email == null || email.isEmpty || !mounted) return;
    try {
      await _auth.sendPasswordResetEmail(email: email);
      _showMessage('Password reset email sent to $email.');
    } on FirebaseAuthException catch (error) {
      _showMessage(_authError(error));
    }
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Enter your email address.';
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Enter your password.';
    if (_isSignUp && value.length < 6) {
      return 'Use at least 6 characters.';
    }
    return null;
  }

  String _authError(FirebaseAuthException error) => switch (error.code) {
    'email-already-in-use' => 'An account already exists for this email.',
    'invalid-email' => 'That email address is not valid.',
    'invalid-credential' ||
    'wrong-password' ||
    'user-not-found' => 'Email or password is incorrect.',
    'weak-password' => 'Choose a stronger password.',
    'too-many-requests' => 'Too many attempts. Please try again later.',
    'network-request-failed' => 'Check your internet connection and try again.',
    _ => error.message ?? 'Authentication failed. Please try again.',
  };

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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 30, 22, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: forest,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.restaurant_menu_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _isSignUp ? 'Start cooking smarter.' : 'Welcome back.',
                    style: Theme.of(context).textTheme.headlineMedium
                        ?.copyWith(color: forest, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    _isSignUp
                        ? 'Create your Chef Vision account.'
                        : 'Sign in to find your next favorite meal.',
                    style: const TextStyle(color: Color(0xFF686E67)),
                  ),
                  const SizedBox(height: 24),
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(value: false, label: Text('Login')),
                      ButtonSegment(value: true, label: Text('Sign Up')),
                    ],
                    selected: {_isSignUp},
                    onSelectionChanged: _isLoading
                        ? null
                        : (selection) =>
                              setState(() => _isSignUp = selection.first),
                    style: ButtonStyle(
                      foregroundColor: WidgetStateProperty.resolveWith(
                        (states) => states.contains(WidgetState.selected)
                            ? Colors.white
                            : forest,
                      ),
                      backgroundColor: WidgetStateProperty.resolveWith(
                        (states) => states.contains(WidgetState.selected)
                            ? orange
                            : Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.email],
                              validator: _validateEmail,
                              decoration: const InputDecoration(
                                labelText: 'Email address',
                                prefixIcon: Icon(Icons.mail_outline),
                              ),
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: !_passwordVisible,
                              textInputAction: TextInputAction.done,
                              autofillHints: [
                                _isSignUp
                                    ? AutofillHints.newPassword
                                    : AutofillHints.password,
                              ],
                              validator: _validatePassword,
                              onFieldSubmitted: (_) => _submit(),
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  tooltip: _passwordVisible
                                      ? 'Hide password'
                                      : 'Show password',
                                  onPressed: () => setState(
                                    () => _passwordVisible = !_passwordVisible,
                                  ),
                                  icon: Icon(
                                    _passwordVisible
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                  ),
                                ),
                              ),
                            ),
                            if (!_isSignUp)
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: _isLoading
                                      ? null
                                      : _forgotPassword,
                                  child: const Text('Forgot Password?'),
                                ),
                              )
                            else
                              const SizedBox(height: 12),
                            const SizedBox(height: 6),
                            FilledButton(
                              onPressed: _isLoading ? null : _submit,
                              style: FilledButton.styleFrom(
                                backgroundColor: orange,
                                minimumSize: const Size.fromHeight(50),
                              ),
                              child: _isLoading
                                  ? const SizedBox.square(
                                      dimension: 21,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      _isSignUp ? 'Create account' : 'Login',
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 18),
                    child: Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text('OR'),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: _isLoading ? null : _continueWithGoogle,
                    icon: const Text(
                      'G',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF4285F4),
                      ),
                    ),
                    label: const Text('Continue with Google'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      foregroundColor: forest,
                      side: const BorderSide(color: Color(0xFFDADDD7)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
