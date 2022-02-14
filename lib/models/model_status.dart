// To parse this JSON data, do
//
//     final modelStatus = modelStatusFromJson(jsonString);

import 'dart:convert';

ModelStatus modelStatusFromJson(String str) =>
    ModelStatus.fromJson(json.decode(str));

String modelStatusToJson(ModelStatus data) => json.encode(data.toJson());

class ModelStatus {
  ModelStatus({
    required this.status,
  });

  final String status;

  factory ModelStatus.fromJson(Map<String, dynamic> json) => ModelStatus(
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
      };
}
