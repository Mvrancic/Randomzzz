class DiceState {
  final List<int> values;
  final bool isRolling;
  final int diceCount;

  const DiceState({
    required this.values,
    this.isRolling = false,
    required this.diceCount,
  });

  factory DiceState.initial() {
    return const DiceState(
      values: [6], // Start with 1 die showing 6
      diceCount: 1,
      isRolling: false,
    );
  }

  DiceState copyWith({
    List<int>? values,
    bool? isRolling,
    int? diceCount,
  }) {
    return DiceState(
      values: values ?? this.values,
      isRolling: isRolling ?? this.isRolling,
      diceCount: diceCount ?? this.diceCount,
    );
  }
}
