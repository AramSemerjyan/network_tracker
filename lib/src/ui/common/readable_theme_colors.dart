import 'dart:math';

import 'package:flutter/material.dart';

/// Resolves background/foreground pairs that stay readable even when host apps
/// provide inconsistent surface and text colors.
class ReadableThemeColors {
  /// Picks a readable background color for tracker screens.
  static Color resolveBackground(BuildContext context) {
    final theme = Theme.of(context);
    final scaffoldBackground = theme.scaffoldBackgroundColor;
    final surface = theme.colorScheme.surface;
    final preferredForeground =
        theme.textTheme.bodyMedium?.color ?? theme.colorScheme.onSurface;

    if (_contrastRatio(scaffoldBackground, preferredForeground) >= 4.5) {
      return scaffoldBackground;
    }
    if (_contrastRatio(surface, preferredForeground) >= 4.5) {
      return surface;
    }

    return ThemeData.estimateBrightnessForColor(scaffoldBackground) ==
            Brightness.dark
        ? Colors.black
        : Colors.white;
  }

  /// Picks a readable foreground color against [background].
  static Color resolveForeground(BuildContext context, Color background) {
    final theme = Theme.of(context);
    final preferredForeground =
        theme.textTheme.bodyMedium?.color ?? theme.colorScheme.onSurface;

    if (_contrastRatio(background, preferredForeground) >= 4.5) {
      return preferredForeground;
    }

    final whiteContrast = _contrastRatio(background, Colors.white);
    final blackContrast = _contrastRatio(background, Colors.black);
    return whiteContrast >= blackContrast ? Colors.white : Colors.black;
  }

  /// Returns a softer foreground color for secondary text/icons.
  static Color resolveMutedForeground(Color foreground) {
    return foreground.withValues(alpha: 0.75);
  }

  /// Builds a theme override with readable text and control colors.
  static ThemeData screenTheme(BuildContext context) {
    final baseTheme = Theme.of(context);
    final background = resolveBackground(context);
    final foreground = resolveForeground(context, background);
    final mutedForeground = resolveMutedForeground(foreground);

    return baseTheme.copyWith(
      scaffoldBackgroundColor: background,
      textTheme: baseTheme.textTheme
          .apply(bodyColor: foreground, displayColor: foreground),
      primaryTextTheme: baseTheme.primaryTextTheme
          .apply(bodyColor: foreground, displayColor: foreground),
      iconTheme: baseTheme.iconTheme.copyWith(color: foreground),
      primaryIconTheme: baseTheme.primaryIconTheme.copyWith(color: foreground),
      listTileTheme: baseTheme.listTileTheme.copyWith(
        textColor: foreground,
        iconColor: foreground,
      ),
      dividerTheme: baseTheme.dividerTheme.copyWith(
        color: mutedForeground.withValues(alpha: 0.35),
      ),
      popupMenuTheme: baseTheme.popupMenuTheme.copyWith(
        color: background,
        textStyle: (baseTheme.popupMenuTheme.textStyle ??
                baseTheme.textTheme.bodyMedium)
            ?.copyWith(color: foreground),
      ),
      appBarTheme: baseTheme.appBarTheme.copyWith(
        backgroundColor: Colors.transparent,
        foregroundColor: foreground,
        surfaceTintColor: Colors.transparent,
        iconTheme: (baseTheme.appBarTheme.iconTheme ?? baseTheme.iconTheme)
            .copyWith(color: foreground),
        actionsIconTheme:
            (baseTheme.appBarTheme.actionsIconTheme ?? baseTheme.iconTheme)
                .copyWith(color: foreground),
        titleTextStyle: (baseTheme.appBarTheme.titleTextStyle ??
                baseTheme.textTheme.titleLarge)
            ?.copyWith(color: foreground),
      ),
      inputDecorationTheme: baseTheme.inputDecorationTheme.copyWith(
        labelStyle: (baseTheme.inputDecorationTheme.labelStyle ??
                baseTheme.textTheme.bodyMedium)
            ?.copyWith(color: mutedForeground),
        hintStyle: (baseTheme.inputDecorationTheme.hintStyle ??
                baseTheme.textTheme.bodyMedium)
            ?.copyWith(color: mutedForeground),
        prefixIconColor: mutedForeground,
        suffixIconColor: mutedForeground,
        border: _inputBorderWithColor(
          baseTheme.inputDecorationTheme.border,
          mutedForeground,
        ),
        enabledBorder: _inputBorderWithColor(
          baseTheme.inputDecorationTheme.enabledBorder,
          mutedForeground,
        ),
        focusedBorder: _inputBorderWithColor(
          baseTheme.inputDecorationTheme.focusedBorder,
          foreground,
        ),
      ),
      textSelectionTheme: baseTheme.textSelectionTheme.copyWith(
        cursorColor: foreground,
        selectionHandleColor: foreground,
      ),
    );
  }

  static InputBorder _inputBorderWithColor(InputBorder? border, Color color) {
    if (border is OutlineInputBorder) {
      return border.copyWith(
        borderSide: border.borderSide.copyWith(color: color),
      );
    }
    if (border is UnderlineInputBorder) {
      return border.copyWith(
        borderSide: border.borderSide.copyWith(color: color),
      );
    }
    return OutlineInputBorder(
      borderSide: BorderSide(color: color),
    );
  }

  static double _contrastRatio(Color a, Color b) {
    final aLuminance = a.computeLuminance();
    final bLuminance = b.computeLuminance();
    final lighter = max(aLuminance, bLuminance);
    final darker = min(aLuminance, bLuminance);
    return (lighter + 0.05) / (darker + 0.05);
  }
}
