import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/app_provider.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // Registration Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _ffUidController = TextEditingController();
  final _ignController = TextEditingController();

  bool _isLogin = true;
  String _error = '';

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A0E1A), Color(0xFF131B2E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.sports_esports_rounded,
                    size: 80,
                    color: Color(0xFFFF5722),
                  ).animate().scale(duration: 600.ms, curve: Curves.elasticOut).shimmer(delay: 1.seconds),
                  const SizedBox(height: 16),
                  Text(
                    'OSG LIVE',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isLogin ? 'WELCOME BACK, SOLDIER' : 'JOIN THE ELITE SQUAD',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white60,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 40),
                  if (_error.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        border: Border.all(color: Colors.red.withOpacity(0.5)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(_error, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
                    ),
                  
                  if (_isLogin) _buildLoginForm() else _buildRegisterForm(),

                  const SizedBox(height: 32),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF5722),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 8,
                      shadowColor: const Color(0xFFFF5722).withOpacity(0.5),
                    ),
                    onPressed: provider.isLoading ? null : _handleAuth,
                    child: provider.isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(
                            _isLogin ? 'SIGN IN' : 'CREATE ACCOUNT',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                          ),
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isLogin = !_isLogin;
                        _error = '';
                      });
                    },
                    child: Text(
                      _isLogin ? "DON'T HAVE AN ACCOUNT? REGISTER" : 'ALREADY A MEMBER? LOGIN',
                      style: const TextStyle(color: Color(0xFFFF9800), fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1),
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

  Widget _buildLoginForm() {
    return Column(
      children: [
        _buildTextField(_identifierController, 'Email or Mobile', Icons.person_outline),
        const SizedBox(height: 16),
        _buildTextField(_passwordController, 'Password', Icons.lock_outline, obscure: true),
      ],
    ).animate().fadeIn();
  }

  Widget _buildRegisterForm() {
    return Column(
      children: [
        _buildTextField(_nameController, 'Full Name', Icons.badge_outlined),
        const SizedBox(height: 12),
        _buildTextField(_emailController, 'Email Address', Icons.email_outlined),
        const SizedBox(height: 12),
        _buildTextField(_mobileController, 'Mobile Number', Icons.phone_android_outlined),
        const SizedBox(height: 12),
        _buildTextField(_ffUidController, 'Free Fire UID', Icons.fingerprint),
        const SizedBox(height: 12),
        _buildTextField(_ignController, 'In-Game Name (IGN)', Icons.sports_esports_outlined),
        const SizedBox(height: 12),
        _buildTextField(_passwordController, 'Create Password', Icons.lock_reset_outlined, obscure: true),
      ],
    ).animate().fadeIn();
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white38, fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xFFFF5722), size: 20),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF5722)),
        ),
      ),
    );
  }

  Future<void> _handleAuth() async {
    final provider = Provider.of<AppProvider>(context, listen: false);
    setState(() => _error = '');
    
    try {
      if (_isLogin) {
        await provider.login(_identifierController.text.trim(), _passwordController.text.trim());
        if (!mounted) return;
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      } else {
        await provider.register({
          'fullName': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'mobile': _mobileController.text.trim(),
          'ffUid': _ffUidController.text.trim(),
          'ign': _ignController.text.trim(),
          'password': _passwordController.text.trim(),
          'state': 'Not Set',
          'dob': '2000-01-01',
        });
        setState(() {
          _isLogin = true;
          _error = 'Account created! Please login.';
        });
      }
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    }
  }
}
