import 'dart:async';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import '../models/hive_cost_item.dart';
import '../models/sales_parser.dart';

class SalesController extends ChangeNotifier {
  static const String costCatalogBoxName = 'cost_catalog';

  SalesController() {
    loadCostCatalog();
  }

  List<SaleRow> sales = [];
  List<CostItem> costItems = [];
  List<HiveCostItem> catalogItems = [];

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

  Box<dynamic> get _catalogBox => Hive.box<dynamic>(costCatalogBoxName);

  bool get isLoadingAny => isLoadingCost || isLoadingSales;
  int get loadingPercent => (loadingProgress * 100).clamp(0, 100).round();

  Future<void> loadCostCatalog() async {
    final items = _catalogBox.values
        .whereType<Map>()
        .map((raw) => HiveCostItem.fromMap(Map<String, dynamic>.from(raw)))
        .where((item) => item.descricao.trim().isNotEmpty)
        .toList()
      ..sort((a, b) => a.descricao.toLowerCase().compareTo(b.descricao.toLowerCase()));

    catalogItems = items;
    notifyListeners();
  }

  Future<void> saveCatalogItem({
    String? id,
    required String descricao,
    required double custo,
  }) async {
    final trimmed = descricao.trim();
    if (trimmed.isEmpty) return;

    final itemId = id ?? DateTime.now().microsecondsSinceEpoch.toString();
    final item = HiveCostItem(id: itemId, descricao: trimmed, custo: custo);
    await _catalogBox.put(itemId, item.toMap());
    await loadCostCatalog();
  }

  Future<void> importCatalogFromJson(String jsonText) async {
    final decoded = jsonDecode(jsonText);
    final List<dynamic> data = decoded is List ? decoded : [decoded];

    for (final raw in data) {
      if (raw is! Map) continue;
      final mapped = Map<String, dynamic>.from(raw);
      final descricao = mapped['descricao']?.toString() ?? '';
      final custo = (mapped['custo'] as num?)?.toDouble() ?? 0;
      final id = mapped['id']?.toString();
      await saveCatalogItem(id: id, descricao: descricao, custo: custo);
    }
  }

  double get despesasAdicionais {
    return costItems.fold<double>(0, (sum, item) => sum + item.custo);
  }

  SummaryData get summary {
    final vendaLiquida = sales.fold<double>(0, (sum, s) => sum + s.totalBRL);
    final custoPecas = sales.fold<double>(0, (sum, s) => sum + s.custo);
    final custosManuais = manualFields.values.fold<double>(0, (sum, v) => sum + v);
    final total = vendaLiquida - custoPecas - custosManuais;

    return SummaryData(
      vendaLiquida: vendaLiquida,
      custoPecas: custoPecas,
      antecipacao: manualFields['antecipacao'] ?? 0,
      publicidade: manualFields['publicidade'] ?? 0,
      simples: manualFields['simples'] ?? 0,
      tarifasFull: manualFields['tarifasFull'] ?? 0,
      pagina: manualFields['pagina'] ?? 0,
      despesasAdicionais: custosManuais,
      total: total,
    );
  }

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

  void _startSmoothProgress({
    required bool cost,
    required bool sales,
    required String message,
  }) {
    _loadingTicker?.cancel();
    _setLoadingState(cost: cost, sales: sales, progress: 0.05, message: message);

    _loadingTicker = Timer.periodic(const Duration(milliseconds: 120), (timer) {
      final next = (loadingProgress + 0.02).clamp(0.05, 0.92);
      if (next >= 0.92) timer.cancel();
      _setLoadingState(cost: cost, sales: sales, progress: next, message: loadingMessage);
    });
  }

  Future<void> _finishLoading({
    required bool cost,
    required bool sales,
    required String message,
  }) async {
    _loadingTicker?.cancel();
    _setLoadingState(cost: cost, sales: sales, progress: 1, message: message);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _setLoadingState(cost: false, sales: false, progress: 0, message: 'Importando planilha...');
  }

