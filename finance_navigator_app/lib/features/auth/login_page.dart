import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/glass_card.dart';
import '../services/auth_service.dart';
import 'registration_page.dart';
import '../main_shell.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showPassword = false;
  bool _rememberMe   = false;
  bool _loading      = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── Sign in via Firebase ───────────────────────────────────────────────────
  Future<void> _signIn() async {
    final email    = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Please enter your email and password.');
      return;
    }

    setState(() { _loading = true; _error = null; });

    final error = await AuthService.signIn(email: email, password: password);

    if (!mounted) return;
    setState(() => _loading = false);

    if (error != null) {
      setState(() => _error = error);
    } else {
      // Auth state listener in main.dart handles navigation automatically,
      // but we also push here for immediate response.
      _goToHome();
    }
  }

  // ── Forgot password ────────────────────────────────────────────────────────
  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Enter your email above, then tap Forgot?');
      return;
    }
    setState(() { _loading = true; _error = null; });
    final error = await AuthService.sendPasswordReset(email);
    if (!mounted) return;
    setState(() => _loading = false);
    if (error != null) {
      setState(() => _error = error);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Password reset email sent. Check your inbox.'),
          backgroundColor: AppColors.income,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Rd.lg)),
        ));
      }
    }
  }

  void _goToHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainShell()), (_) => false);
  }

  void _goToRegister() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RegistrationPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: PopScope(
        canPop: false,
        child: Stack(children: [
          Positioned(
            top: -100, left: 0, right: 0,
            child: Container(
              height: 400,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [AppColors.accent.withOpacity(0.18), Colors.transparent],
                  radius: 0.7,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0, right: -80,
            child: Container(
              width: 280, height: 280,
              decoration: BoxDecoration(
                gradient: RadialGradient(colors: [
                  AppColors.primaryLight.withOpacity(0.4), Colors.transparent]),
                shape: BoxShape.circle,
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: Sp.lg, vertical: Sp.lg),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [

                // Logo
                Row(children: [
                  SizedBox(width: 36, height: 36,
                      child: Image.asset('assets/images/logo.png', fit: BoxFit.contain)),
                  const SizedBox(width: 10),
                  RichText(text: const TextSpan(children: [
                    TextSpan(text: 'Finance ',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w300, color: Colors.white)),
                    TextSpan(text: 'Navigator',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
                  ])),
                ]),
                const SizedBox(height: Sp.xl),

                const Text('Welcome Back', style: AppText.display),
                const SizedBox(height: Sp.sm),
                Text('Sign in to manage your finances',
                    style: AppText.body.copyWith(color: AppColors.onDark.withOpacity(0.60))),
                const SizedBox(height: Sp.xl),

                // Error banner
                if (_error != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: Sp.md, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.expense.withOpacity(0.12),
                      border: Border.all(color: AppColors.expense.withOpacity(0.30)),
                      borderRadius: BorderRadius.circular(Rd.md),
                    ),
                    child: Row(children: [
                      const Icon(Icons.error_outline_rounded, color: AppColors.expense, size: 18),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_error!,
                          style: TextStyle(color: AppColors.expense, fontSize: 13))),
                    ]),
                  ),
                  const SizedBox(height: Sp.md),
                ],

                // Email
                Text('Email', style: AppText.label.copyWith(color: AppColors.onDark.withOpacity(0.70))),
                const SizedBox(height: Sp.sm),
                _inputField(controller: _emailController, hint: 'you@example.com',
                    icon: Icons.mail_outline, keyboard: TextInputType.emailAddress),
                const SizedBox(height: Sp.lg),

                // Password
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Password', style: AppText.label.copyWith(color: AppColors.onDark.withOpacity(0.70))),
                  GestureDetector(
                    onTap: _forgotPassword,
                    child: Text('Forgot?', style: AppText.caption.copyWith(color: AppColors.accent)),
                  ),
                ]),
                const SizedBox(height: Sp.sm),
                _passwordField(),
                const SizedBox(height: Sp.lg),

                // Remember me
                GestureDetector(
                  onTap: () => setState(() => _rememberMe = !_rememberMe),
                  child: Row(children: [
                    _checkbox(_rememberMe),
                    const SizedBox(width: Sp.md),
                    Text('Remember me',
                        style: AppText.body.copyWith(color: AppColors.onDark.withOpacity(0.70))),
                  ]),
                ),
                const SizedBox(height: Sp.xl),

                // Sign in button
                GestureDetector(
                  onTap: _loading ? null : _signIn,
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [AppColors.accent, AppColors.accentLight],
                          begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(Rd.lg),
                      boxShadow: [BoxShadow(color: AppColors.accent.withOpacity(0.35),
                          blurRadius: 16, offset: const Offset(0, 6))],
                    ),
                    child: Center(child: _loading
                        ? const SizedBox(width: 22, height: 22,
                            child: CircularProgressIndicator(
                                color: AppColors.primaryDark, strokeWidth: 2.5))
                        : const Text('Sign In', style: TextStyle(fontSize: 16,
                            fontWeight: FontWeight.w700, color: AppColors.primaryDark,
                            letterSpacing: 0.5))),
                  ),
                ),
                const SizedBox(height: Sp.lg),

                // Divider
                Row(children: [
                  Expanded(child: Container(height: 1, color: AppColors.onDark.withOpacity(0.10))),
                  Padding(padding: const EdgeInsets.symmetric(horizontal: Sp.md),
                      child: Text('or', style: AppText.caption.copyWith(
                          color: AppColors.onDark.withOpacity(0.50)))),
                  Expanded(child: Container(height: 1, color: AppColors.onDark.withOpacity(0.10))),
                ]),
                const SizedBox(height: Sp.lg),

                // Register link
                Center(child: GestureDetector(
                  onTap: _goToRegister,
                  child: RichText(text: TextSpan(
                    text: "Don't have an account? ",
                    style: AppText.body.copyWith(color: AppColors.onDark.withOpacity(0.70)),
                    children: [TextSpan(text: 'Create one',
                        style: AppText.body.copyWith(
                            color: AppColors.accent, fontWeight: FontWeight.w600))],
                  )),
                )),
                const SizedBox(height: Sp.xl),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _inputField({required TextEditingController controller, required String hint,
      required IconData icon, TextInputType keyboard = TextInputType.text}) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: Sp.md, vertical: Sp.md),
      borderRadius: BorderRadius.circular(Rd.lg),
      child: Row(children: [
        Icon(icon, color: AppColors.accent.withOpacity(0.60), size: 20),
        const SizedBox(width: Sp.md),
        Expanded(child: TextField(
          controller: controller, keyboardType: keyboard,
          style: AppText.body.copyWith(color: AppColors.onDark),
          onChanged: (_) { if (_error != null) setState(() => _error = null); },
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppText.body.copyWith(color: AppColors.textHint.withOpacity(0.50)),
            border: InputBorder.none, contentPadding: EdgeInsets.zero),
        )),
      ]),
    );
  }

  Widget _passwordField() {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: Sp.md, vertical: Sp.md),
      borderRadius: BorderRadius.circular(Rd.lg),
      child: Row(children: [
        Icon(Icons.lock_outline, color: AppColors.accent.withOpacity(0.60), size: 20),
        const SizedBox(width: Sp.md),
        Expanded(child: TextField(
          controller: _passwordController, obscureText: !_showPassword,
          style: AppText.body.copyWith(color: AppColors.onDark),
          onChanged: (_) { if (_error != null) setState(() => _error = null); },
          decoration: InputDecoration(
            hintText: 'Enter your password',
            hintStyle: AppText.body.copyWith(color: AppColors.textHint.withOpacity(0.50)),
            border: InputBorder.none, contentPadding: EdgeInsets.zero),
        )),
        GestureDetector(
          onTap: () => setState(() => _showPassword = !_showPassword),
          child: Icon(_showPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: AppColors.accent.withOpacity(0.60), size: 20),
        ),
      ]),
    );
  }

  Widget _checkbox(bool checked) {
    return Container(
      width: 20, height: 20,
      decoration: BoxDecoration(
        color: checked ? AppColors.accent : Colors.transparent,
        border: Border.all(color: checked ? AppColors.accent : AppColors.textHint, width: 1.5),
        borderRadius: BorderRadius.circular(Rd.sm),
      ),
      child: checked ? const Icon(Icons.check, size: 14, color: AppColors.primaryDark) : null,
    );
  }
}