import 'package:flutter/material.dart';
import '../../../shared/widgets/neon_scaffold.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const NeonScaffold(
      title: 'Settings',
      child: Center(child: Text('Sonido · Haptics · Tema · About')),
    );
  }
}
