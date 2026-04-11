import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';

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
  double loadingProgress = 0;
  String loadingMessage = 'Importando planilha...';
  Timer? _loadingTicker;

  bool get isLoadingAny => isLoadingCost || isLoadingSales;

  int get loadingPercent => (loadingProgress * 100).clamp(0, 100).round();

  void _setLoadingState({
    required bool cost,
    required bool sales,
    required double progress,
    required String message,
  }) {
    isLoadingCost = cost;
    isLoadingSales = sales;
    loadingProgress = progress.clamp(0, 1);
    loadingMessage = message;
    notifyListeners();
  }

  void _startSmoothProgress({required bool cost, required bool sales, required String message}) {
    _loadingTicker?.cancel();
    _setLoadingState(cost: cost, sales: sales, progress: 0.05, message: message);
    _loadingTicker = Timer.periodic(const Duration(milliseconds: 120), (timer) {
      final next = (loadingProgress + 0.02).clamp(0.05, 0.92);
      if (next >= 0.92) {
        timer.cancel();
      }
      _setLoadingState(cost: cost, sales: sales, progress: next, message: loadingMessage);
    });
  }

  Future<void> _finishLoading({required bool cost, required bool sales, required String message}) async {
    _loadingTicker?.cancel();
    _setLoadingState(cost: cost, sales: sales, progress: 1, message: message);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _setLoadingState(cost: false, sales: false, progress: 0, message: 'Importando planilha...');
  }

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

    _startSmoothProgress(cost: true, sales: false, message: 'Lendo planilha de custos...');

    try {
      _setLoadingState(
        cost: true,
        sales: false,
        progress: loadingProgress,
        message: 'Processando planilha de custos...',
      );
      final parsedDto = await compute(parseCostFileDto, bytes);
      costItems = parsedDto.map((item) => CostItem.fromMap(Map<String, dynamic>.from(item))).toList(growable: false);
      await _finishLoading(cost: true, sales: false, message: 'Custos importados com sucesso.');
    } catch (_) {
      _loadingTicker?.cancel();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível importar a planilha de custos. Verifique o arquivo.')),
      );
      _setLoadingState(cost: false, sales: false, progress: 0, message: 'Importando planilha...');
    }
  }

  Future<void> pickSalesFile(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['xlsx', 'xls'], withData: true);
    final bytes = result?.files.single.bytes;
    if (bytes == null) return;

    _startSmoothProgress(cost: false, sales: true, message: 'Lendo planilha de vendas...');

    try {
      _setLoadingState(
        cost: false,
        sales: true,
        progress: loadingProgress,
        message: 'Convertendo planilha de vendas...',
      );
      final parsedDto = await compute(parseSalesFileDto, bytes);
      final payload = {
        'sales': parsedDto,
        'costs': costItems.map((item) => item.toMap()).toList(growable: false),
      };
      _setLoadingState(
        cost: false,
        sales: true,
        progress: loadingProgress,
        message: 'Aplicando custos e organizando dados...',
      );
      final withCostsDto = await compute(applyCostsAndSortSalesDto, payload);
      sales = withCostsDto.map((row) => SaleRow.fromMap(Map<String, dynamic>.from(row))).toList(growable: false);
      await _finishLoading(cost: false, sales: true, message: 'Vendas importadas com sucesso.');
    } catch (_) {
      _loadingTicker?.cancel();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível importar a planilha de vendas. Verifique o arquivo.')),
      );
      _setLoadingState(cost: false, sales: false, progress: 0, message: 'Importando planilha...');
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

  @override
  void dispose() {
    _loadingTicker?.cancel();
    super.dispose();
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
