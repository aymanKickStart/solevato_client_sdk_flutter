// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'solevato_new_message_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SolevatoNewMessageRequest _$SolevatoNewMessageRequestFromJson(
    Map<String, dynamic> json) {
  return SolevatoNewMessageRequest(
    content: json['content'] as String,
    echoId: json['echo_id'] as String,
  );
}

Map<String, dynamic> _$SolevatoNewMessageRequestToJson(
        SolevatoNewMessageRequest instance) =>
    <String, dynamic>{
      'content': instance.content,
      'echo_id': instance.echoId,
    };
