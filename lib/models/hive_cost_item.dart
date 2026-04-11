class HiveCostItem {
  HiveCostItem({
    required this.id,
    required this.descricao,
    required this.custo,
  });

  final String id;
  final String descricao;
  final double custo;

  Map<String, Object> toMap() => {
        'id': id,
        'descricao': descricao,
        'custo': custo,
      };

  static HiveCostItem fromMap(Map<String, dynamic> map) => HiveCostItem(
        id: map['id']?.toString() ?? '',
        descricao: map['descricao']?.toString() ?? '',
        custo: (map['custo'] as num?)?.toDouble() ?? 0,
      );

  HiveCostItem copyWith({String? descricao, double? custo}) => HiveCostItem(
        id: id,
        descricao: descricao ?? this.descricao,
        custo: custo ?? this.custo,
      );
}
