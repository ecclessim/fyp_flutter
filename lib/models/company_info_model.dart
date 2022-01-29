class CompanyInfo {
  final String logoUrl;
  final String companyName;
  final String country;
  final String sector;
  final String longSummary;
  final String ticker;
  final num currentPrice;
  final num open;
  final num previousClose;
  final num weekChange52;
  final num volume;
  final num avgVolume;
  final num marketCap;
  final num sharesOutst;
  final num forwardPE;
  final num? divYield;
  final num? yield;

  CompanyInfo({
    required this.logoUrl,
    required this.companyName,
    required this.country,
    required this.sector,
    required this.longSummary,
    required this.ticker,
    required this.currentPrice,
    required this.open,
    required this.previousClose,
    required this.weekChange52,
    required this.volume,
    required this.avgVolume,
    required this.marketCap,
    required this.sharesOutst,
    required this.forwardPE,
    this.divYield,
    this.yield,
  });

  factory CompanyInfo.fromJson(Map<String, dynamic> json) {
    return CompanyInfo(
      logoUrl: json['logo_url'],
      companyName: json['companyName'],
      country: json['country'],
      sector: json['sector'],
      longSummary: json['longSummary'],
      ticker: json['ticker'],
      currentPrice: json['currentPrice'],
      open: json['open'],
      previousClose: json['previousClose'],
      weekChange52: json['52WeekChange'],
      volume: json['volume'],
      avgVolume: json['avgVolume'],
      marketCap: json['mktCap'],
      sharesOutst: json['sharesOutst'],
      forwardPE: json['forwardPE'],
      divYield: json['divYield'],
      yield: json['yield'],
    );
  }
}
