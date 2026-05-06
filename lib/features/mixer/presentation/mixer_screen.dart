import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/scene_data.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extension.dart';
import '../../player/providers/atmospheric_engine_provider.dart';

class MixerScreen extends ConsumerWidget {
  const MixerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final engineState = ref.watch(atmosphericEngineProvider);

    return Scaffold(
      backgroundColor: context.scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon:
              Icon(Icons.arrow_back_ios_new_rounded, color: context.iconColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Sound Mixer',
          style: TextStyle(
            color: context.primaryTextColor,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Create your perfect blend',
            style: TextStyle(
              color: context.mutedTextColor,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),
          if (engineState.audioTracks.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Text(
                  'No audio tracks playing right now.',
                  style: TextStyle(color: context.mutedTextColor, fontSize: 16),
                ),
              ),
            )
          else
            ...engineState.audioTracks.map((track) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: _buildMixerTrack(context, ref, track),
              );
            }),
          if (engineState.audioTracks.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildToolsSection(context, ref, engineState)
          ],
        ],
      ),
    );
  }

  Widget _buildToolsSection(
      BuildContext context, WidgetRef ref, SceneState state) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () async {
            await ref.read(atmosphericEngineProvider.notifier).saveCurrentMix();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Mix saved successfully!')),
              );
            }
          },
          icon: const Icon(Icons.save_rounded, color: Colors.white),
          label: const Text('Save as Default Mix',
              style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.amberGold,
            minimumSize: const Size(double.infinity, 54),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.cardBgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.dividerColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.timer_outlined, color: context.primaryTextColor),
                  const SizedBox(width: 12),
                  Text(
                    state.sleepTimerRemainingSeconds != null
                        ? 'Timer: ${state.sleepTimerRemainingSeconds! ~/ 60}m ${state.sleepTimerRemainingSeconds! % 60}s'
                        : 'Sleep Timer',
                    style: TextStyle(
                      color: context.primaryTextColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (state.sleepTimerRemainingSeconds != null)
                TextButton(
                  onPressed: () {
                    ref
                        .read(atmosphericEngineProvider.notifier)
                        .cancelSleepTimer();
                  },
                  child: const Text('Cancel',
                      style: TextStyle(color: Colors.redAccent)),
                )
              else
                DropdownButton<int>(
                  value: null,
                  hint: const Text('Set'),
                  underline: const SizedBox(),
                  icon: const Icon(Icons.arrow_drop_down_rounded),
                  items: [15, 30, 45, 60].map((minutes) {
                    return DropdownMenuItem<int>(
                      value: minutes,
                      child: Text('${minutes}m'),
                    );
                  }).toList(),
                  onChanged: (minutes) {
                    if (minutes != null) {
                      ref
                          .read(atmosphericEngineProvider.notifier)
                          .startSleepTimer(minutes);
                    }
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMixerTrack(
      BuildContext context, WidgetRef ref, AudioTrack track) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.cardBgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.dividerColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(track.emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  track.name,
                  style: TextStyle(
                    color: context.primaryTextColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                track.volume > 0
                    ? Icons.volume_up_rounded
                    : Icons.volume_off_rounded,
                color: track.volume > 0
                    ? AppTheme.amberGold
                    : context.mutedTextColor,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppTheme.emberOrange,
              inactiveTrackColor:
                  context.isDark ? AppTheme.deepSlate : AppTheme.softWhite,
              thumbColor: AppTheme.amberGold,
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: track.volume,
              onChanged: (val) {
                ref
                    .read(atmosphericEngineProvider.notifier)
                    .setTrackVolume(track.id, val);
              },
            ),
          ),
        ],
      ),
    );
  }
}
