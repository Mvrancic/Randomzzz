import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../players/data/players_controller.dart';
import '../domain/team_picker_state.dart';

final teamPickerControllerProvider = StateNotifierProvider<TeamPickerController, TeamPickerState>((ref) {
  return TeamPickerController(ref);
});

class TeamPickerController extends StateNotifier<TeamPickerState> {
  final Ref _ref;

  TeamPickerController(this._ref) : super(TeamPickerState.initial()) {
     // Listen to players controller to update state if needed, 
     // but mostly we pull data when generating.
     // However, if we toggle 'usePlayers', we might want to check availability.
     
     // Also, verify if global players are empty, maybe auto-switch to manual? 
     // Keeping it simple for now.
  }

  void addManualPlayer(String name) {
    if (state.usePlayers) return;
    if (name.trim().isEmpty) return;
    state = state.copyWith(manualPlayers: [...state.manualPlayers, name.trim()]);
  }

  void removeManualPlayer(int index) {
    if (state.usePlayers) return;
    if (index >= 0 && index < state.manualPlayers.length) {
      final newPlayers = List<String>.from(state.manualPlayers)..removeAt(index);
      state = state.copyWith(manualPlayers: newPlayers);
    }
  }

  void setTeamCount(int count) {
    if (count < 2 || count > 6) return;
    state = state.copyWith(teamCount: count);
  }

  void toggleUsePlayers(bool value) {
    // Check if there are players?
    final players = _ref.read(playersControllerProvider).players;
    if (value && players.isEmpty) {
        // Maybe don't allow? Or just allow and show empty list.
        // For UI feedback, the view should handle "No players found".
    }
    state = state.copyWith(usePlayers: value);
  }

  void generateTeams() {
    List<String> sourcePlayers;
    
    if (state.usePlayers) {
      final players = _ref.read(playersControllerProvider).players;
      sourcePlayers = players.map((p) => p.name).toList();
    } else {
      sourcePlayers = List.from(state.manualPlayers);
    }

    if (sourcePlayers.length < state.teamCount) {
        // Not enough players to form teams (at least 1 per team?)
        // Or we allow 0 size teams? 
        // Let's assume we proceed and some teams might be empty if users are trolling.
    }

    // Shuffle
    final shuffled = List<String>.from(sourcePlayers)..shuffle();

    // Distribute
    final teams = List.generate(state.teamCount, (_) => <String>[]);
    
    for (int i = 0; i < shuffled.length; i++) {
      teams[i % state.teamCount].add(shuffled[i]);
    }

    state = state.copyWith(teams: teams);
  }
  
  void reset() {
      state = state.copyWith(teams: null);
  }
}
