import 'package:flutter/material.dart';

/// Colours and shapes for the Kollavarsham calendar widgets.
///
/// Add it to [ThemeData.extensions] to customise the calendars; any value
/// left `null` falls back to the ambient [ColorScheme].
///
/// ```dart
/// ThemeData(extensions: const [
///   KollavarshamCalendarTheme(holidayColor: Colors.deepOrange),
/// ])
/// ```
@immutable
class KollavarshamCalendarTheme
    extends ThemeExtension<KollavarshamCalendarTheme> {
  /// Creates a calendar theme; `null` values use the defaults.
  const KollavarshamCalendarTheme({
    this.holidayColor,
    this.todayBorderColor,
    this.selectedColor,
    this.onSelectedColor,
    this.secondaryTextColor,
    this.disabledColor,
    this.markerColor,
    this.monthChangeColor,
    this.cellBorderRadius,
  });

  /// Text colour for Sundays. Default: [ColorScheme.error].
  final Color? holidayColor;

  /// Border drawn around today's cell. Default: [ColorScheme.primary].
  final Color? todayBorderColor;

  /// Fill of the selected cell. Default: [ColorScheme.primary].
  final Color? selectedColor;

  /// Text colour on the selected cell. Default: [ColorScheme.onPrimary].
  final Color? onSelectedColor;

  /// Colour of the secondary date and nakshatra in each cell. Default:
  /// [ColorScheme.onSurfaceVariant].
  final Color? secondaryTextColor;

  /// Text colour of days outside the selectable range. Default:
  /// [ColorScheme.onSurface] at 38% opacity.
  final Color? disabledColor;

  /// Colour of event marker dots. Default: [ColorScheme.tertiary].
  final Color? markerColor;

  /// Colour of the label shown where the other calendar's month changes
  /// (e.g. "തുലാം 1"). Default: [ColorScheme.primary].
  final Color? monthChangeColor;

  /// Corner radius of day cells. Default: 8.
  final BorderRadius? cellBorderRadius;

  /// The theme in [context], with every value resolved.
  static ResolvedKollavarshamCalendarTheme of(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final ext = theme.extension<KollavarshamCalendarTheme>() ??
        const KollavarshamCalendarTheme();
    return ResolvedKollavarshamCalendarTheme(
      holidayColor: ext.holidayColor ?? scheme.error,
      todayBorderColor: ext.todayBorderColor ?? scheme.primary,
      selectedColor: ext.selectedColor ?? scheme.primary,
      onSelectedColor: ext.onSelectedColor ?? scheme.onPrimary,
      secondaryTextColor: ext.secondaryTextColor ?? scheme.onSurfaceVariant,
      disabledColor:
          ext.disabledColor ?? scheme.onSurface.withValues(alpha: 0.38),
      markerColor: ext.markerColor ?? scheme.tertiary,
      monthChangeColor: ext.monthChangeColor ?? scheme.primary,
      cellBorderRadius: ext.cellBorderRadius ?? BorderRadius.circular(8),
    );
  }

  @override
  KollavarshamCalendarTheme copyWith({
    Color? holidayColor,
    Color? todayBorderColor,
    Color? selectedColor,
    Color? onSelectedColor,
    Color? secondaryTextColor,
    Color? disabledColor,
    Color? markerColor,
    Color? monthChangeColor,
    BorderRadius? cellBorderRadius,
  }) =>
      KollavarshamCalendarTheme(
        holidayColor: holidayColor ?? this.holidayColor,
        todayBorderColor: todayBorderColor ?? this.todayBorderColor,
        selectedColor: selectedColor ?? this.selectedColor,
        onSelectedColor: onSelectedColor ?? this.onSelectedColor,
        secondaryTextColor: secondaryTextColor ?? this.secondaryTextColor,
        disabledColor: disabledColor ?? this.disabledColor,
        markerColor: markerColor ?? this.markerColor,
        monthChangeColor: monthChangeColor ?? this.monthChangeColor,
        cellBorderRadius: cellBorderRadius ?? this.cellBorderRadius,
      );

  @override
  KollavarshamCalendarTheme lerp(
      covariant KollavarshamCalendarTheme? other, double t) {
    if (other == null) return this;
    return KollavarshamCalendarTheme(
      holidayColor: Color.lerp(holidayColor, other.holidayColor, t),
      todayBorderColor: Color.lerp(todayBorderColor, other.todayBorderColor, t),
      selectedColor: Color.lerp(selectedColor, other.selectedColor, t),
      onSelectedColor: Color.lerp(onSelectedColor, other.onSelectedColor, t),
      secondaryTextColor:
          Color.lerp(secondaryTextColor, other.secondaryTextColor, t),
      disabledColor: Color.lerp(disabledColor, other.disabledColor, t),
      markerColor: Color.lerp(markerColor, other.markerColor, t),
      monthChangeColor: Color.lerp(monthChangeColor, other.monthChangeColor, t),
      cellBorderRadius:
          BorderRadius.lerp(cellBorderRadius, other.cellBorderRadius, t),
    );
  }
}

/// A [KollavarshamCalendarTheme] with every value filled in.
@immutable
class ResolvedKollavarshamCalendarTheme {
  /// Creates a fully resolved theme.
  const ResolvedKollavarshamCalendarTheme({
    required this.holidayColor,
    required this.todayBorderColor,
    required this.selectedColor,
    required this.onSelectedColor,
    required this.secondaryTextColor,
    required this.disabledColor,
    required this.markerColor,
    required this.monthChangeColor,
    required this.cellBorderRadius,
  });

  /// See [KollavarshamCalendarTheme.holidayColor].
  final Color holidayColor;

  /// See [KollavarshamCalendarTheme.todayBorderColor].
  final Color todayBorderColor;

  /// See [KollavarshamCalendarTheme.selectedColor].
  final Color selectedColor;

  /// See [KollavarshamCalendarTheme.onSelectedColor].
  final Color onSelectedColor;

  /// See [KollavarshamCalendarTheme.secondaryTextColor].
  final Color secondaryTextColor;

  /// See [KollavarshamCalendarTheme.disabledColor].
  final Color disabledColor;

  /// See [KollavarshamCalendarTheme.markerColor].
  final Color markerColor;

  /// See [KollavarshamCalendarTheme.monthChangeColor].
  final Color monthChangeColor;

  /// See [KollavarshamCalendarTheme.cellBorderRadius].
  final BorderRadius cellBorderRadius;
}
