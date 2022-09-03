import 'package:json_annotation/json_annotation.dart';

import 'solevato_action_data.dart';

part 'solevato_action.g.dart';

@JsonSerializable(explicitToJson: true)
class SolevatoAction {
  @JsonKey()
  final String identifier;

  @JsonKey()
  final String command;

  @JsonKey()
  final SolevatoActionData? data;

  SolevatoAction({required this.identifier, this.data, required this.command});

  factory SolevatoAction.fromJson(Map<String, dynamic> json) =>
      _$SolevatoActionFromJson(json);

  Map<String, dynamic> toJson() => _$SolevatoActionToJson(this);
}
