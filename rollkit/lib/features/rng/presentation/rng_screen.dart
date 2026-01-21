import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/colors.dart';
import '../../../../shared/widgets/neon_scaffold.dart';
import '../../players/data/players_controller.dart';
import '../data/rng_controller.dart';

class RngScreen extends ConsumerStatefulWidget {
  const RngScreen({super.key});

  @override
  ConsumerState<RngScreen> createState() => _RngScreenState();
}

class _RngScreenState extends ConsumerState<RngScreen> {
  final TextEditingController _minController = TextEditingController();
  final TextEditingController _maxController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize controllers with default values
    final state = ref.read(rngControllerProvider);
    _minController.text = state.min.toString();
    _maxController.text = state.max.toString();
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  void _copyToClipboard(BuildContext context, int? value) {
    if (value != null) {
      Clipboard.setData(ClipboardData(text: value.toString()));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Copied to clipboard!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(rngControllerProvider);
    final controller = ref.read(rngControllerProvider.notifier);
    final playersState = ref.watch(playersControllerProvider);
    final playersController = ref.read(playersControllerProvider.notifier);
    
    final currentPlayer = playersState.currentPlayer;

    return NeonScaffold(
      title: 'Number Generator',
      actions: [
        IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.close_rounded),
        ),
      ],
      child: Column(
        children: [
           // Turn Info
          if (playersState.isGameNightMode && currentPlayer != null)
            Container(
              width: double.infinity,
              color: AppColors.panel,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Turn',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        currentPlayer.name,
                        style: const TextStyle(
                          color: AppColors.neonCyan,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  OutlinedButton(
                    onPressed: playersController.nextTurn,
                    child: const Text('Next'),
                  ),
                ],
              ),
            ),
            
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Result Display
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppColors.panel,
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: AppColors.neonGreen.withValues(alpha: 0.3)),
                       boxShadow: [
                        BoxShadow(
                          color: AppColors.neonGreen.withValues(alpha: 0.1),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'RESULT',
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          state.currentResult?.toString() ?? '-',
                          style: const TextStyle(
                            color: AppColors.neonGreen,
                            fontSize: 80,
                            fontWeight: FontWeight.bold,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (state.currentResult != null)
                          TextButton.icon(
                            onPressed: () => _copyToClipboard(context, state.currentResult),
                            icon: const Icon(Icons.copy_rounded, size: 18),
                            label: const Text('COPY'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Inputs
                  Row(
                    children: [
                      Expanded(
                        child: _NumberInput(
                          label: 'MIN',
                          controller: _minController,
                          onChanged: (val) {
                             if(val.isNotEmpty) controller.setMin(int.parse(val));
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                         child: _NumberInput(
                          label: 'MAX',
                          controller: _maxController,
                          onChanged: (val) {
                            if(val.isNotEmpty) controller.setMax(int.parse(val));
                          },
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Options
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.panel2,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('No Repetition Mode'),
                             Switch(
                              value: state.isUniqueMode, 
                              onChanged: controller.toggleUniqueMode,
                              activeTrackColor: AppColors.neonGreen,
                              activeThumbColor: AppColors.bg,
                              inactiveThumbColor: AppColors.textSecondary,
                              inactiveTrackColor: AppColors.panel,
                            ),
                          ],
                        ),
                        if (state.isUniqueMode) ...[
                          const Divider(color: AppColors.border),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${state.generatedNumbers.length} / ${(state.max - state.min + 1)} generated',
                                style: const TextStyle(color: AppColors.muted, fontSize: 12),
                              ),
                              TextButton(
                                onPressed: controller.resetPoolManual,
                                child: const Text('Reset Pool'),
                              )
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                   const SizedBox(height: 32),
                   
                   // Generate Button
                   SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.neonGreen,
                        foregroundColor: AppColors.bg,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                        shadowColor: AppColors.neonGreen.withValues(alpha: 0.5),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      onPressed: controller.generate,
                      child: const Text('GENERATE'),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // History
                  if (state.history.isNotEmpty) ...[
                     const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'HISTORY',
                         style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 50,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: state.history.length,
                        separatorBuilder: (_,__) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          return Container(
                            width: 50,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.panel,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text(
                              state.history[index].toString(),
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NumberInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final Function(String) onChanged;

  const _NumberInput({
    required this.label, 
    required this.controller, 
    required this.onChanged
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: onChanged,
          style: const TextStyle(
            fontSize: 20, 
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.panel,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }
}
