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
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.warmCream,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            icon: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppTheme.emberOrange.withAlpha(20),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.logout_rounded,
                                color: AppTheme.emberOrange,
                                size: 28,
                              ),
                            ),
                            title: Text(
                              'Log Out?',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isDark ? AppTheme.warmCream : AppTheme.deepSlate,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            content: Text(
                              'Are you sure you want to log out of Breath Noise?',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isDark ? AppTheme.mutedGray : AppTheme.deepSlate.withAlpha(160),
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                            actionsAlignment: MainAxisAlignment.center,
                            actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                            actions: [
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        side: BorderSide(
                                          color: isDark ? Colors.white24 : Colors.black12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      onPressed: () => Navigator.pop(ctx, false),
                                      child: Text(
                                        'Cancel',
                                        style: TextStyle(
                                          color: isDark ? AppTheme.softWhite : AppTheme.deepSlate,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.emberOrange,
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        elevation: 0,
                                      ),
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: const Text(
                                        'Log Out',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                        if (confirmed == true) {
                          await ref.read(authServiceProvider).signOut();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'You have been logged out.',
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: AppTheme.deepSlate,
                              ),
                            );
                          }
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
