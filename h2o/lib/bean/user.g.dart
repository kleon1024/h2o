// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserBean _$UserBeanFromJson(Map<String, dynamic> json) {
  return UserBean(
    id: json['id'] as String,
    name: json['name'] as String,
    accessToken:
        TokenBean.fromJson(json['accessToken'] as Map<String, dynamic>),
    refreshToken:
        TokenBean.fromJson(json['refreshToken'] as Map<String, dynamic>),
    teams: (json['teams'] as List<dynamic>?)
        ?.map((e) => TeamBean.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$UserBeanToJson(UserBean instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
      'teams': instance.teams,
    };
