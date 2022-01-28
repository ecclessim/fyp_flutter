class StockModel {
  String? ticker;
  num? noOfShares;
  num? purchasePrice;
  String? purchaseDate;
  num? totalValue;

  StockModel({
    this.ticker,
    this.noOfShares,
    this.purchasePrice,
    this.purchaseDate,
    this.totalValue,
  });

  factory StockModel.fromMap(map) {
    return StockModel(
      ticker: map['ticker'],
      noOfShares: map['noOfShares'],
      purchasePrice: map['purchasePrice'],
      purchaseDate: map['purchaseDate'],
      totalValue: map['totalValue'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ticker': ticker,
      'noOfShares': noOfShares,
      'purchasePrice': purchasePrice,
      'purchaseDate': purchaseDate,
      'totalValue':
          double.parse((noOfShares! * purchasePrice!).toStringAsFixed(2)),
    };
  }
}
