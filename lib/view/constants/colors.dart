import 'package:flutter/material.dart';

MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  final swatch = <int, Color>{};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  for (var strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }
  return MaterialColor(color.value, swatch);
}

const softPinkColor = Color(0xffFF4B4B);
const primaryColor = Color(0xff2B70C9);
const softerPrimaryColor = Color(0xff4e8bd9);
const darkerPrimaryColor = Color(0xff76bc8f);
const primaryTriadicColor1 = Color(0xff9f84d1);
const primaryTriadicColor2 = Color(0xffd19f84);
const complementaryColor = Color(0xffd184b6);
const eelColor = Color(0xff4b4b4b);

const rallyGreen = Color(0xff1eb980);
const rallyDarkGreen = Color(0xff045D56);
const rallyOrange = Color(0xffff6859);
const rallyYellow = Color(0xffffcf44);
const rallyPurple = Color(0xffb15dff);
const rallyBlue = Color(0xff72deff);
const lightBlue = Color(0x55add8e6);
const lightGray6 = Color(0xffededed);
const darkBlue = Color(0xff2c2c4c);

const secondaryTextColor = Colors.black54;

/// Most color assignments in Rally are not like the the typical color
/// assignments that are common in other apps. Instead of primarily mapping to
/// component type and part, they are assigned round robin based on layout.
class RallyColors {
  static const List<Color> accountColors = <Color>[
    Color(0xFF005D57),
    Color(0xFF04B97F),
    Color(0xFF37EFBA),
    Color(0xFF007D51),
  ];

  static const List<Color> billColors = <Color>[
    Color(0xFFFFDC78),
    Color(0xFFFF6951),
    Color(0xFFFFD7D0),
    Color(0xFFFFAC12),
  ];

  static const List<Color> budgetColors = <Color>[
    Color(0xFFB2F2FF),
    Color(0xFFB15DFF),
    Color(0xFF72DEFF),
    Color(0xFF0082FB),
  ];

  static const List<Color> budgetLightColors = <Color>[
    Color(0xFF64B5F6), // Light Blue
    Color(0xFF7986CB), // Indigo
    Color(0xFF4DB6AC), // Teal
    Color(0xFFEF9A9A), // Red
  ];

  static const Color gray = Color(0xFFD8D8D8);
  static const Color gray60 = Color(0x99D8D8D8);
  static const Color gray25 = Color(0x40D8D8D8);
  static const Color white60 = Color(0x99FFFFFF);
  static const Color primaryBackground = Color(0xFF33333D);
  static const Color inputBackground = Color(0xFF26282F);
  static const Color cardBackground = Color(0x03FEFEFE);
  static const Color buttonColor = Color(0xFF09AF79);
  static const Color focusColor = Color(0xCCFFFFFF);

  /// Convenience method to get a single account color with position i.
  static Color accountColor(int i) {
    return cycledColor(accountColors, i);
  }

  /// Convenience method to get a single bill color with position i.
  static Color billColor(int i) {
    return cycledColor(billColors, i);
  }

  /// Convenience method to get a single budget color with position i.
  static Color budgetColor(int i, {required bool isDarkTheme}) {
    if (isDarkTheme) {
    return cycledColor(budgetColors, i);
    }
    return cycledColor(budgetLightColors, i);
  }


  /// Gets a color from a list that is considered to be infinitely repeating.
  static Color cycledColor(List<Color> colors, int i) {
    return colors[i % colors.length];
  }
}
