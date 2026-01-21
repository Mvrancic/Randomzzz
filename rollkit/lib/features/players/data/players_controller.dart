import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/player.dart';
import '../domain/players_state.dart';

final playersControllerProvider = StateNotifierProvider<PlayersController, PlayersState>((ref) {
  return PlayersController();
});

class PlayersController extends StateNotifier<PlayersState> {
  PlayersController() : super(const PlayersState());

  void addPlayer(String name) {
    if (name.trim().isEmpty) return;
    final newPlayer = Player.create(name: name.trim());
    state = state.copyWith(
      players: [...state.players, newPlayer],
      isGameNightMode: true, // Auto-enable when adding players
    );
  }

  void removePlayer(String id) {
    final updatedPlayers = state.players.where((p) => p.id != id).toList();
    // Adjust turn index if needed
    int newIndex = state.currentTurnIndex;
    if (newIndex >= updatedPlayers.length) {
      newIndex = 0;
    }
    
    state = state.copyWith(
      players: updatedPlayers,
      currentTurnIndex: newIndex,
      isGameNightMode: updatedPlayers.isNotEmpty, // Auto-disable if empty
    );
  }

  void nextTurn() {
    if (state.players.isEmpty) return;
    final nextIndex = (state.currentTurnIndex + 1) % state.players.length;
    state = state.copyWith(currentTurnIndex: nextIndex);
  }

  void setTurn(int index) {
    if (index >= 0 && index < state.players.length) {
      state = state.copyWith(currentTurnIndex: index);
    }
  }

  void toggleGameNightMode() {
    if (state.players.isEmpty) return; // Can't enable without players
    state = state.copyWith(isGameNightMode: !state.isGameNightMode);
  }

  void clearAll() {
    state = const PlayersState();
  }
}
