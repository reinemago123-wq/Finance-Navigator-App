import 'dart:async';
import 'package:flutter/material.dart';
import 'app_theme.dart';

void main() => runApp(const StopwatchApp());

class StopwatchApp extends StatelessWidget {
  const StopwatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.dark),
      home: const StopwatchScreen(),
    );
  }
}

class StopwatchScreen extends StatefulWidget {
  const StopwatchScreen({super.key});

  @override
  _StopwatchScreenState createState() => _StopwatchScreenState();
}

class _StopwatchScreenState extends State<StopwatchScreen> {
  int _seconds = 0;
  Timer? _timer;
  bool _isRunning = false;

  // Formatting logic for HH:MM:SS
  String _formatTime(int totalSeconds) {
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int seconds = totalSeconds % 60;

    return "${hours.toString().padLeft(2, '0')}:"
           "${minutes.toString().padLeft(2, '0')}:"
           "${seconds.toString().padLeft(2, '0')}";
  }

  void _startTimer() {
    if (_isRunning) return;
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _seconds++);
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    _stopTimer();
    setState(() => _seconds = 0);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.bgDark,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. THE CLOCK FACE
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: AppConfig.clockSize,
                    height: AppConfig.clockSize,
                    child: CircularProgressIndicator(
                      value: (_seconds % 60) / 60,
                      strokeWidth: 6,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppConfig.primaryOrange),
                      backgroundColor: Colors.white10,
                    ),
                  ),
                  Text(
                    _formatTime(_seconds),
                    style: const TextStyle(
                      fontSize: AppConfig.clockFontSize,
                      fontWeight: FontWeight.w200,
                      color: AppConfig.timerText,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 60),

              // 2. THE THREE VERTICAL BUTTONS
              Column(
                children: [
                  // START BUTTON (Primary Style)
                  _buildActionButton(
                    label: "START",
                    icon: Icons.play_arrow_rounded,
                    onTap: _isRunning ? null : _startTimer,
                    isPrimary: true,
                  ),
                  const SizedBox(height: AppConfig.btnSpacing),

                  // STOP BUTTON (Outlined Style)
                  _buildActionButton(
                    label: "STOP",
                    icon: Icons.pause_rounded,
                    onTap: !_isRunning ? null : _stopTimer,
                    isPrimary: false,
                  ),
                  const SizedBox(height: AppConfig.btnSpacing),

                  // RESET BUTTON (Subtle Style)
                  _buildActionButton(
                    label: "RESET",
                    icon: Icons.refresh_rounded,
                    onTap: _resetTimer,
                    isPrimary: false,
                    isReset: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- REUSABLE BUTTON WIDGET ---
  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback? onTap,
    required bool isPrimary,
    bool isReset = false,
  }) {
    // Logic for dynamic coloring
    final Color mainColor = isReset ? Colors.white60 : AppConfig.primaryOrange;
    final bool isDisabled = onTap == null;

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: isDisabled ? 0.4 : 1.0,
        child: Container(
          width: AppConfig.btnWidth,
          height: AppConfig.btnHeight,
          decoration: BoxDecoration(
            color: isPrimary ? AppConfig.primaryOrange : Colors.transparent,
            borderRadius: BorderRadius.circular(AppConfig.borderRadius),
            border: Border.all(color: mainColor, width: 2),
            boxShadow: [
              if (isPrimary && !isDisabled)
                BoxShadow(
                  color: AppConfig.primaryOrange.withOpacity(AppConfig.shadowOpacity),
                  blurRadius: AppConfig.shadowBlur,
                  offset: const Offset(0, 8),
                ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isPrimary ? AppConfig.bgDark : mainColor),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: isPrimary ? AppConfig.bgDark : mainColor,
                  fontSize: AppConfig.btnFontSize,
                  fontWeight: FontWeight.w600, // BOLD APP THEME
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}