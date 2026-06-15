import 'package:flutter_app/core/utils/constants.dart';

import '../../core/api/dio_client.dart';
import 'despesas_model.dart';

class DespesasService {
  Future<List<Despesa>> getDespesas() async {
    final res = await DioClient.dio.get(AppConstants.despesas);

    final List data = res.data['results'];

    return data.map((e) => Despesa.fromJson(e)).toList();
  }
}
