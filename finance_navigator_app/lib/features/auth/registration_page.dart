import 'package:flutter/material.dart';
import '../main_shell.dart';
import '../../core/theme.dart';
import '../../widgets/glass_card.dart';
import '../services/auth_service.dart';


class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;

  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _agreeToTerms = false;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ── Navigate to Home — clears entire stack ─────────────────────────────────
  Future<void> _register() async {
    final name     = _fullNameController.text.trim();
    final email    = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm  = _confirmPasswordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Please fill in all fields.');
      return;
    }
    if (password != confirm) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }
    if (!_agreeToTerms) {
      setState(() => _error = 'Please agree to the Terms of Service.');
      return;
    }

    setState(() { _loading = true; _error = null; });

    final error = await AuthService.register(
        fullName: name, email: email, password: password);

    if (!mounted) return;
    setState(() => _loading = false);

    if (error != null) {
      setState(() => _error = error);
    } else {
      _goToHome();
    }
  }

  void _goToHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainShell()),
      (_) => false,
    );
  }

  // ── Navigate back to Login ──────────────────────────────────────────────────
  void _goToLogin() {
    // Safe pop — Register is always pushed on top of Login
    Navigator.of(context).pop();
  }

  // ── Password helpers ────────────────────────────────────────────────────────
  double _getPasswordStrength(String password) {
    if (password.isEmpty) return 0.0;
    if (password.length < 6) return 0.2;
    if (password.length < 8) return 0.4;
    int score = 0;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[a-z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;
    if (password.length >= 12) score++;
    return (score / 5).clamp(0.0, 1.0);
  }

  String _strengthLabel(double s) {
    if (s == 0.0) return 'Password strength';
    if (s <= 0.2) return 'Very weak';
    if (s <= 0.4) return 'Weak';
    if (s <= 0.6) return 'Fair';
    if (s <= 0.8) return 'Good';
    return 'Strong';
  }

  Color _strengthColor(double s) {
    if (s == 0.0) return AppColors.textHint;
    if (s <= 0.2) return AppColors.expense;
    if (s <= 0.4) return AppColors.warning;
    if (s <= 0.6) return AppColors.accent;
    return AppColors.income;
  }

  @override
  Widget build(BuildContext context) {
    final double strength = _getPasswordStrength(_passwordController.text);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // ── Background orbs ──────────────────────────
          Positioned(
            top: -100,
            left: 0,
            right: 0,
            child: Container(
              height: 400,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    AppColors.income.withOpacity(0.12),
                    Colors.transparent,
                  ],
                  radius: 0.7,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryLight.withOpacity(0.35),
                    Colors.transparent,
                  ],
                ),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // ── Scrollable content ───────────────────────
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Sp.lg,
                  vertical: Sp.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Back button → Login ──────────────
                    // FIX: was crashing — now safely pops to LoginPage
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: _goToLogin,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.glassWhite,
                            border: Border.all(
                              color: AppColors.glassBorder,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(Rd.lg),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            color: AppColors.onDark,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: Sp.xl),

                    // ── Title ──────────────────────────────
                    const Text('Create Account', style: AppText.display),
                    const SizedBox(height: Sp.sm),
                    Text(
                      'Start your financial journey today',
                      style: AppText.body.copyWith(
                        color: AppColors.onDark.withOpacity(0.60),
                      ),
                    ),
                    const SizedBox(height: Sp.xl),

                    // ── Error banner ───────────────────────
                    if (_error != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: Sp.md, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.expense.withOpacity(0.12),
                          border: Border.all(
                              color: AppColors.expense.withOpacity(0.30)),
                          borderRadius: BorderRadius.circular(Rd.md),
                        ),
                        child: Row(children: [
                          const Icon(Icons.error_outline_rounded,
                              color: AppColors.expense, size: 18),
                          const SizedBox(width: 8),
                          Expanded(child: Text(_error!,
                              style: const TextStyle(
                                  color: AppColors.expense, fontSize: 13))),
                        ]),
                      ),
                      const SizedBox(height: Sp.md),
                    ],

                    // ── Full Name ──────────────────────────
                    _fieldLabel('Full Name'),
                    const SizedBox(height: Sp.sm),
                    _buildInputField(
                      controller: _fullNameController,
                      hintText: 'John Doe',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: Sp.lg),

                    // ── Email ──────────────────────────────
                    _fieldLabel('Email Address'),
                    const SizedBox(height: Sp.sm),
                    _buildInputField(
                      controller: _emailController,
                      hintText: 'you@example.com',
                      icon: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: Sp.lg),

                    // ── Password + strength ────────────────
                    _fieldLabel('Password'),
                    const SizedBox(height: Sp.sm),
                    _buildPasswordField(
                      controller: _passwordController,
                      hintText: 'Create a strong password',
                      showPassword: _showPassword,
                      onToggle: () =>
                          setState(() => _showPassword = !_showPassword),
                    ),
                    const SizedBox(height: Sp.md),

                    // Strength bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(Rd.sm),
                      child: LinearProgressIndicator(
                        value: strength,
                        minHeight: 5,
                        backgroundColor: AppColors.onDark.withOpacity(0.10),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _strengthColor(strength),
                        ),
                      ),
                    ),
                    const SizedBox(height: Sp.sm),
                    Text(
                      _strengthLabel(strength),
                      style: AppText.caption.copyWith(
                        color: _strengthColor(strength),
                      ),
                    ),
                    const SizedBox(height: Sp.lg),

                    // ── Confirm Password ───────────────────
                    _fieldLabel('Confirm Password'),
                    const SizedBox(height: Sp.sm),
                    _buildPasswordField(
                      controller: _confirmPasswordController,
                      hintText: 'Confirm your password',
                      showPassword: _showConfirmPassword,
                      onToggle: () => setState(
                        () => _showConfirmPassword = !_showConfirmPassword,
                      ),
                    ),
                    const SizedBox(height: Sp.lg),

                    // ── Terms checkbox ─────────────────────
                    GestureDetector(
                      onTap: () =>
                          setState(() => _agreeToTerms = !_agreeToTerms),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            margin: const EdgeInsets.only(top: 2),
                            decoration: BoxDecoration(
                              color: _agreeToTerms
                                  ? AppColors.accent
                                  : Colors.transparent,
                              border: Border.all(
                                color: _agreeToTerms
                                    ? AppColors.accent
                                    : AppColors.textHint,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(Rd.sm),
                            ),
                            child: _agreeToTerms
                                ? const Icon(
                                    Icons.check,
                                    size: 14,
                                    color: AppColors.primaryDark,
                                  )
                                : null,
                          ),
                          const SizedBox(width: Sp.md),
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                text: 'I agree to the ',
                                style: AppText.caption.copyWith(
                                  color: AppColors.onDark.withOpacity(0.70),
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Terms of Service',
                                    style: AppText.caption.copyWith(
                                      color: AppColors.accent,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' and ',
                                    style: AppText.caption.copyWith(
                                      color: AppColors.onDark.withOpacity(0.70),
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Privacy Policy',
                                    style: AppText.caption.copyWith(
                                      color: AppColors.accent,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: Sp.xl),

                    // ── Create Account button ──────────────
                    // FIX: was empty onTap — now navigates to HomePage
                    GestureDetector(
                      onTap: (_agreeToTerms && !_loading) ? _register : null,
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _agreeToTerms
                                ? [AppColors.accent, AppColors.accentLight]
                                : [
                                    AppColors.textHint.withOpacity(0.25),
                                    AppColors.textHint.withOpacity(0.25),
                                  ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(Rd.lg),
                          boxShadow: _agreeToTerms
                              ? [
                                  BoxShadow(
                                    color: AppColors.accent.withOpacity(0.35),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ]
                              : [],
                        ),
                        child: Center(
                          child: _loading
                              ? const SizedBox(
                                  width: 22, height: 22,
                                  child: CircularProgressIndicator(
                                      color: AppColors.primaryDark,
                                      strokeWidth: 2.5))
                              : Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: _agreeToTerms
                                  ? AppColors.primaryDark
                                  : AppColors.onDark.withOpacity(0.40),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: Sp.lg),

                    // ── Sign in link ────────────────────────
                    // FIX: was plain Text — now GestureDetector pops to Login
                    Center(
                      child: GestureDetector(
                        onTap: _goToLogin,
                        child: RichText(
                          text: TextSpan(
                            text: 'Already have an account? ',
                            style: AppText.body.copyWith(
                              color: AppColors.onDark.withOpacity(0.70),
                            ),
                            children: [
                              TextSpan(
                                text: 'Sign in',
                                style: AppText.body.copyWith(
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: Sp.xl),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Shared UI helpers ───────────────────────────────────────────────────────

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: AppText.label.copyWith(
        color: AppColors.onDark.withOpacity(0.70),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(
        horizontal: Sp.md,
        vertical: Sp.md,
      ),
      borderRadius: BorderRadius.circular(Rd.lg),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accent.withOpacity(0.60), size: 20),
          const SizedBox(width: Sp.md),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              style: AppText.body.copyWith(color: AppColors.onDark),
              onChanged: (_) { if (_error != null) setState(() => _error = null); },
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: AppText.body.copyWith(
                  color: AppColors.textHint.withOpacity(0.50),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool showPassword,
    required VoidCallback onToggle,
  }) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(
        horizontal: Sp.md,
        vertical: Sp.md,
      ),
      borderRadius: BorderRadius.circular(Rd.lg),
      child: Row(
        children: [
          Icon(
            Icons.lock_outline,
            color: AppColors.accent.withOpacity(0.60),
            size: 20,
          ),
          const SizedBox(width: Sp.md),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: !showPassword,
              onChanged: (_) => setState(() {}), // triggers strength update
              style: AppText.body.copyWith(color: AppColors.onDark),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: AppText.body.copyWith(
                  color: AppColors.textHint.withOpacity(0.50),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          GestureDetector(
            onTap: onToggle,
            child: Icon(
              showPassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: AppColors.accent.withOpacity(0.60),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}