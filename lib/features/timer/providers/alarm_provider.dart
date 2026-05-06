import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../player/providers/atmospheric_engine_provider.dart';

class AlarmState {
  final bool isSet;
  final DateTime? wakeTime;
  final bool isTriggered;

  AlarmState({
    required this.isSet,
    this.wakeTime,
    this.isTriggered = false,
  });

  AlarmState copyWith({
    bool? isSet,
    DateTime? wakeTime,
    bool? isTriggered,
  }) {
    return AlarmState(
      isSet: isSet ?? this.isSet,
      wakeTime: wakeTime ?? this.wakeTime,
      isTriggered: isTriggered ?? this.isTriggered,
    );
  }
}

class AlarmNotifier extends StateNotifier<AlarmState> {
  final Ref ref;
  Timer? _timer;
  
  AlarmNotifier(this.ref) : super(AlarmState(isSet: false));

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void setAlarm(DateTime time) {
    _timer?.cancel();
    state = AlarmState(isSet: true, wakeTime: time, isTriggered: false);
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (state.wakeTime == null) return;
      
      final now = DateTime.now();
      if (now.isAfter(state.wakeTime!) || now.isAtSameMomentAs(state.wakeTime!)) {
        timer.cancel();
        _triggerAlarm();
      }
    });
  }

  void cancelAlarm() {
    _timer?.cancel();
    state = AlarmState(isSet: false);
  }

  void _triggerAlarm() {
    state = state.copyWith(isTriggered: true);
    final engineNotifier = ref.read(atmosphericEngineProvider.notifier);
    
    // Start audio at 0 volume and fade up over 5 minutes (300 seconds)
    engineNotifier.setMasterVolume(0.0);
    if (!ref.read(atmosphericEngineProvider).isPlaying) {
      engineNotifier.togglePlayPause(); // Play
    }
    
    int elapsed = 0;
    const fadeDurationSeconds = 5 * 60;
    
    Timer.periodic(const Duration(seconds: 1), (fadeTimer) {
      if (!mounted || !state.isTriggered) {
        fadeTimer.cancel();
        return;
      }
      
      elapsed++;
      if (elapsed >= fadeDurationSeconds) {
        engineNotifier.setMasterVolume(1.0);
        fadeTimer.cancel();
      } else {
        engineNotifier.setMasterVolume(elapsed / fadeDurationSeconds);
      }
    });
  }
  
  void stopAlarm() {
    state = state.copyWith(isTriggered: false, isSet: false, wakeTime: null);
  }
}

final alarmProvider = StateNotifierProvider<AlarmNotifier, AlarmState>((ref) {
  return AlarmNotifier(ref);
});
