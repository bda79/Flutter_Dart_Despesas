import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'categorias_model.dart';
import 'categorias_service.dart';

final categoriasProvider =
    StateNotifierProvider<CategoriasController, AsyncValue<List<Categoria>>>(
      (ref) => CategoriasController(),
    );

class CategoriasController extends StateNotifier<AsyncValue<List<Categoria>>> {
  final _service = CategoriasService();

  CategoriasController() : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    try {
      final data = await _service.getCategorias();

      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<Categoria> getOrCreateCategoria(String nome) async {
    final list = state.valueOrNull ?? [];

    // 1. se já existe, retorna
    final existente = list.where(
      (c) => c.nome.toLowerCase() == nome.toLowerCase(),
    );

    if (existente.isNotEmpty) {
      return existente.first;
    }

    // 2. se não existe, cria no backend
    final nova = await _service.createCategoria(nome);

    // 3. atualiza estado local
    state = AsyncValue.data([...list, nova]);

    return nova;
  }
}
