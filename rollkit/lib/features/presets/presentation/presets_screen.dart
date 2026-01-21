import 'package:flutter/material.dart';
import '../../../shared/widgets/neon_scaffold.dart';

class PresetsScreen extends StatelessWidget {
  const PresetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const NeonScaffold(
      title: 'Presets',
      child: Center(child: Text('Acá van tus presets guardados')),
    );
  }
}
