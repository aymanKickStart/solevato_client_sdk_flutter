// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'solevato_conversation.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SolevatoConversationAdapter extends TypeAdapter<SolevatoConversation> {
  @override
  final int typeId = 1;

  @override
  SolevatoConversation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SolevatoConversation(
      id: fields[0] as int,
      inboxId: fields[1] as int,
      messages: (fields[2] as List).cast<SolevatoMessage>(),
      contact: fields[3] as SolevatoContact,
    );
  }

  @override
  void write(BinaryWriter writer, SolevatoConversation obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.inboxId)
      ..writeByte(2)
      ..write(obj.messages)
      ..writeByte(3)
      ..write(obj.contact);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is SolevatoConversationAdapter &&
              runtimeType == other.runtimeType &&
              typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SolevatoConversation _$SolevatoConversationFromJson(Map<String, dynamic> json) {
  return SolevatoConversation(
    id: json['id'] as int,
    inboxId: json['inbox_id'] as int,
    messages: (json['messages'] as List<dynamic>)
        .map((e) => SolevatoMessage.fromJson(e as Map<String, dynamic>))
        .toList(),
    contact: SolevatoContact.fromJson(json['contact'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$SolevatoConversationToJson(
    SolevatoConversation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'inbox_id': instance.inboxId,
      'messages': instance.messages.map((e) => e.toJson()).toList(),
      'contact': instance.contact.toJson(),
    };
