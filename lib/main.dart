import 'dart:math';
import 'dart:typed_data';

import 'package:excel/excel.dart' as ex;
import 'package:file_picker/file_picker.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const SalesInsightApp());
}

class SalesInsightApp extends StatelessWidget {
  const SalesInsightApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestão de Vendas',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const SalesHomePage(),
    );
  }
}

class SalesHomePage extends StatefulWidget {
  const SalesHomePage({super.key});

  @override
  State<SalesHomePage> createState() => _SalesHomePageState();
}

class _SalesHomePageState extends State<SalesHomePage> {
  final CurrencyFormatter _currency = CurrencyFormatter();

  List<SaleRow> sales = [];
  List<CostItem> costItems = [];

  final Map<String, double> manualFields = {
    'antecipacao': 0,
    'publicidade': 0,
    'simples': 0,
    'tarifasFull': 0,
    'pagina': 0,
  };

  bool isLoading = false;

  Future<void> _pickCostFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
      withData: true,
    );

    final bytes = result?.files.single.bytes;
    if (bytes == null) return;

    setState(() {
      costItems = parseCostFile(bytes);
    });
  }

  Future<void> _pickSalesFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
      withData: true,
    );

    final bytes = result?.files.single.bytes;
    if (bytes == null) return;

    setState(() => isLoading = true);

    final parsed = parseSalesFile(bytes);
    final withCosts = parsed
        .map((row) => row.copyWith(custo: findCostForTitle(row.titulo, costItems)))
        .toList();

    withCosts.sort((a, b) {
      if (a.custo == 0 && b.custo > 0) return -1;
      if (b.custo == 0 && a.custo > 0) return 1;
      return 0;
    });

    setState(() {
      sales = withCosts;
      isLoading = false;
    });
  }

  SummaryData get summary {
    final vendaLiquida = sales.fold<double>(0, (sum, s) => sum + s.totalBRL);
    final custoPecas = sales.fold<double>(0, (sum, s) => sum + s.custo);
    final total = vendaLiquida -
        custoPecas -
        manualFields.values.fold<double>(0, (sum, value) => sum + value);

    return SummaryData(
      vendaLiquida: vendaLiquida,
      custoPecas: custoPecas,
      antecipacao: manualFields['antecipacao'] ?? 0,
      publicidade: manualFields['publicidade'] ?? 0,
      simples: manualFields['simples'] ?? 0,
      tarifasFull: manualFields['tarifasFull'] ?? 0,
      pagina: manualFields['pagina'] ?? 0,
      total: total,
    );
  }

  void _resetAll() {
    setState(() {
      sales = [];
      costItems = [];
      for (final k in manualFields.keys) {
        manualFields[k] = 0;
      }
    });
  }

  Future<void> _exportExcel() async {
    final bytes = buildExportFile(sales, summary);
    await FilePicker.platform.saveFile(
      dialogTitle: 'Salvar planilha',
      fileName: '${DateFormat('MM-yyyy').format(DateTime.now())}-Contabilidade.xlsx',
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      bytes: bytes,
    );
  }

  @override
  Widget build(BuildContext context) {
    final sum = summary;

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Gestão de Vendas'),
            Text('Importe sua planilha e analise seus resultados', style: TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          if (sales.isNotEmpty) ...[
            TextButton.icon(onPressed: _resetAll, icon: const Icon(Icons.refresh), label: const Text('Nova Planilha')),
            FilledButton.icon(onPressed: _exportExcel, icon: const Icon(Icons.download), label: const Text('Exportar Excel')),
            const SizedBox(width: 8),
          ],
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: sales.isEmpty
            ? Column(
                children: [
                  Card(
                    child: ListTile(
                      leading: Icon(costItems.isNotEmpty ? Icons.check_circle : Icons.request_page,
                          color: costItems.isNotEmpty ? Colors.green : Colors.grey),
                      title: Text(costItems.isNotEmpty
                          ? '✓ Planilha de custos carregada'
                          : '1. Importe a planilha de custos (opcional)'),
                      subtitle: const Text('Usada para preencher custo automaticamente.'),
                      trailing: ElevatedButton(
                        onPressed: _pickCostFile,
                        child: const Text('Selecionar'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.upload_file, color: Colors.indigo),
                      title: Text(isLoading ? 'Processando...' : '2. Importe a planilha de vendas'),
                      subtitle: const Text('Arquivo .xlsx ou .xls'),
                      trailing: FilledButton(
                        onPressed: isLoading ? null : _pickSalesFile,
                        child: const Text('Selecionar'),
                      ),
                    ),
                  ),
                ],
              )
            : ListView(
                children: [
                  SizedBox(height: 280, child: SummaryChart(summary: sum, currency: _currency)),
                  const SizedBox(height: 12),
                  SummaryCard(
                    summary: sum,
                    currency: _currency,
                    onChange: (key, value) {
                      setState(() {
                        manualFields[key] = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  SalesTable(
                    sales: sales,
                    currency: _currency,
                    onUpdateRow: (index, cost, note) {
                      setState(() {
                        sales[index] = sales[index].copyWith(
                          custo: cost ?? sales[index].custo,
                          observacao: note ?? sales[index].observacao,
                        );
                      });
                    },
                  ),
                ],
              ),
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
            const Text('Gráfico Financeiro', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: BarChart(
                BarChartData(
                  gridData: const FlGridData(show: false),
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
                    bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  barGroups: List.generate(values.length, (i) {
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: values[i].abs(),
                          color: i == values.length - 1 ? Colors.indigo : Colors.indigo.shade200,
                          width: 16,
                        ),
                      ],
                    );
                  }),
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
  const SummaryCard({
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
          ],
        ),
      ),
    );
  }
}

class SalesTable extends StatelessWidget {
  const SalesTable({
    super.key,
    required this.sales,
    required this.currency,
    required this.onUpdateRow,
  });

  final List<SaleRow> sales;
  final CurrencyFormatter currency;
  final void Function(int index, double? cost, String? note) onUpdateRow;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
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
            rows: List.generate(sales.length, (index) {
              final s = sales[index];
              return DataRow(cells: [
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
                DataCell(SizedBox(width: 240, child: Text(s.titulo, overflow: TextOverflow.ellipsis))),
                DataCell(SizedBox(
                  width: 140,
                  child: TextFormField(
                    initialValue: s.observacao,
                    onFieldSubmitted: (text) => onUpdateRow(index, null, text),
                    decoration: const InputDecoration(hintText: 'Obs...', isDense: true, border: OutlineInputBorder()),
                  ),
                )),
              ]);
            }),
          ),
        ),
      ),
    );
  }
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

