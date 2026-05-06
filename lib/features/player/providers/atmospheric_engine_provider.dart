import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/scene_data.dart';
import '../services/audio_handler.dart';
import 'scene_config_provider.dart';

/// State for the currently active scene
class SceneState {
  final SceneDefinition scene;
  final bool isPlaying;
  final double masterVolume;
  final List<AudioTrack> audioTracks;
  final int? sleepTimerMinutes;
  final int? sleepTimerRemainingSeconds;

  const SceneState({
    required this.scene,
    this.isPlaying = true,
    this.masterVolume = 1.0,
    required this.audioTracks,
    this.sleepTimerMinutes,
    this.sleepTimerRemainingSeconds,
  });

  SceneState copyWith({
    SceneDefinition? scene,
    bool? isPlaying,
    double? masterVolume,
    List<AudioTrack>? audioTracks,
    int? sleepTimerMinutes,
    int? sleepTimerRemainingSeconds,
  }) {
    return SceneState(
      scene: scene ?? this.scene,
      isPlaying: isPlaying ?? this.isPlaying,
      masterVolume: masterVolume ?? this.masterVolume,
      audioTracks: audioTracks ?? this.audioTracks,
      sleepTimerMinutes: sleepTimerMinutes ?? this.sleepTimerMinutes,
      sleepTimerRemainingSeconds: sleepTimerRemainingSeconds ?? this.sleepTimerRemainingSeconds,
    );
  }
}

String _mapSceneIdToString(SceneId id) {
  switch (id) {
    case SceneId.classicHearth:
      return 'classic_hearth';
    case SceneId.midnightForest:
      return 'rain_forest';
    case SceneId.coastalBreeze:
      return 'river_side';
    case SceneId.zenGarden:
      return 'tibet_temple';
    case SceneId.rainyCafe:
      return 'hut_in_rain';
    case SceneId.himalayanCabin:
      return 'himalayan_cabin';
    default:
      return 'classic_hearth'; // Fallback
  }
}

List<AudioTrack> _tracksForScene(
    SceneId id, Map<String, dynamic> remoteConfig) {
  final stringId = _mapSceneIdToString(id);

  if (remoteConfig.containsKey(stringId)) {
    return List<AudioTrack>.from(remoteConfig[stringId]['tracks']);
  }

  // Fallback to local configs
  switch (id) {
    case SceneId.classicHearth:
      return SceneData.hearth();
    case SceneId.midnightForest:
      return SceneData.forest();
    case SceneId.himalayanCabin:
      return SceneData.cabin();
    case SceneId.coastalBreeze:
      return SceneData.coastal();
    default:
      return [];
  }
}

class AtmosphericEngineNotifier extends StateNotifier<SceneState> {
  final AppAudioHandler _audioHandler;
  final Map<String, dynamic> _remoteConfig;
  Timer? _sleepTimer;

  AtmosphericEngineNotifier({
    required AppAudioHandler audioHandler,
    required Map<String, dynamic> remoteConfig,
  })  : _audioHandler = audioHandler,
        _remoteConfig = remoteConfig,
        super(
          SceneState(
            scene: SceneData.all.first,
            audioTracks: _tracksForScene(SceneData.all.first.id, remoteConfig),
          ),
        ) {
    // Load initial scene
    _initializeScene(state.scene, state.audioTracks);
  }

