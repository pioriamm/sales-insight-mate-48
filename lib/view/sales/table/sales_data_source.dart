import 'package:flutter/material.dart';
import '../../../models/sales_parser.dart';
import '../utils/currency_formatter.dart';

class SalesDataSource extends DataTableSource {
  SalesDataSource({
    required this.sales,
    required this.currency,
    required this.onUpdateRow,
    required this.onAddMissingCatalogItem,
  });

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
            width: 380,
            child: Row(
              children: [
                if (s.semCadastroCusto)
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => onAddMissingCatalogItem(index, s.custo),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        color: Color(0xFF0D5C63),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                if (s.semCadastroCusto) const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    s.titulo,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
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
}
