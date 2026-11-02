import 'package:flutter/material.dart';
import 'package:kollavarsham_flutter/kollavarsham_flutter.dart';

import 'fonts.dart';

/// Seed colour of the app's Material 3 colour scheme.
const appSeedColor = Color(0xFF00796B);

/// Builds the app theme for [brightness].
ThemeData appTheme(Brightness brightness) => ThemeData(
      useMaterial3: true,
      colorSchemeSeed: appSeedColor,
      brightness: brightness,
      fontFamily: appFontFamily,
      // Noto Sans Malayalam has no Latin letters; Roboto is Android's
      // system font, and the web engine fetches a fallback by itself.
      fontFamilyFallback: const ['Roboto'],
      extensions: [
        // Deep orange, dark enough on light surfaces and light enough on
        // dark ones for 4.5:1 text contrast (WCAG AA).
        KollavarshamCalendarTheme(
          holidayColor: brightness == Brightness.light
              ? const Color(0xFFBF360C)
              : const Color(0xFFFF8A65),
        ),
      ],
    );
