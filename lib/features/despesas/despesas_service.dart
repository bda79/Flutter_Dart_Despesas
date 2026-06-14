import '../../core/api/dio_client.dart';
import '../../core/utils/constants.dart';

class DespesasService {
  Future<List<dynamic>> getDespesas() async {
    final response = await DioClient.dio.get(AppConstants.despesas);

    return response.data;
  }
}
