import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../main.dart';

TextStyle headerTextStyle(
    {int? size,
    Color? color,
    FontWeight? weight,
    TextDecoration? textDecoration,
    double? letterSpacing,
    String? fontFamily}) {
  return TextStyle(
      fontWeight: weight ?? FontWeight.bold,
      decoration: textDecoration ?? TextDecoration.none,
      letterSpacing: letterSpacing ?? 0);
}

TextStyle boldTextStyle(
    {int? size,
    Color? color,
    FontWeight? weight,
    TextDecoration? textDecoration,
    double? letterSpacing,
    String? fontFamily}) {
  return TextStyle(
      fontWeight: weight ?? FontWeight.bold,
      decoration: textDecoration ?? TextDecoration.none,
      letterSpacing: letterSpacing ?? 0);
}

// Primary Text Style
TextStyle primaryTextStyle({int? size, Color? color, FontWeight? weight}) {
  return TextStyle(
    fontWeight: weight ?? FontWeight.normal,
    fontFamily: 'Archivo',
  );
}

// Secondary Text Style
TextStyle secondaryTextStyle({
  int? size,
  Color? color,
  FontWeight? weight,
  String? fontFamily,
  TextDecoration? textDecoration,
}) {
  return TextStyle(
    decoration: textDecoration ?? TextDecoration.none,
    fontWeight: weight ?? FontWeight.normal,
  );
}

void log(Object? value) {
  if (!kReleaseMode) print(value);
}

bool hasMatch(String? s, String p) {
  return (s == null) ? false : RegExp(p).hasMatch(s);
}

Color getColorFromHex(String hexColor, {Color? defaultColor}) {
  if (hexColor.isEmpty) {
    if (defaultColor != null) {
      return defaultColor;
    } else {
      throw ArgumentError('Can not parse provided hex $hexColor');
    }
  }

  hexColor = hexColor.toUpperCase().replaceAll("#", "");
  if (hexColor.length == 6) {
    hexColor = "FF$hexColor";
  }
  return Color(int.parse(hexColor, radix: 16));
}

void toast(String? value,
    {ToastGravity? gravity,
    length = Toast.LENGTH_SHORT,
    Color? bgColor,
    Color? textColor,
    bool print = false}) {
  if (value!.isEmpty || (!kIsWeb && Platform.isLinux)) {
    log(value);
  } else {
    Fluttertoast.showToast(
      msg: value,
      gravity: gravity,
      toastLength: length,
      backgroundColor: bgColor,
      textColor: textColor,
      timeInSecForIosWeb: 2,
    );
    if (print) log(value);
  }
}

/// Launch a new screen
Future<T?> launchScreen<T>(BuildContext context, Widget child,
    {bool isNewTask = false,
    PageRouteAnimation? pageRouteAnimation,
    Duration? duration}) async {
  if (isNewTask) {
    return await Navigator.of(context).pushAndRemoveUntil(
      buildPageRoute(child, pageRouteAnimation, duration),
      (route) => false,
    );
  } else {
    return await Navigator.of(context).push(
      buildPageRoute(child, pageRouteAnimation, duration),
    );
  }
}

enum PageRouteAnimation { Fade, Scale, Rotate, Slide, SlideBottomTop }

Route<T> buildPageRoute<T>(
    Widget? child, PageRouteAnimation? pageRouteAnimation, Duration? duration) {
  if (pageRouteAnimation != null) {
    if (pageRouteAnimation == PageRouteAnimation.Fade) {
      return PageRouteBuilder(
        pageBuilder: (c, a1, a2) => child!,
        transitionsBuilder: (c, anim, a2, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 1000),
      );
    } else if (pageRouteAnimation == PageRouteAnimation.Rotate) {
      return PageRouteBuilder(
        pageBuilder: (c, a1, a2) => child!,
        transitionsBuilder: (c, anim, a2, child) =>
            RotationTransition(turns: ReverseAnimation(anim), child: child),
        transitionDuration: const Duration(milliseconds: 700),
      );
    } else if (pageRouteAnimation == PageRouteAnimation.Scale) {
      return PageRouteBuilder(
        pageBuilder: (c, a1, a2) => child!,
        transitionsBuilder: (c, anim, a2, child) =>
            ScaleTransition(scale: anim, child: child),
        transitionDuration: const Duration(milliseconds: 700),
      );
    } else if (pageRouteAnimation == PageRouteAnimation.Slide) {
      return PageRouteBuilder(
        pageBuilder: (c, a1, a2) => child!,
        transitionsBuilder: (c, anim, a2, child) => SlideTransition(
          position:
              Tween(begin: const Offset(1.0, 0.0), end: const Offset(0.0, 0.0))
                  .animate(anim),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 500),
      );
    } else if (pageRouteAnimation == PageRouteAnimation.SlideBottomTop) {
      return PageRouteBuilder(
        pageBuilder: (c, a1, a2) => child!,
        transitionsBuilder: (c, anim, a2, child) => SlideTransition(
          position:
              Tween(begin: const Offset(0.0, 1.0), end: const Offset(0.0, 0.0))
                  .animate(anim),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 500),
      );
    }
  }
  return MaterialPageRoute<T>(builder: (_) => child!);
}

/// Returns MaterialColor from Color
MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  Map<int, Color> swatch = <int, Color>{};
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

ShapeBorder dialogShape([double? borderRadius]) {
  return RoundedRectangleBorder(
    borderRadius: radius(borderRadius),
  );
}

/// returns Radius
BorderRadius radius([double? radius]) {
  return BorderRadius.all(radiusCircular(radius));
}

/// returns Radius
Radius radiusCircular([double? radius]) {
  return Radius.circular(radius!);
}

class DefaultValues {
  final String defaultLanguage = "en";
}

DefaultValues defaultValues = DefaultValues();
