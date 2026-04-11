import 'package:flutter/material.dart';
import '../../../models/sales_parser.dart';
import '../utils/currency_formatter.dart';
import 'editable_field.dart';

class SummaryCardCustos extends StatelessWidget {
  const SummaryCardCustos({
    super.key,
    required this.summary,
    required this.currency,
    required this.onChange,
  });

  final SummaryData summary;
  final CurrencyFormatter currency;
  final void Function(String field, double value) onChange;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumo Financeiro',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _readRow('VENDA LÍQUIDA', summary.vendaLiquida, Colors.green),
            const Divider(),
            _readRow('CUSTO PEÇAS', summary.custoPecas, Colors.red),
            const Divider(),
            _editRow('antecipacao', 'ANTECIPAÇÃO', summary.antecipacao),
            const Divider(),
            _editRow('publicidade', 'PUBLICIDADE', summary.publicidade),
            const Divider(),
            _editRow('simples', 'SIMPLES', summary.simples),
            const Divider(),
            _editRow('tarifasFull', 'TARIFAS FULL', summary.tarifasFull),
            const Divider(),
            _editRow('pagina', 'PÁGINA', summary.pagina),
            const Divider(thickness: 1.5),
            _readRow(
              'TOTAL',
              summary.total,
              summary.total >= 0 ? Colors.green : Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Linha somente leitura
  Widget _readRow(String label, double value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        Text(
          currency.format(value),
          style: TextStyle(color: color),
        ),
      ],
    );
  }

  /// 🔹 Linha editável (sem recriar controller toda hora)
  Widget _editRow(String field, String label, double value) {
    return EditableField(
      label: label,
      initialValue: value,
      onSubmit: (v) => onChange(field, v),
    );
  }
}