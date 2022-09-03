import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:json_annotation/json_annotation.dart';

import '../local_storage.dart';

part 'solevato_user.g.dart';

///
@JsonSerializable(explicitToJson: true)
@HiveType(typeId: SOLEVATO_HIVE_TYPE_ID)
class SolevatoUser extends Equatable {
  ///custom solevato user identifier
  @JsonKey()
  @HiveField(0)
  final String? identifier;

  ///custom user identifier hash
  @JsonKey()
  @HiveField(1)
  final String? identifierHash;

  ///name of solevato user
  @JsonKey()
  @HiveField(2)
  final String? name;

  ///email of solevato user
  @JsonKey()
  @HiveField(3)
  final String? email;

  ///profile picture url of user
  @JsonKey(name: "avatar_url")
  @HiveField(4)
  final String? avatarUrl;

  ///any other custom attributes to be linked to the user
  @JsonKey(name: "custom_attributes")
  @HiveField(5)
  final dynamic customAttributes;

  SolevatoUser(
      {this.identifier,
      this.identifierHash,
      this.name,
      this.email,
      this.avatarUrl,
      this.customAttributes});

  @override
  List<Object?> get props =>
      [identifier, identifierHash, name, email, avatarUrl, customAttributes];

  factory SolevatoUser.fromJson(Map<String, dynamic> json) =>
      _$SolevatoUserFromJson(json);

  Map<String, dynamic> toJson() => _$SolevatoUserToJson(this);
}
