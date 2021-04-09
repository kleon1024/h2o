// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResponseBean _$ResponseBeanFromJson(Map<String, dynamic> json) {
  return ResponseBean(
    errorCode: json['errorCode'] as int,
    errorMessage: json['errorMessage'] as String,
    data: json['data'],
  );
}

Map<String, dynamic> _$ResponseBeanToJson(ResponseBean instance) =>
    <String, dynamic>{
      'errorCode': instance.errorCode,
      'errorMessage': instance.errorMessage,
      'data': instance.data,
    };
