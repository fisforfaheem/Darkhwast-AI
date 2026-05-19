import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showOnboarding', false);
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Page View
            PageView(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentPage = index),
              children: [
                _buildPage(
                  icon: Icons.document_scanner_rounded,
                  title: "Koi bhi document\nscan karen",
                  description: "Bijli ka bill ho ya sarkari notice, bas photo khainchein.",
                  color: AppColors.primary,
                ),
                _buildPage(
                  isGauge: true,
                  title: "AI apka haq\ndhundh leta hai",
                  description: "Hamara AI qanoon ke mutabiq aap ka HAQ score nikalta hai.",
                  color: AppColors.primary,
                ),
                _buildPage(
                  icon: Icons.check_circle_outline_rounded,
                  title: "Complaint automatic\nfile ho jati hai",
                  description: "Bas confirm karain aur AI ap ki darkhwast portal par bhaij dega.",
                  color: AppColors.success,
                ),
              ],
            ),

            // Top Skip Button
            Positioned(
              top: 16,
              right: 16,
              child: TextButton(
                onPressed: _finishOnboarding,
                child: Text(
                  "Skip",
                  style: AppTextStyles.body.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            // Bottom Indicators and Button
            Positioned(
              bottom: 40,
              left: 24,
              right: 24,
              child: Column(
                children: [
                  // Dot indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) => _buildIndicator(index == _currentPage)),
                  ),
                  const SizedBox(height: 32),
                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage < 2) {
                          _pageController.nextPage(duration: 400.ms, curve: Curves.easeInOut);
                        } else {
                          _finishOnboarding();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        _currentPage == 2 ? "Shuru Karen" : "Aage Barhein",
                        style: AppTextStyles.body.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: 300.ms,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.accent : AppColors.textSecondary.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildPage({
    IconData? icon,
    bool isGauge = false,
    required String title,
    required String description,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isGauge)
            CircularPercentIndicator(
              radius: 80.0,
              lineWidth: 12.0,
              percent: 0.84,
              center: Text("84", style: AppTextStyles.display.copyWith(color: AppColors.primary)),
              progressColor: AppColors.primary,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              circularStrokeCap: CircularStrokeCap.round,
              animation: true,
              animationDuration: 1500,
            ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack)
          else
            Icon(icon, size: 100, color: color)
                .animate()
                .scale(duration: 600.ms, curve: Curves.easeOutBack)
                .shake(delay: 500.ms),
          
          const SizedBox(height: 48),
          
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.headline.copyWith(color: AppColors.primary, fontSize: 28),
          ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),
          
          const SizedBox(height: 16),
          
          Text(
            description,
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ).animate().fadeIn(delay: 300.ms, duration: 600.ms),
        ],
      ),
    );
  }
}
