import 'package:flutter/material.dart';

/// Renders text filled with a gradient. Useful for headings.
class GradientText extends StatelessWidget {
  const GradientText(
    this.text, {
    Key? key,
    required this.gradient,
    this.style,
    this.textAlign,
  }) : super(key: key);

  final String text;
  final TextStyle? style;
  final Gradient gradient;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(
        text,
        textAlign: textAlign,
        style: (style ?? Theme.of(context).textTheme.headlineLarge)?.copyWith(
          color: Colors.white,
        ),
      ),
    );
  }
}
