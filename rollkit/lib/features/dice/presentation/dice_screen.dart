import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/colors.dart';
import '../../../../shared/widgets/neon_scaffold.dart';
import 'package:rollkit/features/dice/data/dice_controller.dart';
import 'widgets/die_widget.dart';

class DiceScreen extends ConsumerWidget {
  const DiceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diceState = ref.watch(diceControllerProvider);
    final controller = ref.read(diceControllerProvider.notifier);

    return NeonScaffold(
      title: 'Dice Roller',
      actions: [
        IconButton(
          onPressed: () => context.pop(), // Or go home if it's not popped
          icon: const Icon(Icons.close_rounded),
        ),
      ],
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 20,
                  runSpacing: 20,
                  children: List.generate(diceState.diceCount, (index) {
                    return DieWidget(
                      value: diceState.values[index],
                      isRolling: diceState.isRolling,
                    );
                  }),
                ),
              ),
            ),
          ),
          // Controls
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.panel2,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              border: Border(top: BorderSide(color: AppColors.border.withValues(alpha: 0.5))),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _CircleButton(
                        icon: Icons.remove_rounded,
                        onTap: controller.removeDie,
                        enabled: diceState.diceCount > 1,
                      ),
                      const SizedBox(width: 24),
                      Text(
                        '${diceState.diceCount} Dice',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(width: 24),
                      _CircleButton(
                        icon: Icons.add_rounded,
                        onTap: controller.addDie,
                        enabled: diceState.diceCount < 5,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.neonCyan,
                        foregroundColor: AppColors.bg,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                        shadowColor: AppColors.neonCyan.withValues(alpha: 0.5),
                      ),
                      onPressed: diceState.isRolling ? null : controller.roll,
                      child: Text(
                        diceState.isRolling ? 'ROLLING...' : 'ROLL',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  const _CircleButton({
    required this.icon,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled ? AppColors.panel : AppColors.panel.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(100),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(100),
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            border: Border.all(
              color: enabled ? AppColors.border : AppColors.border.withValues(alpha: 0.3),
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: enabled ? AppColors.text : AppColors.muted,
          ),
        ),
      ),
    );
  }
}
