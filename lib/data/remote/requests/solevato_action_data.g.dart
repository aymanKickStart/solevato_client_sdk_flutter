// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'solevato_action_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SolevatoActionData _$SolevatoActionDataFromJson(Map<String, dynamic> json) {
  return SolevatoActionData(
    action: actionTypeFromJson(json['action'] as String?),
  );
}

Map<String, dynamic> _$SolevatoActionDataToJson(SolevatoActionData instance) =>
    <String, dynamic>{
      'action': actionTypeToJson(instance.action),
    };
