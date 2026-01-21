import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/colors.dart';
import '../../../../shared/widgets/neon_scaffold.dart';
import '../data/timer_controller.dart';

class TimerScreen extends ConsumerWidget {
  const TimerScreen({super.key});

  String _formatTime(Duration duration) {
    if (duration.inMilliseconds <= 0) return '00:00';
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    // Optional: show milliseconds if last 10 seconds?
    // For now keep it simple like requested.
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(timerControllerProvider);
    final controller = ref.read(timerControllerProvider.notifier);

    return NeonScaffold(
      title: 'Turn Timer',
      actions: [
        IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.close_rounded),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Timer Display
            Expanded(
              flex: 4,
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Progress Indicator (Circle)
                    SizedBox(
                      width: 300,
                      height: 300,
                      child: CircularProgressIndicator(
                        value: state.progress,
                        strokeWidth: 20,
                        backgroundColor: AppColors.panel2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          state.timeLeft.inSeconds <= 5 
                              ? AppColors.danger 
                              : AppColors.neonCyan,
                        ),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    // Text
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatTime(state.timeLeft),
                          style: TextStyle(
                            fontSize: 80,
                            fontWeight: FontWeight.bold,
                            fontFeatures: const [FontFeature.tabularFigures()],
                            color: state.isFinished ? AppColors.danger : AppColors.text,
                            shadows: [
                              Shadow(
                                color: (state.isFinished ? AppColors.danger : AppColors.neonCyan).withValues(alpha: 0.5),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                        ).animate(target: state.isFinished ? 1 : 0)
                         .shake(duration: 500.ms),
                        
                        if (state.isFinished)
                          const Text(
                            "TIME'S UP!",
                            style: TextStyle(
                              color: AppColors.danger,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ).animate().fadeIn().scale(),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Controls
            Expanded(
              flex: 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Presets
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _PresetButton(
                          label: '30s', 
                          duration: const Duration(seconds: 30),
                          isSelected: state.initialDuration == const Duration(seconds: 30),
                          onTap: () => controller.setDuration(const Duration(seconds: 30)),
                        ),
                        const SizedBox(width: 12),
                        _PresetButton(
                          label: '1m', 
                          duration: const Duration(minutes: 1),
                          isSelected: state.initialDuration == const Duration(minutes: 1),
                          onTap: () => controller.setDuration(const Duration(minutes: 1)),
                        ),
                        const SizedBox(width: 12),
                        _PresetButton(
                          label: '2m', 
                          duration: const Duration(minutes: 2),
                          isSelected: state.initialDuration == const Duration(minutes: 2),
                          onTap: () => controller.setDuration(const Duration(minutes: 2)),
                        ),
                        // Custom?
                        const SizedBox(width: 12),
                        IconButton.filled(
                          onPressed: () async {
                             // Show simple dialog for minutes/seconds
                             final result = await showDialog<Duration>(
                               context: context,
                               builder: (ctx) => const _CustomTimerDialog(),
                             );
                             if (result != null) {
                               controller.setDuration(result);
                             }
                          },
                          icon: const Icon(Icons.edit_rounded),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.panel2,
                            foregroundColor: AppColors.text,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Actions
                  Row(
                    children: [
                      // Play/Pause
                      Expanded(
                        child: SizedBox(
                          height: 64,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.panel2,
                              foregroundColor: AppColors.text,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: state.isRunning ? controller.pause : controller.start,
                            child: Icon(state.isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 32),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // NEXT TURN (Big Button)
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 64,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.neonCyan,
                              foregroundColor: AppColors.bg,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              shadowColor: AppColors.neonCyan.withValues(alpha: 0.5),
                              elevation: 5,
                            ),
                            onPressed: controller.nextTurn,
                            icon: const Icon(Icons.skip_next_rounded, size: 32),
                            label: const Text(
                              'NEXT TURN',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                   const SizedBox(height: 16),
                   TextButton(
                     onPressed: controller.reset,
                     style: TextButton.styleFrom(foregroundColor: AppColors.muted),
                     child: const Text('RESET'),
                   ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PresetButton extends StatelessWidget {
  final String label;
  final Duration duration;
  final bool isSelected;
  final VoidCallback onTap;

  const _PresetButton({
    required this.label,
    required this.duration,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.neonCyan.withValues(alpha: 0.2) : AppColors.panel2,
          border: Border.all(
            color: isSelected ? AppColors.neonCyan : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.neonCyan : AppColors.text,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}


class _CustomTimerDialog extends StatefulWidget {
  const _CustomTimerDialog();

  @override
  State<_CustomTimerDialog> createState() => _CustomTimerDialogState();
}

class _CustomTimerDialogState extends State<_CustomTimerDialog> {
  int _minutes = 5;
  int _seconds = 0;

  @override
  Widget build(BuildContext context) {
    return Dialog(
        backgroundColor: AppColors.panel,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                    const Text('Custom Duration', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                             // Minutes
                             _NumberPicker(
                                 value: _minutes, 
                                 min: 0, 
                                 max: 60, 
                                 onChanged: (v) => setState(() => _minutes = v),
                                 label: 'm',
                             ),
                             const Text(':', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                             // Seconds
                             _NumberPicker(
                                 value: _seconds, 
                                 min: 0, 
                                 max: 59, 
                                 onChanged: (v) => setState(() => _seconds = v),
                                 label: 's',
                             ),
                        ],
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(Duration(minutes: _minutes, seconds: _seconds));
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.neonGreen,
                            foregroundColor: AppColors.bg,
                        ),
                        child: const Text('SET TIMER'),
                    )
                ],
            ),
        ),
    );
  }
}

class _NumberPicker extends StatelessWidget {
    final int value;
    final int min;
    final int max;
    final ValueChanged<int> onChanged;
    final String label;

    const _NumberPicker({required this.value, required this.min, required this.max, required this.onChanged, required this.label});

    @override
    Widget build(BuildContext context) {
        return Column(
            children: [
                IconButton(
                    onPressed: value < max ? () => onChanged(value + 1) : null,
                    icon: const Icon(Icons.keyboard_arrow_up_rounded),
                ),
                Text(
                    '$value$label',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                IconButton(
                    onPressed: value > min ? () => onChanged(value - 1) : null,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                ),
            ],
        );
    }
}
