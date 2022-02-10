// To parse this JSON data, do
//
//     final ppoModel = ppoModelFromJson(jsonString);

import 'dart:convert';

PpoModel ppoModelFromJson(String str) => PpoModel.fromJson(json.decode(str));

String ppoModelToJson(PpoModel data) => json.encode(data.toJson());

class PpoModel {
  PpoModel({
    required this.alpha,
    required this.annualReturn,
    required this.annualVolatility,
    required this.beta,
    required this.calmarRatio,
    required this.cumulativeMeanMonthlyReturn,
    required this.cumulativeReturns,
    required this.dailyValueAtRisk,
    required this.kurtosis,
    required this.maxDrawdown,
    required this.omegaRatio,
    required this.sharpeRatio,
    required this.skew,
    required this.sortinoRatio,
    required this.stability,
    required this.suggestedAllocation,
    required this.tailRatio,
  });

  final num alpha;
  final num annualReturn;
  final num annualVolatility;
  final num beta;
  final num calmarRatio;
  final Map<String, double> cumulativeMeanMonthlyReturn;
  final num cumulativeReturns;
  final num dailyValueAtRisk;
  final num kurtosis;
  final num maxDrawdown;
  final num omegaRatio;
  final num sharpeRatio;
  final num skew;
  final num sortinoRatio;
  final num stability;
  final List<Map<String, double>> suggestedAllocation;
  final num tailRatio;

  factory PpoModel.fromJson(Map<String, dynamic> json) => PpoModel(
        alpha: json["Alpha"],
        annualReturn: json["Annual return"].toDouble(),
        annualVolatility: json["Annual volatility"].toDouble(),
        beta: json["Beta"],
        calmarRatio: json["Calmar ratio"].toDouble(),
        cumulativeMeanMonthlyReturn:
            Map.from(json["Cumulative Mean Monthly Return"])
                .map((k, v) => MapEntry<String, double>(k, v.toDouble())),
        cumulativeReturns: json["Cumulative returns"].toDouble(),
        dailyValueAtRisk: json["Daily value at risk"].toDouble(),
        kurtosis: json["Kurtosis"].toDouble(),
        maxDrawdown: json["Max drawdown"].toDouble(),
        omegaRatio: json["Omega ratio"].toDouble(),
        sharpeRatio: json["Sharpe ratio"].toDouble(),
        skew: json["Skew"].toDouble(),
        sortinoRatio: json["Sortino ratio"].toDouble(),
        stability: json["Stability"].toDouble(),
        suggestedAllocation: List<Map<String, double>>.from(
            json["Suggested Allocation"].map((x) => Map.from(x)
                .map((k, v) => MapEntry<String, double>(k, v.toDouble())))),
        tailRatio: json["Tail ratio"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "Alpha": alpha,
        "Annual return": annualReturn,
        "Annual volatility": annualVolatility,
        "Beta": beta,
        "Calmar ratio": calmarRatio,
        "Cumulative Mean Monthly Return": Map.from(cumulativeMeanMonthlyReturn)
            .map((k, v) => MapEntry<String, dynamic>(k, v)),
        "Cumulative returns": cumulativeReturns,
        "Daily value at risk": dailyValueAtRisk,
        "Kurtosis": kurtosis,
        "Max drawdown": maxDrawdown,
        "Omega ratio": omegaRatio,
        "Sharpe ratio": sharpeRatio,
        "Skew": skew,
        "Sortino ratio": sortinoRatio,
        "Stability": stability,
        "Suggested Allocation": List<dynamic>.from(suggestedAllocation.map(
            (x) => Map.from(x).map((k, v) => MapEntry<String, dynamic>(k, v)))),
        "Tail ratio": tailRatio,
      };
}
