import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // Artificial delay for splash effect
    await Future.delayed(const Duration(milliseconds: 2500));
    
    final prefs = await SharedPreferences.getInstance();
    final bool showOnboarding = prefs.getBool('showOnboarding') ?? true;

    if (!mounted) return;

    if (showOnboarding) {
      context.go('/onboarding');
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Text
            Text(
              "DarkhwastAI",
              style: AppTextStyles.display.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ).animate()
             .fadeIn(duration: 800.ms)
             .scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack),

            const SizedBox(height: 16),

            // Amber Divider
            Container(
              height: 2,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(1),
              ),
            ).animate()
             .custom(
               duration: 600.ms,
               delay: 400.ms,
               builder: (context, value, child) => SizedBox(
                 width: MediaQuery.of(context).size.width * 0.4 * value,
                 child: child,
               ),
             ),

            const SizedBox(height: 24),

            // Tagline
            Text(
              "Apka Haq. AI Ka Kaam.",
              style: AppTextStyles.title.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 16,
              ),
            ).animate()
             .fadeIn(delay: 800.ms)
             .slideY(begin: 0.2, end: 0),
          ],
        ),
      ),
    );
  }
}
