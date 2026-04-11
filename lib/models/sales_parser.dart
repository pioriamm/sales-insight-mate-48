import 'dart:math';
import 'dart:typed_data';

import 'package:excel/excel.dart' as ex;
import 'package:intl/intl.dart';

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

  Map<String, Object> toMap() => {
        'id': id,
        'numero': numero,
        'data': data,
        'estado': estado,
        'unidade': unidade,
        'receita': receita,
        'tarifaVenda': tarifaVenda,
        'freteML': freteML,
        'totalBRL': totalBRL,
        'titulo': titulo,
        'custo': custo,
        'observacao': observacao,
      };

  static SaleRow fromMap(Map<String, dynamic> map) => SaleRow(
        id: map['id']?.toString() ?? '',
        numero: map['numero']?.toString() ?? '',
        data: map['data']?.toString() ?? '',
        estado: map['estado']?.toString() ?? '',
        unidade: (map['unidade'] as num?)?.toInt() ?? 0,
        receita: (map['receita'] as num?)?.toDouble() ?? 0,
        tarifaVenda: (map['tarifaVenda'] as num?)?.toDouble() ?? 0,
        freteML: (map['freteML'] as num?)?.toDouble() ?? 0,
        totalBRL: (map['totalBRL'] as num?)?.toDouble() ?? 0,
        titulo: map['titulo']?.toString() ?? '',
        custo: (map['custo'] as num?)?.toDouble() ?? 0,
        observacao: map['observacao']?.toString() ?? '',
      );

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
    required this.despesasAdicionais,
    required this.total,
  });

  final double vendaLiquida;
  final double custoPecas;
  final double antecipacao;
  final double publicidade;
  final double simples;
  final double tarifasFull;
  final double pagina;
  final double despesasAdicionais;
  final double total;
}

class CostItem {
  CostItem({required this.sku, required this.descricao, required this.custo});

  final String sku;
  final String descricao;
  final double custo;

  Map<String, Object> toMap() => {
        'sku': sku,
        'descricao': descricao,
        'custo': custo,
      };

  static CostItem fromMap(Map<String, dynamic> map) => CostItem(
        sku: map['sku']?.toString() ?? '',
        descricao: map['descricao']?.toString() ?? '',
        custo: (map['custo'] as num?)?.toDouble() ?? 0,
      );
}

List<Map<String, Object>> parseSalesFileDto(Uint8List bytes) =>
    parseSalesFile(bytes).map((row) => row.toMap()).toList(growable: false);

List<Map<String, Object>> parseCostFileDto(Uint8List bytes) =>
    parseCostFile(bytes).map((item) => item.toMap()).toList(growable: false);

