class Sortino {
  final num expAnnualReturn;
  final num expAnnualVolatility;
  final num expDollarReturn;
  final num principalLeftover;
  final num sortinoRatio;
  final List<SortinoWeight> sortinoWeights;
  final List<SortinoAllocation> sortinoAllocations;
  Sortino(
      this.expAnnualReturn,
      this.expAnnualVolatility,
      this.expDollarReturn,
      this.principalLeftover,
      this.sortinoRatio,
      this.sortinoWeights,
      this.sortinoAllocations);

  factory Sortino.fromJson(Map<String, dynamic> parsedJson) {
    var swList = parsedJson['Sortino Weights'] as List;
    var saList = parsedJson['Suggested Allocation'] as List;
    print("${swList.runtimeType}, ${saList.runtimeType}");
    List<SortinoWeight> sortinoWeightList =
        swList.map((i) => SortinoWeight.fromJson(i)).toList();
    List<SortinoAllocation> sortinoAllocationList = saList.map((i) {
      return SortinoAllocation.fromJson(i);
    }).toList();
    return Sortino(
        parsedJson['Expected Annual Return'],
        parsedJson['Expected Annual Volatility'],
        parsedJson['Expected Dollar Return'],
        parsedJson['Leftover(\$)'],
        parsedJson['Sortino Ratio'],
        sortinoWeightList,
        sortinoAllocationList);
  }
}

class SortinoWeight {
  final String ticker;
  final num weight;
  SortinoWeight(this.ticker, this.weight);

  factory SortinoWeight.fromJson(Map<String, dynamic> parsedJson) {
    return SortinoWeight(parsedJson['ticker'], parsedJson['weight']);
  }
}

class SortinoAllocation {
  final String ticker;
  final num shares;
  SortinoAllocation(this.ticker, this.shares);

  factory SortinoAllocation.fromJson(Map<String, dynamic> parsedJson) {
    return SortinoAllocation(parsedJson['ticker'], parsedJson['shares']);
  }
}
