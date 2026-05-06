import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/scene_data.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/player/providers/atmospheric_engine_provider.dart';
import '../../../features/timer/presentation/alarm_sheet.dart';
import '../../../features/timer/presentation/focus_timer_widget.dart';
import '../../../features/timer/presentation/sleep_timer_sheet.dart';
import '../../../features/timer/providers/alarm_provider.dart';
import '../../../features/timer/providers/sleep_timer_provider.dart';
import '../../../widgets/audio_track_slider.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  final SceneDefinition scene;

  const PlayerScreen({super.key, required this.scene});

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnim;
  bool _showControls = true;
  bool _showMixer = false;
  bool _showFocusTimer = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      value: 1.0,
    );

    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Auto-hide controls after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() => _showControls = false);
        _fadeController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) {
      _fadeController.forward();
    } else {
      _fadeController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final engineState = ref.watch(atmosphericEngineProvider);
    final timerState = ref.watch(sleepTimerProvider);
    final alarmState = ref.watch(alarmProvider);
    final isTimerRunning = timerState.status == SleepTimerState.running;
    final isAlarmSet = alarmState.isSet;

    // Fade opacity based on sleep timer
    final timerOpacity = isTimerRunning ? timerState.progress : 1.0;

    return Theme(
      data: AppTheme.darkTheme,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundDark,
        body: GestureDetector(
        onTap: _toggleControls,
        child: AnimatedOpacity(
          opacity: timerOpacity.clamp(0.1, 1.0),
          duration: const Duration(seconds: 1),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // == BACKGROUND: Scene Gradient (simulates video bg) ==
              _SceneBackground(scene: widget.scene, pulseAnim: _pulseAnim),

              // == CONTENT OVERLAY ==
              AnimatedOpacity(
                opacity: _showControls ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 400),
                child: IgnorePointer(
                  ignoring: !_showControls,
                  child: Stack(
                    children: [
                      // Top bar
                      _buildTopBar(context, engineState),

                      // Bottom controls
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: _buildBottomControls(
                          context,
                          engineState,
                          isTimerRunning,
                          timerState,
                        ),
                      ),

                      // Audio Mixer Drawer
                      if (_showMixer)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: _AudioMixerPanel(
                            tracks: engineState.audioTracks,
                            onClose: () => setState(() => _showMixer = false),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              if (_showFocusTimer && !_showMixer)
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.25,
                  left: 0,
                  right: 0,
                  child: const Center(child: FocusTimerWidget()),
                ),

              // Timer badge (always visible when timer running)
              if (isTimerRunning && !_showControls)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 12,
                  right: 16,
                  child: _TimerBadge(timerState: timerState),
                ),

              // Alarm badge 
              if (isAlarmSet && !_showControls)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 12 + (isTimerRunning ? 40 : 0),
                  right: 16,
                  child: _AlarmBadge(alarmState: alarmState),
                ),
            ],
          ),
        ),
      ),
    ));
  }

  Widget _buildTopBar(BuildContext context, SceneState engineState) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 8,
          left: 16,
          right: 16,
          bottom: 16,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black.withAlpha(160), Colors.transparent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Row(
          children: [
            // Back button
            _GlassButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(width: 12),

            // Scene info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.scene.name,
                    style: const TextStyle(
                      color: AppTheme.warmCream,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    engineState.isPlaying ? 'Now Playing' : 'Paused',
                    style: TextStyle(
                      color: engineState.isPlaying
                          ? AppTheme.amberGold
                          : AppTheme.mutedGray,
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

              // Alarm button
              _GlassButton(
                icon: Icons.alarm_rounded,
                onTap: () => _showAlarmSheet(context),
              ),
              const SizedBox(width: 8),

              // Cast button
              _GlassButton(
                icon: Icons.cast_rounded,
                onTap: () => _showFeatureSnackBar(context, 'Chromecast'),
              ),
            const SizedBox(width: 8),

            // Settings / info
            _GlassButton(
              icon: Icons.info_outline_rounded,
              onTap: () => _showSceneInfoDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls(
    BuildContext context,
    SceneState engineState,
    bool isTimerRunning,
    SleepTimerNotifierState timerState,
  ) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 24,
        left: 20,
        right: 20,
        top: 40,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.transparent, Colors.black.withAlpha(200)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          // Master volume
          Row(
            children: [
              const Icon(
                Icons.volume_mute_rounded,
                color: AppTheme.mutedGray,
                size: 18,
              ),
              Expanded(
                child: Slider(
                  value: engineState.masterVolume,
                  onChanged: (val) => ref
                      .read(atmosphericEngineProvider.notifier)
                      .setMasterVolume(val),
                ),
              ),
              const Icon(
                Icons.volume_up_rounded,
                color: AppTheme.mutedGray,
                size: 18,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Control buttons row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Focus Timer
              _ControlButton(
                icon: Icons.timer_outlined,
                label: 'Focus',
                isActive: _showFocusTimer,
                onTap: () => setState(() => _showFocusTimer = !_showFocusTimer),
              ),
              const SizedBox(width: 14),

              // Sleep Timer
              _ControlButton(
                icon: isTimerRunning
                    ? Icons.bedtime_rounded
                    : Icons.bedtime_outlined,
                label: isTimerRunning
                    ? _formatDuration(timerState.remaining)
                    : 'Timer',
                isActive: isTimerRunning,
                onTap: () => _showSleepTimerSheet(context),
              ),

              const SizedBox(width: 14),

              // Play / Pause (large center button)
              GestureDetector(
                onTap: () => ref
                    .read(atmosphericEngineProvider.notifier)
                    .togglePlayPause(),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppTheme.emberOrange, AppTheme.amberGold],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.emberOrange.withAlpha(100),
                        blurRadius: 24,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    engineState.isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
              ),

              const SizedBox(width: 14),

              // Mixer
              _ControlButton(
                icon: Icons.equalizer_rounded,
                label: 'Mixer',
                isActive: _showMixer,
                onTap: () => setState(() => _showMixer = !_showMixer),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _showSleepTimerSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const SleepTimerSheet(),
    );
  }

  void _showAlarmSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const AlarmSheet(),
    );
  }

  void _showSceneInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.backgroundCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          widget.scene.name,
          style: const TextStyle(color: AppTheme.warmCream),
        ),
        content: Text(
          widget.scene.tagline,
          style: const TextStyle(color: AppTheme.mutedGray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Close',
              style: TextStyle(color: AppTheme.emberOrange),
            ),
          ),
        ],
      ),
    );
  }

  void _showFeatureSnackBar(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature — Coming in Breath Noise Pro 🚀'),
        backgroundColor: AppTheme.deepSlate,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// ── Private Widgets ──────────────────────────────────────────────────────────

class _SceneBackground extends StatelessWidget {
  final SceneDefinition scene;
  final Animation<double> pulseAnim;

  const _SceneBackground({required this.scene, required this.pulseAnim});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseAnim,
      builder: (context, _) => Container(
        decoration: BoxDecoration(gradient: scene.gradient),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Animated light orb
            Positioned(
              top: MediaQuery.of(context).size.height * 0.2,
              left: MediaQuery.of(context).size.width * 0.1,
              child: Transform.scale(
                scale: pulseAnim.value,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        scene.accentColor.withAlpha(60),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Scene background image
            if (scene.imageAsset != null)
              Positioned.fill(
                child: Opacity(
                  opacity: 0.6,
                  child: Image.asset(
                    scene.imageAsset!,
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              // Scene emoji centered (fallback large watermark style)
              Center(
                child: Transform.scale(
                  scale: pulseAnim.value * 0.98,
                  child: Text(
                    scene.emoji,
                    style: TextStyle(
                      fontSize: 160,
                      shadows: [
                        Shadow(
                          color: scene.primaryColor.withAlpha(60),
                          blurRadius: 80,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Noise / grain overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withAlpha(30),
                      Colors.transparent,
                      Colors.black.withAlpha(60),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GlassButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(20),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withAlpha(30), width: 1),
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(40), blurRadius: 8),
          ],
        ),
        child: Icon(icon, color: AppTheme.softWhite, size: 18),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isActive
                  ? AppTheme.emberOrange.withAlpha(40)
                  : Colors.white.withAlpha(15),
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive
                    ? AppTheme.emberOrange.withAlpha(200)
                    : Colors.white.withAlpha(30),
                width: 1.5,
              ),
            ),
            child: Icon(
              icon,
              color: isActive ? AppTheme.emberOrange : AppTheme.softWhite,
              size: 22,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              color: isActive ? AppTheme.amberGold : AppTheme.mutedGray,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimerBadge extends StatelessWidget {
  final SleepTimerNotifierState timerState;

  const _TimerBadge({required this.timerState});

  @override
  Widget build(BuildContext context) {
    final m =
        timerState.remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s =
        timerState.remaining.inSeconds.remainder(60).toString().padLeft(2, '0');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.emberOrange.withAlpha(40),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.emberOrange.withAlpha(120),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.bedtime_rounded,
            color: AppTheme.amberGold,
            size: 14,
          ),
          const SizedBox(width: 5),
          Text(
            '$m:$s',
            style: const TextStyle(
              color: AppTheme.amberGold,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _AlarmBadge extends StatelessWidget {
  final AlarmState alarmState;

  const _AlarmBadge({required this.alarmState});

  @override
  Widget build(BuildContext context) {
    final t = alarmState.wakeTime;
    if (t == null) return const SizedBox.shrink();

    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withAlpha(40),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.blueAccent.withAlpha(120),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.alarm_rounded,
            color: Colors.blueAccent,
            size: 14,
          ),
          const SizedBox(width: 5),
          Text(
            '$h:$m',
            style: const TextStyle(
              color: Colors.blueAccent,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _AudioMixerPanel extends ConsumerWidget {
  final List<AudioTrack> tracks;
  final VoidCallback onClose;

  const _AudioMixerPanel({required this.tracks, required this.onClose});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 400),
      decoration: BoxDecoration(
        color: AppTheme.backgroundMid.withAlpha(240),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: Colors.white.withAlpha(15), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(120),
            blurRadius: 30,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
            child: Row(
              children: [
                const Text('🎚️', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                const Text(
                  'Sound Mixer',
                  style: TextStyle(
                    color: AppTheme.warmCream,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: onClose,
                  icon: const Icon(
                    Icons.expand_more_rounded,
                    color: AppTheme.mutedGray,
                  ),
                ),
              ],
            ),
          ),

          // Track sliders
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: tracks.length,
              padding: const EdgeInsets.only(bottom: 16),
              itemBuilder: (context, index) {
                final track = tracks[index];
                return AudioTrackSlider(
                  track: track,
                  onVolumeChanged: (vol) {
                    ref
                        .read(atmosphericEngineProvider.notifier)
                        .setTrackVolume(track.id, vol);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
