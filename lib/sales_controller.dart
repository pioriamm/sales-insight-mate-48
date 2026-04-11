import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'sales_parser.dart';

class SalesController extends ChangeNotifier {
  List<SaleRow> sales = [];
  List<CostItem> costItems = [];

  final Map<String, double> manualFields = {
    'antecipacao': 0,
    'publicidade': 0,
    'simples': 0,
    'tarifasFull': 0,
    'pagina': 0,
  };

  bool isLoadingCost = false;
  bool isLoadingSales = false;

  bool get isLoadingAny => isLoadingCost || isLoadingSales;

  SummaryData get summary {
    final vendaLiquida = sales.fold<double>(0, (sum, s) => sum + s.totalBRL);
    final custoPecas = sales.fold<double>(0, (sum, s) => sum + s.custo);
    final total = vendaLiquida - custoPecas - manualFields.values.fold<double>(0, (sum, value) => sum + value);

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

  Future<void> pickCostFile(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['xlsx', 'xls'], withData: true);
    final bytes = result?.files.single.bytes;
    if (bytes == null) return;

    isLoadingCost = true;
    notifyListeners();

    try {
      await Future<void>.delayed(const Duration(milliseconds: 80));
      costItems = parseCostFile(bytes);
      notifyListeners();
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível importar a planilha de custos. Verifique o arquivo.')),
      );
    } finally {
      isLoadingCost = false;
      notifyListeners();
    }
  }

  Future<void> pickSalesFile(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['xlsx', 'xls'], withData: true);
    final bytes = result?.files.single.bytes;
    if (bytes == null) return;

    isLoadingSales = true;
    notifyListeners();

    try {
      await Future<void>.delayed(const Duration(milliseconds: 80));
      final parsed = parseSalesFile(bytes);
      final withCosts = parsed.map((row) => row.copyWith(custo: findCostForTitle(row.titulo, costItems))).toList();

      withCosts.sort((a, b) {
        if (a.custo == 0 && b.custo > 0) return -1;
        if (b.custo == 0 && a.custo > 0) return 1;
        return 0;
      });

      sales = withCosts;
      notifyListeners();
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível importar a planilha de vendas. Verifique o arquivo.')),
      );
    } finally {
      isLoadingSales = false;
      notifyListeners();
    }
  }

  void updateManualField(String key, double value) {
    manualFields[key] = value;
    notifyListeners();
  }

  void updateRow(int index, double? cost, String? note) {
    sales[index] = sales[index].copyWith(custo: cost ?? sales[index].custo, observacao: note ?? sales[index].observacao);
    notifyListeners();
  }

  void resetAll() {
    sales = [];
    costItems = [];
    for (final key in manualFields.keys) {
      manualFields[key] = 0;
    }
    notifyListeners();
  }

  Future<void> exportExcel() async {
    final bytes = buildExportFile(sales, summary);
    await FilePicker.platform.saveFile(
      dialogTitle: 'Salvar planilha',
      fileName: '${DateFormat('MM-yyyy').format(DateTime.now())}-Contabilidade.xlsx',
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      bytes: bytes,
    );
  }
}
