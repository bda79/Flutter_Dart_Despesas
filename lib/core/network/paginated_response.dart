class PaginatedResponse<T> {
  final List<T> results;
  final int? count;
  final String? next;
  final String? previous;

  PaginatedResponse({
    required this.results,
    this.count,
    this.next,
    this.previous,
  });

  // converte resposta API (lista OU paginado)
  factory PaginatedResponse.fromJson(
    dynamic json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    // API devolve LISTA direta
    if (json is List) {
      return PaginatedResponse(results: json.map((e) => fromJson(e)).toList());
    }

    // Django pagination
    if (json is Map<String, dynamic>) {
      final List list = json['results'] ?? [];

      return PaginatedResponse(
        results: list.map((e) => fromJson(e)).toList(),
        count: json['count'],
        next: json['next'],
        previous: json['previous'],
      );
    }

    // fallback seguro
    return PaginatedResponse(results: []);
  }
}
