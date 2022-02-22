// To parse this JSON data, do
//
//     final simpleReturn = simpleReturnFromJson(jsonString);

import 'dart:convert';

SimpleReturn simpleReturnFromJson(String str) =>
    SimpleReturn.fromJson(json.decode(str));

String simpleReturnToJson(SimpleReturn data) => json.encode(data.toJson());

class SimpleReturn {
  SimpleReturn({
    required this.cumulativeReturn,
    required this.portfolioVariance,
    required this.portfolioVolatility,
    required this.simpleAnnualReturn,
    required this.simpleDollarReturn,
  });

  final double cumulativeReturn;
  final double portfolioVariance;
  final double portfolioVolatility;
  final double simpleAnnualReturn;
  final double simpleDollarReturn;

  factory SimpleReturn.fromJson(Map<String, dynamic> json) => SimpleReturn(
        cumulativeReturn: json["cumulative return"].toDouble(),
        portfolioVariance: json["portfolio variance"].toDouble(),
        portfolioVolatility: json["portfolio volatility"].toDouble(),
        simpleAnnualReturn: json["simple annual return"].toDouble(),
        simpleDollarReturn: json["simple dollar return"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "cumulative return": cumulativeReturn,
        "portfolio variance": portfolioVariance,
        "portfolio volatility": portfolioVolatility,
        "simple annual return": simpleAnnualReturn,
        "simple dollar return": simpleDollarReturn,
      };
}
