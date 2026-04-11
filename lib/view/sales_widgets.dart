import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../controller/sales_controller.dart';
import '../models/sales_parser.dart';

class SalesDashboardPage extends StatelessWidget {
  const SalesDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<SalesController>(
        builder: (context, controller, _) {
          return Row(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _HeroPanel(controller: controller),
                          const SizedBox(height: 20),
                          _StatsRow(controller: controller),
                          const SizedBox(height: 20),
                          if (controller.sales.isEmpty)
                            _ImportPanel(controller: controller)
                          else ...[
                            _SummarySection(
                              summary: controller.summary,
                              currency: CurrencyFormatter(),
                              onChange: controller.updateManualField,
                            ),
                            const SizedBox(height: 12),
                            SalesTable(
                              sales: controller.sales,
                              currency: CurrencyFormatter(),
                              onUpdateRow: controller.updateRow,
                            ),
                          ],
                        ],
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: controller.isLoadingAny
                          ? _LoadingOverlay(
                              key: const ValueKey('loading-overlay'),
                              progress: controller.loadingProgress,
                              percent: controller.loadingPercent,
                              message: controller.loadingMessage,
                            )
                          : const SizedBox.shrink(key: ValueKey('loading-hidden')),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  const _SummarySection({required this.summary, required this.currency, required this.onChange});

  final SummaryData summary;
  final CurrencyFormatter currency;
  final void Function(String field, double value) onChange;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final sideBySide = constraints.maxWidth >= 1180;
        if (!sideBySide) {
          return Column(
            children: [
              SizedBox(height: 280, child: SummaryChart(summary: summary, currency: currency)),
              const SizedBox(height: 12),
              SummaryCard(summary: summary, currency: currency, onChange: onChange),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SummaryCard(summary: summary, currency: currency, onChange: onChange),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(height: 380, child: SummaryChart(summary: summary, currency: currency)),
            ),
          ],
        );
      },
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.icon, required this.label, this.active = false});

  final IconData icon;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFABC226) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: active ? Colors.white : Colors.white70),
        title: Text(label, style: TextStyle(color: active ? Colors.white : Colors.white70, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({required this.controller});

  final SalesController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(color: const Color(0xFF194C51), borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Gestão de Vendas', style: TextStyle(fontSize: 44, color: Colors.white, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const Text('Importe planilhas de custos e vendas para análise financeira automática.',
              style: TextStyle(color: Colors.white70, fontSize: 18)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: controller.isLoadingAny ? null : () => controller.pickCostFile(context),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF194C51), padding: const EdgeInsets.all(18)),
                  icon: const Icon(Icons.request_page_outlined),
                  label: Text(controller.costItems.isNotEmpty ? 'Planilha de custos carregada' : 'Importar custos (opcional)'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: controller.isLoadingAny ? null : () => controller.pickSalesFile(context),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFABC226), foregroundColor: Colors.white, padding: const EdgeInsets.all(18)),
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Importar vendas'),
                ),
              ),
              if (controller.sales.isNotEmpty) ...[
                const SizedBox(width: 12),
                IconButton.filled(onPressed: controller.exportExcel, icon: const Icon(Icons.download)),
                const SizedBox(width: 8),
                IconButton.filledTonal(onPressed: controller.resetAll, icon: const Icon(Icons.refresh)),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.controller});

  final SalesController controller;

  @override
  Widget build(BuildContext context) {
    final s = controller.summary;
    final currency = CurrencyFormatter();
    return Row(
      children: [
        Expanded(child: _StatCard(title: 'Vendas importadas', value: '${controller.sales.length}')),
        const SizedBox(width: 16),
        Expanded(child: _StatCard(title: 'Custos importados', value: '${controller.costItems.length}')),
        const SizedBox(width: 16),
        Expanded(child: _StatCard(title: 'Saldo', value: currency.format(s.total))),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(value, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)), Text(title)]),
      ),
    );
  }
}

