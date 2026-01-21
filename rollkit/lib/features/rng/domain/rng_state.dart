class RngState {
  final int min;
  final int max;
  final int? currentResult;
  final List<int> history;
  final bool isUniqueMode;
  final List<int> generatedNumbers;

  const RngState({
    this.min = 1,
    this.max = 100,
    this.currentResult,
    this.history = const [],
    this.isUniqueMode = false,
    this.generatedNumbers = const [],
  });

  factory RngState.initial() {
    return const RngState();
  }

  RngState copyWith({
    int? min,
    int? max,
    int? currentResult,
    List<int>? history,
    bool? isUniqueMode,
    List<int>? generatedNumbers,
  }) {
    return RngState(
      min: min ?? this.min,
      max: max ?? this.max,
      currentResult: currentResult ?? this.currentResult,
      history: history ?? this.history,
      isUniqueMode: isUniqueMode ?? this.isUniqueMode,
      generatedNumbers: generatedNumbers ?? this.generatedNumbers,
    );
  }
}
