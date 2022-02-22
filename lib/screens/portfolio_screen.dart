import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fyp_flutter/firebase_controller/firestore_repo.dart';
import 'package:fyp_flutter/helper_screen/helper_methods.dart';
import 'package:fyp_flutter/models/PortfolioWeightHandler.dart';
import 'package:fyp_flutter/models/SimpleReturn.dart';
import 'package:fyp_flutter/screens/rl_model_result_screen.dart';
import 'package:fyp_flutter/screens/stock_records_screen.dart';
import 'package:fyp_flutter/webservices/web_services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pie_chart/pie_chart.dart';
// import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';

class PortfolioScreen extends StatefulWidget {
  final currentPortfolio;
  final portfolioPrincipal;
  final uid;

  PortfolioScreen({this.currentPortfolio, this.portfolioPrincipal, this.uid});
  @override
  _PortfolioScreenState createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  bool weightFlag = true;
  PortfolioWeightHandler weightHandler =
      new PortfolioWeightHandler(portfolio: []);
  Map<String, double> pieChartData = {'Loading': 0};
  List stocks = [];
  List weightedTickers = [];
  List weights = [];
  bool returnsLoadedFlag = false;
  String? cachedModelDate;
  String? cachedModelValue;
  String? cachedModelResponse;
  String uniqueTickers = "";
  num cumulativeReturn = 0;
  num portfolioVariance = 0;
  num portfolioVolatilty = 0;
  num portfolioReturn = 0;
  num portfolioDollarReturn = 0;
  @override
  void initState() {
    super.initState();
    _getUniqueTickersData();
    _loadPreferences();
    _getPortfolioReturns();
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
              "${widget.currentPortfolio}",
              style: GoogleFonts.roboto(
                textStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              "Showing all stocks in the portfolio.",
              style: GoogleFonts.roboto(fontSize: 16),
            )
          ],
        ),
        centerTitle: true,
      ),
      bottomSheet: stocks.length >= 4
          ? Container(
              height: 50,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 50,
                    spreadRadius: 2,
                  ),
                ],
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: TextButton.icon(
                  onPressed: () async {
                    //show loading indicator
                    showLoadingDialog(context);
                    await getRlModelPrediction(
                        widget.currentPortfolio, widget.portfolioPrincipal);
                  },
                  icon: Icon(Icons.spa_rounded),
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30),
                                topRight: Radius.circular(30)))),
                  ),
                  label: Text(
                    "Get portfolio analysis",
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  )),
            )
          : Container(
              height: 0,
            ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 25),
        child: FloatingActionButton(
          mini: true,
          elevation: 0,
          onPressed: () async {
            await HelperMethods.showAddNewStockDialog(
                context, null, widget.currentPortfolio);
            _getUniqueTickersData();
          },
          child: Icon(Icons.add),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await _getUniqueTickersData();
          },
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 15,
                  ),
                  if (stocks.length == 0)
                    Container(
                      height: 400,
                      child: Padding(
                        padding: const EdgeInsets.all(50.0),
                        child: Center(
                          child: Text(
                              "No stocks in portfolio yet.\nAdd your first stock by clicking the + button",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.roboto(fontSize: 18)),
                        ),
                      ),
                    )
                  else
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: Text("Your Stocks:",
                            textAlign: TextAlign.left,
                            style: GoogleFonts.roboto(
                              color: Colors.blueAccent,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            )),
                      ),
                    ),
                  SizedBox(height: 15),
                  ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Container(
                            child: Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ListTile(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)),
                                onTap: () async {
                                  // get firestore stocks based on ticker
                                  showStockRecordDialog(
                                      context,
                                      widget.currentPortfolio,
                                      stocks[index]["ticker"]);
                                },
                                tileColor: Colors.white,
                                leading: Container(
                                  height: 50,
                                  width: 80,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      stocks[index]['ticker'].toString(),
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.roboto(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800),
                                    ),
                                  ),
                                ),
                                trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 100,
                                        height: 50,
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            "\$${stocks[index]['last_quote'].toString()}",
                                            textAlign: TextAlign.left,
                                            style: GoogleFonts.roboto(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                              color: HelperMethods.greenOrRed(
                                                  double.parse(stocks[index]
                                                          ['last_quote']
                                                      .toString()),
                                                  double.parse(stocks[index]
                                                          ['previous_close']
                                                      .toString())),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Container(
                                          width: 80,
                                          decoration: BoxDecoration(
                                            color:
                                                HelperMethods.binaryGreenOrRed(
                                                    double.parse(stocks[index]
                                                            ['daily_change']
                                                        .toString())),
                                          ),
                                          child: Center(
                                              child: Column(
                                            children: [
                                              Expanded(
                                                child: Align(
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    stocks[index]
                                                            ['daily_change']
                                                        .toString(),
                                                    style: GoogleFonts.roboto(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Align(
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    "${stocks[index]['daily_change_pct'].toString()}%",
                                                    style: GoogleFonts.roboto(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )),
                                        ),
                                      )
                                    ]),
                              ),
                            ),
                          ),
                        );
                      },
                      itemCount: stocks.length),
                  SizedBox(height: 15),
                  Visibility(
                    visible: returnsLoadedFlag,
                    child: Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20),
                            child: Text("At a glance:",
                                textAlign: TextAlign.left,
                                style: GoogleFonts.roboto(
                                  color: Colors.blueAccent,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                )),
                          ),
                        ),
                        SizedBox(height: 15),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Column(
                              children: [
                                _simpleReturnTile(
                                  Icon(Icons.assessment_rounded),
                                  "Cumulative Return",
                                  "${cumulativeReturn.toStringAsFixed(2)}%",
                                ),
                                _simpleReturnTile(
                                  Icon(Icons.attach_money_rounded),
                                  "Simple Annual Return",
                                  "${(portfolioReturn * 100).toStringAsFixed(2)}%",
                                ),
                                _simpleReturnTile(
                                  Icon(Icons.show_chart_rounded),
                                  "Volatility",
                                  "${(portfolioVolatilty * 100).toStringAsFixed(2)}%",
                                ),
                                _simpleReturnTile(
                                  Icon(Icons.show_chart_rounded),
                                  "Variance",
                                  "${(portfolioVariance * 100).toStringAsFixed(2)}%",
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: ListTile(
                                  leading: Text("Weights:",
                                      textAlign: TextAlign.left,
                                      style: GoogleFonts.roboto(
                                        color: Colors.blueAccent,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      )),
                                  trailing: IconButton(
                                    icon: Icon(
                                      Icons.pie_chart_rounded,
                                      color: Colors.blueAccent,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        weightFlag = !weightFlag;
                                      });
                                    },
                                  ))),
                        ),
                        _weightSwitch()
                      ],
                    ),
                  ),
                  SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _weightSwitch() {
    return Container(
      child: weightFlag ? _weightListTile() : _weightPieChart(),
    );
  }

  _weightListTile() {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(2.0),
              child: Container(
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                      leading: Text(
                        weightedTickers[index],
                        style: GoogleFonts.roboto(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      trailing: Text(
                        (double.parse(weights[index]) * 100)
                                .toStringAsFixed(2) +
                            "%",
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      )),
                ),
              ),
            );
          },
          itemCount: weights.length),
    );
  }

  _weightPieChart() {
    return PieChart(
      dataMap: pieChartData,
      animationDuration: Duration(milliseconds: 400),
      chartRadius: MediaQuery.of(context).size.width * 0.6,
      initialAngleInDegree: 0,
      chartValuesOptions: ChartValuesOptions(
        showChartValues: true,
        showChartValueBackground: true,
      ),
      legendOptions: LegendOptions(
        showLegendsInRow: true,
        legendPosition: LegendPosition.bottom,
        showLegends: true,
        legendTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  _simpleReturnTile(Icon icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        dense: true,
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            icon,
          ],
        ),
        title: Text(
          "$title",
          style: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.left,
        ),
        trailing: Text(
          "$subtitle",
          style: GoogleFonts.roboto(
            color: Colors.blueAccent,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.left,
        ),
      ),
    );
  }

  Future<void> _getPortfolioReturns() async {
    print("getting portfolio returns");
    var simpleReturnsAPI = new SimpleReturnsApi();
    String portfolioDate =
        await FireStoreRepo().getPortfolioDate(widget.currentPortfolio);
    await FireStoreRepo()
        .calculateStockWeights(widget.currentPortfolio)
        .then((value) async {
      weightHandler.portfolio = value;
      String portfolioValue =
          HelperMethods.centsToDollars(widget.portfolioPrincipal.round())
              .toString();
      await simpleReturnsAPI
          .getSimpleReturns(portfolioValue, weightHandler.getTickers(),
              weightHandler.getWeights(), portfolioDate)
          .then((value) {
        SimpleReturn simpleReturn = value;
        setState(() {
          returnsLoadedFlag = true;
          cumulativeReturn = simpleReturn.cumulativeReturn;
          portfolioVariance = simpleReturn.portfolioVariance;
          portfolioVolatilty = simpleReturn.portfolioVolatility;
          portfolioReturn = simpleReturn.simpleAnnualReturn;
          portfolioDollarReturn = simpleReturn.simpleDollarReturn;
          weightedTickers = weightHandler.getTickers().split(" ");
          weights = weightHandler.getWeights().split(" ");
          pieChartData = weightHandler.getCombinedMap();
        });
      });
    });
  }

  Future<void> _getUniqueTickersData() async {
    String tickerString = "";
    var dailyStockAPI = new DailyStockApi();

    await FireStoreRepo()
        .getUniqueStockTicker(widget.currentPortfolio)
        .then((value) async => {
              print("VALUE -> $value"),
              if (value.length > 0)
                {
                  tickerString = value.join(" "),
                  // print("Combined tickers: " + tickerString),
                  await dailyStockAPI.getDailyStock(tickerString).then((value) {
                    // print("FETCHED DAILY STOCK DATA");
                    // print("$value");
                    setState(() {
                      HelperMethods.showSnackBar(context, "Loaded Stocks");
                      uniqueTickers = tickerString;
                      stocks = value;
                    });
                  }),
                }
            });
  }

  _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print(
        "_loadPreferences: => FETCHED ${prefs.getString("${widget.currentPortfolio}modelValue")}");
    setState(() {
      cachedModelDate = prefs.getString("${widget.currentPortfolio}modelDate");
      cachedModelValue =
          prefs.getString("${widget.currentPortfolio}modelValue");
      cachedModelResponse =
          prefs.getString("${widget.currentPortfolio}modelResponse");
    });
  }

  Future getRlModelPrediction(
      String portfolioName, double portfolioValue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // await prefs.clear();

    // case where shared_preferences is empty or > 1 day old : regenerate analysis
    // case where shared_preferences data exists and is < 1 day old : use data from shared_preferences

    double pfValue = await FireStoreRepo().getPortfolioValue(portfolioName);
    int convertedPfValue = pfValue.round();
    bool isPfValueSame = false;
    bool cachedTimeDifference = false;
    String? cachedModelValue = prefs.getString("${portfolioName}modelValue");
    String? cachedModelDate =
        prefs.getString("${portfolioName}modelResponseDate");
    if (cachedModelValue != null && cachedModelDate != null) {
      isPfValueSame = (cachedModelValue == convertedPfValue.toString());
      cachedTimeDifference =
          DateTime.now().difference(DateTime.parse(cachedModelDate)).inDays > 1;
    }

    print("cachedModelValue: $cachedModelValue");
    print("cachedModelDate: $cachedModelDate");
    if (prefs.getString("${portfolioName}modelResponse") == null ||
        !isPfValueSame) {
      print("Regenerating model");
      try {
        await RLModelApi()
            .trainModel(widget.currentPortfolio + widget.uid, uniqueTickers,
                convertedPfValue.toString())
            .then((value) {
          print("Model Status: ${value.status}");
        });
        await RLModelApi()
            .getModelPrediction(widget.currentPortfolio + widget.uid,
                uniqueTickers, convertedPfValue.toString())
            .then((value) => {
                  prefs.setString("${portfolioName}modelValue",
                      convertedPfValue.toString()),
                  prefs.setString(
                      '${portfolioName}modelResponse', jsonEncode(value)),
                  prefs.setString('${portfolioName}modelResponseDate',
                      DateTime.now().toString()),
                  Navigator.pop(context),
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RlResultsScreen(
                        portfolioName: portfolioName,
                        portfolioValue: convertedPfValue,
                        results: jsonEncode(value),
                      ),
                    ),
                  ),
                });
      } catch (e) {
        print("Error: $e");
      }
    } else if (cachedTimeDifference) {
      print("getRlModelPrediction: => Regenerating prediction");
      await RLModelApi()
          .getModelPrediction(widget.currentPortfolio + widget.uid,
              uniqueTickers, convertedPfValue.toString())
          .then((value) => {
                prefs.setString(
                    "${portfolioName}modelValue", convertedPfValue.toString()),
                prefs.setString(
                    '${portfolioName}modelResponse', jsonEncode(value)),
                prefs.setString('${portfolioName}modelResponseDate',
                    DateTime.now().toString()),
                Navigator.pop(context),
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RlResultsScreen(
                      portfolioName: portfolioName,
                      portfolioValue: convertedPfValue,
                      results: jsonEncode(value),
                    ),
                  ),
                ),
              });
    } else {
      print("getRlModelPrediction: => Using cached prediction");
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RlResultsScreen(
            portfolioName: portfolioName,
            portfolioValue: convertedPfValue,
            results: prefs.getString('${portfolioName}modelResponse'),
          ),
        ),
      );
    }
  }

  Future showStockRecordDialog(
      BuildContext context, String selectedPortfolio, String selectedTicker) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StockRecordsScreen(
              currentPortfolio: selectedPortfolio,
              selectedTicker: selectedTicker);
        });
  }

  void showLoadingDialog(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            child: Container(
              height: 150,
              width: 200,
              child: Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: CircularProgressIndicator(),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    "Analysing...",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(fontSize: 14),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Please do not close this dialog.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(
                        fontSize: 14, fontWeight: FontWeight.bold),
                  )
                ],
              )),
            ),
          );
        });
  }
}
