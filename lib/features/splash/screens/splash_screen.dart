import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:titik_waktu/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  Timer? _navTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeInOutCubic),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();

    // Navigate to Home Screen after ~1.6 seconds total
    _navTimer = Timer(const Duration(milliseconds: 1600), () {
      if (mounted) {
        context.go('/');
      }
    });
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final dotColor = isDark ? AppColors.amberDarkIndicator : AppColors.amberLightIndicator;
    final primaryColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final mutedColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Clock/Dot animation
                Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        width: 1.5,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Center dot (Amber)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: dotColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        // Clock hand rotating
                        Transform.rotate(
                          angle: _rotationAnimation.value * 2 * math.pi,
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              margin: const EdgeInsets.only(top: 14),
                              width: 2.5,
                              height: 22,
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // App Title Fade In
                Opacity(
                  opacity: _fadeAnimation.value,
                  child: Column(
                    children: [
                      Text(
                        'TITIK WAKTU',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 3.0,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Jadwal & Pengingat Tepat Waktu',
                        style: TextStyle(
                          fontSize: 12,
                          color: mutedColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
