import 'package:material_ui/material_ui.dart';

/// Marks a [ThemeData] that [qpExpressiveTheme] opted into Material 3
/// Expressive, which is how `QPTheme.of` learns about it.
@immutable
class QPExpressiveExtension extends ThemeExtension<QPExpressiveExtension> {
  /// Creates the marker.
  const QPExpressiveExtension();

  @override
  QPExpressiveExtension copyWith() => this;

  @override
  QPExpressiveExtension lerp(QPExpressiveExtension? other, double t) => this;
}

/// [theme] in the Material 3 Expressive style, for every component that
/// supports it.
ThemeData qpExpressiveTheme(ThemeData theme) => theme.copyWith(
  iconButtonTheme: IconButtonThemeData(
    style: theme.iconButtonTheme.style,
    variant: StyleVariant.material3Expressive,
  ),
  extensions: theme.extensions.values.followedBy(const <QPExpressiveExtension>[
    QPExpressiveExtension(),
  ]),
);
