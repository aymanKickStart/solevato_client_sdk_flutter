import 'package:solevato_client_sdk_flutter/solevato_client_sdk_flutter.dart';
import 'package:solevato_client_sdk_flutter/data/local/local_storage.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'solevato_event.g.dart';

@JsonSerializable(explicitToJson: true)
class SolevatoEvent {
  @JsonKey(toJson: eventTypeToJson, fromJson: eventTypeFromJson)
  final SolevatoEventType? type;

  @JsonKey()
  final String? identifier;

  @JsonKey(fromJson: eventMessageFromJson)
  final SolevatoEventMessage? message;

  SolevatoEvent({this.type, this.message, this.identifier});

  factory SolevatoEvent.fromJson(Map<String, dynamic> json) =>
      _$SolevatoEventFromJson(json);

  Map<String, dynamic> toJson() => SolevatoEventToJson(this);
}

SolevatoEventMessage? eventMessageFromJson(value) {
  if (value == null) {
    return null;
  } else if (value is num) {
    return SolevatoEventMessage();
  } else if (value is String) {
    return SolevatoEventMessage();
  } else {
    return SolevatoEventMessage.fromJson(value as Map<String, dynamic>);
  }
}

@JsonSerializable(explicitToJson: true)
class SolevatoEventMessage {
  @JsonKey()
  final SolevatoEventMessageData? data;

  @JsonKey(toJson: eventMessageTypeToJson, fromJson: eventMessageTypeFromJson)
  final SolevatoEventMessageType? event;

  SolevatoEventMessage({this.data, this.event});

  factory SolevatoEventMessage.fromJson(Map<String, dynamic> json) =>
      _$SolevatoEventMessageFromJson(json);

  Map<String, dynamic> toJson() => _$SolevatoEventMessageToJson(this);
}

@JsonSerializable(explicitToJson: true)
class SolevatoEventMessageData {
  @JsonKey(name: "account_id")
  final int? accountId;

  @JsonKey()
  final String? content;

  @JsonKey(name: "content_attributes")
  final dynamic contentAttributes;

  @JsonKey(name: "content_type")
  final String? contentType;

  @JsonKey(name: "conversation_id")
  final int? conversationId;

  @JsonKey(name: "created_at")
  final dynamic createdAt;

  @JsonKey(name: "echo_id")
  final String? echoId;

  @JsonKey(name: "external_source_ids")
  final dynamic externalSourceIds;

  @JsonKey()
  final int? id;

  @JsonKey(name: "inbox_id")
  final int? inboxId;

  @JsonKey(name: "message_type")
  final int? messageType;

  @JsonKey(name: "private")
  final bool? private;

  @JsonKey()
  final SolevatoEventMessageUser? sender;

  @JsonKey(name: "sender_id")
  final int? senderId;

  @JsonKey(name: "source_id")
  final String? sourceId;

  @JsonKey()
  final String? status;

  @JsonKey(name: "updated_at")
  final dynamic updatedAt;

  @JsonKey()
  final dynamic conversation;

  @JsonKey()
  final SolevatoEventMessageUser? user;

  @JsonKey()
  final dynamic users;

  SolevatoEventMessageData(
      {this.id,
      this.user,
      this.conversation,
      this.echoId,
      this.sender,
      this.conversationId,
      this.createdAt,
      this.contentAttributes,
      this.contentType,
      this.messageType,
      this.content,
      this.inboxId,
      this.sourceId,
      this.updatedAt,
      this.status,
      this.accountId,
      this.externalSourceIds,
      this.private,
      this.senderId,
      this.users});

  factory SolevatoEventMessageData.fromJson(Map<String, dynamic> json) =>
      _$SolevatoEventMessageDataFromJson(json);

  Map<String, dynamic> toJson() => _$SolevatoEventMessageDataToJson(this);

  getMessage() {
    return SolevatoMessage.fromJson(toJson());
  }
}

/// {@category FlutterClientSdk}
@HiveType(typeId: SOLEVATO_EVENT_USER_HIVE_TYPE_ID)
@JsonSerializable(explicitToJson: true)
class SolevatoEventMessageUser extends Equatable {
  @JsonKey(name: "avatar_url")
  @HiveField(0)
  final String? avatarUrl;

  @JsonKey()
  @HiveField(1)
  final int? id;

  @JsonKey()
  @HiveField(2)
  final String? name;

  @JsonKey()
  @HiveField(3)
  final String? thumbnail;

  SolevatoEventMessageUser(
      {this.id, this.avatarUrl, this.name, this.thumbnail});

  factory SolevatoEventMessageUser.fromJson(Map<String, dynamic> json) =>
      _$SolevatoEventMessageUserFromJson(json);

  Map<String, dynamic> toJson() => _$SolevatoEventMessageUserToJson(this);

  @override
  List<Object?> get props => [id, avatarUrl, name, thumbnail];
}

enum SolevatoEventType { welcome, ping, confirm_subscription }

String? eventTypeToJson(SolevatoEventType? actionType) {
  return actionType.toString();
}

SolevatoEventType? eventTypeFromJson(String? value) {
  switch (value) {
    case "welcome":
      return SolevatoEventType.welcome;
    case "ping":
      return SolevatoEventType.ping;
    case "confirm_subscription":
      return SolevatoEventType.confirm_subscription;
    default:
      return null;
  }
}

enum SolevatoEventMessageType {
  presence_update,
  message_created,
  message_updated,
  conversation_typing_off,
  conversation_typing_on,
  conversation_status_changed
}

String? eventMessageTypeToJson(SolevatoEventMessageType? actionType) {
  switch (actionType) {
    case null:
      return null;
    case SolevatoEventMessageType.conversation_typing_on:
      return "conversation.typing_on";
    case SolevatoEventMessageType.conversation_typing_off:
      return "conversation.typing_off";
    case SolevatoEventMessageType.presence_update:
      return "presence.update";
    case SolevatoEventMessageType.message_created:
      return "message.created";
    case SolevatoEventMessageType.message_updated:
      return "message.updated";
    case SolevatoEventMessageType.conversation_status_changed:
      return "conversation.status_changed";
    default:
      return actionType.toString();
  }
}

SolevatoEventMessageType? eventMessageTypeFromJson(String? value) {
  switch (value) {
    case "presence.update":
      return SolevatoEventMessageType.presence_update;
    case "message.created":
      return SolevatoEventMessageType.message_created;
    case "message.updated":
      return SolevatoEventMessageType.message_updated;
    case "conversation.typing_on":
      return SolevatoEventMessageType.conversation_typing_on;
    case "conversation.typing_off":
      return SolevatoEventMessageType.conversation_typing_off;
    case "conversation.status_changed":
      return SolevatoEventMessageType.conversation_status_changed;
    default:
      return null;
  }
}
