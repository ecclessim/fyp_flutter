class PortfolioWeightHandler {
  List<Map<String, dynamic>> portfolio;
  PortfolioWeightHandler({required this.portfolio});
  String getWeights() {
    List<double> weights = [];
    String weightString = "";
    for (int i = 0; i < portfolio.length; i++) {
      weights.add(portfolio[i]['weight']);
    }
    weightString = weights.join(" ");
    return weightString;
  }

  String getTickers() {
    List<String> tickers = [];
    String tickerString = "";
    for (int i = 0; i < portfolio.length; i++) {
      tickers.add(portfolio[i]['ticker']);
    }
    // concat list tickers into one string
    tickerString = tickers.join(" ");
    return tickerString;
  }

  Map<String, double> getCombinedMap() {
    Map<String, double> combinedMap = {};
    for (int i = 0; i < portfolio.length; i++) {
      combinedMap[portfolio[i]['ticker']] = portfolio[i]['weight'];
    }
    return combinedMap;
  }
}
