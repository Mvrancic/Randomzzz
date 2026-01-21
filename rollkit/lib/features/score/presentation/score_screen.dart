import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/colors.dart';
import '../../../../shared/widgets/neon_scaffold.dart';
import '../../players/data/players_controller.dart';
import '../data/score_controller.dart';
import '../domain/score_state.dart';

class ScoreScreen extends ConsumerWidget {
  const ScoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scoreControllerProvider);
    final controller = ref.read(scoreControllerProvider.notifier);

    return NeonScaffold(
      title: 'Score Counter',
      actions: [
        IconButton(
          onPressed: () {
            controller.addPlayer();
          },
          icon: const Icon(Icons.person_add_rounded),
        ),
         IconButton(
          onPressed: () {
            // Check for game night players
            final players = ref.read(playersControllerProvider).players;
            if (players.isNotEmpty) {
               showDialog(
                 context: context,
                 builder: (ctx) => AlertDialog(
                   backgroundColor: AppColors.panel,
                   title: const Text('Load Game Night Players?', style: TextStyle(color: AppColors.text)),
                   content: Text(
                     'Found ${players.length} active players. This will replace the current scoreboard.', 
                     style: TextStyle(color: AppColors.textSecondary)
                   ),
                   actions: [
                     TextButton(onPressed: () => ctx.pop(), child: const Text('CANCEL')),
                     TextButton(onPressed: () {
                       controller.loadPlayers(players);
                       ctx.pop();
                     }, child: const Text('LOAD', style: TextStyle(color: AppColors.neonCyan))),
                   ],
                 ),
               );
            } else {
               ScaffoldMessenger.of(context).showSnackBar(
                 const SnackBar(
                   content: Text('No Game Night players found. Add them on the Home Screen!'),
                   backgroundColor: AppColors.panel2,
                 ),
               );
            }
          },
          icon: const Icon(Icons.groups_2_rounded), // Use group icon for bulk load
        ),
         IconButton(
          onPressed: () {
             showDialog(
                context: context, 
                builder: (ctx) => AlertDialog(
                  backgroundColor: AppColors.panel,
                  title: const Text('Reset Scores?', style: TextStyle(color: AppColors.text)),
                  content: Text('This will reset all scores to zero.', style: TextStyle(color: AppColors.textSecondary)),
                  actions: [
                    TextButton(onPressed: () => ctx.pop(), child: const Text('CANCEL')),
                    TextButton(onPressed: () {
                      controller.resetScores();
                      ctx.pop();
                    }, child: const Text('RESET', style: TextStyle(color: AppColors.danger))),
                  ],
                ),
             );
          },
          icon: const Icon(Icons.refresh_rounded),
        ),
        IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.close_rounded),
        ),
      ],
      child: state.isVersusMode
          ? _VersusMode(state: state, controller: controller)
          : _GridMode(state: state, controller: controller),
    );
  }
}

class _VersusMode extends StatelessWidget {
  final ScoreState state;
  final ScoreController controller;

  const _VersusMode({required this.state, required this.controller});

  @override
  Widget build(BuildContext context) {
    // Left and Right Split
    final p1 = state.players[0];
    final p2 = state.players[1];

    return Row(
      children: [
        Expanded(
          child: _VersusPanel(
            player: p1, 
            controller: controller,
            isLeft: true,
          ),
        ),
        Container(width: 2, color: AppColors.border),
        Expanded(
          child: _VersusPanel(
            player: p2, 
            controller: controller,
            isLeft: false,
          ),
        ),
      ],
    );
  }
}

class _VersusPanel extends StatelessWidget {
  final ScorePlayer player;
  final ScoreController controller;
  final bool isLeft;

