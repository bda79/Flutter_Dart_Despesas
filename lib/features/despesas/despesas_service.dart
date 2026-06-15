import '../../core/api/dio_client.dart';
import '../../core/cache/simple_cache.dart';
import '../../core/network/paginated_response.dart';
import '../../core/utils/constants.dart';
import 'despesas_model.dart';

class DespesasService {
  static const _cacheKey = "despesas";

  Future<List<Despesa>> getDespesas({bool forceRefresh = false}) async {
    // 1. CACHE FIRST
    if (!forceRefresh) {
      final cached = SimpleCache.get<List<Despesa>>(_cacheKey);
      if (cached != null) {
        return cached;
      }
    }

    // 2. API CALL
    final res = await DioClient.dio.get(AppConstants.despesas);

    final response = PaginatedResponse<Despesa>.fromJson(
      res.data,
      (json) => Despesa.fromJson(json),
    );

    final despesas = response.results;

    // 3. SAVE CACHE
    SimpleCache.set(_cacheKey, despesas);

    return despesas;
  }
}
