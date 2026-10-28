import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../services/api_service.dart';
import '../theme/app_theme.dart';

enum AuthStep {
  login,
  signup,
  otpVerification,
}

class AuthScreen extends ConsumerStatefulWidget {
  final Function(UserAccount user) onAuthenticated;

  const AuthScreen({super.key, required this.onAuthenticated});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  AuthStep _currentStep = AuthStep.login;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _otpController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  String _targetEmail = '';
  String _otpType = 'sign-in';
  String? _devOtp;

  int _resendCountdown = 0;
  Timer? _countdownTimer;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _otpController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _countdownTimer?.cancel();
    setState(() => _resendCountdown = 30);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_resendCountdown <= 1) {
        timer.cancel();
        setState(() => _resendCountdown = 0);
      } else {
        setState(() => _resendCountdown--);
      }
    });
  }

  Future<void> _handleLoginOrSignup() async {
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text.trim();
    final fullName = _nameController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please enter your email and password.');
      return;
    }

    if (_currentStep == AuthStep.signup && fullName.isEmpty) {
      setState(() => _errorMessage = 'Please enter your full name.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    final api = ApiService();
    try {
      if (_currentStep == AuthStep.login) {
        final res = await api.login(email: email, password: password);
        _targetEmail = email;
        _otpType = res['type'] as String? ?? 'sign-in';
        _devOtp = res['devOtp'] as String?;
        _otpController.clear();
        setState(() {
          _currentStep = AuthStep.otpVerification;
          _isLoading = false;
          _successMessage = 'A 6-digit OTP code has been sent to your email.';
        });
        _startResendTimer();
      } else {
        final res = await api.signup(email: email, password: password, fullName: fullName);
        _targetEmail = email;
        _otpType = res['type'] as String? ?? 'email-verification';
        _devOtp = res['devOtp'] as String?;
        _otpController.clear();
        setState(() {
          _currentStep = AuthStep.otpVerification;
          _isLoading = false;
          _successMessage = 'Account created! Enter the OTP sent to your email.';
        });
        _startResendTimer();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _handleVerifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length < 4) {
      setState(() => _errorMessage = 'Please enter the 6-digit OTP code.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final api = ApiService();
    try {
      final user = await api.verifyOtp(
        email: _targetEmail,
        otp: otp,
        type: _otpType,
      );

      if (mounted) {
        widget.onAuthenticated(user);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _handleResendOtp() async {
    if (_resendCountdown > 0 || _isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    final api = ApiService();
    try {
      final res = await api.resendOtp(email: _targetEmail, type: _otpType);
      _devOtp = res['devOtp'] as String?;
      setState(() {
        _isLoading = false;
        _successMessage = 'A new verification code has been dispatched.';
      });
      _startResendTimer();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
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
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Icon Header
                  Center(
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppTheme.tint(AppTheme.primary, 0.16),
                        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                        border: Border.all(
                          color: AppTheme.tint(AppTheme.primary, 0.4),
                        ),
                      ),
                      child: Icon(
                        _currentStep == AuthStep.otpVerification
                            ? LucideIcons.mailCheck
                            : LucideIcons.brain,
                        size: 28,
                        color: AppTheme.primaryLight,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Header Titles
                  Text(
                    _getTitle(),
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
                    _getSubtitle(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Form Container
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: AppTheme.card,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: _currentStep == AuthStep.otpVerification
                        ? _buildOtpForm()
                        : _buildCredentialsForm(),
                  ),
                  const SizedBox(height: 16),

                  // Bottom toggles
                  if (_currentStep != AuthStep.otpVerification) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _currentStep == AuthStep.login
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
                              _currentStep = _currentStep == AuthStep.login
                                  ? AuthStep.signup
                                  : AuthStep.login;
                              _errorMessage = null;
                              _successMessage = null;
                            });
                          },
                          child: Text(
                            _currentStep == AuthStep.login ? 'Sign up' : 'Sign in',
                            style: const TextStyle(
                              color: AppTheme.primaryLight,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getTitle() {
    switch (_currentStep) {
      case AuthStep.login:
        return 'Sign In';
      case AuthStep.signup:
        return 'Create Account';
      case AuthStep.otpVerification:
        return 'Enter Verification OTP';
    }
  }

  String _getSubtitle() {
    switch (_currentStep) {
      case AuthStep.login:
        return 'Enter your email & password to receive an OTP and sign in';
      case AuthStep.signup:
        return 'Sign up with your credentials to access the 3-AI council';
      case AuthStep.otpVerification:
        return 'We sent a 6-digit verification code to:\n$_targetEmail';
    }
  }

  Widget _buildCredentialsForm() {
    final isLogin = _currentStep == AuthStep.login;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!isLogin) ...[
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
          label: 'Email Address',
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
        _buildFeedbackBanners(),
        const SizedBox(height: 20),
        _buildActionButton(
          label: isLogin ? 'Sign In & Get OTP' : 'Sign Up & Get OTP',
          icon: LucideIcons.arrowRight,
          onTap: _handleLoginOrSignup,
        ),
      ],
    );
  }

  Widget _buildOtpForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '6-Digit OTP Code',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _currentStep = AuthStep.login;
                  _errorMessage = null;
                  _successMessage = null;
                });
              },
              child: const Text(
                'Change Email',
                style: TextStyle(
                  color: AppTheme.primaryLight,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // OTP Input Box
        Container(
          decoration: BoxDecoration(
            color: AppTheme.input,
            borderRadius: BorderRadius.circular(AppTheme.radiusSm + 2),
            border: Border.all(color: AppTheme.border),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: TextField(
            controller: _otpController,
            autofocus: true,
            keyboardType: TextInputType.number,
            maxLength: 6,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              letterSpacing: 8,
              fontWeight: FontWeight.w700,
              fontFamily: 'monospace',
            ),
            decoration: const InputDecoration(
              hintText: '••••••',
              hintStyle: TextStyle(color: AppTheme.textMuted, letterSpacing: 8),
              counterText: '',
              border: InputBorder.none,
            ),
            onSubmitted: (_) => _handleVerifyOtp(),
          ),
        ),

        // Dev Quick Auto-Fill Chip
        if (_devOtp != null && _devOtp!.isNotEmpty) ...[
          const SizedBox(height: 10),
          InkWell(
            onTap: () {
              setState(() {
                _otpController.text = _devOtp!;
              });
            },
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.tint(AppTheme.info, 0.12),
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                border: Border.all(color: AppTheme.tint(AppTheme.info, 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.key, size: 12, color: AppTheme.info),
                  const SizedBox(width: 6),
                  Text(
                    'Auto-fill Demo OTP: $_devOtp',
                    style: const TextStyle(
                      color: AppTheme.info,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],

        _buildFeedbackBanners(),
        const SizedBox(height: 20),

        _buildActionButton(
          label: 'Verify OTP & Log In',
          icon: LucideIcons.check,
          onTap: _handleVerifyOtp,
        ),
        const SizedBox(height: 14),

        // Resend OTP Action
        Center(
          child: TextButton.icon(
            onPressed: _resendCountdown > 0 || _isLoading ? null : _handleResendOtp,
            icon: const Icon(LucideIcons.rotateCw, size: 13),
            label: Text(
              _resendCountdown > 0
                  ? 'Resend OTP in ${_resendCountdown}s'
                  : 'Resend Verification Code',
              style: TextStyle(
                color: _resendCountdown > 0 ? AppTheme.textMuted : AppTheme.primaryLight,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeedbackBanners() {
    return Column(
      children: [
        if (_errorMessage != null) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.tint(AppTheme.error, 0.12),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              border: Border.all(color: AppTheme.tint(AppTheme.error, 0.35)),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.circleAlert, size: 14, color: AppTheme.error),
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
        if (_successMessage != null) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.tint(AppTheme.success, 0.12),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              border: Border.all(color: AppTheme.tint(AppTheme.success, 0.35)),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.circleCheck, size: 14, color: AppTheme.success),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _successMessage!,
                    style: const TextStyle(
                      color: Color(0xFF86EFAC),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: _isLoading ? AppTheme.surfaceHigh : AppTheme.primary,
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      child: InkWell(
        onTap: _isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
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
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(icon, size: 15, color: Colors.white),
                    ],
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
