import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../player/providers/atmospheric_engine_provider.dart';

enum SleepTimerState { idle, running, expired }

class SleepTimerNotifierState {
  final SleepTimerState status;
  final Duration remaining;
  final Duration total;

  const SleepTimerNotifierState({
    this.status = SleepTimerState.idle,
    this.remaining = Duration.zero,
    this.total = Duration.zero,
  });

  double get progress =>
      total.inSeconds == 0 ? 0 : remaining.inSeconds / total.inSeconds;

  SleepTimerNotifierState copyWith({
    SleepTimerState? status,
    Duration? remaining,
    Duration? total,
  }) {
    return SleepTimerNotifierState(
      status: status ?? this.status,
      remaining: remaining ?? this.remaining,
      total: total ?? this.total,
    );
  }
}

class SleepTimerNotifier extends StateNotifier<SleepTimerNotifierState> {
  Timer? _timer;
  final Ref _ref;

  SleepTimerNotifier(this._ref) : super(const SleepTimerNotifierState());

  void startTimer(Duration duration) {
    _timer?.cancel();
    state = SleepTimerNotifierState(
      status: SleepTimerState.running,
      remaining: duration,
      total: duration,
    );
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final newRemaining = state.remaining - const Duration(seconds: 1);

      if (newRemaining <= Duration.zero) {
        timer.cancel();
        _ref.read(atmosphericEngineProvider.notifier).pause();
        state = state.copyWith(
          status: SleepTimerState.expired,
          remaining: Duration.zero,
        );
      } else {
        // Fade out over the last 60 seconds
        if (newRemaining.inSeconds <= 60) {
          final fadeVolume = newRemaining.inSeconds / 60.0;
          _ref
              .read(atmosphericEngineProvider.notifier)
              .setMasterVolume(fadeVolume);
        }
        state = state.copyWith(remaining: newRemaining);
      }
    });
  }

  void cancelTimer() {
    _timer?.cancel();
    state = const SleepTimerNotifierState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final sleepTimerProvider =
    StateNotifierProvider<SleepTimerNotifier, SleepTimerNotifierState>(
  (ref) => SleepTimerNotifier(ref),
);
