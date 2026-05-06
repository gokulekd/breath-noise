import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_extension.dart';

class LightSyncScreen extends ConsumerWidget {
  const LightSyncScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          'Light Sync',
          style: TextStyle(
            color: context.primaryTextColor,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.amberGold.withAlpha(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.amberGold.withAlpha(40),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(Icons.lightbulb_outline_rounded,
                    size: 64, color: AppTheme.amberGold),
              ),
              const SizedBox(height: 32),
              Text(
                'Immersive Lighting',
                style: TextStyle(
                  color: context.primaryTextColor,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Connect your smart lights (Philips Hue, LIFX) to sync the ambient glow with the current scene for a fully immersive experience.',
                style: TextStyle(
                  color: context.mutedTextColor,
                  fontSize: 16,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.cardBgColor,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: AppTheme.amberGold.withAlpha(80)),
                    ),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Scanning for devices on network...'),
                        backgroundColor: context.isDark ? AppTheme.deepSlate : AppTheme.mutedGray,
                      ),
                    );
                  },
                  icon:
                      const Icon(Icons.wifi_rounded, color: AppTheme.amberGold),
                  label: Text(
                    'Scan for Smart Lights',
                    style: TextStyle(
                      color: context.primaryTextColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