  const _VersusPanel({required this.player, required this.controller, required this.isLeft});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top Area (Increment) - 3/4 of height
        Expanded(
          flex: 3,
          child: GestureDetector(
            onTap: () => controller.updateScore(player.id, 1),
            behavior: HitTestBehavior.opaque,
            child: Container(
              color: Colors.transparent, // Capture taps
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Name (Editable)
                  GestureDetector(
                    onTap: () async {
                       final newName = await showDialog<String>(
                         context: context,
                         builder: (context) {
                           final textController = TextEditingController(text: player.name);
                           return AlertDialog(
                             backgroundColor: AppColors.panel,
                             title: const Text('Rename Team', style: TextStyle(color: AppColors.text)),
                             content: TextField(
                               controller: textController,
                               autofocus: true,
                               style: const TextStyle(color: AppColors.text),
                               decoration: const InputDecoration(
                                 hintText: 'Enter name',
                                 hintStyle: TextStyle(color: AppColors.muted),
                                 enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.neonCyan)),
                                 focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.neonCyan, width: 2)),
                               ),
                               onSubmitted: (val) => Navigator.pop(context, val),
                             ),
                             actions: [
                               TextButton(
                                 onPressed: () => Navigator.pop(context), 
                                 child: const Text('CANCEL', style: TextStyle(color: AppColors.muted))
                               ),
                               TextButton(
                                 onPressed: () => Navigator.pop(context, textController.text), 
                                 child: const Text('SAVE', style: TextStyle(color: AppColors.neonCyan, fontWeight: FontWeight.bold))
                               ),
                             ],
                           );
                         },
                       );
                       
                       if (newName != null && newName.isNotEmpty) {
                         controller.updateName(player.id, newName);
                       }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          player.name,
                          style: TextStyle(
                            color: player.color, 
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.edit_rounded, size: 16, color: (player.color ?? Colors.white).withValues(alpha: 0.5)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '${player.score}',
                    style: TextStyle(
                      fontSize: 100,
                      fontWeight: FontWeight.bold,
                      color: player.color,
                      shadows: [
                         Shadow(
                           color: (player.color ?? Colors.white).withValues(alpha: 0.5),
                           blurRadius: 30,
                         ),
                      ]
                    ),
                  ).animate(key: ValueKey(player.score)).scale(duration: 200.ms, curve: Curves.easeOutBack),
                ],
              ),
            ),
          ),
        ),
        
        // No divider as requested
        
        // Bottom Area (Decrement) - 1/4 of height
        Expanded(
          flex: 1,
          child: GestureDetector(
            onTap: () => controller.updateScore(player.id, -1),
             behavior: HitTestBehavior.opaque,
             child: Container(
               color: Colors.transparent,
               width: double.infinity,
               alignment: Alignment.center,
               // No icon, just touch area
             ),
          ),
        ),
      ],
    );
  }
}

class _GridMode extends StatelessWidget {
  final ScoreState state;
  final ScoreController controller;

  const _GridMode({required this.state, required this.controller});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: state.players.length,
      itemBuilder: (context, index) {
        final p = state.players[index];
        return _ScoreCard(player: p, controller: controller);
      },
    );
  }
}

class _ScoreCard extends StatelessWidget {
  final ScorePlayer player;
  final ScoreController controller;

  const _ScoreCard({required this.player, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.panel2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: (player.color ?? AppColors.text).withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          // Header (Name + Remove)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 8, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                       final newName = await showDialog<String>(
                         context: context,
                         builder: (context) {
                           final textController = TextEditingController(text: player.name);
                           return AlertDialog(
                             backgroundColor: AppColors.panel,
                             title: const Text('Rename Team', style: TextStyle(color: AppColors.text)),
                             content: TextField(
                               controller: textController,
                               autofocus: true,
                               style: const TextStyle(color: AppColors.text),
                               decoration: const InputDecoration(
                                 hintText: 'Enter name',
                                 hintStyle: TextStyle(color: AppColors.muted),
                                 enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.neonCyan)),
                                 focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.neonCyan, width: 2)),
                               ),
                               onSubmitted: (val) => Navigator.pop(context, val),
                             ),
                             actions: [
                               TextButton(
                                 onPressed: () => Navigator.pop(context), 
                                 child: const Text('CANCEL', style: TextStyle(color: AppColors.muted))
                               ),
                               TextButton(
                                 onPressed: () => Navigator.pop(context, textController.text), 
                                 child: const Text('SAVE', style: TextStyle(color: AppColors.neonCyan, fontWeight: FontWeight.bold))
                               ),
                             ],
                           );
                         },
                       );
                       
                       if (newName != null && newName.isNotEmpty) {
                         controller.updateName(player.id, newName);
                       }
                    },
                    child: Text(
                      player.name,
                      style: TextStyle(
                        color: player.color,
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => controller.removePlayer(player.id),
                  icon: const Icon(Icons.close_rounded, size: 16),
                  color: AppColors.muted,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: Center(
              child: Text(
                '${player.score}',
                style: const TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ).animate(key: ValueKey(player.score)).scale(duration: 150.ms),
            ),
          ),
          
          // Controls
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _CircleButton(
                  icon: Icons.remove, 
                  color: AppColors.panel, 
                  onTap: () => controller.updateScore(player.id, -1),
                ),
                _CircleButton(
                  icon: Icons.add, 
                  color: AppColors.neonGreen, 
                  onTap: () => controller.updateScore(player.id, 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CircleButton({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Icon(icon, color: AppColors.text),
        ),
      ),
    );
  }
}
