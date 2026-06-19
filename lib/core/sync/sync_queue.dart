import 'package:flutter_app/core/cache/hive_cache.dart';
import 'package:flutter_app/core/sync/sync_action.dart';

class SyncQueue {
  static const _key = "sync_queue";

  static Future<List<SyncAction>> getQueue() async {
    final list = await HiveCache.get<List>(_key) ?? [];
    return list.map((e) => SyncAction.fromJson(e)).toList();
  }

  static Future<void> add(SyncAction action) async {
    final queue = await getQueue();
    queue.add(action);

    await HiveCache.set(_key, queue.map((e) => e.toJson()).toList());
  }

  static Future<void> clear() async {
    await HiveCache.delete(_key);
  }
}