class SaleRow {
  SaleRow({
    required this.id,
    required this.numero,
    required this.data,
    required this.estado,
    required this.unidade,
    required this.receita,
    required this.tarifaVenda,
    required this.freteML,
    required this.totalBRL,
    required this.titulo,
    this.custo = 0,
    this.observacao = '',
  });

  final String id;
  final String numero;
  final String data;
  final int unidade;
  final String estado;
  final double receita;
  final double tarifaVenda;
  final double freteML;
  final double totalBRL;
  final String titulo;
  final double custo;
  final String observacao;

  SaleRow copyWith({double? custo, String? observacao}) => SaleRow(
        id: id,
        numero: numero,
        data: data,
        estado: estado,
        unidade: unidade,
        receita: receita,
        tarifaVenda: tarifaVenda,
        freteML: freteML,
        totalBRL: totalBRL,
        titulo: titulo,
        custo: custo ?? this.custo,
        observacao: observacao ?? this.observacao,
      );
}

class SummaryData {
  SummaryData({
    required this.vendaLiquida,
    required this.custoPecas,
    required this.antecipacao,
    required this.publicidade,
    required this.simples,
    required this.tarifasFull,
    required this.pagina,
    required this.total,
  });

  final double vendaLiquida;
  final double custoPecas;
  final double antecipacao;
  final double publicidade;
  final double simples;
  final double tarifasFull;
  final double pagina;
  final double total;
}

class CostItem {
  CostItem({required this.sku, required this.descricao, required this.custo});

  final String sku;
  final String descricao;
  final double custo;
}

