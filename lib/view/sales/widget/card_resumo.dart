import 'package:flutter/material.dart';
import 'package:sales_insight_mate/view/sales/widget/summary_cards.dart';

import '../../../models/sales_parser.dart';
import '../utils/currency_formatter.dart';

class CardResumo extends StatelessWidget {
  const CardResumo({
    required this.summary,
    required this.currency,
    required this.salesCount,
  });

  final SummaryData summary;
  final CurrencyFormatter currency;
  final int salesCount;

  @override
  Widget build(BuildContext context) {
    return SummaryCards(
      summary: summary,
      currency: currency,
      salesCount: salesCount,
    );
  }
}