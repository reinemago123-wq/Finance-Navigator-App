import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/glass_card.dart';
import 'registration_page.dart';
import '../main_shell.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _showPassword = false;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── Navigate to Home — replaces entire back-stack ──────────────────────────
  void _goToHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainShell()),
      (_) => false, // clear everything behind it
    );
  }

  // ── Navigate to Register ───────────────────────────────────────────────────
  void _goToRegister() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RegistrationPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      // ── WillPopScope prevents back-button crash when login is the root ──────
      body: PopScope(
        canPop: false, // Login is root screen — nowhere to pop to
        child: Stack(
          children: [
            // ── Background orbs ─────────────────────────
            Positioned(
              top: -100,
              left: 0,
              right: 0,
              child: Container(
                height: 400,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accent.withOpacity(0.18),
                      Colors.transparent,
                    ],
                    radius: 0.7,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: -80,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primaryLight.withOpacity(0.4),
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
                      // ── Logo + App name ──────────────────
                      Row(
                        children: [
                          SizedBox(
                            width: 36,
                            height: 36,
                            child: Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(width: 10),
                          RichText(
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Finance ',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.white,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Navigator',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Sp.xl),

                      // ── Title ──────────────────────────────
                      const Text('Welcome Back', style: AppText.display),
                      const SizedBox(height: Sp.sm),
                      Text(
                        'Sign in to manage your finances',
                        style: AppText.body.copyWith(
                          color: AppColors.onDark.withOpacity(0.60),
                        ),
                      ),
                      const SizedBox(height: Sp.xl),

                      // ── Email ──────────────────────────────
                      Text(
                        'Email or Username',
                        style: AppText.label.copyWith(
                          color: AppColors.onDark.withOpacity(0.70),
                        ),
                      ),
                      const SizedBox(height: Sp.sm),
                      _buildInputField(
                        controller: _emailController,
                        hintText: 'you@example.com',
                        icon: Icons.mail_outline,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: Sp.lg),

                      // ── Password ───────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Password',
                            style: AppText.label.copyWith(
                              color: AppColors.onDark.withOpacity(0.70),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              // TODO: navigate to ForgotPasswordPage
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'Password reset coming soon',
                                  ),
                                  backgroundColor:
                                      AppColors.primaryLight,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(Rd.lg),
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              'Forgot?',
                              style: AppText.caption.copyWith(
                                color: AppColors.accent,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Sp.sm),
                      _buildPasswordField(
                        controller: _passwordController,
                        hintText: 'Enter your password',
                        showPassword: _showPassword,
                        onToggle: () => setState(
                          () => _showPassword = !_showPassword,
                        ),
                      ),
                      const SizedBox(height: Sp.lg),

                      // ── Remember Me ────────────────────────
                      GestureDetector(
                        onTap: () => setState(
                          () => _rememberMe = !_rememberMe,
                        ),
                        child: Row(
                          children: [
                            _buildCheckbox(_rememberMe),
                            const SizedBox(width: Sp.md),
                            Text(
                              'Remember me',
                              style: AppText.body.copyWith(
                                color: AppColors.onDark.withOpacity(0.70),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: Sp.xl),

                      // ── Sign In button ─────────────────────
                      // FIX: was empty onTap — now navigates to HomePage
                      GestureDetector(
                        onTap: _goToHome,
                        child: _primaryButton('Sign In'),
                      ),
                      const SizedBox(height: Sp.lg),

                      // ── Divider ────────────────────────────
                      _divider(),
                      const SizedBox(height: Sp.lg),

                      // ── Create account link ────────────────
                      // FIX: was plain Text — now wrapped in GestureDetector
                      Center(
                        child: GestureDetector(
                          onTap: _goToRegister,
                          child: RichText(
                            text: TextSpan(
                              text: "Don't have an account? ",
                              style: AppText.body.copyWith(
                                color: AppColors.onDark.withOpacity(0.70),
                              ),
                              children: [
                                TextSpan(
                                  text: 'Create one',
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
      ),
    );
  }

  // ── Shared UI helpers ───────────────────────────────────────────────────────

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

  Widget _buildCheckbox(bool checked) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: checked ? AppColors.accent : Colors.transparent,
        border: Border.all(
          color: checked ? AppColors.accent : AppColors.textHint,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(Rd.sm),
      ),
      child: checked
          ? const Icon(Icons.check, size: 14, color: AppColors.primaryDark)
          : null,
    );
  }

  Widget _primaryButton(String label) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.accent, AppColors.accentLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(Rd.lg),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryDark,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _divider() {
    return Row(
      children: [
        Expanded(
          child: Container(height: 1, color: AppColors.onDark.withOpacity(0.10)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Sp.md),
          child: Text(
            'or',
            style: AppText.caption.copyWith(
              color: AppColors.onDark.withOpacity(0.50),
            ),
          ),
        ),
        Expanded(
          child: Container(height: 1, color: AppColors.onDark.withOpacity(0.10)),
        ),
      ],
    );
  }
}