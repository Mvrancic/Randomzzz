import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/colors.dart';
import '../../../shared/widgets/neon_scaffold.dart';
import '../../players/presentation/widgets/players_bar_widget.dart';
import 'widgets/game_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <_HubItem>[
      _HubItem(
        icon: Icons.casino_rounded,
        title: 'Dice Roller',
        subtitle: 'Customize your dice and roll them!',
        accent: AppColors.neonCyan,
        onTap: () {
          context.push('/dice');
        },
      ),
      _HubItem(
        icon: Icons.track_changes_rounded,
        title: 'Roulette',
        subtitle: 'Customizable options!',
        accent: AppColors.neonPurple,
        onTap: () {
          context.push('/roulette');
        },
      ),
      _HubItem(
        icon: Icons.numbers_rounded,
        title: 'Number Generator',
        subtitle: 'Min/Max & Unique Mode',
        accent: AppColors.neonGreen,
        onTap: () {
          context.push('/rng');
        },
      ),
      _HubItem(
        icon: Icons.groups_rounded,
        title: 'Team Picker',
        subtitle: 'Balance teams',
        accent: AppColors.neonPink,
        onTap: () {
          context.push('/teams');
        },
      ),
      _HubItem(
        icon: Icons.timer_rounded,
        title: 'Turn Timer',
        subtitle: 'Pass the turn with a tap',
        accent: AppColors.neonCyan,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Soon: Timer')),
          );
        },
      ),
      _HubItem(
        icon: Icons.scoreboard_rounded,
        title: 'Score Counter',
        subtitle: '2–8 players',
        accent: AppColors.neonPurple,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Soon: Score')),
          );
        },
      ),
    ];

    return NeonScaffold(
      title: 'RollKit',
      actions: [
        IconButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Soon: Quick Roll')),
            );
          },
          icon: const Icon(Icons.flash_on_rounded),
        ),
      ],
      child: Column(
        children: [
          const PlayersBarWidget(),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final it = items[i];
          return GameCard(
            icon: it.icon,
            title: it.title,
            subtitle: it.subtitle,
            accent: it.accent,
            onTap: it.onTap,
          )
              .animate()
              .fadeIn(duration: 350.ms, delay: (60 * i).ms)
              .slideY(begin: 0.08, end: 0, duration: 350.ms, curve: Curves.easeOutCubic);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HubItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final VoidCallback onTap;

  _HubItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.onTap,
  });
}

