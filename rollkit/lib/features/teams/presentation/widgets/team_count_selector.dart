import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';

class TeamCountSelector extends StatelessWidget {
  final int count;
  final Function(int) onChanged;

  const TeamCountSelector({
    super.key, 
    required this.count, 
    required this.onChanged
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'NUMBER OF TEAMS',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.muted, 
            fontSize: 12, 
            fontWeight: FontWeight.bold, 
            letterSpacing: 1.5,
            shadows: [Shadow(color: Colors.black, blurRadius: 4)],
          ),
        ),
        const SizedBox(height: 12),
        Container(
           height: 60,
           decoration: BoxDecoration(
             color: AppColors.panel,
             borderRadius: BorderRadius.circular(16),
             boxShadow: [
               BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10),
             ],
           ),
           child: Row(
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
               IconButton(
                 onPressed: () => onChanged(count - 1),
                 icon: const Icon(Icons.remove_rounded),
                 color: AppColors.neonPink,
               ),
               const SizedBox(width: 24),
               Text(
                 count.toString(),
                 style: const TextStyle(
                   fontSize: 28,
                   fontWeight: FontWeight.bold,
                   color: AppColors.text,
                 ),
               ),
                const SizedBox(width: 24),
                IconButton(
                 onPressed: () => onChanged(count + 1),
                 icon: const Icon(Icons.add_rounded),
                 color: AppColors.neonPink,
               ),
             ],
           ),
        ),
      ],
    );
  }
}
