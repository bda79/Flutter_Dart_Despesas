class Despesa {
  final int id;
  final String descricao;
  final double valor;
  final String categoria;

  Despesa({
    required this.id,
    required this.descricao,
    required this.valor,
    required this.categoria,
  });

  factory Despesa.fromJson(Map<String, dynamic> json) {
    return Despesa(
      id: json['id'],
      descricao: json['descricao'] ?? '',
      valor: double.parse(json['valor'].toString()),
      categoria: json['categoria_nome'] ?? '',
    );
  }
}
