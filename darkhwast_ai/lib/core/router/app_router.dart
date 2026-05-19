import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/onboarding/screens/splash_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
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
    routes: [
      // Full-screen routes (No Bottom Nav)
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/scanner',
        builder: (context, state) {
          final mode = state.extra as ScannerMode?;
          return ScannerScreen(initialMode: mode);
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
              builder: (context, state) => const SizedBox.shrink()),
          GoRoute(
              path: '/cases',
              builder: (context, state) => const SizedBox.shrink()),
          GoRoute(
              path: '/about',
              builder: (context, state) => const SizedBox.shrink()),
        ],
      ),
    ],
  );
}
