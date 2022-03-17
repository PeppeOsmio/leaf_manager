import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:leaf_03/miscellaneous/helper.dart';

class UI {
  static const Color applicationBrandColor = Color(0xFF53B075);

  static const primaryColorDark = Color(0xFFFCFCFC);
  static const primaryColorLight = Color(0xFF212121);

  static Color primaryColor(BuildContext context) {
    return Helper.isDarkMode(context) ? primaryColorDark : primaryColorLight;
  }

  static const windowBackgroundColorDark = Color(0xFF111111);
  static const windowBackgroundColorLight = Color(0xFFF5F5F5);

  static Color windowBackgroundColor(BuildContext context) {
    return Helper.isDarkMode(context)
        ? windowBackgroundColorDark
        : windowBackgroundColorLight;
  }

  static Color buttonPrimaryColor(BuildContext context) {
    return Helper.isDarkMode(context)
        ? const Color(0xFFFCFCFC)
        : const Color(0xFF212121);
  }

  static Color buttonSecondaryColor(BuildContext context) {
    return Helper.isDarkMode(context)
        ? const Color(0xFFFCFCFC).withOpacity(0.87)
        : const Color(0xFF212121).withOpacity(0.87);
  }

  static Color textfieldBackgroundColor(BuildContext context) {
    return Helper.isDarkMode(context)
        ? Colors.white.withOpacity(0.08)
        : Colors.black.withOpacity(0.08);
  }

  static Color dividerColor(BuildContext context) {
    return Helper.isDarkMode(context)
        ? Colors.white.withOpacity(0.04)
        : Colors.black.withOpacity(0.04);
  }

  static Color textPrimaryColor(BuildContext context) {
    return Helper.isDarkMode(context)
        ? const Color(0xFFFCFCFC).withOpacity(0.87)
        : const Color(0xFF212121).withOpacity(0.87);
  }

  static Color textPrimaryColorDark(BuildContext context) {
    return Helper.isDarkMode(context)
        ? const Color(0xFF212121).withOpacity(0.87)
        : const Color(0xFFFCFCFC).withOpacity(0.87);
  }

  static Color textSecondaryColor(BuildContext context) {
    return Helper.isDarkMode(context)
        ? const Color(0xFFFCFCFC).withOpacity(0.54)
        : const Color(0xFF212121).withOpacity(0.54);
  }

  static Color cardBackgroundColor(BuildContext context) {
    return Helper.isDarkMode(context) ? Colors.black : Colors.white;
  }

  static Color toolbarActionButtonColor(BuildContext context) {
    return Helper.isDarkMode(context) ? const Color(0xFF212121) : Colors.white;
  }

  static Color checkboxTileDefaultColor(BuildContext context) {
    return textSecondaryColor(context);
  }

  static Color cropCircleBackgroundColor(BuildContext context) {
    return Helper.isDarkMode(context)
        ? Colors.white.withOpacity(0.04)
        : Colors.black.withOpacity(0.04);
  }

  static Color polygonFillColor(BuildContext context) {
    return Helper.isDarkMode(context)
        ? const Color(0xFFFFAB00).withOpacity(0.16)
        : const Color(0xFF2962FF).withOpacity(0.16);
  }

  static Color polygonStrokeColor(BuildContext context) {
    return Helper.isDarkMode(context)
        ? const Color(0xFFFFE57F)
        : const Color(0xFF82B1FF);
  }

  // Typeface constants for this app guidelines.
  static const Typeface headline0 =
      Typeface(fontSize: 32.0, fontWeight: FontWeight.w300);
  static const Typeface headline1 = Typeface(fontSize: 26.0);
  static const Typeface headline2 =
      Typeface(fontSize: 22.0, letterSpacing: -.2, fontWeight: FontWeight.w400);
  static const Typeface headline3 =
      Typeface(fontSize: 17.0, fontWeight: FontWeight.w400);
  static const Typeface headline4 =
      Typeface(fontSize: 15.0, fontWeight: FontWeight.w400);
  static const Typeface body = Typeface(fontSize: 13.0, letterSpacing: -.2);
  static const Typeface button =
      Typeface(fontSize: 14, letterSpacing: -0.15, fontWeight: FontWeight.w500);
  static const Typeface caption1 = Typeface(fontSize: 11, letterSpacing: 0.07);
  static const Typeface caption2 =
      Typeface(fontSize: 11, letterSpacing: -.2, fontWeight: FontWeight.w500);

  static TextStyle textStyle({Typeface typeface = body, Color? color}) =>
      GoogleFonts.montserrat(
          fontSize: typeface.fontSize,
          letterSpacing: typeface.letterSpacing,
          fontWeight: typeface.fontWeight,
          color: color);

  static TextStyle fontAwesomeStyle({Typeface typeface = body, Color? color}) =>
      TextStyle(
          fontWeight: typeface.fontWeight,
          fontSize: typeface.fontSize,
          letterSpacing: typeface.letterSpacing,
          color: color,
          fontFamily: "FontAwesome-Brands");
}

class Typeface {
  final double fontSize;
  final double letterSpacing;
  final FontWeight fontWeight;

  const Typeface(
      {required this.fontSize,
      this.letterSpacing = 0.0,
      this.fontWeight = FontWeight.w400});

  Typeface copyWith(
          {double? fontSize, double? letterSpacing, FontWeight? fontWeight}) =>
      Typeface(
          fontSize: fontSize ?? this.fontSize,
          letterSpacing: letterSpacing ?? this.letterSpacing,
          fontWeight: fontWeight ?? this.fontWeight);
}