class _ImportPanel extends StatelessWidget {
  const _ImportPanel({required this.controller});

  final SalesController controller;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text('Nenhuma planilha de vendas importada ainda.'), SizedBox(height: 4), Text('Use os botões do topo para iniciar.')]),
      ),
    );
  }
}

class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay({
    super.key,
    required this.progress,
    required this.percent,
    required this.message,
  });

  final double progress;
  final int percent;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          ModalBarrier(color: Colors.black.withOpacity(0.28), dismissible: false),
          Center(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: 280,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(message, style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(value: progress),
                      const SizedBox(height: 8),
                      Text('$percent% concluído'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SummaryChart extends StatelessWidget {
  const SummaryChart({super.key, required this.summary, required this.currency});

  final SummaryData summary;
  final CurrencyFormatter currency;

  @override
  Widget build(BuildContext context) {
    final values = [
      summary.vendaLiquida,
      summary.custoPecas,
      summary.antecipacao,
      summary.publicidade,
      summary.simples,
      summary.tarifasFull,
      summary.pagina,
      summary.total,
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Gráfico de Linha por Segmentação', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: LineChart(
                LineChartData(
                  minY: 0,
                  gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: _getHorizontalInterval(values)),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 56,
                        getTitlesWidget: (value, _) => Text(currency.compact(value), style: const TextStyle(fontSize: 10)),
                      ),
                    ),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        reservedSize: 34,
                        getTitlesWidget: (value, meta) {
                          if (value % 1 != 0) return const SizedBox.shrink();
                          final i = value.toInt();
                          if (i < 0 || i >= _labels.length) return const SizedBox.shrink();
                          return SideTitleWidget(
                            meta: meta,
                            child: Text(
                              _labels[i],
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (spots) => spots
                          .map(
                            (spot) => LineTooltipItem(
                              '${_labels[spot.x.toInt()]}\n${currency.format(values[spot.x.toInt()])}',
                              const TextStyle(color: Colors.white),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(
                        values.length,
                        (i) => FlSpot(i.toDouble(), values[i].abs()),
                      ),
                      isCurved: true,
                      color: Colors.indigo,
                      dotData: const FlDotData(show: true),
                      barWidth: 3,
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.indigo.withOpacity(0.12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SummaryCard extends StatelessWidget {
  const SummaryCard({super.key, required this.summary, required this.currency, required this.onChange});

  final SummaryData summary;
  final CurrencyFormatter currency;
  final void Function(String field, double value) onChange;

  @override
  Widget build(BuildContext context) {
    Widget readRow(String label, double value, Color color) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(label, style: const TextStyle(fontWeight: FontWeight.w600)), Text(currency.format(value), style: TextStyle(color: color))],
        );

    Widget editRow(String field, String label, double value) {
      final controller = TextEditingController(text: value == 0 ? '' : value.toStringAsFixed(2));
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          SizedBox(
            width: 120,
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.end,
              onSubmitted: (text) => onChange(field, double.tryParse(text.replaceAll(',', '.')) ?? 0),
              decoration: const InputDecoration(hintText: '0,00', isDense: true, border: OutlineInputBorder()),
            ),
          ),
        ],
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Resumo Financeiro', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          readRow('VENDA LÍQUIDA', summary.vendaLiquida, Colors.green),
          const Divider(),
          readRow('CUSTO PEÇAS', summary.custoPecas, Colors.red),
          const Divider(),
          editRow('antecipacao', 'ANTECIPAÇÃO', summary.antecipacao),
          const Divider(),
          editRow('publicidade', 'PUBLICIDADE', summary.publicidade),
          const Divider(),
          editRow('simples', 'SIMPLES', summary.simples),
          const Divider(),
          editRow('tarifasFull', 'TARIFAS FULL', summary.tarifasFull),
          const Divider(),
          editRow('pagina', 'PÁGINA', summary.pagina),
          const Divider(thickness: 1.5),
          readRow('TOTAL', summary.total, summary.total >= 0 ? Colors.green : Colors.red),
        ]),
      ),
    );
  }
}

class SalesTable extends StatelessWidget {
  const SalesTable({super.key, required this.sales, required this.currency, required this.onUpdateRow});

  final List<SaleRow> sales;
  final CurrencyFormatter currency;
  final void Function(int index, double? cost, String? note) onUpdateRow;

  @override
  Widget build(BuildContext context) {
    final source = _SalesDataSource(
      sales: sales,
      currency: currency,
      onUpdateRow: onUpdateRow,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: PaginatedDataTable(
            showCheckboxColumn: false,
            headingRowHeight: 44,
            dataRowMinHeight: 52,
            rowsPerPage: 25,
            availableRowsPerPage: const [10, 25, 50, 100],
            columns: const [
              DataColumn(label: Text('N.º Venda')),
              DataColumn(label: Text('Data')),
              DataColumn(label: Text('Estado')),
              DataColumn(label: Text('Unid')),
              DataColumn(label: Text('Receita')),
              DataColumn(label: Text('Tarifa')),
              DataColumn(label: Text('Frete ML')),
              DataColumn(label: Text('Custo')),
              DataColumn(label: Text('Total')),
              DataColumn(label: Text('Título')),
              DataColumn(label: Text('Observação')),
            ],
            source: source,
          ),
        ),
      ),
    );
  }
}

class _SalesDataSource extends DataTableSource {
  _SalesDataSource({
    required this.sales,
    required this.currency,
    required this.onUpdateRow,
  });

  final List<SaleRow> sales;
  final CurrencyFormatter currency;
  final void Function(int index, double? cost, String? note) onUpdateRow;

  @override
  DataRow? getRow(int index) {
    if (index < 0 || index >= sales.length) return null;
    final s = sales[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(s.numero)),
        DataCell(Text(s.data)),
        DataCell(Text(s.estado)),
        DataCell(Text(s.unidade.toString())),
        DataCell(Text(currency.format(s.receita))),
        DataCell(Text(currency.format(s.tarifaVenda))),
        DataCell(Text(currency.format(s.freteML))),
        DataCell(SizedBox(
          width: 100,
          child: TextFormField(
            initialValue: s.custo == 0 ? '' : s.custo.toStringAsFixed(2),
            onFieldSubmitted: (text) => onUpdateRow(index, double.tryParse(text.replaceAll(',', '.')) ?? 0, null),
            decoration: const InputDecoration(hintText: '0,00', isDense: true, border: OutlineInputBorder()),
          ),
        )),
        DataCell(Text(currency.format(s.totalBRL))),
        DataCell(SizedBox(width: 240, child: Text(s.titulo, maxLines: 1, overflow: TextOverflow.ellipsis))),
        DataCell(SizedBox(
          width: 140,
          child: TextFormField(
            initialValue: s.observacao,
            onFieldSubmitted: (text) => onUpdateRow(index, null, text),
            decoration: const InputDecoration(hintText: 'Obs...', isDense: true, border: OutlineInputBorder()),
          ),
        )),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => sales.length;

  @override
  int get selectedRowCount => 0;
}

const _labels = ['Venda', 'Peças', 'Antec.', 'Publi.', 'Simples', 'Tar. Full', 'Página', 'Total'];

double _getHorizontalInterval(List<double> values) {
  final maxAbs = values.map((value) => value.abs()).fold<double>(0, (max, value) => value > max ? value : max);
  if (maxAbs <= 1000) return 250;
  if (maxAbs <= 5000) return 1000;
  if (maxAbs <= 50000) return 5000;
  return maxAbs / 5;
}

class CurrencyFormatter {
  final _currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  String format(double value) => _currency.format(value);

  String compact(double value) {
    if (value == 0) return '0';
    final abs = value.abs();
    if (abs >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (abs >= 1000) return '${(value / 1000).toStringAsFixed(0)}k';
    return value.toStringAsFixed(0);
  }
}
