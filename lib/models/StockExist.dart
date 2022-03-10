// To parse this JSON data, do
//
//     final stockExist = stockExistFromJson(jsonString);

import 'dart:convert';

StockExist stockExistFromJson(String str) =>
    StockExist.fromJson(json.decode(str));

String stockExistToJson(StockExist data) => json.encode(data.toJson());

class StockExist {
  StockExist({
    required this.exist,
  });

  final bool exist;

  factory StockExist.fromJson(Map<String, dynamic> json) => StockExist(
        exist: json["exist"],
      );

  Map<String, dynamic> toJson() => {
        "exist": exist,
      };
}
