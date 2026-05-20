import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/providers/ai_mode_provider.dart';
import '../../../core/providers/demo_provider.dart';
import '../../../core/services/gemini_service.dart';

class AiSetupScreen extends ConsumerStatefulWidget {
  const AiSetupScreen({super.key});

  @override
  ConsumerState<AiSetupScreen> createState() => _AiSetupScreenState();
}

class _AiSetupScreenState extends ConsumerState<AiSetupScreen> {
  bool _useOwnKey = false;
  final _keyController = TextEditingController();
  bool _obscure = true;
  String? _error;
  bool _isValidating = false;

  @override
  void initState() {
    super.initState();
    _loadStoredKey();
  }

  Future<void> _loadStoredKey() async {
    final key = await ref.read(aiModeProvider.notifier).readStoredKey();
    if (key != null && key.isNotEmpty && mounted) {
      _keyController.text = key;
      setState(() {
        _useOwnKey = true;
      });
    }
  }

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  Future<void> _continueDemo() async {
    await ref.read(aiModeProvider.notifier).completeSetupCuratedDemo();
    await ref.read(demoModeProvider.notifier).setEnabled(true);
    if (!mounted) return;
    await _goNext();
  }

  Future<void> _continueWithKey() async {
    if (_isValidating) return;
    final key = _keyController.text.trim();
    if (key.isEmpty) {
      setState(() => _error = 'Gemini API key likhein ya Demo Mode chunain.');
      return;
    }
    setState(() {
      _error = null;
      _isValidating = true;
    });

    final isValid = await GeminiService.validateApiKey(key);
    if (!mounted) return;

    setState(() {
      _isValidating = false;
    });

    if (!isValid) {
      setState(() => _error = 'Apki API Key ghalt hai ya block hai. Dobara check karen.');
      return;
    }

    await ref.read(aiModeProvider.notifier).completeSetupWithUserKey(key);
    await ref.read(demoModeProvider.notifier).setEnabled(false);
    if (!mounted) return;
    await _goNext();
  }

  Future<void> _goNext() async {
    final prefs = await SharedPreferences.getInstance();
    final showOnboarding = prefs.getBool('showOnboarding') ?? true;
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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Text(
                'App Ka Mode Chunein',
                style: AppTextStyles.headline.copyWith(
                  color: AppColors.primary,
                  fontSize: 26,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'DarkhwastAI ko do tarah se chalaya ja sakta hai: Demo Mode jis mein pehle se tayyar scenarios shamil hain, ya Live AI Mode jis mein aap apni Gemini API key use kar sakte hain.',
                style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 28),
              _ModeCard(
                title: 'Demo Mode (Simulated)',
                subtitle:
                    '3 real Pakistani scenarios — IESCO, FBR ghost deadline, BISP. Poora 5-agent flow bina API key ke.',
                icon: Icons.auto_awesome_rounded,
                selected: !_useOwnKey,
                accent: AppColors.accent,
                onTap: () => setState(() {
                  _useOwnKey = false;
                  _error = null;
                }),
              ),
              const SizedBox(height: 12),
              _ModeCard(
                title: 'AI Mode (Live)',
                subtitle:
                    'Google AI Studio se Gemini key — Live analysis aur real-time answers ke liye.',
                icon: Icons.key_rounded,
                selected: _useOwnKey,
                accent: AppColors.primary,
                onTap: () => setState(() {
                  _useOwnKey = true;
                  _error = null;
                }),
              ),
              if (_useOwnKey) ...[
                const SizedBox(height: 20),
                TextField(
                  controller: _keyController,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: 'GEMINI_API_KEY',
                    hintText: 'AIza...',
                    errorText: _error,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () =>
                          setState(() => _obscure = !_obscure),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Key: aistudio.google.com/apikey',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _isValidating
                    ? null
                    : (_useOwnKey ? _continueWithKey : _continueDemo),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isValidating
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _useOwnKey ? 'Save Key & Continue' : 'Continue with Demo',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? accent.withValues(alpha: 0.1)
          : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? accent : AppColors.primary.withValues(alpha: 0.12),
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: selected ? accent : AppColors.textSecondary),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.title.copyWith(
                        color: AppColors.primary,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                Icon(Icons.check_circle_rounded, color: accent, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
