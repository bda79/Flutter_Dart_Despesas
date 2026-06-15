import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/request_manager.dart';
import 'despesas_model.dart';
import 'despesas_service.dart';

final despesasProvider =
    StateNotifierProvider<DespesasController, AsyncValue<List<Despesa>>>(
      (ref) => DespesasController(),
    );

class DespesasController extends StateNotifier<AsyncValue<List<Despesa>>> {
  final _service = DespesasService();

  DespesasController() : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    try {
      final data = await RequestManager.run(() => _service.getDespesas());

      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    final data = await RequestManager.run(
      () => _service.getDespesas(forceRefresh: true),
    );

    state = AsyncValue.data(data);
  }
}
