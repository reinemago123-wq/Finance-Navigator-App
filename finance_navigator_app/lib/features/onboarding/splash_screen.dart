import 'package:flutter/material.dart';
import '../../core/theme.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const SplashScreen({super.key, required this.onComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoCtrl;
  late AnimationController _textCtrl;
  late AnimationController _loaderCtrl;
  late AnimationController _rotateCtrl;

  late Animation<double> _logoFade;
  late Animation<double> _logoScale;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;
  late Animation<double> _loaderAnim;
  late Animation<double> _rotateAnim;

  @override
  void initState() {
    super.initState();

    // Logo bounce-in
    _logoCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _logoFade = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOut));
    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut));

    // Slow continuous rotation on the compass star
    _rotateCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 20))
      ..repeat();
    _rotateAnim = Tween<double>(begin: 0, end: 1).animate(_rotateCtrl);

    // Text slides up
    _textCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _textFade = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut));
    _textSlide =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
            CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut));

    // Shimmer loader
    _loaderCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat();
    _loaderAnim = Tween<double>(begin: -1.0, end: 2.0).animate(
        CurvedAnimation(parent: _loaderCtrl, curve: Curves.easeInOut));

    // Stagger: logo first, text after 600ms
    _logoCtrl.forward();
    Future.delayed(const Duration(milliseconds: 600),
        () { if (mounted) _textCtrl.forward(); });

    // Navigate after 2.8s
    Future.delayed(const Duration(milliseconds: 2800),
        () { if (mounted) widget.onComplete(); });
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _textCtrl.dispose();
    _loaderCtrl.dispose();
    _rotateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Stack(
        children: [
          // Background radial glow — blue tint matching the logo
          Positioned(
            top: -80, left: 0, right: 0,
            child: Container(
              height: 500,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF2A7FD4).withOpacity(0.22),
                    Colors.transparent,
                  ],
                  radius: 0.65,
                ),
              ),
            ),
          ),
          // Bottom-right soft orb
          Positioned(
            bottom: -60, right: -60,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(
                gradient: RadialGradient(colors: [
                  AppColors.primaryLight.withOpacity(0.3),
                  Colors.transparent,
                ]),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Main content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Logo: compass star with slow rotation + glow ──
                FadeTransition(
                  opacity: _logoFade,
                  child: ScaleTransition(
                    scale: _logoScale,
                    child: RotationTransition(
                      turns: _rotateAnim,
                      child: Container(
                        width: 120, height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2A7FD4).withOpacity(0.45),
                              blurRadius: 50,
                              spreadRadius: 8,
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 120,
                          height: 120,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // ── App name + tagline ──
                FadeTransition(
                  opacity: _textFade,
                  child: SlideTransition(
                    position: _textSlide,
                    child: Column(
                      children: [
                        // "Finance" light + "Navigator" bold
                        RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: 'Finance ',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              TextSpan(
                                text: 'Navigator',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Your money, under control',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withOpacity(0.50),
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 52),

                        // Shimmer loader bar
                        AnimatedBuilder(
                          animation: _loaderAnim,
                          builder: (context, _) {
                            return Container(
                              width: 52, height: 3.5,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2A7FD4).withOpacity(0.20),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(2),
                                child: FractionallySizedBox(
                                  widthFactor: 0.50,
                                  alignment: Alignment(_loaderAnim.value, 0),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFF4A9EE8),
                                          Color(0xFF2A7FD4),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}