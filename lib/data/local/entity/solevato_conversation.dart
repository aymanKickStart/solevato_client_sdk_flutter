import 'package:solevato_client_sdk_flutter/solevato_client_sdk_flutter.dart';
import 'package:solevato_client_sdk_flutter/data/local/entity/solevato_contact.dart';
import 'package:solevato_client_sdk_flutter/data/local/local_storage.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'solevato_conversation.g.dart';

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: SOLEVATO_CONVERSATION_HIVE_TYPE_ID)
class SolevatoConversation extends Equatable {
  ///The numeric ID of the conversation
  @JsonKey()
  @HiveField(0)
  final int id;

  ///The numeric ID of the inbox
  @JsonKey(name: "inbox_id")
  @HiveField(1)
  final int inboxId;

  ///List of all messages from the conversation
  @JsonKey()
  @HiveField(2)
  final List<SolevatoMessage> messages;

  ///Contact of the conversation
  @JsonKey()
  @HiveField(3)
  final SolevatoContact contact;

  SolevatoConversation({
    required this.id,
    required this.inboxId,
    required this.messages,
    required this.contact,
  });

  factory SolevatoConversation.fromJson(Map<String, dynamic> json) =>
      _$SolevatoConversationFromJson(json);

  Map<String, dynamic> toJson() => _$SolevatoConversationToJson(this);

  @override
  List<Object?> get props => [id, inboxId, messages, contact];
}
