import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/colors.dart';
import '../../data/players_controller.dart';

class PlayersBarWidget extends ConsumerWidget {
  const PlayersBarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(playersControllerProvider);
    final hasPlayers = state.players.isNotEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasPlayers ? AppColors.neonPurple.withValues(alpha: 0.5) : AppColors.border,
          width: hasPlayers ? 2 : 1,
        ),
        boxShadow: hasPlayers
            ? [
                BoxShadow(
                  color: AppColors.neonPurple.withValues(alpha: 0.2),
                  blurRadius: 12,
                  spreadRadius: 1,
                )
              ]
            : [],
      ),
      child: Row(
        children: [
          Icon(
            Icons.people_rounded,
            color: hasPlayers ? AppColors.neonPurple : AppColors.muted,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasPlayers ? 'Game Night Mode' : 'Standard Mode',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (hasPlayers)
                  Text(
                    '${state.players.length} Players • ${state.isGameNightMode ? "ON" : "OFF"}',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  )
                else
                  Text(
                    'Add players to enable turn tracking',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _showManagePlayersDialog(context, ref),
            child: Text(hasPlayers ? 'Edit' : 'Add'),
          ),
        ],
      ),
    );
  }

  void _showManagePlayersDialog(BuildContext context, WidgetRef ref) {
    final controller = ref.read(playersControllerProvider.notifier);
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final state = ref.watch(playersControllerProvider);
          return AlertDialog(
            backgroundColor: AppColors.panel,
            title: const Text('Manage Players'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Add player input
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: textController,
                          decoration: const InputDecoration(
                            hintText: 'Player Name',
                            isDense: true,
                          ),
                          onSubmitted: (val) {
                            controller.addPlayer(val);
                            textController.clear();
                          },
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          controller.addPlayer(textController.text);
                          textController.clear();
                        },
                        icon: const Icon(Icons.add_circle_rounded, color: AppColors.neonCyan),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Player list
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: state.players.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final player = state.players[index];
                        return ListTile(
                          title: Text(player.name),
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          trailing: IconButton(
                            icon: const Icon(Icons.remove_circle_outline, size: 20),
                            onPressed: () => controller.removePlayer(player.id),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              if (state.players.isNotEmpty)
                TextButton(
                  onPressed: () {
                    controller.clearAll();
                    Navigator.pop(context);
                  },
                  child: const Text('Clear All', style: TextStyle(color: Colors.redAccent)),
                ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Done'),
              ),
            ],
          );
        },
      ),
    );
  }
}
