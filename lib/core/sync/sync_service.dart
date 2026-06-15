import 'package:connectivity_plus/connectivity_plus.dart';

import '../api/dio_client.dart';
import '../utils/constants.dart';
import 'sync_queue.dart';
import 'sync_action.dart';

class SyncService {
  static Future<void> start() async {
    Connectivity().onConnectivityChanged.listen((status) {
      if (!status.contains(ConnectivityResult.none)) {
        sync();
      }
    });
  }

  static Future<void> sync() async {
    final queue = await SyncQueue.getQueue();

    if (queue.isEmpty) return;

    for (final action in queue) {
      try {
        switch (action.type) {
          case SyncActionType.createDespesa:
            await DioClient.dio.post(
              AppConstants.despesas,
              data: action.payload,
            );
            break;
        }
      } catch (_) {
        // se falhar, mantém na queue
        return;
      }
    }

    await SyncQueue.clear();
  }
}
