import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/scene_data.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extension.dart';
import '../../../features/home/presentation/all_scenes_screen.dart';
import '../../../features/mixer/presentation/mixer_screen.dart';
import '../../../features/player/presentation/player_screen.dart';
import '../../../features/player/providers/atmospheric_engine_provider.dart';
import '../../../features/settings/presentation/light_sync_screen.dart';
import '../../../features/timer/presentation/sleep_timer_sheet.dart';
import '../../../features/timer/providers/sleep_timer_provider.dart';
import '../../../widgets/app_drawer.dart';
import '../../../widgets/scene_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late Animation<double> _headerFadeAnim;
  late Animation<Offset> _headerSlideAnim;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _headerFadeAnim = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOut,
    );
    _headerSlideAnim =
        Tween<Offset>(begin: const Offset(0, -0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOut),
    );

    _headerController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final engineState = ref.watch(atmosphericEngineProvider);
    final timerState = ref.watch(sleepTimerProvider);
    final scenes = SceneData.all.take(4).toList();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: const AppDrawer(),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── App Bar ──────────────────────────────────────────────
          SliverAppBar(
            automaticallyImplyLeading: false,
            toolbarHeight: 80,
            expandedHeight: 0,
            floating: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            flexibleSpace: const FlexibleSpaceBar(),
            title: SlideTransition(
              position: _headerSlideAnim,
              child: FadeTransition(
                opacity: _headerFadeAnim,
                child: Builder(builder: (context) {
                  return GestureDetector(
                    onTap: () {
                      Scaffold.of(context).openDrawer();
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.emberOrange.withAlpha(40),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              AppAssets.appLogo,
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Breath Noise',
                          style: TextStyle(
                            color: context.primaryTextColor,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
            actions: [
              // Timer status indicator
              if (timerState.status == SleepTimerState.running)
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.emberOrange.withAlpha(30),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.emberOrange.withAlpha(100),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.bedtime_rounded,
                          color: AppTheme.amberGold,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDuration(timerState.remaining),
                          style: const TextStyle(
                            color: AppTheme.amberGold,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              IconButton(
                icon: Icon(
                  Icons.person_outline_rounded,
                  color: context.iconColor,
                ),
                onPressed: () => _showProfileSheet(context),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Greeting Section ──────────────────────────────
                _buildGreetingHeader(context),
                const SizedBox(height: 8),

                // ── Hero Section ──────────────────────────────────
                _buildHeroSection(context, engineState, size),

                // ── "Now Playing" Chip (if active) ───────────────
                if (engineState.isPlaying)
                  _buildNowPlayingBanner(context, engineState),

                // ── Section: Scenes ───────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 14),
                  child: Text(
                    'Atmospheres',
                    style: TextStyle(
                      color: context.primaryTextColor,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),

                // Scene Grid
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: scenes.length,
                    itemBuilder: (context, index) {
                      final scene = scenes[index];
                      final isActive = engineState.scene.id == scene.id &&
                          engineState.isPlaying;
                      return SceneCard(
                        scene: scene,
                        isActive: isActive,
                        onTap: () => _onSceneTap(context, scene),
                      );
                    },
                  ),
                ),

                // ── See All Button ───────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Center(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        backgroundColor: context.cardBgColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: AppTheme.emberOrange.withAlpha(50)),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AllScenesScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'See All',
                        style: TextStyle(
                          color: AppTheme.emberOrange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Features Section ───────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 32, 20, 14),
                  child: Text(
                    'Features',
                    style: TextStyle(
                      color: context.primaryTextColor,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                _buildFeaturesRow(context),

                const SizedBox(height: 32),

                // ── Upgrade Banner ─────────────────────────────────
                _buildUpgradeBanner(context),

                SizedBox(height: MediaQuery.of(context).padding.bottom + 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGreetingHeader(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Good Morning ✨';
    } else if (hour < 17) {
      greeting = 'Good Afternoon 🌤️';
    } else {
      greeting = 'Good Evening 🌙';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: const TextStyle(
              color: AppTheme.amberGold,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Ready to relax?',
            style: TextStyle(
              color: context.primaryTextColor,
              fontSize: 34,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(
    BuildContext context,
    SceneState engineState,
    Size size,
  ) {
    return GestureDetector(
      onTap: engineState.isPlaying
          ? () => Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, a1, a2) =>
                      PlayerScreen(scene: engineState.scene),
                  transitionsBuilder: (_, anim, __, child) =>
                      FadeTransition(opacity: anim, child: child),
                ),
              )
          : null,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        height: 240,
        decoration: BoxDecoration(
          gradient: engineState.scene.gradient,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: engineState.scene.primaryColor.withAlpha(80),
              blurRadius: 30,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Optional image
            if (engineState.scene.imageAsset != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: Opacity(
                  opacity: 0.4,
                  child: Image.asset(
                    engineState.scene.imageAsset!,
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              // Animated glow
              _AnimatedGlow(color: engineState.scene.accentColor),

            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Now playing label
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(20),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: engineState.isPlaying
                                ? AppTheme.amberGold
                                : AppTheme.mutedGray,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          engineState.isPlaying ? 'Playing Now' : 'Ready',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Space for padding now that emoji is gone
                  const SizedBox(height: 8),

                  // Name
                  Text(
                    engineState.scene.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.0,
                      shadows: [
                        Shadow(
                          color: Colors.black.withAlpha(100),
                          offset: const Offset(0, 2),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    engineState.scene.tagline,
                    style: TextStyle(
                      color: Colors.white.withAlpha(220),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      shadows: [
                        Shadow(
                          color: Colors.black.withAlpha(100),
                          offset: const Offset(0, 1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Play button overlay
            if (!engineState.isPlaying)
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withAlpha(40),
                    border: Border.all(
                      color: Colors.white.withAlpha(60),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),

            // Chevron open hint
            if (engineState.isPlaying)
              const Positioned(
                right: 20,
                bottom: 20,
                child: Icon(
                  Icons.open_in_full_rounded,
                  color: Colors.white54,
                  size: 18,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNowPlayingBanner(BuildContext context, SceneState state) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PlayerScreen(scene: state.scene)),
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: context.cardBgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.dividerColor, width: 1),
        ),
        child: Row(
          children: [
            // Animated bars
            _MiniWaveIndicator(color: state.scene.accentColor),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.scene.name,
                    style: TextStyle(
                      color: context.primaryTextColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Playing · Tap to open',
                    style: TextStyle(
                      color: context.mutedTextColor,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              state.isPlaying
                  ? Icons.pause_circle_rounded
                  : Icons.play_circle_rounded,
              color: state.scene.primaryColor,
              size: 32,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesRow(BuildContext context) {
    final features = [
      (
        '🎚️',
        'Sound Mixer',
        'Layer up to 4 sounds',
        AppTheme.emberOrange,
        () {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => const MixerScreen()));
        }
      ),
      (
        '⏰',
        'Sleep Timer',
        'Fades out gently',
        const Color(0xFF7B68EE),
        () {
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            builder: (_) => const SleepTimerSheet(),
          );
        }
      ),
      (
        '💡',
        'Light Sync',
        'LIFX / Hue Pro',
        AppTheme.amberGold,
        () {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const LightSyncScreen()));
        }
      ),
    ];

    return SizedBox(
      height: 130,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: features.length,
        itemBuilder: (context, index) {
          final f = features[index];
          return GestureDetector(
            onTap: f.$5,
            child: Container(
              width: 140,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.cardBgColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: (f.$4).withAlpha(40), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(f.$1, style: const TextStyle(fontSize: 26)),
                  const Spacer(),
                  Text(
                    f.$2,
                    style: TextStyle(
                      color: context.primaryTextColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    f.$3,
                    style: TextStyle(
                      color: context.mutedTextColor,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUpgradeBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A0A00), Color(0xFF2D1400), Color(0xFF3D1A00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.amberGold.withAlpha(60), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppTheme.amberGold.withAlpha(20),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.amberGold.withAlpha(40),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '✨ BREATH NOISE PRO',
                  style: TextStyle(
                    color: AppTheme.amberGold,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Unlock the full\nBreath Noise experience',
            style: TextStyle(
              color: AppTheme.warmCream,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '3 premium scenes · Light sync · 8K streaming · No ads',
            style: TextStyle(
              color: Colors.white.withAlpha(160),
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.emberOrange, AppTheme.amberGold],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.emberOrange.withAlpha(80),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => _showUpgradeDialog(context),
                    child: const Text(
                      'Get Pro · ₹249',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _onSceneTap(BuildContext context, SceneDefinition scene) {
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
  }

  void _showProfileSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProfileSheet(),
    );
  }

  void _showUpgradeDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 40,
              spreadRadius: 10,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 6,
              decoration: BoxDecoration(
                color: AppTheme.mutedGray.withAlpha(80),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 32),
            // Glowing Pro Icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppTheme.emberOrange, AppTheme.amberGold],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.amberGold.withAlpha(80),
                    blurRadius: 30,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Icon(
                Icons.star_rounded,
                size: 48,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Breath Noise Pro',
              style: TextStyle(
                color: AppTheme.warmCream,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Unlock the ultimate relaxation experience.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.mutedGray,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 40),
            // Features Grid
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.backgroundCard,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withAlpha(15)),
              ),
              child: Column(
                children: [
                  _proFeatureRow(
                      '🎬', 'All Atmospheres', 'Access 10+ premium scenes'),
                  const Divider(color: Colors.white10, height: 32),
                  _proFeatureRow(
                      '🎚️', 'Advanced Mixer', 'Layer unlimited custom sounds'),
                  const Divider(color: Colors.white10, height: 32),
                  _proFeatureRow(
                      '💡', 'Light Sync', 'Hue/LIFX hardware integration'),
                  const Divider(color: Colors.white10, height: 32),
                  _proFeatureRow('🚫', 'Ad-Free', 'Zero interruptions, ever'),
                ],
              ),
            ),
            const SizedBox(height: 40),
            // CTA
            SizedBox(
              width: double.infinity,
              height: 64,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.emberOrange, AppTheme.amberGold],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.emberOrange.withAlpha(100),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    'Get Pro · ₹249',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Maybe later',
                style: TextStyle(
                  color: AppTheme.mutedGray,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );
  }

  Widget _proFeatureRow(String emoji, String title, String subtitle) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(10),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 22)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.warmCream,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: AppTheme.softWhite.withAlpha(160),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

// ── Animated Widgets ─────────────────────────────────────────────────────────

class _AnimatedGlow extends StatefulWidget {
  final Color color;

  const _AnimatedGlow({required this.color});

  @override
  State<_AnimatedGlow> createState() => __AnimatedGlowState();
}

class __AnimatedGlowState extends State<_AnimatedGlow>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _anim = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) => Positioned.fill(
        child: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0.5, -0.3),
              radius: 1.5,
              colors: [
                widget.color.withAlpha((_anim.value * 50).round()),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniWaveIndicator extends StatefulWidget {
  final Color color;

  const _MiniWaveIndicator({required this.color});

  @override
  State<_MiniWaveIndicator> createState() => __MiniWaveIndicatorState();
}

class __MiniWaveIndicatorState extends State<_MiniWaveIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) => Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(4, (i) {
          final offset = (i / 4) * 3.14159;
          final h = 8.0 + (12 * (((_ctrl.value + offset / 3.14159) % 1.0)));
          return Container(
            width: 3,
            height: h.clamp(8.0, 20.0),
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
      ),
    );
  }
}

class _ProfileSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.backgroundMid,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(40),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Avatar
          Container(
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
                  color: AppTheme.emberOrange.withAlpha(80),
                  blurRadius: 20,
                ),
              ],
            ),
            child: const Center(
              child: Text('🔥', style: TextStyle(fontSize: 32)),
            ),
          ),
          const SizedBox(height: 12),

          const Text(
            'Breath Noise User',
            style: TextStyle(
              color: AppTheme.warmCream,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Free Plan',
            style: TextStyle(color: AppTheme.mutedGray, fontSize: 13),
          ),

          const SizedBox(height: 28),
          const Divider(color: AppTheme.deepSlate),
          const SizedBox(height: 8),

          ListTile(
            leading: const Icon(Icons.star_rounded, color: AppTheme.amberGold),
            title: const Text(
              'Upgrade to Pro',
              style: TextStyle(
                color: AppTheme.warmCream,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: const Text(
              '₹249 one-time · No subscription',
              style: TextStyle(color: AppTheme.mutedGray, fontSize: 12),
            ),
            trailing: const Icon(
              Icons.chevron_right,
              color: AppTheme.mutedGray,
            ),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(
              Icons.settings_outlined,
              color: AppTheme.softWhite,
            ),
            title: const Text(
              'Settings',
              style: TextStyle(
                color: AppTheme.warmCream,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: const Icon(
              Icons.chevron_right,
              color: AppTheme.mutedGray,
            ),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
