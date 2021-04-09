// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TokenBean _$TokenBeanFromJson(Map<String, dynamic> json) {
  return TokenBean(
    token: json['token'] as String,
    expiresAt: json['expiresAt'] as String,
  );
}

Map<String, dynamic> _$TokenBeanToJson(TokenBean instance) => <String, dynamic>{
      'token': instance.token,
      'expiresAt': instance.expiresAt,
    };
