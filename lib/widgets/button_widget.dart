import 'package:flutter/material.dart';
import 'package:juan_million/widgets/text_widget.dart';

class ButtonWidget extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final double? width;
  final double? fontSize;
  final double? height;
  final double? radius;
  final Color? color;
  final Color? textColor;

  const ButtonWidget(
      {super.key,
      this.radius = 50,
      required this.label,
      this.textColor = Colors.white,
      required this.onPressed,
      this.width = 275,
      this.fontSize = 18,
      this.height = 50,
      this.color = const Color(0xff007BFF)});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 40, right: 40),
      child: MaterialButton(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius!)),
          minWidth: width,
          height: height,
          color: color,
          onPressed: onPressed,
          child:
              TextWidget(text: label, fontSize: fontSize!, color: textColor)),
    );
  }
}
