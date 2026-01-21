import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../players/data/players_controller.dart';
import '../../players/domain/player.dart';
import '../domain/roulette_state.dart';

final rouletteControllerProvider = StateNotifierProvider<RouletteController, RouletteState>((ref) {
  return RouletteController(ref);
});

class RouletteController extends StateNotifier<RouletteState> {
  final Ref _ref;
  final _random = Random();

  RouletteController(this._ref) : super(RouletteState.initial()) {
    // Listen to changes in players if usePlayers is active
    _ref.listen<List<Player>>(
      playersControllerProvider.select((s) => s.players),
      (previous, next) {
        if (state.usePlayers) {
          state = state.copyWith(items: next.map((p) => p.name).toList());
        }
      },
    );
  }

  void addItem(String item) {
    if (state.usePlayers) return; // Can't add manually in players mode
    if (item.trim().isEmpty) return;
    state = state.copyWith(items: [...state.items, item.trim()]);
  }

  void removeItem(int index) {
    if (state.usePlayers) return;
    if (index >= 0 && index < state.items.length) {
      final newItems = List<String>.from(state.items)..removeAt(index);
      state = state.copyWith(items: newItems);
    }
  }

  void toggleUsePlayers(bool value) {
    if (value) {
      final players = _ref.read(playersControllerProvider).players;
      state = state.copyWith(
        usePlayers: true,
        items: players.map((p) => p.name).toList(),
      );
    } else {
      state = state.copyWith(usePlayers: false, items: ['Yes', 'No']); // Reset or keep? Reset for now.
    }
  }

  Future<void> spin() async {
    if (state.isSpinning || state.items.isEmpty) return;

    state = state.copyWith(isSpinning: true, winnerIndex: null); // Clear previous winner

    // Simulate spin duration. The animation in the UI should match or be slightly shorter than this logic?
    // Actually, usually the logical result is determined instantly, and the UI spins until it lands on it.
    // Or we pick a random index now, and tell the UI to spin to that target.
    // Let's pick the winner now.
    final winnerIndex = _random.nextInt(state.items.length);
    
    // We'll set the winner index immediately so the UI knows where to stop, 
    // BUT we keep isSpinning true until the animation is expected to end?
    // A better approach for a physics-like feel:
    // Set isSpinning = true.
    // Let the UI handle the curve.
    // Wait for the UI animation duration.
    
    // Let's assume a fixed duration spin for MVP simplicity (e.g. 3 seconds)
    const spinDuration = Duration(seconds: 3);
    
    // Pre-calculate winner so we can maybe use it? 
    // For a real roulette, visual determines winner. 
    // Here, let's say logic determines it, and visual must match.
    // passing winnerIndex early might be needed for the painter to know end angle.
    state = state.copyWith(winnerIndex: winnerIndex);

    await Future.delayed(spinDuration);

    state = state.copyWith(isSpinning: false);
  }
}
