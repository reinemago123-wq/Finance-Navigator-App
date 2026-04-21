import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/glass_card.dart';
import '../auth/login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // User data — editable
  String _name  = 'Alex Johnson';
  String _email = 'alex@example.com';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Stack(children: [
        Positioned(
          top: -60, left: -40,
          child: Container(
            width: 240, height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                AppColors.accent.withOpacity(0.10), Colors.transparent]),
            ),
          ),
        ),

        SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(Sp.lg, Sp.lg, Sp.lg, 120),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // ── Header ────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Profile', style: AppText.h2.copyWith(color: AppColors.onDark)),
                  GestureDetector(
                    onTap: () => _openEditProfile(context),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.glassWhite,
                        border: Border.all(color: AppColors.glassBorder),
                        borderRadius: BorderRadius.circular(Rd.md),
                      ),
                      child: const Icon(Icons.edit_outlined,
                          color: AppColors.accent, size: 18),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Sp.lg),

              // ── Avatar card ────────────────────────────
              GlassCard(
                padding: const EdgeInsets.all(Sp.lg),
                child: Column(children: [
                  Stack(alignment: Alignment.bottomRight, children: [
                    Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primaryLight.withOpacity(0.8), AppColors.primary],
                          begin: Alignment.topLeft, end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.accent.withOpacity(0.35), width: 2),
                      ),
                      child: const Icon(Icons.person_rounded,
                          color: AppColors.onDark, size: 40),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: 26, height: 26,
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primaryDark, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt_outlined,
                            size: 13, color: AppColors.primaryDark),
                      ),
                    ),
                  ]),
                  const SizedBox(height: Sp.md),
                  Text(_name,
                      style: AppText.h3.copyWith(color: AppColors.onDark)),
                  const SizedBox(height: 4),
                  Text(_email,
                      style: AppText.body.copyWith(
                          color: AppColors.onDark.withOpacity(0.55), fontSize: 13)),
                  const SizedBox(height: Sp.md),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.14),
                      border: Border.all(color: AppColors.accent.withOpacity(0.30)),
                      borderRadius: Rd.chip,
                    ),
                    child: const Text('FREE PLAN',
                        style: TextStyle(color: AppColors.accent, fontSize: 10,
                            fontWeight: FontWeight.w700, letterSpacing: 1.0)),
                  ),
                ]),
              ),
              const SizedBox(height: Sp.md),

              // ── Stats row ──────────────────────────────
              Row(children: [
                _StatTile(value: '124', label: 'Transactions'),
                const SizedBox(width: Sp.sm),
                _StatTile(value: '\$12.4k', label: 'Total Saved',
                    valueColor: AppColors.accent),
                const SizedBox(width: Sp.sm),
                _StatTile(value: '15d', label: 'Streak',
                    valueColor: AppColors.income),
              ]),
              const SizedBox(height: Sp.xl),

              // ── Account settings ───────────────────────
              _sectionLabel('Account'),
              const SizedBox(height: Sp.sm),
              _SettingsRow(
                icon: Icons.person_outline_rounded,
                iconColor: AppColors.accent,
                label: 'Edit Profile',
                onTap: () => _openEditProfile(context),
              ),
              const SizedBox(height: Sp.sm),
              _SettingsRow(
                icon: Icons.lock_outline_rounded,
                iconColor: const Color(0xFF4A9EE8),
                label: 'Change Password',
                onTap: () => _openChangePassword(context),
              ),
              const SizedBox(height: Sp.sm),
              _SettingsRow(
                icon: Icons.notifications_outlined,
                iconColor: AppColors.income,
                label: 'Notifications',
                trailing: _Toggle(initialValue: true),
                onTap: () {},
              ),
              const SizedBox(height: Sp.sm),
              _SettingsRow(
                icon: Icons.dark_mode_outlined,
                iconColor: const Color(0xFFA29BFE),
                label: 'Dark Mode',
                trailing: _Toggle(initialValue: true),
                onTap: () {},
              ),
              const SizedBox(height: Sp.xl),

              // ── Support ────────────────────────────────
              _sectionLabel('Support'),
              const SizedBox(height: Sp.sm),
              _SettingsRow(
                icon: Icons.help_outline_rounded,
                iconColor: const Color(0xFF4ECDC4),
                label: 'Help & Support',
                onTap: () {},
              ),
              const SizedBox(height: Sp.sm),
              _SettingsRow(
                icon: Icons.privacy_tip_outlined,
                iconColor: AppColors.warning,
                label: 'Privacy Policy',
                onTap: () {},
              ),
              const SizedBox(height: Sp.xl),

              // ── Sign out ───────────────────────────────
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (_) => false,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(Sp.md),
                  decoration: BoxDecoration(
                    color: AppColors.expense.withOpacity(0.08),
                    border: Border.all(color: AppColors.expense.withOpacity(0.25)),
                    borderRadius: BorderRadius.circular(Rd.lg),
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.logout_rounded,
                        color: AppColors.expense.withOpacity(0.80), size: 18),
                    const SizedBox(width: 8),
                    Text('Sign Out',
                        style: TextStyle(
                            color: AppColors.expense.withOpacity(0.80),
                            fontSize: 14, fontWeight: FontWeight.w600)),
                  ]),
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _sectionLabel(String text) => Text(text,
      style: AppText.caption.copyWith(
          color: AppColors.onDark.withOpacity(0.40),
          letterSpacing: 0.8, fontSize: 11));

  // ── Open Edit Profile sheet ───────────────────────────────────────────────
  void _openEditProfile(BuildContext context) {
    final nameCtrl  = TextEditingController(text: _name);
    final emailCtrl = TextEditingController(text: _email);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(12, 0, 12,
            12 + MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(Sp.lg),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.97),
            borderRadius: BorderRadius.circular(Rd.xxl),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 40, height: 4,
                decoration: BoxDecoration(
                    color: AppColors.onDark.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: Sp.md),
            const Text('Edit Profile', style: AppText.h3),
            const SizedBox(height: Sp.lg),
            _sheetField(ctrl: nameCtrl,  hint: 'Full name',
                icon: Icons.person_outline_rounded),
            const SizedBox(height: Sp.md),
            _sheetField(ctrl: emailCtrl, hint: 'Email address',
                icon: Icons.mail_outline_rounded,
                keyboard: TextInputType.emailAddress),
            const SizedBox(height: Sp.xl),
            GestureDetector(
              onTap: () {
                setState(() {
                  _name  = nameCtrl.text.trim().isNotEmpty ? nameCtrl.text.trim() : _name;
                  _email = emailCtrl.text.trim().isNotEmpty ? emailCtrl.text.trim() : _email;
                });
                Navigator.pop(context);
              },
              child: _saveBtn('Save Changes'),
            ),
          ]),
        ),
      ),
    );
  }

  // ── Open Change Password sheet ────────────────────────────────────────────
  void _openChangePassword(BuildContext context) {
    final currentCtrl = TextEditingController();
    final newCtrl     = TextEditingController();
    final confirmCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(12, 0, 12,
            12 + MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(Sp.lg),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.97),
            borderRadius: BorderRadius.circular(Rd.xxl),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 40, height: 4,
                decoration: BoxDecoration(
                    color: AppColors.onDark.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: Sp.md),
            const Text('Change Password', style: AppText.h3),
            const SizedBox(height: Sp.lg),
            _sheetField(ctrl: currentCtrl, hint: 'Current password',
                icon: Icons.lock_outline_rounded, obscure: true),
            const SizedBox(height: Sp.md),
            _sheetField(ctrl: newCtrl, hint: 'New password',
                icon: Icons.lock_reset_outlined, obscure: true),
            const SizedBox(height: Sp.md),
            _sheetField(ctrl: confirmCtrl, hint: 'Confirm new password',
                icon: Icons.lock_outline_rounded, obscure: true),
            const SizedBox(height: Sp.xl),
            GestureDetector(
              onTap: () => Navigator.pop(ctx),
              child: _saveBtn('Update Password'),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _sheetField({
    required TextEditingController ctrl,
    required String hint,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
    bool obscure = false,
  }) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: Sp.md, vertical: 12),
      child: Row(children: [
        Icon(icon, color: AppColors.accent.withOpacity(0.65), size: 18),
        const SizedBox(width: Sp.md),
        Expanded(child: TextField(
          controller: ctrl,
          keyboardType: keyboard,
          obscureText: obscure,
          style: AppText.body.copyWith(fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppText.body.copyWith(
                color: AppColors.onDark.withOpacity(0.28), fontSize: 13),
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
        )),
      ]),
    );
  }

  Widget _saveBtn(String label) => Container(
    height: 52, width: double.infinity,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [AppColors.accent, AppColors.accentDark],
        begin: Alignment.topLeft, end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(Rd.lg),
      boxShadow: AppShadows.goldGlow,
    ),
    child: Center(child: Text(label,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
            color: AppColors.primaryDark))),
  );
}

