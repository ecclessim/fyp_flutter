class PortfolioModel {
  String? portfolioName;
  num? portfolioValue;
  String? createdDate;
  PortfolioModel({
    this.portfolioName,
    this.portfolioValue,
    this.createdDate,
  });

  factory PortfolioModel.fromMap(map) {
    return PortfolioModel(
      portfolioName: map['portfolioName'],
      portfolioValue: map['portfolioValue'],
      createdDate: map['createdDate'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'portfolioName': portfolioName,
      'portfolioValue': portfolioValue,
      'createdDate': createdDate,
    };
  }
}
