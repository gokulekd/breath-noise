import 'package:flutter/material.dart';

import '../../../core/constants/scene_data.dart';
import '../../../core/theme/app_theme.dart';

class AudioTrackSlider extends StatefulWidget {
  final AudioTrack track;
  final ValueChanged<double> onVolumeChanged;

  const AudioTrackSlider({
    super.key,
    required this.track,
    required this.onVolumeChanged,
  });

  @override
  State<AudioTrackSlider> createState() => _AudioTrackSliderState();
}

class _AudioTrackSliderState extends State<AudioTrackSlider> {
  late double _localVolume;

  @override
  void initState() {
    super.initState();
    _localVolume = widget.track.volume;
  }

  @override
  void didUpdateWidget(AudioTrackSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.track.volume != widget.track.volume) {
      _localVolume = widget.track.volume;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isActive = _localVolume > 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isActive
            ? AppTheme.emberOrange.withAlpha(15)
            : AppTheme.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? AppTheme.emberOrange.withAlpha(80)
              : Colors.white.withAlpha(12),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Emoji + animated indicator
          SizedBox(
            width: 44,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (isActive)
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: _localVolume),
                    duration: const Duration(milliseconds: 300),
                    builder: (context, value, _) => Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.emberOrange.withAlpha(
                          (value * 60).round(),
                        ),
                      ),
                    ),
                  ),
                Text(widget.track.emoji, style: const TextStyle(fontSize: 20)),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Name + Slider
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.track.name,
                      style: TextStyle(
                        color:
                            isActive ? AppTheme.warmCream : AppTheme.mutedGray,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                    if (isActive)
                      Text(
                        '${(_localVolume * 100).round()}%',
                        style: TextStyle(
                          color: AppTheme.amberGold.withAlpha(200),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor:
                        isActive ? AppTheme.emberOrange : AppTheme.deepSlate,
                    inactiveTrackColor: AppTheme.deepSlate,
                    thumbColor:
                        isActive ? AppTheme.amberGold : AppTheme.mutedGray,
                    overlayColor: AppTheme.amberGold.withAlpha(30),
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 7,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 16,
                    ),
                  ),
                  child: Slider(
                    value: _localVolume,
                    onChanged: (val) {
                      setState(() => _localVolume = val);
                      widget.onVolumeChanged(val);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
