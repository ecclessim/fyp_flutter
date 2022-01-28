class WeightModel {
  String? ticker;
  num? totalAssetValue;

  WeightModel({
    this.ticker,
    this.totalAssetValue,
  });

  factory WeightModel.fromMap(map) {
    return WeightModel(
      ticker: map['ticker'],
      totalAssetValue: map['totalAssetValue'],
    );
  }
}
