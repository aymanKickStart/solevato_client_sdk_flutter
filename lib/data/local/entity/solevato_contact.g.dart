// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'solevato_contact.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SolevatoContactAdapter extends TypeAdapter<SolevatoContact> {
  @override
  final int typeId = 0;

  @override
  SolevatoContact read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SolevatoContact(
      id: fields[0] as int,
      contactIdentifier: fields[1] as String?,
      pubsubToken: fields[2] as String?,
      name: fields[3] as String,
      email: fields[4] as String,
      disableBranding: fields[5] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, SolevatoContact obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.contactIdentifier)
      ..writeByte(2)
      ..write(obj.pubsubToken)
      ..writeByte(3)
      ..write(obj.name)
      ..writeByte(4)
      ..write(obj.email)
      ..writeByte(5)
      ..write(obj.disableBranding);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is SolevatoContactAdapter &&
              runtimeType == other.runtimeType &&
              typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SolevatoContact _$SolevatoContactFromJson(Map<String, dynamic> json) {
  return SolevatoContact(
    id: json['id'] as int,
    contactIdentifier: json['source_id'] as String?,
    pubsubToken: json['pubsub_token'] as String?,
    name: json['name'] as String,
    email: json['email'] as String,
    disableBranding: json['disable_branding'] as bool?,
  );
}

Map<String, dynamic> _$SolevatoContactToJson(SolevatoContact instance) =>
    <String, dynamic>{
      'id': instance.id,
      'source_id': instance.contactIdentifier,
      'pubsub_token': instance.pubsubToken,
      'name': instance.name,
      'email': instance.email,
      'disable_branding': instance.disableBranding,
    };
