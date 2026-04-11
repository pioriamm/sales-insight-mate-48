import 'package:flutter/material.dart';

import '../../sales_dashboard_page.dart';
import '../utils/currency_formatter.dart';

class SummaryItem extends StatelessWidget {
  const SummaryItem({
    required this.title,
    required this.value,
    required this.subtitle,
    this.rightWidget,
  });

  final String title;
  final double value;
  final String subtitle;
  final Widget? rightWidget;

  @override
  Widget build(BuildContext context) {
    final currency = CurrencyFormatter();

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 12),
                  Text(
                    currency.format(value),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
            if (rightWidget != null) rightWidget!,
          ],
        ),
      ),
    );
  }
}