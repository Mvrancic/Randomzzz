class TeamPickerState {
  final List<String> manualPlayers;
  final int teamCount;
  final List<List<String>>? teams;
  final bool usePlayers; // If true, uses global players from Game Night mode

  const TeamPickerState({
    this.manualPlayers = const [],
    this.teamCount = 2,
    this.teams,
    this.usePlayers = false,
  });

  factory TeamPickerState.initial() {
    return const TeamPickerState();
  }

  TeamPickerState copyWith({
    List<String>? manualPlayers,
    int? teamCount,
    List<List<String>>? teams,
    bool? usePlayers,
  }) {
    return TeamPickerState(
      manualPlayers: manualPlayers ?? this.manualPlayers,
      teamCount: teamCount ?? this.teamCount,
      teams: teams ?? this.teams,
      usePlayers: usePlayers ?? this.usePlayers,
    );
  }
}