  @override
  void dispose() {
    _sleepTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeScene(SceneDefinition scene, List<AudioTrack> tracks) async {
    await _loadSavedMix(scene, tracks);
    await _audioHandler.loadScene(scene, state.audioTracks, masterVolume: state.masterVolume);
    if (mounted && state.isPlaying) {
      _audioHandler.play();
    }
  }

  Future<void> _loadSavedMix(SceneDefinition scene, List<AudioTrack> defaultTracks) async {
    final prefs = await SharedPreferences.getInstance();
    final savedJson = prefs.getString('mix_${scene.id}');
    
    if (savedJson != null) {
      try {
        final Map<String, dynamic> savedVolumes = jsonDecode(savedJson);
        final restoredTracks = defaultTracks.map((track) {
          if (savedVolumes.containsKey(track.id)) {
            return track.copyWith(volume: (savedVolumes[track.id] as num).toDouble());
          }
          return track;
        }).toList();
        state = state.copyWith(audioTracks: restoredTracks);
        return;
      } catch (e) {
        // Fallback to default if decoding fails
      }
    }
    state = state.copyWith(audioTracks: defaultTracks);
  }

  Future<void> saveCurrentMix() async {
    final prefs = await SharedPreferences.getInstance();
    final volumesMap = {
      for (final track in state.audioTracks) track.id: track.volume
    };
    await prefs.setString('mix_${state.scene.id}', jsonEncode(volumesMap));
  }

  void startSleepTimer(int minutes) {
    _sleepTimer?.cancel();
    state = state.copyWith(
      sleepTimerMinutes: minutes,
      sleepTimerRemainingSeconds: minutes * 60,
    );

    _sleepTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final remaining = (state.sleepTimerRemainingSeconds ?? 0) - 1;
      
      if (remaining <= 0) {
        timer.cancel();
        pause();
        state = state.copyWith(
          sleepTimerMinutes: null,
          sleepTimerRemainingSeconds: null,
        );
      } else {
        // Optional: fade out over last 30 seconds
        if (remaining <= 30 && remaining > 0) {
           final fadeRatio = remaining / 30.0;
           _audioHandler.setMasterVolume(state.masterVolume * fadeRatio);
        }
        
        state = state.copyWith(sleepTimerRemainingSeconds: remaining);
      }
    });
  }

  void cancelSleepTimer() {
    _sleepTimer?.cancel();
    state = state.copyWith(
      sleepTimerMinutes: null,
      sleepTimerRemainingSeconds: null,
    );
    // Restore master volume if fade out was interrupted
    _audioHandler.setMasterVolume(state.masterVolume);
  }

  void selectScene(SceneDefinition scene) {
    if (scene.id == state.scene.id) return;

    final tracks = _tracksForScene(scene.id, _remoteConfig);
    state = state.copyWith(
      scene: scene,
      audioTracks: tracks,
      isPlaying: true,
    );
    
    _initializeScene(scene, tracks);
  }

  void togglePlayPause() {
    final isPlaying = !state.isPlaying;
    state = state.copyWith(isPlaying: isPlaying);

    if (isPlaying) {
      _audioHandler.play();
    } else {
      _audioHandler.pause();
    }
  }

  void pause() {
    if (state.isPlaying) {
      state = state.copyWith(isPlaying: false);
      _audioHandler.pause();
    }
  }

  void setMasterVolume(double volume) {
    final clamped = volume.clamp(0.0, 1.0);
    state = state.copyWith(masterVolume: clamped);
    _audioHandler.setMasterVolume(clamped);
  }

  void setTrackVolume(String trackId, double volume) {
    final clamped = volume.clamp(0.0, 1.0);

    // Update State
    final updatedTracks = state.audioTracks.map((track) {
      if (track.id == trackId) {
        return track.copyWith(volume: clamped);
      }
      return track;
    }).toList();
    state = state.copyWith(audioTracks: updatedTracks);

    // Update Audio mix
    _audioHandler.setTrackVolume(trackId, clamped);
  }
}

final atmosphericEngineProvider =
    StateNotifierProvider<AtmosphericEngineNotifier, SceneState>(
  (ref) {
    final handler = ref.watch(audioHandlerProvider);
    final remoteConfigAsync = ref.watch(remoteSceneConfigProvider);

    // Pass empty map or the loaded remote config map
    final configMap = remoteConfigAsync.valueOrNull ?? {};

    return AtmosphericEngineNotifier(
      audioHandler: handler,
      remoteConfig: configMap,
    );
  },
);
