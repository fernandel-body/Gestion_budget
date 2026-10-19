import 'package:flutter/material.dart';
import '../core/format.dart';

/// Montant en Ariary : chiffres en gras et alignés, « Ar » plus petit.
class AmountText extends StatelessWidget {
  const AmountText(
    this.value, {
    super.key,
    this.size = 16,
    this.color,
    this.weight = FontWeight.w700,
    this.sign = '',
  });

  final num value;
  final double size;
  final Color? color;
  final FontWeight weight;
  final String sign;

  @override
  Widget build(BuildContext context) {
    final formatted = formatAr(value); // ex : 12 500 Ar
    final number = formatted.substring(0, formatted.length - 3);
    final c = color ?? Theme.of(context).colorScheme.onSurface;
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$sign$number',
            style: TextStyle(
              fontSize: size,
              fontWeight: weight,
              color: c,
              letterSpacing: size > 24 ? -size * 0.03 : 0,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          TextSpan(
            text: ' Ar',
            style: TextStyle(
              fontSize: size * 0.55,
              fontWeight: FontWeight.w500,
              color: c.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