List<SaleRow> parseSalesFile(Uint8List bytes) {
  final excel = ex.Excel.decodeBytes(bytes);
  final sheet = excel.tables.values.first;
  final rows = sheet?.rows ?? [];
  if (rows.isEmpty) return [];

  final header = rows.first.map((e) => (e?.value ?? '').toString()).toList();

  int idx(String key, [String? alt1, String? alt2]) {
    final normalized = header.map(_normalize).toList();
    final candidates = [key, if (alt1 != null) alt1, if (alt2 != null) alt2].map(_normalize).toList();
    final found = normalized.indexWhere((h) => candidates.any((c) => h == c));
    return found;
  }

  final iNumero = idx('N.º de venda', 'Nº de venda', 'N° de venda');
  final iData = idx('Data da venda');
  final iEstado = idx('Estado');
  final iUnid = idx('Unid', 'Unidade');
  final iReceita = idx('Receita');
  final iTarifa = idx('Tarifa de venda');
  final iFrete = idx('Frete ML');
  final iTotal = idx('Total (BRL)');
  final iTitulo = idx('Título do anúncio', 'Titulo do anúncio');

  String valueAt(List<ex.Data?> row, int i) => i >= 0 && i < row.length ? (row[i]?.value ?? '').toString() : '';

  final sales = <SaleRow>[];
  for (var i = 1; i < rows.length; i++) {
    final row = rows[i];
    if (row.every((c) => c == null || c.value == null || c.value.toString().trim().isEmpty)) continue;

    sales.add(SaleRow(
      id: '$i',
      numero: valueAt(row, iNumero),
      data: _formatDate(valueAt(row, iData)),
      estado: valueAt(row, iEstado),
      unidade: _parseNumber(valueAt(row, iUnid)).round(),
      receita: _parseNumber(valueAt(row, iReceita)),
      tarifaVenda: _parseNumber(valueAt(row, iTarifa)),
      freteML: _parseNumber(valueAt(row, iFrete)),
      totalBRL: _parseNumber(valueAt(row, iTotal)),
      titulo: valueAt(row, iTitulo),
    ));
  }

  return sales;
}

List<CostItem> parseCostFile(Uint8List bytes) {
  final excel = ex.Excel.decodeBytes(bytes);
  final sheet = excel.tables.values.first;
  final rows = sheet?.rows ?? [];
  if (rows.isEmpty) return [];

  final header = rows.first.map((e) => (e?.value ?? '').toString()).toList();
  int pick(List<String> options) {
    final normalized = header.map(_normalize).toList();
    for (final o in options) {
      final i = normalized.indexWhere((h) => h.contains(_normalize(o)));
      if (i >= 0) return i;
    }
    return -1;
  }

  final iSku = pick(['sku']);
  final iDesc = pick(['descricao', 'descrição']);
  final iCost = pick(['custo']);

  String valueAt(List<ex.Data?> row, int i) => i >= 0 && i < row.length ? (row[i]?.value ?? '').toString() : '';

  final items = <CostItem>[];
  for (var i = 1; i < rows.length; i++) {
    final row = rows[i];
    if (row.every((c) => c == null || c.value == null || c.value.toString().trim().isEmpty)) continue;
    items.add(CostItem(
      sku: valueAt(row, iSku),
      descricao: valueAt(row, iDesc),
      custo: _parseNumber(valueAt(row, iCost)),
    ));
  }

  return items;
}

Uint8List buildExportFile(List<SaleRow> sales, SummaryData summary) {
  final excel = ex.Excel.createExcel();
  final defaultSheet = excel.getDefaultSheet();
  if (defaultSheet != null) {
    excel.delete(defaultSheet);
  }

  final detail = excel['Vendas'];
  detail.appendRow([
    ex.TextCellValue('N.º de venda'),
    ex.TextCellValue('Data da venda'),
    ex.TextCellValue('Estado'),
    ex.TextCellValue('Unid'),
    ex.TextCellValue('Receita'),
    ex.TextCellValue('Tarifa de venda'),
    ex.TextCellValue('Frete ML'),
    ex.TextCellValue('Total (BRL)'),
    ex.TextCellValue('Título do anúncio'),
    ex.TextCellValue('Custo'),
    ex.TextCellValue('Observação'),
  ]);

  for (final s in sales) {
    detail.appendRow([
      ex.TextCellValue(s.numero),
      ex.TextCellValue(s.data),
      ex.TextCellValue(s.estado),
      ex.IntCellValue(s.unidade),
      ex.DoubleCellValue(s.receita),
      ex.DoubleCellValue(s.tarifaVenda),
      ex.DoubleCellValue(s.freteML),
      ex.DoubleCellValue(s.totalBRL),
      ex.TextCellValue(s.titulo),
      ex.DoubleCellValue(s.custo),
      ex.TextCellValue(s.observacao),
    ]);
  }

  final resumo = excel['Resumo'];
  void append(String descricao, double valor) => resumo.appendRow([ex.TextCellValue(descricao), ex.DoubleCellValue(valor)]);

  append('VENDA LÍQUIDA', summary.vendaLiquida);
  append('CUSTO PEÇAS', summary.custoPecas);
  append('ANTECIPAÇÃO', summary.antecipacao);
  append('PUBLICIDADE', summary.publicidade);
  append('SIMPLES', summary.simples);
  append('TARIFAS FULL', summary.tarifasFull);
  append('PÁGINA', summary.pagina);
  append('TOTAL', summary.total);

  return Uint8List.fromList(excel.encode() ?? []);
}

