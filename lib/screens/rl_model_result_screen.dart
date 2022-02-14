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

  _projectionListTile(String leading, String trailing) {
    return ListTile(
      visualDensity: VisualDensity.compact,
      dense: true,
      leading: Text(
        "$leading",
        style: GoogleFonts.roboto(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
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
                    padding: const EdgeInsets.only(left: 30, right: 30),
                    child: Text("Projections:",
                        textAlign: TextAlign.left,
                        style: GoogleFonts.roboto(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
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
                                      decodedResults!.annualReturn.toDouble())),
                              _projectionListTile(
                                  "Expected Annual Volatility",
                                  _percentify(decodedResults!.annualVolatility
                                      .toDouble())),
                              _projectionListTile(
                                  "Alpha",
                                  _percentify(
                                      decodedResults!.alpha.toDouble())),
                              _projectionListTile("Beta",
                                  _percentify(decodedResults!.beta.toDouble())),
                              _projectionListTile(
                                  "Cumulative Returns",
                                  _percentify(decodedResults!.cumulativeReturns
                                      .toDouble())),
                              _projectionListTile(
                                  "Daily Value at Risk",
                                  _percentify(decodedResults!.dailyValueAtRisk
                                      .toDouble())),
                              _projectionListTile("Kurtosis",
                                  decodedResults!.kurtosis.toStringAsFixed(3)),
                              _projectionListTile(
                                  "Maximum Drawdown",
                                  _percentify(
                                      decodedResults!.maxDrawdown.toDouble())),
                              _projectionListTile(
                                  "Calmar Ratio",
                                  decodedResults!.calmarRatio
                                      .toStringAsFixed(3)),
                              _projectionListTile(
                                  "Omega Ratio",
                                  decodedResults!.omegaRatio
                                      .toStringAsFixed(3)),
                              _projectionListTile(
                                  "Sharpe Ratio",
                                  decodedResults!.sharpeRatio
                                      .toStringAsFixed(3)),
                              _projectionListTile(
                                  "Sortino Ratio",
                                  decodedResults!.sortinoRatio
                                      .toStringAsFixed(3)),
                              _projectionListTile("Tail Ratio",
                                  decodedResults!.tailRatio.toStringAsFixed(3)),
                              _projectionListTile(
                                "Skew",
                                decodedResults!.skew.toStringAsFixed(3),
                              ),
                              _projectionListTile(
                                  "Stability",
                                  _percentify(
                                      decodedResults!.stability.toDouble())),
                            ])),
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
