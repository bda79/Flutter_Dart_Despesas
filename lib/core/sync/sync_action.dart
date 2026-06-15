enum SyncActionType { createDespesa }

class SyncAction {
  final SyncActionType type;
  final Map<String, dynamic> payload;

  SyncAction({required this.type, required this.payload});

  Map<String, dynamic> toJson() => {"type": type.name, "payload": payload};

  factory SyncAction.fromJson(Map json) {
    return SyncAction(
      type: SyncActionType.values.firstWhere((e) => e.name == json["type"]),
      payload: Map<String, dynamic>.from(json["payload"]),
    );
  }
}
