import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/rng_state.dart';

final rngControllerProvider = StateNotifierProvider<RngController, RngState>((ref) {
  return RngController();
});

class RngController extends StateNotifier<RngState> {
  final _random = Random();

  RngController() : super(RngState.initial());

  void setMin(int value) {
    state = state.copyWith(min: value);
    _resetPool(); // Min/Max change invalidates current pool
  }

  void setMax(int value) {
    state = state.copyWith(max: value);
    _resetPool();
  }

  void toggleUniqueMode(bool value) {
    state = state.copyWith(isUniqueMode: value);
    if (value) {
      _resetPool();
    }
  }

  void _resetPool() {
    state = state.copyWith(generatedNumbers: [], currentResult: null); // Clear result on reset? Or keep?
    // Let's keep result but clear pool tracking
  }

  void resetPoolManual() {
    _resetPool();
    state = state.copyWith(currentResult: null, history: []);
  }

  void generate() {
    if (state.min > state.max) return; // Invalid range

    int result;
    if (state.isUniqueMode) {
      // Calculate available numbers
      final rangeSize = state.max - state.min + 1;
      if (state.generatedNumbers.length >= rangeSize) {
        // Pool exhausted
        return; 
      }

      do {
        result = state.min + _random.nextInt(state.max - state.min + 1);
      } while (state.generatedNumbers.contains(result));

      state = state.copyWith(
        currentResult: result,
        history: [result, ...state.history],
        generatedNumbers: [...state.generatedNumbers, result],
      );
    } else {
      result = state.min + _random.nextInt(state.max - state.min + 1);
      state = state.copyWith(
        currentResult: result,
        history: [result, ...state.history],
      );
    }
  }
}
