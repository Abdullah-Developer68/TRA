import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../services/api_service.dart';
import '../theme/app_theme.dart';

class AuthScreen extends ConsumerStatefulWidget {
  final VoidCallback onAuthenticated;

  const AuthScreen({super.key, required this.onAuthenticated});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _isLogin = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final fullName = _nameController.text.trim();

    if (email.isEmpty || password.isEmpty || (!_isLogin && fullName.isEmpty)) {
      setState(() => _errorMessage = 'Please fill in all fields.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final api = ApiService();
    try {
      if (_isLogin) {
        await api.login(email: email, password: password);
      } else {
        await api.signup(email: email, password: password, fullName: fullName);
      }
      if (mounted) {
        widget.onAuthenticated();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Icon Header
                  Center(
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppTheme.tint(AppTheme.primary, 0.14),
                        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                        border: Border.all(
                          color: AppTheme.tint(AppTheme.primary, 0.35),
                        ),
                      ),
                      child: const Icon(
                        LucideIcons.brain,
                        size: 26,
                        color: AppTheme.primaryLight,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    _isLogin ? 'Welcome back' : 'Create an account',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _isLogin
                        ? 'Sign in to access your 3-AI council sessions'
                        : 'Sign up to start querying the 3-AI council',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Form Container
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.card,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (!_isLogin) ...[
                          _buildTextField(
                            controller: _nameController,
                            label: 'Full Name',
                            hint: 'Your name',
                            icon: LucideIcons.user,
                          ),
                          const SizedBox(height: 14),
                        ],
                        _buildTextField(
                          controller: _emailController,
                          label: 'Email',
                          hint: 'name@example.com',
                          icon: LucideIcons.mail,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 14),
                        _buildTextField(
                          controller: _passwordController,
                          label: 'Password',
                          hint: '••••••••',
                          icon: LucideIcons.lock,
                          obscureText: true,
                        ),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.tint(AppTheme.error, 0.12),
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusSm),
                              border: Border.all(
                                color: AppTheme.tint(AppTheme.error, 0.35),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  LucideIcons.circleAlert,
                                  size: 14,
                                  color: AppTheme.error,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(
                                      color: Color(0xFFFCA5A5),
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        Material(
                          color: _isLoading
                              ? AppTheme.surfaceHigh
                              : AppTheme.primary,
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMd),
                          child: InkWell(
                            onTap: _isLoading ? null : _submit,
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusMd),
                            child: SizedBox(
                              height: 44,
                              child: Center(
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppTheme.primaryLight,
                                        ),
                                      )
                                    : Text(
                                        _isLogin ? 'Sign In' : 'Create Account',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Switch between Login / Signup
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isLogin
                            ? "Don't have an account? "
                            : "Already have an account? ",
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isLogin = !_isLogin;
                            _errorMessage = null;
                          });
                        },
                        child: Text(
                          _isLogin ? 'Sign up' : 'Sign in',
                          style: const TextStyle(
                            color: AppTheme.primaryLight,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.input,
            borderRadius: BorderRadius.circular(AppTheme.radiusSm + 2),
            border: Border.all(color: AppTheme.border),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Icon(icon, size: 15, color: AppTheme.textMuted),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: obscureText,
                  keyboardType: keyboardType,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 13.5,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 13.5,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
