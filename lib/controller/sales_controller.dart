import 'dart:async';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/cost_catalog_repository.dart';
import '../models/cost_catalog_item.dart';
import '../models/sales_parser.dart';

class SalesController extends ChangeNotifier {
  static const String costCatalogBoxName = 'cost_catalog';

  SalesController() {
    loadCostCatalog();
  }

  List<SaleRow> sales = [];
  List<CostItem> costItems = [];
  List<CostCatalogItem> catalogItems = [];

  final CostCatalogRepository _catalogRepository = CostCatalogRepository();

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

  Future<void> init() async {
    await _catalogRepository.init();
    await _reloadCatalog();
  }

  Future<void> _reloadCatalog() async {
    final items = await _catalogRepository.getAll();

    catalogItems = List.from(items)
      ..sort((a, b) => a.descricao
          .toLowerCase()
          .compareTo(b.descricao.toLowerCase()));
  }

  bool get isLoadingAny => isLoadingCost || isLoadingSales;
  int get loadingPercent => (loadingProgress * 100).clamp(0, 100).round();

  Future<void> loadCostCatalog() async {
    await _reloadCatalog();
    notifyListeners();
  }

  Future<void> saveCatalogItem({
    String? id,
    required String descricao,
    required double custo,
  }) async {
    final trimmed = descricao.trim();
    if (trimmed.isEmpty) return;

    final item = CostCatalogItem(
      id: id ?? _catalogRepository.nextId(),
      descricao: trimmed,
      custo: custo,
    );
    await _catalogRepository.upsert(item);
    await loadCostCatalog();
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

      costItems = parsedDto
          .map((item) => CostItem.fromMap(Map<String, dynamic>.from(item)))
          .toList(growable: false);

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
      final parsedSales = parsedDto
          .map((row) => SaleRow.fromMap(Map<String, dynamic>.from(row)))
          .toList(growable: false);

      final catalogByDescription = <String, CostCatalogItem>{
        for (final item in catalogItems) _normalize(item.descricao): item,
      };

      final combinedCosts = [
        ...catalogItems.map((item) => CostItem(sku: item.id, descricao: item.descricao, custo: item.custo)),
        ...costItems,
      ];

      sales = parsedSales
          .map((row) {
            final match = catalogByDescription[_normalize(row.titulo)];
            final catalogCost = match?.custo ?? 0;
            final fallbackCost = findCostForTitle(row.titulo, combinedCosts);
            return row.copyWith(
              custo: catalogCost > 0 ? catalogCost : fallbackCost,
              foundInCatalog: match != null,
            );
          })
          .toList(growable: false);

      await _finishLoading(
        cost: false,
        sales: true,
        message: 'Vendas importadas com sucesso.',
      );
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
    final current = sales[index];
    final nextCost = cost ?? current.custo;

    sales[index] = current.copyWith(
      custo: nextCost,
      observacao: note ?? current.observacao,
    );

    if (cost != null && nextCost > 0) {
      final found = await _catalogRepository.findByDescription(current.titulo);
      if (found == null) {
        await _catalogRepository.upsert(CostCatalogItem(
          id: _catalogRepository.nextId(),
          descricao: current.titulo,
          custo: nextCost,
        ));
        await _reloadCatalog();
      }
    }

    notifyListeners();
  }

  Future<void> addSaleItemToCatalog(int index, double custo) async {
    final current = sales[index];
    final found = await _catalogRepository.findByDescription(current.titulo);
    if (found == null) {
      await _catalogRepository.upsert(CostCatalogItem(
        id: _catalogRepository.nextId(),
        descricao: current.titulo,
        custo: custo,
      ));
      await _reloadCatalog();
    }

    sales[index] = current.copyWith(
      custo: custo,
      foundInCatalog: true,
    );
    notifyListeners();
  }

  Future<void> addCatalogItem(String descricao, double custo) async {
    final item = CostCatalogItem(
      id: _catalogRepository.nextId(),
      descricao: descricao,
      custo: custo,
    );
    await _catalogRepository.upsert(item);
    await _reloadCatalog();
    notifyListeners();
  }

  Future<void> updateCatalogItem(CostCatalogItem item) async {
    await _catalogRepository.upsert(item);
    await _reloadCatalog();
    notifyListeners();
  }

  Future<void> deleteCatalogItem(String id) async {
    await _catalogRepository.delete(id);
    await _reloadCatalog();
    notifyListeners();
  }

  Future<void> clearCatalog() async {
    await _catalogRepository.clearAll();
    await _reloadCatalog();
    notifyListeners();
  }

  Future<int> importCatalogFromJson([String? jsonText]) async {
    String? payload = jsonText;

    if (payload == null) {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );

      final bytes = result?.files.single.bytes;
      if (bytes == null) return 0;
      payload = utf8.decode(bytes);
    }

    final parsed = _parseCatalogJson(payload);

    await _catalogRepository.saveAll(parsed);
    await _reloadCatalog();
    notifyListeners();
    return parsed.length;
  }

  List<CostCatalogItem> _parseCatalogJson(String jsonText) {
    final decoded = jsonDecode(jsonText);
    final rawList = (decoded is List)
        ? decoded
        : (decoded is Map<String, dynamic> && decoded['items'] is List)
            ? decoded['items'] as List<dynamic>
            : <dynamic>[];

    return rawList
        .whereType<Map>()
        .map((item) => CostCatalogItem(
              id: item['id']?.toString().trim().isNotEmpty == true
                  ? item['id'].toString()
                  : _catalogRepository.nextId(),
              descricao: item['descricao']?.toString() ?? '',
              custo: (item['custo'] as num?)?.toDouble() ?? 0,
            ))
        .where((item) => item.descricao.trim().isNotEmpty)
        .toList(growable: false);
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
    final bytes = buildExportFile(sales, summary, manualFields);

    await FilePicker.platform.saveFile(
      dialogTitle: 'Salvar planilha',
      fileName: '${DateFormat('MM-yyyy').format(DateTime.now())}-Contabilidade.xlsx',
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      bytes: bytes,
    );
  }

  String _normalize(String value) {
    return value.trim().toLowerCase();
  }
}
