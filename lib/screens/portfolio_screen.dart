import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fyp_flutter/firebase_controller/firestore_repo.dart';
import 'package:fyp_flutter/helper_screen/helper_methods.dart';
import 'package:fyp_flutter/models/model_status.dart';
import 'package:fyp_flutter/screens/rl_model_result_screen.dart';
import 'package:fyp_flutter/screens/stock_records_screen.dart';
import 'package:fyp_flutter/webservices/web_services.dart';
import 'package:google_fonts/google_fonts.dart';
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
  List stocks = [];
  String uniqueTickers = "";
  @override
  void initState() {
    super.initState();
    _getUniqueTickersData();
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
                                              color: HelperMethods
                                                  .binaryGreenOrRed(
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _getUniqueTickersData() async {
    String tickerString = "";
    var api = new DailyStockApi();
    await FireStoreRepo()
        .getUniqueStockTicker(widget.currentPortfolio)
        .then((value) async => {
              print("VALUE -> $value"),
              if (value.length > 0)
                {
                  tickerString = value.join(" "),
                  // print("Combined tickers: " + tickerString),
                  await api.getDailyStock(tickerString).then((value) {
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
