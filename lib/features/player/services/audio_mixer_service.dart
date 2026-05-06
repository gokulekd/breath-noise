import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../../../core/constants/scene_data.dart';

/// A service to manage multiple synchronized audio tracks using just_audio.
class AudioMixerService {
  // Map of track ID to AudioPlayer instance
  final Map<String, AudioPlayer> _players = {};

  // Current master volume (0.0 to 1.0)
  double _masterVolume = 1.0;

  // Current individual track volumes to calculate actual player volume
  final Map<String, double> _trackVolumes = {};

  /// Loads the audio tracks for a given scene.
  /// Disposes of any previously playing tracks.
  Future<void> loadScene(List<AudioTrack> tracks,
      {double masterVolume = 1.0}) async {
    // 1. Stop and dispose old players
    await stopAll();

    _masterVolume = masterVolume;
    _trackVolumes.clear();

    // 2. Initialize new players
    for (final track in tracks) {
      if (track.networkUrl == null) continue;

      try {
        final player = AudioPlayer();
        await player.setUrl(track.networkUrl!);
        await player.setLoopMode(LoopMode.one); // Seamless looping

        _trackVolumes[track.id] = track.volume;
        player.setVolume(_calculateActualVolume(track.volume));

        _players[track.id] = player;
      } catch (e) {
        debugPrint('Error loading track ${track.id}: $e');
      }
    }
  }

  /// Calculates the actual volume applied to the player.
  double _calculateActualVolume(double trackVolume) {
    return (trackVolume * _masterVolume).clamp(0.0, 1.0);
  }

  /// Plays all loaded tracks simultaneously.
  Future<void> playAll() async {
    final futures = _players.values.map((player) => player.play());
    await Future.wait(futures);
  }

  /// Pauses all tracks.
  Future<void> pauseAll() async {
    final futures = _players.values.map((player) => player.pause());
    await Future.wait(futures);
  }

  /// Stops and disposes all tracks, clearing the mixer.
  Future<void> stopAll() async {
    final futures = _players.values.map((player) async {
      await player.stop();
      await player.dispose();
    });
    await Future.wait(futures);
    _players.clear();
  }

  /// Updates the master volume, adjusting all tracks proportionally.
  void setMasterVolume(double volume) {
    _masterVolume = volume.clamp(0.0, 1.0);
    _players.forEach((id, player) {
      final trackVol = _trackVolumes[id] ?? 0.0;
      player.setVolume(_calculateActualVolume(trackVol));
    });
  }

  /// Updates the volume of a specific track.
  void setTrackVolume(String trackId, double volume) {
    final safeVolume = volume.clamp(0.0, 1.0);
    _trackVolumes[trackId] = safeVolume;

    if (_players.containsKey(trackId)) {
      _players[trackId]!.setVolume(_calculateActualVolume(safeVolume));
    }
  }

  /// Disposes the service.
  void dispose() {
    stopAll();
  }
}
