class TimerState {
  final Duration initialDuration;
  final Duration timeLeft;
  final bool isRunning;
  final bool isFinished;

  const TimerState({
    this.initialDuration = const Duration(minutes: 1),
    this.timeLeft = const Duration(minutes: 1),
    this.isRunning = false,
    this.isFinished = false,
  });
  
  // Computed
  double get progress =>  initialDuration.inMilliseconds == 0 
      ? 0 
      : timeLeft.inMilliseconds / initialDuration.inMilliseconds;

  TimerState copyWith({
    Duration? initialDuration,
    Duration? timeLeft,
    bool? isRunning,
    bool? isFinished,
  }) {
    return TimerState(
      initialDuration: initialDuration ?? this.initialDuration,
      timeLeft: timeLeft ?? this.timeLeft,
      isRunning: isRunning ?? this.isRunning,
      isFinished: isFinished ?? this.isFinished,
    );
  }
}
