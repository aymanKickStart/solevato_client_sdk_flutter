// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'solevato_action.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SolevatoAction _$SolevatoActionFromJson(Map<String, dynamic> json) {
  return SolevatoAction(
    identifier: json['identifier'] as String,
    data: json['data'] == null
        ? null
        : SolevatoActionData.fromJson(json['data'] as Map<String, dynamic>),
    command: json['command'] as String,
  );
}

Map<String, dynamic> _$SolevatoActionToJson(SolevatoAction instance) =>
    <String, dynamic>{
      'identifier': instance.identifier,
      'command': instance.command,
      'data': instance.data?.toJson(),
    };
