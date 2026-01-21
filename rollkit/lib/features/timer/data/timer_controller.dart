import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/timer_state.dart';

final timerControllerProvider = StateNotifierProvider<TimerController, TimerState>((ref) {
  return TimerController();
});

class TimerController extends StateNotifier<TimerState> {
  Timer? _ticker;

  TimerController() : super(const TimerState());

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void setDuration(Duration duration) {
    _ticker?.cancel();
    state = state.copyWith(
      initialDuration: duration,
      timeLeft: duration,
      isRunning: false,
      isFinished: false,
    );
  }

  void start() {
    if (state.timeLeft.inMilliseconds <= 0) return;
    if (state.isRunning) return;

    state = state.copyWith(isRunning: true, isFinished: false);

    _ticker = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      final newTime = state.timeLeft - const Duration(milliseconds: 100);
      
      if (newTime.inMilliseconds <= 0) {
        timer.cancel();
        state = state.copyWith(
          timeLeft: Duration.zero,
          isRunning: false,
          isFinished: true,
        );
      } else {
        state = state.copyWith(timeLeft: newTime);
      }
    });
  }

  void pause() {
    _ticker?.cancel();
    state = state.copyWith(isRunning: false);
  }
  
  void reset() {
    _ticker?.cancel();
    state = state.copyWith(
      timeLeft: state.initialDuration,
      isRunning: false,
      isFinished: false,
    );
  }

  void nextTurn() {
     // Reset and Start immediately
     reset();
     start();
  }
}
