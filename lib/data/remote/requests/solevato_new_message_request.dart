import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'solevato_new_message_request.g.dart';

@JsonSerializable(explicitToJson: true)
class SolevatoNewMessageRequest extends Equatable {
  @JsonKey()
  final String content;
  @JsonKey(name: "echo_id")
  final String echoId;

  SolevatoNewMessageRequest({required this.content, required this.echoId});

  @override
  List<Object> get props => [content, echoId];

  factory SolevatoNewMessageRequest.fromJson(Map<String, dynamic> json) =>
      _$SolevatoNewMessageRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SolevatoNewMessageRequestToJson(this);
}
