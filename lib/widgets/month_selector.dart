import 'package:flutter/material.dart';
import '../core/format.dart';

class MonthSelector extends StatelessWidget {
  const MonthSelector(
      {super.key, required this.month, required this.onChanged});

  final DateTime month;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final isCurrent = !month.isBefore(firstOfMonth(DateTime.now()));
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => onChanged(addMonths(month, -1)),
        ),
        SizedBox(
          width: 170,
          child: Text(
            monthLabel(month),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: isCurrent ? null : () => onChanged(addMonths(month, 1)),
        ),
      ],
    );
  }
}
