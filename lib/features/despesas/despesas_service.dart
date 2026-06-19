import 'package:flutter_app/core/api/dio_client.dart';
import 'package:flutter_app/core/cache/hive_cache.dart';
import 'package:flutter_app/core/network/paginated_response.dart';
import 'package:flutter_app/core/network/request_manager.dart';
import 'package:flutter_app/core/sync/sync_action.dart';
import 'package:flutter_app/core/sync/sync_queue.dart';
import 'package:flutter_app/core/utils/constants.dart';
import 'package:flutter_app/features/despesas/despesas_model.dart';

class DespesasService {
  static const _cacheKey = "despesas";

  Future<List<Despesa>> getDespesas({bool forceRefresh = false}) async {
    // CACHE FIRST
    if (!forceRefresh) {
      final cached = await HiveCache.get<List>(_cacheKey);

      if (cached != null) {
        return cached
            .map((e) => Despesa.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    }

    final response = await RequestManager.run(() async {
      final res = await DioClient.dio.get(AppConstants.despesas);

      return PaginatedResponse<Despesa>.fromJson(
        res.data,
        (json) => Despesa.fromJson(json),
      );
    });

    final despesas = response.results;

    await HiveCache.set(_cacheKey, despesas.map((e) => e.toJson()).toList());

    return despesas;
  }

  Future<Despesa> createDespesa(Map<String, dynamic> data) async {
    final safeData = Map<String, dynamic>.from(data);

    safeData["data"] = (safeData["data"] is DateTime)
        ? (safeData["data"] as DateTime).toIso8601String().split("T")[0]
        : safeData["data"];
    try {
      return await RequestManager.run(() async {
        final res = await DioClient.dio.post(
          AppConstants.despesas,
          data: safeData,
        );

        return Despesa.fromJson(res.data);
      }, showLoading: false);
    } catch (e) {
      await SyncQueue.add(
        SyncAction(type: SyncActionType.createDespesa, payload: safeData),
      );

      rethrow;
    }
  }

  Future<Despesa> updateDespesa(int id, Map<String, dynamic> data) async {
    final safeData = Map<String, dynamic>.from(data);

    safeData["data"] = (safeData["data"] is DateTime)
        ? (safeData["data"] as DateTime).toIso8601String().split("T")[0]
        : safeData["data"];

    final res = await RequestManager.run(() async {
      final response = await DioClient.dio.put(
        '${AppConstants.despesas}$id/',
        data: safeData,
      );
      return Despesa.fromJson(response.data);
    }, showLoading: false);

    return res;
  }

  Future<void> deleteDespesa(int id) async {
    await RequestManager.run(() async {
      await DioClient.dio.delete('${AppConstants.despesas}$id/');
    }, showLoading: false);
  }
}
