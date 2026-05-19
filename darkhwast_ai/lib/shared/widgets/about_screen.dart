import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/config/app_env.dart';
import '../../../core/providers/demo_provider.dart';
import '../../../core/providers/firebase_providers.dart';
import '../../../core/services/firebase_bootstrap.dart';
import '../../features/agent_trace/providers/agent_pipeline_provider.dart';
import '../../features/agent_trace/widgets/agent_log_exporter.dart';

class AboutScreen extends ConsumerStatefulWidget {
  const AboutScreen({super.key});

  @override
  ConsumerState<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends ConsumerState<AboutScreen> {
  int _tapCount = 0;

  void _handleLogoTap() {
    setState(() => _tapCount++);
    if (_tapCount >= 5) {
      ref.read(demoModeProvider.notifier).toggle();
      final isDemo = ref.read(demoModeProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isDemo
              ? "Demo Mode ON — scripted mocks (for judges)"
              : AppEnv.liveAiReady
                  ? "Demo Mode OFF — Live ${AppEnv.geminiModel} active"
                  : "Demo Mode OFF — add GEMINI_API_KEY to .env first"),
          backgroundColor: isDemo ? AppColors.success : AppColors.primary,
        ),
      );
      setState(() => _tapCount = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDemo = ref.watch(demoModeProvider);
    final firebaseReady = ref.watch(firebaseReadyProvider);
    final firebaseConfigured = ref.watch(firebaseConfiguredProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("DarkhwastAI Ke Baare Mein"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            GestureDetector(
              onTap: _handleLogoTap,
              child: const Icon(Icons.auto_awesome_rounded,
                  color: AppColors.accent, size: 64),
            ),
            const SizedBox(height: 24),
            Text(
              "Apka Haq. AI Ka Kaam.",
              style: AppTextStyles.headline.copyWith(color: AppColors.primary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            _buildFirebaseStatus(firebaseConfigured, firebaseReady),

            const SizedBox(height: 12),

            _buildLiveAiStatus(isDemo),

            const SizedBox(height: 16),

            if (isDemo) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.success),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.offline_bolt_rounded,
                        color: AppColors.success),
                    const SizedBox(width: 12),
                    Text(
                      "DEMO MODE ACTIVE",
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              _buildDemoScenarioPicker(),
              const SizedBox(height: 8),
            ],

            _buildSection(
              "English",
              "DarkhwastAI is Pakistan's first AI-powered platform designed to help citizens enforce their legal rights against utility overcharges, government notices, and bureaucratic delays. Take a photo, and our AI does the rest.",
            ),

            const SizedBox(height: 24),

            _buildSection(
              "اردو",
              "درخواست اے آئی پاکستان کا پہلا پلیٹ فارم ہے جو شہریوں کو ان کے قانونی حقوق کے حصول میں مدد دیتا ہے۔ چاہے وہ بجلی کا غلط بل ہو یا حکومتی نوٹس، ہمارا اے آئی آپ کی مدد کے لیے تیار ہے۔",
              isUrdu: true,
            ),

            const SizedBox(height: 32),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome_outlined,
                      color: AppColors.accent, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Powered by Google Gemini (${AppEnv.geminiModel})",
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Legal Disclaimer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.urgent.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: AppColors.urgent.withValues(alpha: 0.1)),
              ),
              child: Text(
                "DISCLAIMER: HAQ Score aur AI Analysis sirf information ke liye hain. Legal advice ke liye apne waqeel se rabta karen.",
                style: AppTextStyles.caption.copyWith(
                    color: AppColors.urgent, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 24),

            if (isDemo) ...[
              ElevatedButton.icon(
                onPressed: () => context.push('/logs'),
                icon: const Icon(Icons.analytics_outlined),
                label: const Text('Agent trace dekhein'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  foregroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  final pipeline = ref.read(pipelineProvider);
                  if (!pipeline.isComplete) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Pehle ek document scan complete karen.'),
                      ),
                    );
                    return;
                  }
                  try {
                    await AgentLogExporter.shareLog(pipeline);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Export failed: $e')),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.ios_share_rounded),
                label: const Text('Agent log share karen'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ] else
              const SizedBox(height: 8),

            Text("Team DarkhwastAI • AISeekho 2026",
                style: AppTextStyles.caption.copyWith(letterSpacing: 1.5)),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveAiStatus(bool isDemo) {
    final Color color;
    final IconData icon;
    final String label;
    final String detail;

    if (isDemo) {
      color = AppColors.accent;
      icon = Icons.smart_toy_outlined;
      label = 'DEMO PIPELINE';
      detail = 'Mock JSON scenarios — no Gemini API calls';
    } else if (AppEnv.liveAiReady) {
      color = AppColors.success;
      icon = Icons.psychology_outlined;
      label = 'AI analysis ready';
      detail = 'Document scan par Gemini se haq analysis hoti hai';
    } else if (AppEnv.hasGeminiKey && AppEnv.forceMock) {
      color = AppColors.urgent;
      icon = Icons.block_rounded;
      label = 'MOCK FORCED';
      detail = 'USE_MOCK=true in .env — set false for live AI';
    } else {
      color = AppColors.urgent;
      icon = Icons.key_off_rounded;
      label = 'NO API KEY';
      detail = 'Add GEMINI_API_KEY to darkhwast_ai/.env';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(detail,
                    style: AppTextStyles.caption.copyWith(fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFirebaseStatus(bool configured, bool ready) {
    final Color color;
    final IconData icon;
    final String label;
    final String detail;

    if (ready) {
      color = AppColors.success;
      icon = Icons.cloud_done_rounded;
      label = 'Cloud connected';
      detail = 'Aap ke cases sync ho rahe hain';
    } else if (configured) {
      color = AppColors.urgent;
      icon = Icons.cloud_off_rounded;
      label = 'Offline mode';
      detail = FirebaseBootstrap.lastError ??
          (FirebaseBootstrap.isReady
              ? 'No internet — cases saved on this device'
              : 'Cases is device par save honge jab tak cloud connect na ho');
    } else {
      color = AppColors.textSecondary;
      icon = Icons.storage_rounded;
      label = 'LOCAL DEMO MODE';
      detail = 'Run flutterfire configure — see docs/FIREBASE_SETUP.md';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(detail,
                    style: AppTextStyles.caption.copyWith(fontSize: 11)),
                if (ready && FirebaseBootstrap.currentUser != null)
                  Text(
                    'UID: ${FirebaseBootstrap.currentUser!.uid.substring(0, 8)}…',
                    style: AppTextStyles.caption.copyWith(fontSize: 10),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoScenarioPicker() {
    final scenario = ref.watch(demoScenarioProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Demo Scenario (for judges)",
          style: AppTextStyles.title
              .copyWith(fontSize: 14, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: const Text("IESCO Bill (HAQ 81)"),
              selected: scenario == 'electricity_bill',
              onSelected: (_) => ref
                  .read(demoScenarioProvider.notifier)
                  .setScenario('electricity_bill'),
            ),
            ChoiceChip(
              label: const Text("SNGPL Gas Bill"),
              selected: scenario == 'gas_bill',
              onSelected: (_) => ref
                  .read(demoScenarioProvider.notifier)
                  .setScenario('gas_bill'),
            ),
            ChoiceChip(
              label: const Text("BISP Letter"),
              selected: scenario == 'bisp_letter',
              onSelected: (_) => ref
                  .read(demoScenarioProvider.notifier)
                  .setScenario('bisp_letter'),
            ),
            ChoiceChip(
              label: const Text("FBR Tax (Urgent)"),
              selected: scenario == 'tax_notice',
              onSelected: (_) => ref
                  .read(demoScenarioProvider.notifier)
                  .setScenario('tax_notice'),
            ),
            ChoiceChip(
              label: const Text("Other Document"),
              selected: scenario == 'general_document',
              onSelected: (_) => ref
                  .read(demoScenarioProvider.notifier)
                  .setScenario('general_document'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          "Tip: Enable demo mode (tap logo 5×), pick scenario, then scan from Home.",
          style: AppTextStyles.caption,
        ),
      ],
    );
  }

  Widget _buildSection(String title, String text, {bool isUrdu = false}) {
    return Column(
      crossAxisAlignment:
          isUrdu ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(title,
            style: AppTextStyles.title
                .copyWith(fontSize: 14, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Text(
          text,
          style: isUrdu ? AppTextStyles.urduBody : AppTextStyles.body,
          textAlign: isUrdu ? TextAlign.right : TextAlign.left,
        ),
      ],
    );
  }
}
