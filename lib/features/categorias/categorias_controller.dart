import 'package:flutter_app/features/categorias/categorias_model.dart';
import 'package:flutter_app/features/categorias/categorias_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final categoriasServiceProvider = Provider<CategoriasService>(
  (ref) => CategoriasService(),
);

final categoriasProvider =
    StateNotifierProvider<CategoriasController, AsyncValue<List<Categoria>>>(
      (ref) => CategoriasController(ref.watch(categoriasServiceProvider)),
    );

class CategoriasController extends StateNotifier<AsyncValue<List<Categoria>>> {
  final CategoriasService _service;

  CategoriasController(this._service) : super(const AsyncValue.loading());

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

    final existente = list.where(
      (c) => c.nome.toLowerCase() == nome.toLowerCase(),
    );

    if (existente.isNotEmpty) {
      return existente.first;
    }

    final nova = await _service.createCategoria(nome);

    state = AsyncValue.data([...list, nova]);

    return nova;
  }
}
