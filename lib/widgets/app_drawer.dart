import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_assets.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/theme_provider.dart';
import '../features/auth/services/auth_service.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final userAsync = ref.watch(authStateChangesProvider);
    final user = userAsync.valueOrNull;

    final displayName = (user?.displayName?.isNotEmpty == true)
        ? user!.displayName!
        : (user?.email?.split('@').first ?? 'User');
    final email = user?.email ?? '';
    final photoUrl = user?.photoURL;

    final parts = displayName.trim().split(RegExp(r'\s+'));
    final initials = parts.length >= 2
        ? '${parts.first[0]}${parts.last[0]}'.toUpperCase()
        : displayName.substring(0, displayName.length.clamp(1, 2)).toUpperCase();

    return Drawer(
      backgroundColor: Colors.transparent, // We want to control the background
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.backgroundDark : AppTheme.warmCream,
          border: Border(
            right: BorderSide(
              color: isDark ? Colors.white.withAlpha(20) : AppTheme.deepSlate.withAlpha(20),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // App branding row
                    Row(
                      children: [
                        Image.asset(
                          AppAssets.appLogo,
                          width: 50,
                          height: 50,
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'BREATH NOISE',
                              style: TextStyle(
                                color: isDark ? AppTheme.warmCream : AppTheme.deepSlate,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 2.0,
                              ),
                            ),
                            Text(
                              'HEARTH',
                              style: TextStyle(
                                color: isDark
                                    ? AppTheme.emberOrange.withAlpha(200)
                                    : AppTheme.emberOrange,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2.0,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // User info row
                    Row(
                      children: [
                        // Avatar
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: photoUrl == null
                                ? const LinearGradient(
                                    colors: [
                                      AppTheme.emberOrange,
                                      AppTheme.amberGold,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
                          ),
                          child: photoUrl != null
                              ? ClipOval(
                                  child: Image.network(
                                    photoUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Center(
                                      child: Text(
                                        initials,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : Center(
                                  child: Text(
                                    initials,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayName,
                                style: TextStyle(
                                  color: isDark
                                      ? AppTheme.warmCream
                                      : AppTheme.deepSlate,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (email.isNotEmpty)
                                Text(
                                  email,
                                  style: const TextStyle(
                                    color: AppTheme.mutedGray,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Divider(color: isDark ? Colors.white10 : Colors.black12, height: 32),

              // Menu Items
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildDrawerItem(
                      isDark: isDark,
                      icon: Icons.home_rounded,
                      title: 'Home',
                      isActive: true,
                      onTap: () => Navigator.pop(context),
                    ),
                    _buildDrawerItem(
                      isDark: isDark,
                      icon: Icons.favorite_border_rounded,
                      title: 'Favorites',
                      onTap: () {
                        // Keep drawer open but show a coming soon snackbar
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(
                            content: const Text("Favorites - Coming Soon!"),
                            backgroundColor: isDark ? AppTheme.deepSlate : AppTheme.mutedGray,
                          ),
                        );
                      },
                    ),
                    _buildDrawerItem(
                      isDark: isDark,
                      icon: Icons.timer_outlined,
                      title: 'Sleep History',
                      showComingSoon: true,
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(
                            content: const Text("Sleep History - Coming Soon!"),
                            backgroundColor: isDark ? AppTheme.deepSlate : AppTheme.mutedGray,
                          ),
                        );
                      },
                    ),
                    _buildDrawerItem(
                      isDark: isDark,
                      icon: Icons.settings_rounded,
                      title: 'Settings',
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(
                            content: const Text("Settings - Coming Soon!"),
                            backgroundColor: isDark ? AppTheme.deepSlate : AppTheme.mutedGray,
                          ),
                        );
                      },
                    ),
                    _buildDrawerItem(
                      isDark: isDark,
                      icon: Icons.info_outline_rounded,
                      title: 'About',
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(
                            content: const Text("About"),
                            backgroundColor: isDark ? AppTheme.deepSlate : AppTheme.mutedGray,
                          ),
                        );
                      },
                    ),
                    _buildDrawerItem(
                      isDark: isDark,
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy',
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(
                            content: const Text("Privacy Policy"),
                            backgroundColor: isDark ? AppTheme.deepSlate : AppTheme.mutedGray,
                          ),
                        );
                      },
                    ),
                    _buildDrawerItem(
                      isDark: isDark,
                      icon: Icons.assignment_outlined,
                      title: 'Terms & Conditions',
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(
                            content: const Text("Terms & Conditions"),
                            backgroundColor: isDark ? AppTheme.deepSlate : AppTheme.mutedGray,
                          ),
                        );
                      },
                    ),
                    _buildThemeToggleItem(
                      isDark: isDark,
                      onToggle: (value) {
                        ref.read(themeProvider.notifier).toggleTheme(value);
                      },
                    ),
                    _buildDrawerItem(
                      isDark: isDark,
                      icon: Icons.logout_rounded,
                      title: 'Log Out',
                      onTap: () async {
                        Navigator.pop(context);
                        await ref.read(authServiceProvider).signOut();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                             SnackBar(
                              content: const Text("Logged Out"),
                              backgroundColor: isDark ? AppTheme.deepSlate : AppTheme.mutedGray,
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),

              Divider(color: isDark ? Colors.white10 : Colors.black12, height: 32),

              // Footer
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.amberGold.withAlpha(20),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.star_rounded,
                            color: AppTheme.amberGold,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Breath Noise Pro',
                            style: TextStyle(
                              color: isDark ? AppTheme.warmCream : AppTheme.deepSlate,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                     Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        color: isDark ? AppTheme.mutedGray : AppTheme.deepSlate.withAlpha(150),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required bool isDark,
    required IconData icon,
    required String title,
    bool isActive = false,
    bool showComingSoon = false,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: AppTheme.emberOrange.withAlpha(20),
        highlightColor: AppTheme.emberOrange.withAlpha(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isActive ? (isDark ? Colors.white.withAlpha(10) : Colors.black.withAlpha(10)) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive ? (isDark ? Colors.white.withAlpha(5) : Colors.black.withAlpha(5)) : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isActive
                    ? AppTheme.emberOrange
                    : (isDark ? AppTheme.softWhite.withAlpha(160) : AppTheme.deepSlate.withAlpha(160)),
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isActive
                        ? (isDark ? AppTheme.warmCream : AppTheme.deepSlate)
                        : (isDark ? AppTheme.softWhite.withAlpha(160) : AppTheme.deepSlate.withAlpha(160)),
                    fontSize: 16,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
              if (showComingSoon)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.amberGold.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.amberGold.withAlpha(80),
                      width: 1,
                    ),
                  ),
                  child: const Text(
                    'SOON',
                    style: TextStyle(
                      color: AppTheme.amberGold,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeToggleItem({
    required bool isDark,
    required ValueChanged<bool> onToggle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(
          children: [
            Icon(
              isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              color: isDark ? AppTheme.softWhite.withAlpha(160) : AppTheme.deepSlate.withAlpha(160),
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                isDark ? 'Dark Theme' : 'Light Theme',
                style: TextStyle(
                  color: isDark ? AppTheme.softWhite.withAlpha(160) : AppTheme.deepSlate.withAlpha(160),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Switch(
              value: isDark,
              onChanged: onToggle,
              activeThumbColor: AppTheme.amberGold,
              activeTrackColor: AppTheme.amberGold.withAlpha(50),
              inactiveThumbColor: isDark ? AppTheme.mutedGray : AppTheme.deepSlate.withAlpha(100),
              inactiveTrackColor: isDark ? AppTheme.deepSlate.withAlpha(50) : AppTheme.deepSlate.withAlpha(20),
            ),
          ],
        ),
      ),
    );
  }
}
