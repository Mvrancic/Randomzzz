import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/colors.dart';
import '../../../../shared/widgets/neon_scaffold.dart';
import '../../players/data/players_controller.dart';
import '../data/roulette_controller.dart';
import 'widgets/roulette_wheel.dart';

class RouletteScreen extends ConsumerStatefulWidget {
  const RouletteScreen({super.key});

  @override
  ConsumerState<RouletteScreen> createState() => _RouletteScreenState();
}

class _RouletteScreenState extends ConsumerState<RouletteScreen> {
  final TextEditingController _itemController = TextEditingController();

  @override
  void dispose() {
    _itemController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(rouletteControllerProvider);
    final controller = ref.read(rouletteControllerProvider.notifier);
    final playersState = ref.watch(playersControllerProvider);
    final playersController = ref.read(playersControllerProvider.notifier);
    
    final currentPlayer = playersState.currentPlayer;

    return NeonScaffold(
      title: 'Roulette',
      actions: [
        IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.close_rounded),
        ),
      ],
      child: Column(
        children: [
           // Turn Info (Similar to Dice)
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
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40), // Push it a bit lower as requested
                    SizedBox(
                      height: 400,
                      child: RouletteWheel(
                        items: state.items,
                        isSpinning: state.isSpinning,
                        winnerIndex: state.winnerIndex,
                        onAnimationEnd: () {
                           _showResultDialog(context, state.items[state.winnerIndex ?? 0], currentPlayer?.name);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Controls / Item Management
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
                  // Game Night Toggle / Add Item Row
                  Row(
                     children: [
                       if (playersState.players.isNotEmpty)
                        Row(
                          children: [
                             Switch(
                              value: state.usePlayers, 
                              onChanged: (val) {
                                controller.toggleUsePlayers(val);
                              },
                              activeTrackColor: AppColors.neonPurple,
                              activeThumbColor: AppColors.text,
                            ),
                            const Text('Use Players'),
                            const SizedBox(width: 16),
                          ],
                        ),
                        
                       if (!state.usePlayers) ...[
                         Expanded(
                           child: TextField(
                             controller: _itemController,
                             enabled: !state.isSpinning,
                             decoration: InputDecoration(
                               hintText: 'Add item...',
                               filled: true,
                               fillColor: AppColors.panel,
                               border: OutlineInputBorder(
                                 borderRadius: BorderRadius.circular(12),
                                 borderSide: BorderSide.none,
                               ),
                               contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                             ),
                             onSubmitted: (val) {
                               controller.addItem(val);
                               _itemController.clear();
                             },
                           ),
                         ),
                         const SizedBox(width: 8),
                         IconButton.filled(
                           onPressed: state.isSpinning 
                            ? null 
                            : () {
                             controller.addItem(_itemController.text);
                             _itemController.clear();
                           },
                           icon: const Icon(Icons.add_rounded),
                           style: IconButton.styleFrom(
                             backgroundColor: AppColors.neonGreen,
                             foregroundColor: AppColors.bg,
                           ),
                         ),
                       ],
                     ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Item List (Chips)
                  if (!state.usePlayers)
                    SizedBox(
                      height: 40,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: state.items.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          return Chip(
                            label: Text(state.items[index]),
                            onDeleted: state.isSpinning ? null : () => controller.removeItem(index),
                            backgroundColor: AppColors.panel,
                            deleteIconColor: AppColors.danger,
                            labelStyle: const TextStyle(color: AppColors.text, fontSize: 12),
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          );
                        },
                      ),
                    ),
                    
                  const SizedBox(height: 24),
                  
                  // SPIN BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.neonPurple,
                        foregroundColor: AppColors.bg,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                        shadowColor: AppColors.neonPurple.withValues(alpha: 0.5),
                        disabledBackgroundColor: AppColors.muted,
                      ),
                      onPressed: (state.isSpinning || state.items.isEmpty) 
                          ? null 
                          : controller.spin,
                      child: Text(
                        state.isSpinning ? 'SPINNING...' : 'SPIN',
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

  void _showResultDialog(BuildContext context, String result, String? playerName) {
    showDialog(
      context: context,
      barrierDismissible: true, // Click outside to close
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.panel,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.neonPurple.withValues(alpha: 0.5), width: 2),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.emoji_events_rounded, color: AppColors.neonPurple, size: 48),
                    const SizedBox(height: 16),
                    if (playerName != null) ...[
                      Text(
                        "$playerName's turn",
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                    ],
                    Text(
                      result,
                      style: const TextStyle(
                        color: AppColors.neonCyan,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: AppColors.neonCyan,
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.panel2,
                          foregroundColor: AppColors.neonPurple,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Awesome!'),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: AppColors.muted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
