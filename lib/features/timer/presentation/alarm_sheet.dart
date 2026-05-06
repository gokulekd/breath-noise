import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../providers/alarm_provider.dart';

class AlarmSheet extends ConsumerStatefulWidget {
  const AlarmSheet({super.key});

  @override
  ConsumerState<AlarmSheet> createState() => _AlarmSheetState();
}

class _AlarmSheetState extends ConsumerState<AlarmSheet> {
  DateTime _selectedDate = DateTime.now().add(const Duration(hours: 8)); // default to 8 hours later

  @override
  Widget build(BuildContext context) {
    final alarmState = ref.watch(alarmProvider);
    final isAlarmSet = alarmState.isSet;
    final alarmTimeStr = isAlarmSet && alarmState.wakeTime != null
        ? '${alarmState.wakeTime!.hour.toString().padLeft(2, '0')}:${alarmState.wakeTime!.minute.toString().padLeft(2, '0')}'
        : null;

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.backgroundCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.mutedGray.withAlpha(50),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Wake-up Alarm',
            style: TextStyle(
              color: AppTheme.warmCream,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Gently fade in nature sounds to wake you.',
            style: TextStyle(
              color: AppTheme.mutedGray,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          if (isAlarmSet && alarmTimeStr != null) ...[
            const Text(
              'Alarm set for',
              style: TextStyle(color: AppTheme.amberGold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              alarmTimeStr,
              style: const TextStyle(
                color: AppTheme.warmCream,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                ref.read(alarmProvider.notifier).cancelAlarm();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent.withAlpha(50),
                foregroundColor: Colors.redAccent,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Cancel Alarm'),
            ),
          ] else ...[
            SizedBox(
              height: 200,
              child: CupertinoTheme(
                data: const CupertinoThemeData(
                  textTheme: CupertinoTextThemeData(
                    dateTimePickerTextStyle: TextStyle(
                      color: AppTheme.warmCream,
                      fontSize: 24,
                    ),
                  ),
                ),
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime: _selectedDate,
                  onDateTimeChanged: (val) {
                    setState(() {
                      // Preserve only the time, adjust the day if it's before now
                      final now = DateTime.now();
                      var target = DateTime(now.year, now.month, now.day, val.hour, val.minute);
                      if (target.isBefore(now)) {
                        target = target.add(const Duration(days: 1));
                      }
                      _selectedDate = target;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref.read(alarmProvider.notifier).setAlarm(_selectedDate);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.amberGold,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Set Alarm'),
            ),
          ]
        ],
      ),
    );
  }
}
