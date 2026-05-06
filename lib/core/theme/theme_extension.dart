import 'package:flutter/material.dart';
import 'app_theme.dart';

extension ThemeExtension on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get scaffoldBgColor => Theme.of(this).scaffoldBackgroundColor;
  Color get cardBgColor => isDark ? AppTheme.backgroundCard : AppTheme.softWhite;
  Color get primaryTextColor => isDark ? AppTheme.warmCream : AppTheme.deepSlate;
  Color get secondaryTextColor => isDark ? AppTheme.softWhite : AppTheme.deepSlate.withAlpha(200);
  Color get mutedTextColor => isDark ? AppTheme.mutedGray : AppTheme.deepSlate.withAlpha(150);
  Color get dividerColor => isDark ? Colors.white10 : Colors.black12;
  Color get iconColor => isDark ? AppTheme.softWhite : AppTheme.deepSlate;
  Color get iconSoftColor => isDark ? AppTheme.softWhite.withAlpha(160) : AppTheme.deepSlate.withAlpha(160);
  
  Color withAlpha(Color color, int darkAlpha, int lightAlpha) {
    return color.withAlpha(isDark ? darkAlpha : lightAlpha);
  }
}