  Future<void> pickCostFile(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
      withData: true,
    );

    final bytes = result?.files.single.bytes;
    if (bytes == null) return;

    _startSmoothProgress(cost: true, sales: false, message: 'Lendo planilha de custos...');

    try {
      _setLoadingState(cost: true, sales: false, progress: loadingProgress, message: 'Processando planilha de custos...');

      final parsedDto = await compute(parseCostFileDto, bytes);
      costItems = parsedDto.map((item) => CostItem.fromMap(Map<String, dynamic>.from(item))).toList(growable: false);

      await _finishLoading(cost: true, sales: false, message: 'Custos importados com sucesso.');
    } catch (_) {
      _loadingTicker?.cancel();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Não foi possível importar a planilha de custos.')));
      _setLoadingState(cost: false, sales: false, progress: 0, message: 'Importando planilha...');
    }
  }

  Future<void> pickSalesFile(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
      withData: true,
    );

    final bytes = result?.files.single.bytes;
    if (bytes == null) return;

    _startSmoothProgress(cost: false, sales: true, message: 'Lendo planilha de vendas...');

    try {
      _setLoadingState(cost: false, sales: true, progress: loadingProgress, message: 'Convertendo planilha de vendas...');
      final parsedDto = await compute(parseSalesFileDto, bytes);

      final mergedCosts = [
        ...costItems,
        ...catalogItems.map((item) => CostItem(sku: item.id, descricao: item.descricao, custo: item.custo)),
      ];

      final payload = {
        'sales': parsedDto,
        'costs': mergedCosts.map((item) => item.toMap()).toList(growable: false),
      };

      _setLoadingState(cost: false, sales: true, progress: loadingProgress, message: 'Aplicando custos...');
      final withCostsDto = await compute(applyCostsAndSortSalesDto, payload);

      sales = withCostsDto.map((row) => SaleRow.fromMap(Map<String, dynamic>.from(row))).toList(growable: false);
      await _finishLoading(cost: false, sales: false, message: 'Vendas importadas com sucesso.');
    } catch (_) {
      _loadingTicker?.cancel();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Não foi possível importar a planilha de vendas.')));
      _setLoadingState(cost: false, sales: false, progress: 0, message: 'Importando planilha...');
    }
  }

  void updateManualField(String key, double value) {
    manualFields[key] = value;
    notifyListeners();
  }

  Future<void> updateRow(int index, double? cost, String? note) async {
    final original = sales[index];
    final updatedCost = cost ?? original.custo;

    sales[index] = original.copyWith(
      custo: updatedCost,
      observacao: note ?? original.observacao,
    );

    if (cost != null && updatedCost > 0 && !_hasCatalogDescription(original.titulo)) {
      await saveCatalogItem(descricao: original.titulo, custo: updatedCost);
    }

    notifyListeners();
  }

  bool _hasCatalogDescription(String descricao) {
    final normalized = _normalize(descricao);
    if (normalized.isEmpty) return true;
    return catalogItems.any((item) => _normalize(item.descricao) == normalized);
  }

  String _normalize(String value) => value
      .toLowerCase()
      .replaceAll(RegExp(r'[áàâãä]'), 'a')
      .replaceAll(RegExp(r'[éèêë]'), 'e')
      .replaceAll(RegExp(r'[íìîï]'), 'i')
      .replaceAll(RegExp(r'[óòôõö]'), 'o')
      .replaceAll(RegExp(r'[úùûü]'), 'u')
      .replaceAll(RegExp(r'ç'), 'c')
      .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
      .trim();

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
    final bytes = buildExportFile(sales, summary, manualFields);

    await FilePicker.platform.saveFile(
      dialogTitle: 'Salvar planilha',
      fileName: '${DateFormat('MM-yyyy').format(DateTime.now())}-Contabilidade.xlsx',
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      bytes: bytes,
    );
  }
}
