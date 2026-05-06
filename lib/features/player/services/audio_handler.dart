import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/scene_data.dart';
import 'audio_mixer_service.dart';

final audioHandlerProvider = Provider<AppAudioHandler>((ref) {
  throw UnimplementedError('Initialized in main.dart');
});

Future<AppAudioHandler> initAudioService() async {
  return await AudioService.init(
    builder: () => AppAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.breath_noise.channel.audio',
      androidNotificationChannelName: 'Breath Noise Audio',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );
}

class AppAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final AudioMixerService _mixer = AudioMixerService();

  AppAudioHandler() {
    _notifyAudioHandlerAboutPlaybackEvents();
  }

  void _notifyAudioHandlerAboutPlaybackEvents() {
    // We mock the playback state based on our mixer commands.
    // AudioMixerService does not emit global play states easily since it has multiple players.
    // So we manually broadcast state changes.
  }

  void _broadcastState(PlaybackState stateToBroadcast) {
    playbackState.add(stateToBroadcast);
  }

  void _updateMediaItem(SceneDefinition scene) {
    mediaItem.add(MediaItem(
      id: scene.id.toString(),
      title: scene.name,
      artist: 'Breath Noise',
      artUri: null, // Avoids Invalid argument(s): No host specified in URI asset:///
    ));
  }

  /// Loads a scene and updates the media item.
  Future<void> loadScene(SceneDefinition scene, List<AudioTrack> tracks, {double masterVolume = 1.0}) async {
    _updateMediaItem(scene);
    await _mixer.loadScene(tracks, masterVolume: masterVolume);
  }

  @override
  Future<void> play() async {
    await _mixer.playAll();
    _broadcastState(playbackState.value.copyWith(
      controls: [MediaControl.pause],
      systemActions: const {MediaAction.seek},
      playing: true,
      processingState: AudioProcessingState.ready,
    ));
  }

  @override
  Future<void> pause() async {
    await _mixer.pauseAll();
    _broadcastState(playbackState.value.copyWith(
      controls: [MediaControl.play],
      playing: false,
      processingState: AudioProcessingState.ready,
    ));
  }

  @override
  Future<void> stop() async {
    await _mixer.stopAll();
    _broadcastState(playbackState.value.copyWith(
      controls: [],
      playing: false,
      processingState: AudioProcessingState.idle,
    ));
    await super.stop();
  }

  void setMasterVolume(double volume) {
    _mixer.setMasterVolume(volume);
  }

  void setTrackVolume(String trackId, double volume) {
    _mixer.setTrackVolume(trackId, volume);
  }
}
