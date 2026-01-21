class RouletteState {
  final List<String> items;
  final bool isSpinning;
  final int? winnerIndex;
  final bool usePlayers;

  const RouletteState({
    this.items = const [],
    this.isSpinning = false,
    this.winnerIndex,
    this.usePlayers = false,
  });

  factory RouletteState.initial() {
    return const RouletteState(
      items: ['Yes', 'No'], // Default items
      isSpinning: false,
      usePlayers: false,
    );
  }

  RouletteState copyWith({
    List<String>? items,
    bool? isSpinning,
    int? winnerIndex,
    bool? usePlayers,
  }) {
    return RouletteState(
      items: items ?? this.items,
      isSpinning: isSpinning ?? this.isSpinning,
      winnerIndex: winnerIndex ?? this.winnerIndex,
      usePlayers: usePlayers ?? this.usePlayers,
    );
  }
}
