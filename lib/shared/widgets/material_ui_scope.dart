import 'package:flutter/material.dart' as legacy;
import 'package:material_ui/material_ui.dart';

/// Bridges the app's `flutter/material` setup (provided by [ShadApp]) to the
/// standalone `material_ui` package used by already-migrated dependencies such
/// as `data_table_2` 3.x.
///
/// Provides a `material_ui` [Theme] mapped from the legacy theme, Spanish
/// `material_ui` [MaterialLocalizations] and a [Material] ancestor.
///
/// Temporary: remove once `shadcn_ui` migrates to `material_ui`.
class MaterialUiScope extends StatelessWidget {
  const MaterialUiScope({
    super.key,
    required this.child,
    this.showTooltips = true,
  });

  final Widget child;
  final bool showTooltips;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _fromLegacy(legacy.Theme.of(context)),
      child: Localizations.override(
        context: context,
        delegates: const [GlobalMaterialLocalizations.delegate],
        child: TooltipVisibility(
          visible: showTooltips,
          child: Material(type: MaterialType.transparency, child: child),
        ),
      ),
    );
  }

  ThemeData _fromLegacy(legacy.ThemeData theme) {
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final divider = theme.dividerTheme;
    final scrollbar = theme.scrollbarTheme;

    return ThemeData(
      useMaterial3: theme.useMaterial3,
      brightness: theme.brightness,
      platform: theme.platform,
      visualDensity: VisualDensity(
        horizontal: theme.visualDensity.horizontal,
        vertical: theme.visualDensity.vertical,
      ),
      scaffoldBackgroundColor: theme.scaffoldBackgroundColor,
      dividerColor: theme.dividerColor,
      hoverColor: theme.hoverColor,
      iconTheme: theme.iconTheme,
      colorScheme: ColorScheme(
        brightness: scheme.brightness,
        primary: scheme.primary,
        onPrimary: scheme.onPrimary,
        primaryContainer: scheme.primaryContainer,
        onPrimaryContainer: scheme.onPrimaryContainer,
        secondary: scheme.secondary,
        onSecondary: scheme.onSecondary,
        secondaryContainer: scheme.secondaryContainer,
        onSecondaryContainer: scheme.onSecondaryContainer,
        tertiary: scheme.tertiary,
        onTertiary: scheme.onTertiary,
        tertiaryContainer: scheme.tertiaryContainer,
        onTertiaryContainer: scheme.onTertiaryContainer,
        error: scheme.error,
        onError: scheme.onError,
        errorContainer: scheme.errorContainer,
        onErrorContainer: scheme.onErrorContainer,
        surface: scheme.surface,
        onSurface: scheme.onSurface,
        surfaceDim: scheme.surfaceDim,
        surfaceBright: scheme.surfaceBright,
        surfaceContainerLowest: scheme.surfaceContainerLowest,
        surfaceContainerLow: scheme.surfaceContainerLow,
        surfaceContainer: scheme.surfaceContainer,
        surfaceContainerHigh: scheme.surfaceContainerHigh,
        surfaceContainerHighest: scheme.surfaceContainerHighest,
        onSurfaceVariant: scheme.onSurfaceVariant,
        outline: scheme.outline,
        outlineVariant: scheme.outlineVariant,
        shadow: scheme.shadow,
        scrim: scheme.scrim,
        inverseSurface: scheme.inverseSurface,
        onInverseSurface: scheme.onInverseSurface,
        inversePrimary: scheme.inversePrimary,
        surfaceTint: scheme.surfaceTint,
      ),
      textTheme: TextTheme(
        displayLarge: textTheme.displayLarge,
        displayMedium: textTheme.displayMedium,
        displaySmall: textTheme.displaySmall,
        headlineLarge: textTheme.headlineLarge,
        headlineMedium: textTheme.headlineMedium,
        headlineSmall: textTheme.headlineSmall,
        titleLarge: textTheme.titleLarge,
        titleMedium: textTheme.titleMedium,
        titleSmall: textTheme.titleSmall,
        bodyLarge: textTheme.bodyLarge,
        bodyMedium: textTheme.bodyMedium,
        bodySmall: textTheme.bodySmall,
        labelLarge: textTheme.labelLarge,
        labelMedium: textTheme.labelMedium,
        labelSmall: textTheme.labelSmall,
      ),
      dividerTheme: DividerThemeData(
        color: divider.color,
        space: divider.space,
        thickness: divider.thickness,
        indent: divider.indent,
        endIndent: divider.endIndent,
        radius: divider.radius,
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbVisibility: scrollbar.thumbVisibility,
        thickness: scrollbar.thickness,
        trackVisibility: scrollbar.trackVisibility,
        radius: scrollbar.radius,
        thumbColor: scrollbar.thumbColor,
        trackColor: scrollbar.trackColor,
        trackBorderColor: scrollbar.trackBorderColor,
        crossAxisMargin: scrollbar.crossAxisMargin,
        mainAxisMargin: scrollbar.mainAxisMargin,
        minThumbLength: scrollbar.minThumbLength,
        interactive: scrollbar.interactive,
      ),
    );
  }
}
