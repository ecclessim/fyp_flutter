class MinVol {
  final num expAnnualReturn;
  final num expAnnualVolatility;
  final num expDollarReturn;
  final num principalLeftover;
  final num sharpeRatio;
  final List<MinVolWeight> minVolWeights;
  final List<MinVolAllocation> minVolAllocations;
  MinVol(
      this.expAnnualReturn,
      this.expAnnualVolatility,
      this.expDollarReturn,
      this.principalLeftover,
      this.sharpeRatio,
      this.minVolWeights,
      this.minVolAllocations);

  factory MinVol.fromJson(Map<String, dynamic> parsedJson) {
    var swList = parsedJson['Minimum Volatility Weights'] as List;
    var saList = parsedJson['Suggested Allocation'] as List;
    print("${swList.runtimeType}, ${saList.runtimeType}");
    List<MinVolWeight> minVolWeightList =
        swList.map((i) => MinVolWeight.fromJson(i)).toList();
    List<MinVolAllocation> minVolAllocationList = saList.map((i) {
      return MinVolAllocation.fromJson(i);
    }).toList();
    return MinVol(
        parsedJson['Expected Annual Return'],
        parsedJson['Expected Annual Volatility'],
        parsedJson['Expected Dollar Return'],
        parsedJson['Leftover(\$)'],
        parsedJson['Sharpe Ratio'],
        minVolWeightList,
        minVolAllocationList);
  }
}

class MinVolWeight {
  final String ticker;
  final num weight;
  MinVolWeight(this.ticker, this.weight);

  factory MinVolWeight.fromJson(Map<String, dynamic> parsedJson) {
    return MinVolWeight(parsedJson['ticker'], parsedJson['weight']);
  }
}

class MinVolAllocation {
  final String ticker;
  final num shares;
  MinVolAllocation(this.ticker, this.shares);

  factory MinVolAllocation.fromJson(Map<String, dynamic> parsedJson) {
    return MinVolAllocation(parsedJson['ticker'], parsedJson['shares']);
  }
}
