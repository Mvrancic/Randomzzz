import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/colors.dart';
import 'pips_painter.dart';

class DieWidget extends StatelessWidget {
  final int value;
  final bool isRolling;
  final double size;

  const DieWidget({
    super.key,
    required this.value,
    this.isRolling = false,
    this.size = 120, // Increased default size
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.panel, // Explicit dark background
        borderRadius: BorderRadius.circular(size * 0.2),
        border: Border.all(
          color: AppColors.neonCyan.withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonCyan.withValues(alpha: 0.15),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Center(
        child: isRolling
            ? CustomPaint(
                size: Size(size, size),
                painter: PipsPainter(
                  value: value, // Show current value (or random if controller updates it)
                  color: AppColors.text,
                ),
              )
                .animate(onPlay: (c) => c.repeat())
                .shake(duration: 200.ms, hz: 4) // Shake widely
                .rotate(duration: 400.ms, begin: 0, end: 1) // Spin
            : CustomPaint(
                size: Size(size, size),
                painter: PipsPainter(
                  value: value,
                  color: AppColors.text,
                ),
              ).animate(key: ValueKey(value)).scale(
                    duration: 400.ms,
                    curve: Curves.elasticOut,
                    begin: const Offset(0.5, 0.5),
                  ),
      ),
    );
  }
}
