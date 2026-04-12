class CostCatalogItem {
  CostCatalogItem({
    required this.id,
    required this.descricao,
    required this.custo,
  });

  final String id;
  final String descricao;
  final double custo;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'descricao': descricao,
      'custo': custo,
    };
  }

  static CostCatalogItem fromMap(Map<dynamic, dynamic> map) {
    return CostCatalogItem(
      id: map['id']?.toString() ?? '',
      descricao: map['descricao']?.toString() ?? '',
      custo: (map['custo'] as num?)?.toDouble() ?? 0,
    );
  }

  CostCatalogItem copyWith({
    String? id,
    String? descricao,
    double? custo,
  }) {
    return CostCatalogItem(
      id: id ?? this.id,
      descricao: descricao ?? this.descricao,
      custo: custo ?? this.custo,
    );
  }
}
