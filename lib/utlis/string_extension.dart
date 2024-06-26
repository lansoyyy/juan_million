import 'dart:convert';
import 'package:juan_million/utlis/app_common.dart';

extension StringExtension on String? {
  static String urlPattern =
      r'^((?:.|\n)*?)((http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)([-A-Z0-9.]+)(/[-A-Z0-9+&@#/%=~_|!:,.;]*)?(\?[A-Z0-9+&@#/%=~_|!:‌​,.;]*)?)';

  static String phonePattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';

  static String emailPattern =
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";

  /// Check email validation
  bool validateEmail() => hasMatch(this, emailPattern);

  /// Check phone validation
  bool validatePhone() => hasMatch(this, phonePattern);

  /// Check URL validation
  bool validateURL() => hasMatch(this, urlPattern);

  /// Returns true if given String is null or isEmpty
  bool get isEmptyOrNull =>
      this == null ||
      (this != null && this!.isEmpty) ||
      (this != null && this! == 'null');

  /// Capitalize given String
  String capitalizeFirstLetter() => (validate().isNotEmpty)
      ? (this!.substring(0, 1).toUpperCase() + this!.substring(1).toLowerCase())
      : validate();

  /// Capitalize First letter of words
  String ucWords() {
    return this!
        .toLowerCase()
        .split(' ')
        .map((word) => word.substring(0, 1).toUpperCase() + word.substring(1))
        .join(' ');
  }

  /// Validate PH contact number
  bool isValidPHNumber() {
    String number = this!.toValidPHNumber();
    return (number.startsWith('+639') && number.length == 13);
  }

  /// Convert to PH valid number
  String toValidPHNumber() {
    if (this!.startsWith('639')) return "+${this!}";
    if (this!.startsWith('09')) return this!.replaceFirst('09', '+639');
    return this!;
  }

  /// Address string value
  String formatRegion() {
    return this!.contains("REGION")
        ? this!.replaceAll("REGION", "Region")
        : this!;
  }

  // Check null string, return given value if null
  String validate({String value = ''}) {
    if (isEmptyOrNull) {
      return value;
    } else {
      return this!;
    }
  }

  bool isJson() {
    try {
      json.decode(validate());
    } catch (e) {
      return false;
    }
    return true;
  }

  String splitBefore(Pattern pattern) {
    ArgumentError.checkNotNull(pattern, 'pattern');
    var matchIterator = pattern.allMatches(validate()).iterator;

    Match? match;
    while (matchIterator.moveNext()) {
      match = matchIterator.current;
    }

    if (match != null) {
      return validate().substring(0, match.start);
    }
    return '';
  }

  String splitAfter(Pattern pattern) {
    ArgumentError.checkNotNull(pattern, 'pattern');
    var matchIterator = pattern.allMatches(this!).iterator;

    if (matchIterator.moveNext()) {
      var match = matchIterator.current;
      var length = match.end - match.start;
      return validate().substring(match.start + length);
    }
    return '';
  }
}
