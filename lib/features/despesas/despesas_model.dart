class Despesa {
  final int id;
  final String descricao;
  final double valor;
  final int categoriaId;
  final String categoria;
  final String tipo;
  final DateTime data;
  final bool isPending;

  Despesa({
    required this.id,
    required this.descricao,
    required this.valor,
    required this.categoriaId,
    required this.categoria,
    required this.tipo,
    required this.data,
    this.isPending = false,
  });

  factory Despesa.fromJson(Map<String, dynamic> json) {
    return Despesa(
      id: (json['id'] ?? 0) as int,
      descricao: json['descricao'] ?? '',
      valor: (json['valor'] is num)
          ? (json['valor'] as num).toDouble()
          : double.tryParse(json['valor'].toString().replaceAll(',', '.')) ??
                0.0,
      categoriaId: json['categoria'] ?? 0,
      categoria: json['categoria_nome'] ?? '',
      tipo: json['tipo'] ?? 'saida',
      data: DateTime.tryParse(json['data'] ?? '') ?? DateTime.now(),
      isPending: json['isPending'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'descricao': descricao,
      'valor': valor,
      'categoria': categoriaId,
      'categoria_nome': categoria,
      'tipo': tipo,
      'data': data.toIso8601String().split('T')[0],
      'isPending': isPending,
    };
  }

  Despesa copyWith({
    int? id,
    String? descricao,
    double? valor,
    int? categoriaId,
    String? categoria,
    String? tipo,
    DateTime? data,
    bool? isPending,
  }) {
    return Despesa(
      id: id ?? this.id,
      descricao: descricao ?? this.descricao,
      valor: valor ?? this.valor,
      categoriaId: categoriaId ?? this.categoriaId,
      categoria: categoria ?? this.categoria,
      tipo: tipo ?? this.tipo,
      data: data ?? this.data,
      isPending: isPending ?? this.isPending,
    );
  }
}
