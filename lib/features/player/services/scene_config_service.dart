import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;

import '../../../core/constants/scene_data.dart';

class SceneConfigService {
  final String configUrl =
      "https://raw.githubusercontent.com/gokulekd/lumina-hearth-assets/main/scenes_config.json";

  Future<Map<String, dynamic>> fetchRemoteConfig() async {
    try {
      final response = await http.get(Uri.parse(configUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final Map<String, dynamic> result = {};
        for (var scene in data['scenes']) {
          String sceneId = scene['id'];
          List<AudioTrack> tracks = [];

          Object? emojiForScene() {
            if (sceneId == 'classic_hearth') return '🔥';
            if (sceneId == 'rain_forest') return '🌲';
            if (sceneId == 'river_side') return '🌊';
            if (sceneId == 'tibet_temple') return '🛕';
            if (sceneId == 'hut_in_rain') return '🛖';
            if (sceneId == 'himalayan_cabin') return '❄️';
            return '🎵';
          }

          for (var track in scene['tracks']) {
            tracks.add(AudioTrack(
              id: track['id'],
              name: track['name'],
              emoji: emojiForScene().toString(),
              networkUrl: track['url'],
              volume: (track['default_volume'] as num).toDouble(),
            ));
          }

          result[sceneId] = {
            'video_url': scene['video_url'],
            'tracks': tracks,
          };
        }

        return result;
      } else {
        throw Exception('Failed to load scenes');
      }
    } catch (e) {
      developer.log(
        'Error fetching remote config',
        error: e,
        name: 'SceneConfigService',
      );
      return {};
    }
  }
}
