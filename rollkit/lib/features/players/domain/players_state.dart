import 'player.dart';

class PlayersState {
  final List<Player> players;
  final int currentTurnIndex;
  final bool isGameNightMode;

  const PlayersState({
    this.players = const [],
    this.currentTurnIndex = 0,
    this.isGameNightMode = false,
  });

  Player? get currentPlayer => players.isNotEmpty ? players[currentTurnIndex] : null;

  PlayersState copyWith({
    List<Player>? players,
    int? currentTurnIndex,
    bool? isGameNightMode,
  }) {
    return PlayersState(
      players: players ?? this.players,
      currentTurnIndex: currentTurnIndex ?? this.currentTurnIndex,
      isGameNightMode: isGameNightMode ?? this.isGameNightMode,
    );
  }
}
