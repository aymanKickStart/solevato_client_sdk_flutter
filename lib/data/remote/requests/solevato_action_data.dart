import 'package:json_annotation/json_annotation.dart';

part 'solevato_action_data.g.dart';

@JsonSerializable(explicitToJson: true)
class SolevatoActionData {
  @JsonKey(toJson: actionTypeToJson, fromJson: actionTypeFromJson)
  final SolevatoActionType action;

  SolevatoActionData({required this.action});

  factory SolevatoActionData.fromJson(Map<String, dynamic> json) =>
      _$SolevatoActionDataFromJson(json);

  Map<String, dynamic> toJson() => _$SolevatoActionDataToJson(this);
}

enum SolevatoActionType { subscribe, update_presence }

String actionTypeToJson(SolevatoActionType actionType) {
  switch (actionType) {
    case SolevatoActionType.update_presence:
      return "update_presence";
    case SolevatoActionType.subscribe:
      return "subscribe";
  }
}

SolevatoActionType actionTypeFromJson(String? value) {
  switch (value) {
    case "update_presence":
      return SolevatoActionType.update_presence;
    case "subscribe":
      return SolevatoActionType.subscribe;
    default:
      return SolevatoActionType.update_presence;
  }
}
