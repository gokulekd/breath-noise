import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/scene_data.dart';
import '../../../core/theme/theme_extension.dart';
import '../../../features/player/presentation/player_screen.dart';
import '../../../features/player/providers/atmospheric_engine_provider.dart';
import '../../../widgets/scene_card.dart';

class AllScenesScreen extends ConsumerWidget {
  const AllScenesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scenes = SceneData.all;
    final engineState = ref.watch(atmosphericEngineProvider);

    return Scaffold(
      backgroundColor: context.scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: context.iconColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'All Atmospheres',
          style: TextStyle(
            color: context.primaryTextColor,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: GridView.builder(
          physics: const BouncingScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemCount: scenes.length,
          itemBuilder: (context, index) {
            final scene = scenes[index];
            final isActive =
                engineState.scene.id == scene.id && engineState.isPlaying;
            return SceneCard(
              scene: scene,
              isActive: isActive,
              onTap: () {
                ref.read(atmosphericEngineProvider.notifier).selectScene(scene);
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, a1, a2) => PlayerScreen(scene: scene),
                    transitionsBuilder: (_, anim, __, child) =>
                        FadeTransition(opacity: anim, child: child),
                    transitionDuration: const Duration(milliseconds: 500),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
