import 'package:flutter/material.dart';
import 'package:sales_insight_mate/view/sales/table/sales_data_source.dart';

import '../../../models/sales_parser.dart';
import '../utils/currency_formatter.dart';

class SalesTable extends StatelessWidget {
  const SalesTable({
    super.key,
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
  Widget build(BuildContext context) {
    final source = SalesDataSource(
      context: context,
      sales: sales,
      currency: currency,
      onUpdateRow: onUpdateRow,
      onAddMissingCatalogItem: onAddMissingCatalogItem,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              width: constraints.maxWidth,
              child: PaginatedDataTable(
                showCheckboxColumn: false,
                headingRowHeight: 48,
                dataRowMinHeight: 60,
                dataRowMaxHeight: 92,
                rowsPerPage: 10,
                availableRowsPerPage: const [10, 25, 50, 100],
                columns: const [
                  DataColumn(label: Text('N.º Venda')),
                  DataColumn(label: Text('Data')),
                  DataColumn(label: Text('Estado')),
                  DataColumn(label: Text('Unid')),
                  DataColumn(label: Text('Título')),
                  DataColumn(label: Text('Receita')),
                  DataColumn(label: Text('Tarifa')),
                  DataColumn(label: Text('Frete ML')),
                  DataColumn(label: Text('Custo')),
                  DataColumn(label: Text('Total')),
                  DataColumn(label: Text('Observação')),
                ],
                source: source,
              ),
            );
          },
        ),
      ),
    );
  }
}
