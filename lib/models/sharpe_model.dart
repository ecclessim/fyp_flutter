class Sharpe {
  final num expAnnualReturn;
  final num expAnnualVolatility;
  final num expDollarReturn;
  final num principalLeftover;
  final num sharpeRatio;
  final List<SharpeWeight> sharpeWeights;
  final List<SharpeAllocation> sharpeAllocations;
  Sharpe(
      this.expAnnualReturn,
      this.expAnnualVolatility,
      this.expDollarReturn,
      this.principalLeftover,
      this.sharpeRatio,
      this.sharpeWeights,
      this.sharpeAllocations);

  factory Sharpe.fromJson(Map<String, dynamic> parsedJson) {
    var swList = parsedJson['Sharpe Weights'] as List;
    var saList = parsedJson['Suggested Allocation'] as List;
    print("${swList.runtimeType}, ${saList.runtimeType}");
    List<SharpeWeight> sharpeWeightList =
        swList.map((i) => SharpeWeight.fromJson(i)).toList();
    List<SharpeAllocation> sharpeAllocationList = saList.map((i) {
      return SharpeAllocation.fromJson(i);
    }).toList();
    return Sharpe(
        parsedJson['Expected Annual Return'],
        parsedJson['Expected Annual Volatility'],
        parsedJson['Expected Dollar Return'],
        parsedJson['Leftover(\$)'],
        parsedJson['Sharpe Ratio'],
        sharpeWeightList,
        sharpeAllocationList);
  }
}

class SharpeWeight {
  final String ticker;
  final num weight;
  SharpeWeight(this.ticker, this.weight);

  factory SharpeWeight.fromJson(Map<String, dynamic> parsedJson) {
    return SharpeWeight(parsedJson['ticker'], parsedJson['weight']);
  }
}

class SharpeAllocation {
  final String ticker;
  final num shares;
  SharpeAllocation(this.ticker, this.shares);

  factory SharpeAllocation.fromJson(Map<String, dynamic> parsedJson) {
    return SharpeAllocation(parsedJson['ticker'], parsedJson['shares']);
  }
}
