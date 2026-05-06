import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum FocusTimerMode { pomodoro, shortBreak, longBreak }
enum FocusTimerStatus { idle, running, paused }

class FocusTimerState {
  final FocusTimerMode mode;
  final FocusTimerStatus status;
  final int remainingSeconds;
  final int initialSeconds;

  const FocusTimerState({
    required this.mode,
    required this.status,
    required this.remainingSeconds,
    required this.initialSeconds,
  });

  FocusTimerState copyWith({
    FocusTimerMode? mode,
    FocusTimerStatus? status,
    int? remainingSeconds,
    int? initialSeconds,
  }) {
    return FocusTimerState(
      mode: mode ?? this.mode,
      status: status ?? this.status,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      initialSeconds: initialSeconds ?? this.initialSeconds,
    );
  }
}

class FocusTimerNotifier extends StateNotifier<FocusTimerState> {
  Timer? _timer;

  static const int pomodoroSeconds = 25 * 60;
  static const int shortBreakSeconds = 5 * 60;
  static const int longBreakSeconds = 15 * 60;

  FocusTimerNotifier()
      : super(const FocusTimerState(
          mode: FocusTimerMode.pomodoro,
          status: FocusTimerStatus.idle,
          remainingSeconds: pomodoroSeconds,
          initialSeconds: pomodoroSeconds,
        ));

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void start() {
    if (state.status == FocusTimerStatus.running) return;

    state = state.copyWith(status: FocusTimerStatus.running);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (state.remainingSeconds > 0) {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      } else {
        timer.cancel();
        state = state.copyWith(status: FocusTimerStatus.idle);
      }
    });
  }

  void pause() {
    _timer?.cancel();
    state = state.copyWith(status: FocusTimerStatus.paused);
  }

  void stop() {
    _timer?.cancel();
    state = state.copyWith(
      status: FocusTimerStatus.idle,
      remainingSeconds: state.initialSeconds,
    );
  }

  void setMode(FocusTimerMode mode) {
    _timer?.cancel();
    int seconds = pomodoroSeconds;
    if (mode == FocusTimerMode.shortBreak) seconds = shortBreakSeconds;
    if (mode == FocusTimerMode.longBreak) seconds = longBreakSeconds;

    state = state.copyWith(
      mode: mode,
      status: FocusTimerStatus.idle,
      remainingSeconds: seconds,
      initialSeconds: seconds,
    );
  }
}

final focusTimerProvider = StateNotifierProvider<FocusTimerNotifier, FocusTimerState>((ref) {
  return FocusTimerNotifier();
});
