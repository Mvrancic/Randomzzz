import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

class NeonScaffold extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final Widget child;

  const NeonScaffold({
    super.key,
    required this.title,
    required this.child,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background glow
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.7, -0.9),
                radius: 1.2,
                colors: [
                  AppColors.neonPurple.withValues(alpha: 0.18),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.9, -0.2),
                radius: 1.4,
                colors: [
                  AppColors.neonCyan.withValues(alpha: 0.14),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(title, style: Theme.of(context).textTheme.titleLarge),
            actions: actions,
          ),
          body: SafeArea(
            top: false,
            child: child,
          ),
        ),
      ],
    );
  }
}
