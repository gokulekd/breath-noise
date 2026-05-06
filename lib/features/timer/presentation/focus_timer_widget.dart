import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../providers/focus_timer_provider.dart';

class FocusTimerWidget extends ConsumerWidget {
  const FocusTimerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final focusState = ref.watch(focusTimerProvider);
    final isRunning = focusState.status == FocusTimerStatus.running;

    final m = (focusState.remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (focusState.remainingSeconds % 60).toString().padLeft(2, '0');

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.backgroundDark.withAlpha(200),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withAlpha(20), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _getModeText(focusState.mode),
            style: const TextStyle(
              color: AppTheme.amberGold,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$m:$s',
            style: const TextStyle(
              color: AppTheme.warmCream,
              fontSize: 48,
              fontWeight: FontWeight.w300,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded),
                color: AppTheme.softWhite,
                iconSize: 32,
                onPressed: () {
                  if (isRunning) {
                    ref.read(focusTimerProvider.notifier).pause();
                  } else {
                    ref.read(focusTimerProvider.notifier).start();
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.stop_rounded),
                color: AppTheme.mutedGray,
                iconSize: 28,
                onPressed: () {
                  ref.read(focusTimerProvider.notifier).stop();
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ModeDot(
                isActive: focusState.mode == FocusTimerMode.pomodoro,
                onTap: () => ref.read(focusTimerProvider.notifier).setMode(FocusTimerMode.pomodoro),
                color: AppTheme.emberOrange,
              ),
              const SizedBox(width: 8),
              _ModeDot(
                isActive: focusState.mode == FocusTimerMode.shortBreak,
                onTap: () => ref.read(focusTimerProvider.notifier).setMode(FocusTimerMode.shortBreak),
                color: AppTheme.amberGold,
              ),
              const SizedBox(width: 8),
              _ModeDot(
                isActive: focusState.mode == FocusTimerMode.longBreak,
                onTap: () => ref.read(focusTimerProvider.notifier).setMode(FocusTimerMode.longBreak),
                color: Colors.blueAccent,
              ),
            ],
          )
        ],
      ),
    );
  }

  String _getModeText(FocusTimerMode mode) {
    switch (mode) {
      case FocusTimerMode.pomodoro:
        return 'FOCUS';
      case FocusTimerMode.shortBreak:
        return 'SHORT BREAK';
      case FocusTimerMode.longBreak:
        return 'LONG BREAK';
    }
  }
}

class _ModeDot extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;
  final Color color;

  const _ModeDot({
    required this.isActive,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: isActive ? 12 : 8,
        height: isActive ? 12 : 8,
        decoration: BoxDecoration(
          color: isActive ? color : Colors.white.withAlpha(60),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
