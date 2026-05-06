import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../features/timer/providers/sleep_timer_provider.dart';

class SleepTimerSheet extends ConsumerStatefulWidget {
  const SleepTimerSheet({super.key});

  @override
  ConsumerState<SleepTimerSheet> createState() => _SleepTimerSheetState();
}

class _SleepTimerSheetState extends ConsumerState<SleepTimerSheet> {
  int _selectedMinutes = 30;
  final List<int> _presets = [15, 30, 45, 60, 90, 120];

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(sleepTimerProvider);
    final isRunning = timerState.status == SleepTimerState.running;

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.backgroundMid,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(40),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          const Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Text('⏳', style: TextStyle(fontSize: 24)),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sleep Timer',
                      style: TextStyle(
                        color: AppTheme.warmCream,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Fade out and stop playback',
                      style: TextStyle(color: AppTheme.mutedGray, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Circular timer progress (when running)
          if (isRunning) ...[
            _CircularTimerProgress(timerState: timerState),
            const SizedBox(height: 24),
            _buildCancelButton(context),
          ] else ...[
            // Duration presets
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _presets.map((minutes) {
                  final isSelected = _selectedMinutes == minutes;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedMinutes = minutes),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.emberOrange.withAlpha(30)
                            : AppTheme.backgroundCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.emberOrange.withAlpha(180)
                              : Colors.white.withAlpha(15),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        minutes >= 60
                            ? '${minutes ~/ 60}h${minutes % 60 > 0 ? ' ${minutes % 60}m' : ''}'
                            : '${minutes}m',
                        style: TextStyle(
                          color: isSelected
                              ? AppTheme.emberOrange
                              : AppTheme.softWhite,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w400,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 24),

            // Start button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.emberOrange, AppTheme.amberGold],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.emberOrange.withAlpha(80),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      ref
                          .read(sleepTimerProvider.notifier)
                          .startTimer(Duration(minutes: _selectedMinutes));
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Start Timer',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        ref.read(sleepTimerProvider.notifier).cancelTimer();
        Navigator.pop(context);
      },
      child: const Text(
        'Cancel Timer',
        style: TextStyle(
          color: AppTheme.mutedGray,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _CircularTimerProgress extends StatelessWidget {
  final SleepTimerNotifierState timerState;

  const _CircularTimerProgress({required this.timerState});

  @override
  Widget build(BuildContext context) {
    final remaining = timerState.remaining;
    final h = remaining.inHours;
    final m = remaining.inMinutes.remainder(60);
    final s = remaining.inSeconds.remainder(60);

    return SizedBox(
      width: 180,
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background track
          const SizedBox(
            width: 180,
            height: 180,
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: 6,
              color: AppTheme.deepSlate,
            ),
          ),
          // Progress arc
          SizedBox(
            width: 180,
            height: 180,
            child: CircularProgressIndicator(
              value: timerState.progress,
              strokeWidth: 6,
              strokeCap: StrokeCap.round,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppTheme.emberOrange,
              ),
            ),
          ),
          // Time display
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                h > 0
                    ? '${h}h ${m.toString().padLeft(2, '0')}m'
                    : '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  color: AppTheme.warmCream,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const Text(
                'remaining',
                style: TextStyle(color: AppTheme.mutedGray, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
