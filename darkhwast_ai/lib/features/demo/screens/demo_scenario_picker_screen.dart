import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/demo/demo_scenario_catalog.dart';
import '../../../core/providers/demo_provider.dart';

class DemoScenarioPickerScreen extends ConsumerWidget {
  const DemoScenarioPickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Curated demo'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        children: [
          Text(
            'Scenario chunain',
            style: AppTextStyles.headline.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Text(
            'Pehle bill ki photo lein ya gallery se chunain, phir 5-agent pipeline chalega.',
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          ...DemoScenarioCatalog.scenarios.map((scenario) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _ScenarioCard(
                scenario: scenario,
                onTap: () async {
                  await ref
                      .read(demoScenarioProvider.notifier)
                      .setScenario(scenario.id);
                  if (!context.mounted) return;
                  context.push(
                    '/scanner',
                    extra: DemoScanLaunch(
                      scenarioId: scenario.id,
                      runDemoImmediately: false,
                    ),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ScenarioCard extends StatelessWidget {
  const _ScenarioCard({required this.scenario, required this.onTap});

  final DemoScenario scenario;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.12),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(scenario.icon, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          scenario.titleUrdu,
                          style: AppTextStyles.title.copyWith(
                            color: AppColors.primary,
                            fontSize: 17,
                          ),
                        ),
                        Text(scenario.authority, style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'HAQ ${scenario.haqScore}',
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                scenario.hook,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    scenario.hasGhostDeadline
                        ? Icons.warning_amber_rounded
                        : Icons.schedule_rounded,
                    size: 16,
                    color: scenario.urgencyColor,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      scenario.urgencyBadge,
                      style: AppTextStyles.caption.copyWith(
                        color: scenario.urgencyColor,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (scenario.hasCollective)
                    Text(
                      '29 collective',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
