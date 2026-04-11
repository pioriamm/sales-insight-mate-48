import 'package:hive_flutter/hive_flutter.dart';

import '../models/cost_catalog_item.dart';

class CostCatalogRepository {
  static const String boxName = 'cost_catalog';

  late final Box<Map> _box;

  Future<void> init() async {
    _box = await Hive.openBox<Map>(boxName);
  }

  List<CostCatalogItem> getAll() {
    return _box.values
        .map((item) => CostCatalogItem.fromMap(item))
        .where((item) => item.descricao.trim().isNotEmpty)
        .toList(growable: false);
  }

  Future<void> upsert(CostCatalogItem item) async {
    await _box.put(item.id, item.toMap());
  }

  Future<void> saveAll(List<CostCatalogItem> items) async {
    for (final item in items) {
      await upsert(item);
    }
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  CostCatalogItem? findByDescription(String description) {
    final normalized = _normalize(description);

    for (final raw in _box.values) {
      final item = CostCatalogItem.fromMap(raw);
      if (_normalize(item.descricao) == normalized) {
        return item;
      }
    }

    return null;
  }

  String nextId() {
    final now = DateTime.now().microsecondsSinceEpoch;
    return now.toString();
  }

  String _normalize(String value) {
    return value.trim().toLowerCase();
  }
}
