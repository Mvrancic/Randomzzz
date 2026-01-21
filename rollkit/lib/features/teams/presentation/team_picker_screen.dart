import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/colors.dart';
import '../../../../shared/widgets/neon_scaffold.dart';
import '../../players/data/players_controller.dart';
import '../data/team_picker_controller.dart';

class TeamPickerScreen extends ConsumerStatefulWidget {
  const TeamPickerScreen({super.key});

  @override
  ConsumerState<TeamPickerScreen> createState() => _TeamPickerScreenState();
}

class _TeamPickerScreenState extends ConsumerState<TeamPickerScreen> {
  final TextEditingController _playerController = TextEditingController();

  @override
  void dispose() {
    _playerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(teamPickerControllerProvider);
    final controller = ref.read(teamPickerControllerProvider.notifier);
    final playersState = ref.watch(playersControllerProvider);
    
    // Auto-reset results if input changes? Maybe not necessary.

    return NeonScaffold(
      title: 'Team Picker',
      actions: [
        IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.close_rounded),
        ),
      ],
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                   // Input Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.panel,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        // Toggle Source
                         if (playersState.players.isNotEmpty)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                               const Text(
                                'Use Game Night Players',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                               Switch(
                                value: state.usePlayers, 
                                onChanged: controller.toggleUsePlayers,
                                activeTrackColor: AppColors.neonPink,
                                activeThumbColor: AppColors.bg,
                                inactiveThumbColor: AppColors.textSecondary,
                                inactiveTrackColor: AppColors.panel2,
                              ),
                            ],
                          ),
                          
                        if (state.usePlayers && playersState.players.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: playersState.players.map((p) => Chip(
                              label: Text(p.name),
                              backgroundColor: AppColors.panel2,
                              side: BorderSide.none,
                              labelStyle: const TextStyle(fontSize: 12),
                            )).toList(),
                          ),
                        ] else ...[
                          // Manual Input
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _playerController,
                                  decoration: InputDecoration(
                                    hintText: 'Add player name...',
                                    filled: true,
                                    fillColor: AppColors.panel2,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                  ),
                                  onSubmitted: (val) {
                                    controller.addManualPlayer(val);
                                    _playerController.clear();
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton.filled(
                                onPressed: () {
                                  controller.addManualPlayer(_playerController.text);
                                  _playerController.clear();
                                },
                                icon: const Icon(Icons.add_rounded),
                                style: IconButton.styleFrom(
                                  backgroundColor: AppColors.neonPink,
                                  foregroundColor: AppColors.bg,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                           if (state.manualPlayers.isEmpty)
                            const Text(
                              'Add players to start!',
                              style: TextStyle(color: AppColors.muted, fontStyle: FontStyle.italic),
                            )
                           else
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: state.manualPlayers.asMap().entries.map((entry) {
                                return Chip(
                                  label: Text(entry.value),
                                  onDeleted: () => controller.removeManualPlayer(entry.key),
                                  backgroundColor: AppColors.panel2,
                                  side: BorderSide.none,
                                  deleteIconColor: AppColors.danger,
                                  labelStyle: const TextStyle(fontSize: 12),
                                );
                              }).toList(),
                            ),
                        ],
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Team Count Selection
                  const Text(
                    'NUMBER OF TEAMS',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.muted, 
                      fontSize: 12, 
                      fontWeight: FontWeight.bold, 
                      letterSpacing: 1.5
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                     height: 60,
                     decoration: BoxDecoration(
                       color: AppColors.panel,
                       borderRadius: BorderRadius.circular(16),
                     ),
                     child: Row(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         IconButton(
                           onPressed: () => controller.setTeamCount(state.teamCount - 1),
                           icon: const Icon(Icons.remove_rounded),
                           color: AppColors.neonPink,
                         ),
                         const SizedBox(width: 24),
                         Text(
                           state.teamCount.toString(),
                           style: const TextStyle(
                             fontSize: 28,
                             fontWeight: FontWeight.bold,
                             color: AppColors.text,
                           ),
                         ),
                          const SizedBox(width: 24),
                          IconButton(
                           onPressed: () => controller.setTeamCount(state.teamCount + 1),
                           icon: const Icon(Icons.add_rounded),
                           color: AppColors.neonPink,
                         ),
                       ],
                     ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // RESULTS
                  if (state.teams != null) ...[
                    const Divider(color: AppColors.border),
                    const SizedBox(height: 24),
                     GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.8, 
                        ),
                        itemCount: state.teams!.length,
                        itemBuilder: (context, index) {
                          final team = state.teams![index];
                          return Container(
                            decoration: BoxDecoration(
                              color: AppColors.panel, // Or cycle colors?
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _getTeamColor(index).withValues(alpha: 0.5),
                                width: 2,
                              ),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                     color: _getTeamColor(index).withValues(alpha: 0.2),
                                     borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                                  ),
                                  child: Text(
                                    'Team ${index + 1}',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: _getTeamColor(index),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: ListView.separated(
                                    padding: const EdgeInsets.all(12),
                                    itemCount: team.length,
                                    separatorBuilder: (_,__) => const Divider(height: 8, color: Colors.transparent),
                                    itemBuilder: (context, pIndex) {
                                      return Text(
                                        team[pIndex],
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(fontSize: 14),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                     ),
                  ] else ...[
                     const SizedBox(height: 48),
                     const Center(
                       child: Icon(Icons.groups_3_rounded, size: 64, color: AppColors.panel2),
                     ),
                  ],
                ],
              ),
            ),
          ),
          
          // Generate Button
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.panel2,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              border: Border(top: BorderSide(color: AppColors.border.withValues(alpha: 0.5))),
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonPink,
                    foregroundColor: AppColors.bg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                    shadowColor: AppColors.neonPink.withValues(alpha: 0.5),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  onPressed: controller.generateTeams,
                  child: const Text('SHUFFLE TEAMS'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getTeamColor(int index) {
    const colors = [
      AppColors.neonCyan,
      AppColors.neonGreen,
      AppColors.neonPink,
      AppColors.neonPurple,
      Color(0xFFFFD740),
      Color(0xFFFF6E40),
    ];
    return colors[index % colors.length];
  }
}