List<Map<String, Object>> applyCostsAndSortSalesDto(Map<String, dynamic> payload) {
  final salesDto = (payload['sales'] as List<dynamic>? ?? const [])
      .whereType<Map<dynamic, dynamic>>()
      .map((row) => Map<String, dynamic>.from(row))
      .toList(growable: false);
  final costs = (payload['costs'] as List<dynamic>? ?? const [])
      .whereType<Map<dynamic, dynamic>>()
      .map((item) => CostItem.fromMap(Map<String, dynamic>.from(item)))
      .toList(growable: false);

  final withCosts = salesDto
      .map((row) {
        final sale = SaleRow.fromMap(row);
        return sale.copyWith(custo: findCostForTitle(sale.titulo, costs));
      })
      .toList(growable: false);

  withCosts.sort((a, b) {
    if (a.custo == 0 && b.custo > 0) return -1;
    if (b.custo == 0 && a.custo > 0) return 1;
    return 0;
  });

  return withCosts.map((row) => row.toMap()).toList(growable: false);
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
    return normalized.indexWhere((h) => candidates.any((c) => h == c));
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
  Object? rawAt(List<ex.Data?> row, int i) => i >= 0 && i < row.length ? row[i]?.value : null;

  final sales = <SaleRow>[];
  for (var i = 1; i < rows.length; i++) {
    final row = rows[i];
    if (row.every((c) => c == null || c.value == null || c.value.toString().trim().isEmpty)) continue;

    sales.add(SaleRow(
      id: '$i',
      numero: valueAt(row, iNumero),
      data: _formatDate(valueAt(row, iData)),
      estado: valueAt(row, iEstado),
      unidade: _parseUnit(rawAt(row, iUnid)),
      receita: _parseMoney(rawAt(row, iReceita)),
      tarifaVenda: _parseMoney(rawAt(row, iTarifa)),
      freteML: _parseMoney(rawAt(row, iFrete)),
      totalBRL: _parseMoney(rawAt(row, iTotal)),
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
    double cost = _parseNumber(valueAt(row, iCost));

    if (cost == 0) {
      for (var col = max(iDesc + 1, 0); col < row.length; col++) {
        final parsed = _parseNumber(row[col]?.value);
        if (parsed != 0) {
          cost = parsed;
          break;
        }
      }
    }

    items.add(CostItem(
      sku: valueAt(row, iSku),
      descricao: valueAt(row, iDesc),
      custo: cost,
    ));
  }

  return items;
}

Uint8List buildExportFile(
    List<SaleRow> sales,
    SummaryData summary,
    Map<String, double> despesas, // ✅ NOVO
    ) {
  final excel = ex.Excel.createExcel();

  final defaultSheet = excel.getDefaultSheet();
  if (defaultSheet != null) {
    excel.delete(defaultSheet);
  }

  /// =========================
  /// 🔹 ABA VENDAS
  /// =========================
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

  /// =========================
  /// 🔹 ABA RESUMO
  /// =========================
  final resumo = excel['Resumo'];

  void append(String descricao, double valor) {
    resumo.appendRow([
      ex.TextCellValue(descricao),
      ex.DoubleCellValue(valor),
    ]);
  }

  append('VENDA LÍQUIDA', summary.vendaLiquida);
  append('CUSTO PEÇAS', summary.custoPecas);

  /// 🔹 DESPESAS DINÂMICAS
  despesas.forEach((key, value) {
    append(key.toUpperCase(), value);
  });

  append('TOTAL', summary.total);

  return Uint8List.fromList(excel.encode() ?? []);
}

double findCostForTitle(String title, List<CostItem> items) {
  if (title.trim().isEmpty || items.isEmpty) return 0;

  final normalizedTitle = _normalize(title);
  final compactTitle = normalizedTitle.replaceAll(' ', '');
  final titleKeywords = _keywords(normalizedTitle);

  for (final item in items) {
    final normalizedSku = _normalize(item.sku).replaceAll(' ', '');
    if (normalizedSku.isEmpty) continue;
    if (compactTitle.contains(normalizedSku)) return item.custo.abs();
  }

  CostItem? best;
  var bestScore = 0.0;

  for (final item in items) {
    final sku = _normalize(item.sku).replaceAll(' ', '');
    if (sku.isNotEmpty && (compactTitle.contains(sku) || sku.contains(compactTitle))) return item.custo.abs();

    final desc = _normalize(item.descricao);
    if (desc.isEmpty) continue;

    if (normalizedTitle.contains(desc) || desc.contains(normalizedTitle)) return item.custo.abs();

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

  final direct = value is num ? value.toDouble() : double.tryParse(text);
  if (direct != null) return direct;

  final cleaned = text
      .replaceAll(RegExp(r'[^0-9,\.\-]'), '')
      .replaceAll(RegExp(r'(?<=\d)\.(?=\d{3}(\D|$))'), '')
      .replaceAll(',', '.');

  final matches = RegExp(r'-?\d+(\.\d+)?').allMatches(cleaned).toList();
  if (matches.isEmpty) return 0;
  return double.tryParse(matches.last.group(0)!) ?? 0;
}

double _parseMoney(Object? value) {
  if (value == null) return 0;
  if (value is num) {
    final asDouble = value.toDouble();
    if (value is int && value.abs() >= 1000) return asDouble / 100;
    return asDouble;
  }

  final text = value.toString().trim();
  if (text.isEmpty) return 0;

  final parsed = _parseNumber(text);
  if (text.contains(',') || text.contains('.')) return parsed;

  final digitsOnly = text.replaceAll(RegExp(r'[^0-9\-]'), '');
  if (RegExp(r'^-?\d{3,}$').hasMatch(digitsOnly)) return parsed / 100;
  return parsed;
}

int _parseUnit(Object? value) {
  if (value == null) return 0;
  if (value is num) return value.round();

  final text = value.toString().trim();
  if (text.isEmpty) return 0;

  final direct = _parseNumber(text);
  if (direct != 0) return direct.round();

  final match = RegExp(r'\d+').firstMatch(text);
  if (match == null) return 0;
  return int.tryParse(match.group(0)!) ?? 0;
}

String _formatDate(String value) {
  final text = value.trim();
  if (text.isEmpty) return '';

  final iso = DateTime.tryParse(text);
  if (iso != null) return DateFormat('dd/MM/yyyy HH:mm').format(iso);

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
