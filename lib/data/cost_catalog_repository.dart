import 'package:firebase_database/firebase_database.dart';

import '../models/cost_catalog_item.dart';

class CostCatalogRepository {
  static const String collectionPath = 'cost_catalog';

  final DatabaseReference _rootRef = FirebaseDatabase.instance.ref(collectionPath);

  Future<void> init() async {}

  Future<List<CostCatalogItem>> getAll() async {
    final snapshot = await _rootRef.get();
    if (!snapshot.exists || snapshot.value == null) {
      return const [];
    }

    final raw = snapshot.value;
    if (raw is! Map) {
      return const [];
    }

    return raw.entries
        .where((entry) => entry.value is Map)
        .map((entry) => CostCatalogItem.fromMap(Map<String, dynamic>.from(entry.value as Map)))
        .where((item) => item.descricao.trim().isNotEmpty)
        .toList(growable: false);
  }

  Future<void> upsert(CostCatalogItem item) async {
    await _rootRef.child(item.id).set(item.toMap());
  }

  Future<void> saveAll(List<CostCatalogItem> items) async {
    final batch = <String, dynamic>{};

    for (final item in items) {
      batch[item.id] = item.toMap();
    }

    if (batch.isEmpty) return;

    await _rootRef.update(batch);
  }

  Future<void> delete(String id) async {
    await _rootRef.child(id).remove();
  }

  Future<void> clearAll() async {
    await _rootRef.remove();
  }

  Future<CostCatalogItem?> findByDescription(String description) async {
    final normalized = _normalize(description);
    final all = await getAll();

    for (final item in all) {
      if (_normalize(item.descricao) == normalized) {
        return item;
      }
    }

    return null;
  }

  String nextId() {
    return _rootRef.push().key ?? DateTime.now().microsecondsSinceEpoch.toString();
  }

  String _normalize(String value) {
    return value.trim().toLowerCase();
  }
}
