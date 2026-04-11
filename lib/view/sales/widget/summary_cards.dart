import 'package:flutter/material.dart';
import 'package:sales_insight_mate/view/sales/widget/summary_item.dart';

import '../../../models/sales_parser.dart';
import '../../sales_dashboard_page.dart';
import '../utils/currency_formatter.dart';

class SummaryCards extends StatelessWidget {
  const SummaryCards({
    required this.summary,
    required this.currency,
    required this.salesCount,
  });

  final SummaryData summary;
  final CurrencyFormatter currency;
  final int salesCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SummaryItem(
            title: 'Vendas Brutas',
            value: summary.vendaLiquida,
            subtitle: 'Valor',
            rightWidget: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$salesCount',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Vendas',
                  style: TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SummaryItem(
            title: 'Despesas Adicionais',
            value: summary.despesasAdicionais,
            subtitle: 'Valor',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SummaryItem(
            title: 'Custos das Vendas',
            value: summary.custoPecas,
            subtitle: 'Valor',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SummaryItem(
            title: 'Liquido Vendas',
            value: summary.total,
            subtitle: 'Saldo',
          ),
        ),
      ],
    );
  }
}