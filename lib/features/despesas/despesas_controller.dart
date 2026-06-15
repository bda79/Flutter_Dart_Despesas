import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'despesas_model.dart';
import 'despesas_service.dart';

final despesasProvider =
    AsyncNotifierProvider<DespesasController, List<Despesa>>(
      DespesasController.new,
    );

class DespesasController extends AsyncNotifier<List<Despesa>> {
  final _service = DespesasService();

  @override
  Future<List<Despesa>> build() async {
    return await _service.getDespesas();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      return await _service.getDespesas();
    });
  }
}