double findCostForTitle(String title, List<CostItem> items) {
  if (title.trim().isEmpty || items.isEmpty) return 0;

  final normalizedTitle = _normalize(title);
  final titleKeywords = _keywords(normalizedTitle);

  CostItem? best;
  var bestScore = 0.0;

  for (final item in items) {
    final desc = _normalize(item.descricao);
    if (desc.isEmpty) continue;

    if (normalizedTitle.contains(desc) || desc.contains(normalizedTitle)) {
      return item.custo.abs();
    }

    final descKeywords = _keywords(desc);
    var matches = 0;

    for (final keyword in titleKeywords) {
      if (descKeywords.any((dk) => dk == keyword || (dk.length > 3 && keyword.length > 3 && (dk.contains(keyword) || keyword.contains(dk))))) {
        matches++;
      }
    }

    final score = matches / max(titleKeywords.length, descKeywords.length);
    final minMatches = descKeywords.length <= 3 ? 1 : 2;

    if (matches >= minMatches && score > bestScore) {
      bestScore = score;
      best = item;
    }
  }

  return best?.custo.abs() ?? 0;
}

String _normalize(String s) => s
    .toLowerCase()
    .replaceAll(RegExp(r'[áàâãä]'), 'a')
    .replaceAll(RegExp(r'[éèêë]'), 'e')
    .replaceAll(RegExp(r'[íìîï]'), 'i')
    .replaceAll(RegExp(r'[óòôõö]'), 'o')
    .replaceAll(RegExp(r'[úùûü]'), 'u')
    .replaceAll(RegExp(r'ç'), 'c')
    .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
    .trim();

List<String> _keywords(String s) => s.split(RegExp(r'\s+')).where((w) => w.length > 2).toList();

double _parseNumber(Object? value) {
  if (value == null) return 0;
  final text = value.toString().trim();
  if (text.isEmpty) return 0;
  final normalized = text.replaceAll('.', '').replaceAll(',', '.').replaceAll(RegExp(r'\s'), '');
  return double.tryParse(normalized) ?? 0;
}

String _formatDate(String value) {
  final text = value.trim();
  if (text.isEmpty) return '';

  final iso = DateTime.tryParse(text);
  if (iso != null) {
    return DateFormat('dd/MM/yyyy HH:mm').format(iso);
  }

  final full = RegExp(r'(\d{1,2})\s+de\s+(\w+)\s+de\s+(\d{4})\s+(\d{1,2}):(\d{2})', caseSensitive: false).firstMatch(text);
  if (full != null) {
    final day = full.group(1)!.padLeft(2, '0');
    final month = {
          'janeiro': '01',
          'fevereiro': '02',
          'marco': '03',
          'março': '03',
          'abril': '04',
          'maio': '05',
          'junho': '06',
          'julho': '07',
          'agosto': '08',
          'setembro': '09',
          'outubro': '10',
          'novembro': '11',
          'dezembro': '12',
        }[_normalize(full.group(2)!)] ??
        '01';
    final year = full.group(3)!;
    final hour = full.group(4)!.padLeft(2, '0');
    final minute = full.group(5)!;
    return '$day/$month/$year $hour:$minute';
  }

  return text;
}
