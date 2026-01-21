import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/dice_state.dart';

final diceControllerProvider = StateNotifierProvider<DiceController, DiceState>((ref) {
  return DiceController();
});

class DiceController extends StateNotifier<DiceState> {
  DiceController() : super(DiceState.initial());

  final _random = Random();

  void addDie() {
    if (state.diceCount < 5) {
      final newCount = state.diceCount + 1;
      final newValues = List<int>.from(state.values)..add(6); // Default 6
      state = state.copyWith(diceCount: newCount, values: newValues);
    }
  }

  void removeDie() {
    if (state.diceCount > 1) {
      final newCount = state.diceCount - 1;
      final newValues = List<int>.from(state.values)..removeLast();
      state = state.copyWith(diceCount: newCount, values: newValues);
    }
  }

  Future<void> roll() async {
    if (state.isRolling) return;

    // Start rolling animation
    state = state.copyWith(isRolling: true);

    // Simulate "rolling" time (e.g. 800ms)
    // In a real app, we might update values rapidly here or let the UI handle the shake
    // For now, let's wait a bit then emit final result.
    await Future.delayed(const Duration(milliseconds: 800));

    // Generate random values for all dice
    final newValues = List.generate(
      state.diceCount,
      (_) => _random.nextInt(6) + 1, // 1-6 standard die
    );

    state = state.copyWith(
      isRolling: false,
      values: newValues,
    );
  }
}
