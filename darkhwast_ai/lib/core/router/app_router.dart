import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/demo/demo_scenario_catalog.dart';
import '../../features/setup/screens/ai_setup_screen.dart';
import '../../features/demo/screens/demo_scenario_picker_screen.dart';
import '../../features/onboarding/screens/splash_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/scanner/screens/document_review_screen.dart';
import '../../features/scanner/screens/scanner_screen.dart';
import '../../features/agent_trace/screens/agent_trace_screen.dart';
import '../../features/intent_selection/screens/intent_selection_screen.dart';
import '../../features/haq_dashboard/screens/haq_dashboard_screen.dart';
import '../../features/haq_dashboard/screens/document_explanation_screen.dart';
import '../../features/complaint/screens/complaint_draft_screen.dart';
import '../../features/confirmation/screens/confirmation_screen.dart';
import '../../features/confirmation/screens/filing_screen.dart';
import '../../features/agent_trace/widgets/log_viewer_screen.dart';
import '../../shared/widgets/nav_shell.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page not found')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(state.error?.toString() ?? 'Unknown route'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.go('/home'),
              child: const Text('Home'),
            ),
          ],
        ),
      ),
    ),
    routes: [
      // Full-screen routes (No Bottom Nav)
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(
        path: '/ai-setup',
        builder: (context, state) => const AiSetupScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/demo-picker',
        builder: (context, state) => const DemoScenarioPickerScreen(),
      ),
      GoRoute(
        path: '/scanner',
        builder: (context, state) {
          final extra = state.extra;
          if (extra is DemoScanLaunch) {
            return ScannerScreen(demoLaunch: extra);
          }
          if (extra is ScannerMode) {
            return ScannerScreen(initialMode: extra);
          }
          return const ScannerScreen();
        },
      ),
      GoRoute(
        path: '/document-review',
        builder: (context, state) {
          final extras = state.extra;
          if (extras is! Map<String, dynamic>) {
            return _missingRouteScreen(context, 'Koi photo nahi mili.');
          }
          final file = extras['file'];
          if (file is! File) {
            return _missingRouteScreen(context, 'Koi photo nahi mili.');
          }
          final crop = extras['crop'];
          return DocumentReviewScreen(
            imageFile: file,
            initialCropNormalized: crop is Rect ? crop : null,
          );
        },
      ),
      GoRoute(
        path: '/agent-trace',
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>?;
          return AgentTraceScreen(
            documentFile: extras?['file'],
            voiceText: extras?['voiceText'],
          );
        },
      ),
      // Resume route for Phase 2 (after intent selection)
      GoRoute(
        path: '/agent-trace-resume',
        builder: (context, state) => const AgentTraceScreen(isResuming: true),
      ),
      GoRoute(
        path: '/intent-selection',
        builder: (context, state) => const IntentSelectionScreen(),
      ),
      GoRoute(
        path: '/haq-dashboard',
        builder: (context, state) => const HaqDashboardScreen(),
      ),
      GoRoute(
        path: '/document-explanation',
        builder: (context, state) => const DocumentExplanationScreen(),
      ),
      GoRoute(
        path: '/complaint',
        builder: (context, state) => const ComplaintDraftScreen(),
      ),
      GoRoute(
        path: '/filing',
        builder: (context, state) => const FilingScreen(),
      ),
      GoRoute(
        path: '/confirmation',
        builder: (context, state) => const ConfirmationScreen(),
      ),
      GoRoute(
        path: '/logs',
        builder: (context, state) => const LogViewerScreen(),
      ),

      // Shell route for the main app experience (With Bottom Nav)
      ShellRoute(
        builder: (context, state, child) => const NavigationShell(),
        routes: [
          // These are just markers for the shell to know we are in the main area
          GoRoute(
            path: '/home',
            builder: (context, state) => const SizedBox.shrink(),
          ),
          GoRoute(
            path: '/cases',
            builder: (context, state) => const SizedBox.shrink(),
          ),
          GoRoute(
            path: '/about',
            builder: (context, state) => const SizedBox.shrink(),
          ),
        ],
      ),
    ],
  );

  static Widget _missingRouteScreen(BuildContext context, String message) {
    return Scaffold(
      appBar: AppBar(title: const Text('DarkhwastAI')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.go('/home'),
                child: const Text('Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
