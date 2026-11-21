import 'package:flutter/physics.dart' show SpringDescription, SpringSimulation;
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
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: theme.elevatedButtonTheme.style,
    variant: StyleVariant.material3Expressive,
  ),
  extensions: theme.extensions.values.followedBy(const <QPExpressiveExtension>[
    QPExpressiveExtension(),
  ]),
);

/// A spring as a [Curve] over [duration], for implicit animations.
///
/// It traces the spring from rest, so an interrupted animation starts over at
/// zero velocity instead of keeping its momentum.
class QPSpringCurve extends Curve {
  /// Creates the curve of [spring].
  QPSpringCurve(SpringDescription spring)
    : this._(SpringSimulation(spring, 0, 1, 0));

  QPSpringCurve._(SpringSimulation simulation)
    : _simulation = simulation,
      duration = _settlingTime(simulation);

  final SpringSimulation _simulation;

  /// How long the spring takes to come to rest.
  final Duration duration;

  static Duration _settlingTime(SpringSimulation simulation) {
    int milliseconds = 0;
    while (!simulation.isDone(milliseconds / Duration.millisecondsPerSecond)) {
      milliseconds++;
    }
    return Duration(milliseconds: milliseconds);
  }

  @override
  double transformInternal(double t) => _simulation.x(
    t * duration.inMilliseconds / Duration.millisecondsPerSecond,
  );
}

/// The spring of a small component changing its selection.
final QPSpringCurve qpSelectionSpring = QPSpringCurve(
  Springs.standardFastSpatial,
);
