import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/scene_config_service.dart';

final sceneConfigServiceProvider = Provider<SceneConfigService>((ref) {
  return SceneConfigService();
});

// A FutureProvider to load the remote config once
final remoteSceneConfigProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.watch(sceneConfigServiceProvider);
  return await service.fetchRemoteConfig();
});
