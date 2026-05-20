import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/config/app_env.dart';
import '../../../core/providers/ai_mode_provider.dart';
import '../../../core/providers/demo_provider.dart';
import '../../../core/providers/firebase_providers.dart';
import '../../../core/services/firebase_bootstrap.dart';
import '../../../core/services/gemini_service.dart';

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
          content: Text(
            isDemo
                ? "Demo Mode ON — scripted mocks (for judges)"
                : AppEnv.liveAiReady
                ? "Demo Mode OFF — Live ${AppEnv.geminiModel} active"
                : "Demo Mode OFF — add GEMINI_API_KEY to .env first",
          ),
          backgroundColor: isDemo ? AppColors.success : AppColors.primary,
        ),
      );
      setState(() => _tapCount = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDemo = ref.watch(isCuratedDemoProvider);
    final aiMode = ref.watch(aiModeProvider);
    final firebaseReady = ref.watch(firebaseReadyProvider);
    final firebaseConfigured = ref.watch(firebaseConfiguredProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Settings"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            GestureDetector(
              onTap: _handleLogoTap,
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: AppColors.accent,
                size: 64,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "DarkhwastAI",
              style: AppTextStyles.headline.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Apka Haq. AI Ka Kaam.",
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),

            if (isDemo) ...[
              _buildSwitchToLiveCard(),
              const SizedBox(height: 24),
            ] else ...[
              _buildAiModeSection(aiMode),
              const SizedBox(height: 12),
              _buildLiveAiStatus(isDemo),
              const SizedBox(height: 12),
              _buildFirebaseStatus(firebaseConfigured, firebaseReady),
              const SizedBox(height: 24),
            ],

            _buildSection(
              "About DarkhwastAI",
              "DarkhwastAI is Pakistan's first AI-powered platform designed to help citizens enforce their legal rights against utility overcharges, government notices, and bureaucratic delays. Take a photo, and our AI does the rest.",
            ),

            const SizedBox(height: 24),

            _buildSection(
              "درخواست اے آئی کے بارے میں",
              "درخواست اے آئی پاکستان کا پہلا پلیٹ فارم ہے جو شہریوں کو ان کے قانونی حقوق کے حصول میں مدد دیتا ہے۔ چاہے وہ بجلی کا غلط بل ہو یا حکومتی نوٹس، ہمارا اے آئی آپ کی مدد کے لیے تیار ہے۔",
              isUrdu: true,
            ),

            const SizedBox(height: 32),

            if (!isDemo) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome_outlined,
                      color: AppColors.accent,
                      size: 22,
                    ),
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
            ],

            // Legal Disclaimer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.urgent.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.urgent.withValues(alpha: 0.1),
                ),
              ),
              child: Text(
                "DISCLAIMER: HAQ Score aur AI Analysis sirf information ke liye hain. Legal advice ke liye apne waqeel se rabta karen.",
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.urgent,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 32),

            Text(
              "Team DarkhwastAI • AISeekho 2026",
              style: AppTextStyles.caption.copyWith(letterSpacing: 1.5),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchToLiveCard() {
    return Card(
      elevation: 0,
      color: AppColors.primary.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppColors.primary.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => _showChangeKeyDialog(),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.offline_bolt_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Switch to AI Mode (Live)",
                      style: AppTextStyles.title.copyWith(
                        color: AppColors.primary,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Connect your own Gemini API key for live qanooni analysis.",
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.primary,
                size: 16,
              ),
            ],
          ),
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
      label = 'CURATED DEMO';
      detail = '3 judge scenarios — full 5-agent pipeline, no API key in APK';
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
                Text(
                  detail,
                  style: AppTextStyles.caption.copyWith(fontSize: 11),
                ),
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
      detail =
          FirebaseBootstrap.lastError ??
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
                Text(
                  detail,
                  style: AppTextStyles.caption.copyWith(fontSize: 11),
                ),
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

  Widget _buildAiModeSection(AiMode mode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI Mode (Live)',
            style: AppTextStyles.title.copyWith(
              color: AppColors.primary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Aap ki Gemini key is device par save hai aur fully verified hai.',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    await ref
                        .read(aiModeProvider.notifier)
                        .switchToCuratedDemo();
                    await ref.read(demoModeProvider.notifier).setEnabled(true);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Demo Mode active kar diya gaya hai.'),
                      ),
                    );
                  },
                  child: const Text('Switch to Demo'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showChangeKeyDialog(),
                  child: const Text('Change Key'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showChangeKeyDialog() async {
    final key = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const _GeminiApiKeyDialog(),
    );
    if (key == null || key.isEmpty) return;
    await ref.read(aiModeProvider.notifier).switchToUserKey(key);
    await ref.read(demoModeProvider.notifier).setEnabled(false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Live Gemini key saved on device')),
    );
  }

  Widget _buildSection(String title, String text, {bool isUrdu = false}) {
    return Column(
      crossAxisAlignment: isUrdu
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.title.copyWith(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
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

class _GeminiApiKeyDialog extends StatefulWidget {
  const _GeminiApiKeyDialog();

  @override
  State<_GeminiApiKeyDialog> createState() => _GeminiApiKeyDialogState();
}

class _GeminiApiKeyDialogState extends State<_GeminiApiKeyDialog> {
  final _controller = TextEditingController();
  bool _isValidating = false;
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _validateAndSave() async {
    final key = _controller.text.trim();
    if (key.isEmpty) {
      setState(() {
        _errorText = "Key khali nahi ho sakti.";
      });
      return;
    }

    setState(() {
      _isValidating = true;
      _errorText = null;
    });

    final isValid = await GeminiService.validateApiKey(key);
    if (!mounted) return;

    setState(() {
      _isValidating = false;
    });

    if (isValid) {
      Navigator.pop(context, key);
    } else {
      setState(() {
        _errorText = "API Key ghalt hai. Dobara check karen.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Enter Gemini API Key'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            obscureText: true,
            decoration: InputDecoration(
              hintText: 'AIza...',
              errorText: _errorText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Apni key aistudio.google.com se haasil karen.',
            style: AppTextStyles.caption.copyWith(fontSize: 11),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isValidating ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isValidating ? null : _validateAndSave,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isValidating
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}