// ── Stat tile ─────────────────────────────────────────────────────────────────
class _StatTile extends StatelessWidget {
  final String value, label;
  final Color? valueColor;
  const _StatTile({required this.value, required this.label, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 14),
        borderRadius: BorderRadius.circular(Rd.md),
        child: Column(children: [
          Text(value, style: TextStyle(
              color: valueColor ?? AppColors.onDark,
              fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(label, style: AppText.caption.copyWith(fontSize: 10),
              textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}

// ── Settings row ──────────────────────────────────────────────────────────────
class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final Widget? trailing;
  final VoidCallback onTap;

  const _SettingsRow({
    required this.icon, required this.iconColor,
    required this.label, required this.onTap, this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: Sp.md, vertical: 14),
        borderRadius: BorderRadius.circular(Rd.md),
        child: Row(children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.14),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: iconColor, size: 17),
          ),
          const SizedBox(width: Sp.md),
          Expanded(child: Text(label,
              style: AppText.body.copyWith(fontSize: 14,
                  fontWeight: FontWeight.w500))),
          trailing ?? Icon(Icons.chevron_right_rounded,
              color: AppColors.onDark.withOpacity(0.25), size: 20),
        ]),
      ),
    );
  }
}

// ── Toggle switch ─────────────────────────────────────────────────────────────
class _Toggle extends StatefulWidget {
  final bool initialValue;
  const _Toggle({this.initialValue = false});
  @override
  State<_Toggle> createState() => _ToggleState();
}

class _ToggleState extends State<_Toggle> {
  late bool _on;
  @override
  void initState() { super.initState(); _on = widget.initialValue; }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _on = !_on),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 42, height: 24,
        decoration: BoxDecoration(
          color: _on ? AppColors.income.withOpacity(0.28) : AppColors.onDark.withOpacity(0.10),
          border: Border.all(
              color: _on ? AppColors.income.withOpacity(0.45) : AppColors.onDark.withOpacity(0.15)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: _on ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 18, height: 18,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: _on ? AppColors.income : AppColors.onDark.withOpacity(0.35),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
    
  }
}