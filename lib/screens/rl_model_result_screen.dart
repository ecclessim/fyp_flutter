// import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fyp_flutter/helper_screen/helper_methods.dart';
import 'package:fyp_flutter/models/ppo_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class Allocation {
  final String ticker;
  final double weight;
  Allocation(this.ticker, this.weight);
}

class CumulativeReturns {
  final DateTime date;
  final num cumReturn;
  CumulativeReturns(this.date, this.cumReturn);
}

class RlResultsScreen extends StatefulWidget {
  final results;
  final portfolioName;
  final portfolioValue;
  RlResultsScreen({this.results, this.portfolioName, this.portfolioValue});
  @override
  _RlResultsScreenState createState() => _RlResultsScreenState();
}

class _RlResultsScreenState extends State<RlResultsScreen> {
  bool metricDescFlag = false;
  PpoModel? decodedResults;
  Map<String, double>? cumulativeReturns;
  List<CumulativeReturns>? cumulativeReturnsList;
  List<charts.Series<dynamic, DateTime>>? seriesList;
  Map<String, double> retrievedAllocationMap = {'Loading': 0.0};
  List<Allocation>? allocations;
  String portfolioValueString = "";
  @override
  void initState() {
    super.initState();
    processResults();
  }

  String _percentify(double value) {
    return "${(value * 100).toStringAsFixed(2)}%";
  }

  List<charts.Series<CumulativeReturns, DateTime>> _generateReturnsSeries() {
    return [
      new charts.Series<CumulativeReturns, DateTime>(
        id: 'Returns',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (CumulativeReturns cumulativeReturn, _) =>
            cumulativeReturn.date,
        measureFn: (CumulativeReturns cumulativeReturn, _) =>
            cumulativeReturn.cumReturn,
        data: cumulativeReturnsList!,
      )
    ];
  }

