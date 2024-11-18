import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final double fontSize;
  final double? width;
  final double? height;
  final Color? color;

  // ignore: use_super_parameters
  const CustomButton({
    Key? key,
    required this.onPressed,
    required this.text,
    required this.fontSize,
    this.width,
    this.height,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(
          color ?? const Color.fromARGB(255, 9, 35, 113),
        ),
        minimumSize: MaterialStateProperty.all(
          Size(
            width ?? MediaQuery.of(context).size.width / 1.6,
            height ?? 50.0,
          ),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          double adaptiveFontSize = fontSize;

          adaptiveFontSize = adaptiveFontSize < 12 ? 12 : adaptiveFontSize;
          adaptiveFontSize = adaptiveFontSize > constraints.maxHeight * 0.4
              ? constraints.maxHeight * 0.4
              : adaptiveFontSize;

          return Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: adaptiveFontSize,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          );
        },
      ),
    );
  }
}
