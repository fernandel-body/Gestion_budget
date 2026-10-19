import 'package:flutter/material.dart';
import 'amount_text.dart';

/// Petit bloc « libellé + montant » de la carte du mois.
class IncomeFigure extends StatelessWidget {
  const IncomeFigure({super.key, required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.78),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 2),
        AmountText(value, size: 16, color: Colors.white),
      ],
    );
  }
}