  _projectionListTile(String leading, String trailing, String metricDescription,
      bool visibilityController) {
    return ListTile(
      visualDensity: VisualDensity.compact,
      dense: true,
      title: Text(
        "$leading",
        style: GoogleFonts.roboto(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Visibility(
          visible: visibilityController,
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: Text(
              metricDescription,
              textAlign: TextAlign.left,
              style: GoogleFonts.roboto(
                fontSize: 15,
                color: Colors.blueAccent,
              ),
            ),
          )),
      trailing: Text(
        "$trailing",
        style: GoogleFonts.roboto(
          color: Colors.blueAccent,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  _customVisibilityDivider(bool visibilityController) {
    return Visibility(
      visible: visibilityController,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Divider(color: Colors.black38, thickness: 1, height: 0),
      ),
    );
  }

  processResults() {
    final ppoModel = ppoModelFromJson(widget.results);
    setState(() {
      portfolioValueString =
          HelperMethods.numberCommafy(widget.portfolioValue.toString());
      decodedResults = ppoModel;
      cumulativeReturns = ppoModel.cumulativeMeanMonthlyReturn;
      retrievedAllocationMap = ppoModel.suggestedAllocation[0];
      allocations = retrievedAllocationMap.entries
          .map((e) => Allocation(e.key, e.value))
          .toList();
      allocations?.sort((a, b) => b.weight.compareTo(a.weight));
      cumulativeReturnsList = ppoModel.cumulativeMeanMonthlyReturn.entries
          .map((e) => CumulativeReturns(
              DateTime.fromMillisecondsSinceEpoch(int.parse(e.key)),
              (e.value) * 100))
          .toList();
      seriesList = _generateReturnsSeries();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black54,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
        title: Column(
          children: [
            Text(
              "${widget.portfolioName}",
              style: GoogleFonts.roboto(
                textStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              "Showing projected results.",
              style: GoogleFonts.roboto(fontSize: 16),
            )
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 50,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 30, right: 30),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    child: RichText(
                      textAlign: TextAlign.justify,
                      text: TextSpan(
                          text: "With a principal of",
                          style: GoogleFonts.roboto(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                          children: [
                            TextSpan(
                                text: " \$$portfolioValueString",
                                style: GoogleFonts.roboto(
                                  fontSize: 18,
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold,
                                )),
                            TextSpan(
                              text:
                                  " and the included assets, the portfolio agent recommends the following portfolio allocation",
                              style: GoogleFonts.roboto(
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              text: " given the latest portfolio information.",
                              style: GoogleFonts.roboto(
                                fontSize: 18,
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ]),
                    ),
                  ),
                ),
                SizedBox(height: 40),
                PieChart(
                  dataMap: retrievedAllocationMap,
                  animationDuration: Duration(milliseconds: 800),
                  chartRadius: MediaQuery.of(context).size.width * 0.6,
                  initialAngleInDegree: 0,
                  legendOptions: LegendOptions(
                    showLegendsInRow: true,
                    legendPosition: LegendPosition.bottom,
                    showLegends: true,
                    legendTextStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                //Text title "In Detail"
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 30, right: 30),
                    child: Text("Asset Weights:",
                        textAlign: TextAlign.left,
                        style: GoogleFonts.roboto(
                          color: Colors.blueAccent,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                        )),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: allocations?.length,
                      itemBuilder: (context, index) {
                        return Card(
                          // color: Color(0xFFeef7ff),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 3,
                          child: ListTile(
                            dense: true,
                            leading: Text(
                              "${allocations![index].ticker}",
                              style: GoogleFonts.roboto(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            trailing: Container(
                              width: 80,
                              child: Text(
                                "${_percentify(allocations![index].weight)}",
                                textAlign: TextAlign.right,
                                style: GoogleFonts.roboto(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 30, right: 30),
                    child: Text("Cumulative Returns:",
                        textAlign: TextAlign.left,
                        style: GoogleFonts.roboto(
                          color: Colors.blueAccent,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                        )),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  height: 350,
                  width: MediaQuery.of(context).size.width,
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: charts.TimeSeriesChart(
                      seriesList!,
                      animate: false,
                      behaviors: [
                        new charts.ChartTitle('Time',
                            behaviorPosition: charts.BehaviorPosition.bottom,
                            titleStyleSpec: charts.TextStyleSpec(
                                fontSize: 12,
                                color: charts.MaterialPalette.black),
                            titleOutsideJustification:
                                charts.OutsideJustification.middleDrawArea),
                        new charts.ChartTitle('Returns (%)',
                            behaviorPosition: charts.BehaviorPosition.start,
                            titleStyleSpec: charts.TextStyleSpec(
                                fontSize: 12,
                                color: charts.MaterialPalette.black),
                            titleOutsideJustification:
                                charts.OutsideJustification.middleDrawArea)
                      ],
                      primaryMeasureAxis: charts.NumericAxisSpec(
                        tickProviderSpec: charts.BasicNumericTickProviderSpec(
                            zeroBound: false),
                      ),
                      domainAxis: charts.DateTimeAxisSpec(
                        tickProviderSpec:
                            charts.DayTickProviderSpec(increments: [500]),
                        renderSpec: charts.SmallTickRendererSpec(
                          labelStyle: charts.TextStyleSpec(
                            fontSize: 10,
                            color: charts.MaterialPalette.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: ListTile(
                        leading: Text("Projections:",
                            textAlign: TextAlign.left,
                            style: GoogleFonts.roboto(
                              fontSize: 32,
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.w900,
                            )),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.info_outline_rounded,
                            color: Colors.blueAccent,
                          ),
                          onPressed: () {
                            setState(() {
                              metricDescFlag = !metricDescFlag;
                            });
                          },
                        )),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  child: Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(children: <Widget>[
                              _projectionListTile(
                                  "Expected Annual Return",
                                  _percentify(
                                      decodedResults!.annualReturn.toDouble()),
                                  "The expected return is the profit or loss that an investor anticipates on an investment",
                                  metricDescFlag),
                              _customVisibilityDivider(metricDescFlag),
                              _projectionListTile(
                                  "Expected Annual Volatility",
                                  _percentify(decodedResults!.annualVolatility
                                      .toDouble()),
                                  "Standard deviation of the portfolio's daily arithmetic returns for a one year period.",
                                  metricDescFlag),
                              _customVisibilityDivider(metricDescFlag),
                              _projectionListTile(
                                  "Alpha",
                                  _percentify(decodedResults!.alpha.toDouble()),
                                  "Excess returns earned on an investment above the benchmark return.",
                                  metricDescFlag),
                              _customVisibilityDivider(metricDescFlag),
                              _projectionListTile(
                                  "Beta",
                                  _percentify(decodedResults!.beta.toDouble()),
                                  "Beta is a concept that measures the expected move in a stock relative to movements in the overall market.",
                                  metricDescFlag),
                              _customVisibilityDivider(metricDescFlag),
                              _projectionListTile(
                                  "Cumulative Returns",
                                  _percentify(decodedResults!.cumulativeReturns
                                      .toDouble()),
                                  "The cumulative return is the total change in the investment price over a set time",
                                  metricDescFlag),
                              _customVisibilityDivider(metricDescFlag),
                              _projectionListTile(
                                  "Daily Value at Risk",
                                  _percentify(decodedResults!.dailyValueAtRisk
                                      .toDouble()),
                                  "The maximum loss expected (or worst case scenario) on an investment, over a given time period and given a specified degree of confidence",
                                  metricDescFlag),
                              _customVisibilityDivider(metricDescFlag),
                              _projectionListTile(
                                  "Kurtosis",
                                  decodedResults!.kurtosis.toStringAsFixed(3),
                                  "A large kurtosis is associated with a high risk for an investment because it indicates high probabilities of extremely large and extremely small returns.",
                                  metricDescFlag),
                              _customVisibilityDivider(metricDescFlag),
                              _projectionListTile(
                                  "Skew",
                                  decodedResults!.skew.toStringAsFixed(3),
                                  "The negative skewness of the distribution indicates that an investor may expect frequent small gains and a few large losses.",
                                  metricDescFlag),
                              _customVisibilityDivider(metricDescFlag),
                              _projectionListTile(
                                  "Maximum Drawdown",
                                  _percentify(
                                      decodedResults!.maxDrawdown.toDouble()),
                                  "The maximum observed loss from a peak to a trough of a portfolio",
                                  metricDescFlag),
                              _customVisibilityDivider(metricDescFlag),
                              _projectionListTile(
                                  "Calmar Ratio",
                                  decodedResults!.calmarRatio
                                      .toStringAsFixed(3),
                                  "Calmar Ratio is a measure of risk-adjusted returns using a fund's maximum drawdown as it's sole measure of risk.",
                                  metricDescFlag),
                              _customVisibilityDivider(metricDescFlag),
                              _projectionListTile(
                                  "Omega Ratio",
                                  decodedResults!.omegaRatio.toStringAsFixed(3),
                                  "Omega Ratio is a weighted risk-return ratio for a given level of expected return that helps us to identify the chances of winning in comparison to losing (higher = better). It also considers skewness and kurtosis",
                                  metricDescFlag),
                              _customVisibilityDivider(metricDescFlag),
                              _projectionListTile(
                                  "Sharpe Ratio",
                                  decodedResults!.sharpeRatio
                                      .toStringAsFixed(3),
                                  "The Sharpe Ratio is the average return earned in excess of the risk-free rate per unit of volatility or total risk. Volatility is a measure of the price fluctuations of an asset or portfolio.",
                                  metricDescFlag),
                              _customVisibilityDivider(metricDescFlag),
                              _projectionListTile(
                                  "Sortino Ratio",
                                  decodedResults!.sortinoRatio
                                      .toStringAsFixed(3),
                                  "The Sortino Ratio takes an asset or portfolio's return and subtracts the risk-free rate, and then divides that amount by the asset's downside deviation.",
                                  metricDescFlag),
                              // _customVisibilityDivider(metricDescFlag),
                              // _projectionListTile(
                              //     "Tail Ratio",
                              //     _percentify(
                              //         decodedResults!.tailRatio.toDouble()),
                              //     "Tail risk is the chance of a loss occurring due to a rare event, as predicted by a probability distribution.",
                              //     metricDescFlag),
                            ])),
                      )),
                ),
                SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
