// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TeamBean _$TeamBeanFromJson(Map<String, dynamic> json) {
  return TeamBean(
    uuid: json['uuid'] as String,
    name: json['name'] as String,
  );
}

Map<String, dynamic> _$TeamBeanToJson(TeamBean instance) => <String, dynamic>{
      'uuid': instance.uuid,
      'name': instance.name,
    };
