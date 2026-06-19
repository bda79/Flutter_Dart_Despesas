import 'package:flutter_app/features/despesas/despesas_model.dart';
import 'package:flutter_app/features/despesas/despesas_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final despesasServiceProvider = Provider<DespesasService>(
  (ref) => DespesasService(),
);

final despesasProvider =
    StateNotifierProvider<DespesasController, AsyncValue<List<Despesa>>>(
      (ref) => DespesasController(ref.watch(despesasServiceProvider)),
    );

class DespesasController extends StateNotifier<AsyncValue<List<Despesa>>> {
  final DespesasService _service;

  DespesasController(this._service) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    try {
      final data = await _service.getDespesas();

      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    try {
      final data = await _service.getDespesas(forceRefresh: true);

      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addDespesa({
    required String descricao,
    required double valor,
    required int categoriaId,
    required String categoriaNome,
    required String tipo,
    required DateTime data,
  }) async {
    final current = state.valueOrNull ?? [];

    final temp = Despesa(
      id: DateTime.now().millisecondsSinceEpoch,
      tipo: tipo,
      descricao: descricao,
      valor: valor,
      categoriaId: categoriaId,
      categoria: categoriaNome,
      data: data,
      isPending: true,
    );

    state = AsyncValue.data([...current, temp]);

    try {
      final created = await _service.createDespesa({
        "tipo": tipo,
        "descricao": descricao,
        "valor": valor,
        "categoria": categoriaId,
        "data": data.toIso8601String().split("T")[0],
      });

      final updated = (state.valueOrNull ?? [])
          .map((d) => d.id == temp.id ? created : d)
          .toList();

      state = AsyncValue.data(updated);
    } catch (_) {
      final rollback = (state.valueOrNull ?? [])
          .where((d) => d.id != temp.id)
          .toList();

      state = AsyncValue.data(rollback);
    }
  }
}
