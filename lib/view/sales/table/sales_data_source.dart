import 'package:flutter/material.dart';
import '../../../models/sales_parser.dart';
import '../utils/currency_formatter.dart';

class SalesDataSource extends DataTableSource {
  SalesDataSource({
    required this.context,
    required this.sales,
    required this.currency,
    required this.onUpdateRow,
    required this.onAddMissingCatalogItem,
  });

  final BuildContext context;
  final List<SaleRow> sales;
  final CurrencyFormatter currency;
  final Future<void> Function(int, double?, String?) onUpdateRow;
  final Future<void> Function(int, double) onAddMissingCatalogItem;

  @override
  DataRow? getRow(int index) {
    if (index < 0 || index >= sales.length) return null;

    final s = sales[index];

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(s.numero)),

        DataCell(Text(s.data)),

        DataCell(Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            s.estado,
            style: const TextStyle(color: Colors.green),
          ),
        )),

        DataCell(Text(s.unidade.toString())),

        DataCell(
          SizedBox(
            width: 460,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    s.titulo,
                    maxLines: 2,
                  ),
                ),
                if (!s.foundInCatalog)
                  IconButton(
                    tooltip: 'Adicionar ao banco de custos',
                    icon: const Icon(Icons.add_circle, size: 30, color:  Color(0xFF194C51),),
                    onPressed: () => _openAddCatalogDialog(index, s),
                  ),
              ],
            ),
          ),
        ),

        DataCell(Text(currency.format(s.receita))),

        DataCell(Text(
          currency.format(s.tarifaVenda),
          style: const TextStyle(color: Colors.red),
        )),

        DataCell(Text(
          currency.format(s.freteML),
          style: const TextStyle(color: Colors.red),
        )),

        /// CUSTO EDITÁVEL
        DataCell(
          SizedBox(
            width: 100,
            child: TextFormField(
              initialValue: s.custo == 0 ? '' : s.custo.toStringAsFixed(2),
              textAlign: TextAlign.center,
              onFieldSubmitted: (text) {
                final value = double.tryParse(text.replaceAll(',', '.')) ?? 0;
                onUpdateRow(index, value, null);
              },
              decoration: const InputDecoration(
                hintText: '0,00',
                isDense: true,
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ),

        DataCell(Text(
          currency.format(s.totalBRL),
          style: const TextStyle(fontWeight: FontWeight.bold),
        )),

        /// OBSERVAÇÃO EDITÁVEL
        DataCell(
          SizedBox(
            width: 140,
            child: TextFormField(
              initialValue: s.observacao,
              onFieldSubmitted: (text) => onUpdateRow(index, null, text),
              decoration: const InputDecoration(
                hintText: 'Obs...',
                isDense: true,
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  int get rowCount => sales.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;

  Future<void> _openAddCatalogDialog(int index, SaleRow sale) async {
    final titleCtrl = TextEditingController(text: sale.titulo);
    final costCtrl = TextEditingController(
      text: sale.custo > 0 ? sale.custo.toStringAsFixed(2) : '',
    );

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Adicionar no banco de custos'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Descrição'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: costCtrl,
                decoration: const InputDecoration(labelText: 'Custo'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    if (shouldSave != true) return;
    final cost = double.tryParse(costCtrl.text.replaceAll(',', '.')) ?? 0;
    if (cost <= 0) return;
    await onAddMissingCatalogItem(index, cost);
  }
}
