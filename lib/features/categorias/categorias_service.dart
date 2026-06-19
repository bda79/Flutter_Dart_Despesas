import 'package:flutter_app/core/api/dio_client.dart';
import 'package:flutter_app/core/network/paginated_response.dart';
import 'package:flutter_app/core/network/request_manager.dart';
import 'package:flutter_app/core/utils/constants.dart';
import 'package:flutter_app/features/categorias/categorias_model.dart';

class CategoriasService {
  Future<List<Categoria>> getCategorias() async {
    final response = await RequestManager.run(() async {
      final res = await DioClient.dio.get(AppConstants.categorias);

      return PaginatedResponse<Categoria>.fromJson(
        res.data,
        (json) => Categoria.fromJson(json),
      );
    });

    final categories = response.results;

    return categories;
  }

  Future<Categoria> createCategoria(String nome) async {
    return RequestManager.run(() async {
      final res = await DioClient.dio.post(
        AppConstants.categorias,
        data: {"nome": nome},
      );

      return Categoria.fromJson(res.data);
    });
  }
}
