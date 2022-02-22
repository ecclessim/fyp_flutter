import 'package:flutter/material.dart';
import 'package:fyp_flutter/firebase_controller/firestore_repo.dart';
import 'package:fyp_flutter/helper_screen/helper_methods.dart';
import 'package:fyp_flutter/webservices/web_services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pie_chart/pie_chart.dart';

class OptimisationResultScreen extends StatefulWidget {
  final functionName;
  final portfolioName;
  final label;

  OptimisationResultScreen({this.functionName, this.portfolioName, this.label});
  @override
  _OptimisationResultScreenState createState() =>
      _OptimisationResultScreenState();
}

class _OptimisationResultScreenState extends State<OptimisationResultScreen> {
  List stocks = [];
  String _ratio = "Ratio";
  String portfolioDateStarted = "";
  double portfolioValue = 0.0;

  double expAnnualReturn = 0.0;
  double expAnnualVolatility = 0.0;
  double expectedDollarReturn = 0.0;
  double principalLeftover = 0.0;
  double retrievedRatio = 0.0;
  List<dynamic> retrievedWeights = [];
  List<dynamic> retrievedAllocations = [];
  Map<String, double> retrievedAllocationMap = {'Loading': 0.0};
  @override
  void initState() {
    super.initState();
    _loadOptimization();
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
            child: Container(
              // height: MediaQuery.of(context).size.height * 10,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 50,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 30, right: 30),
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
                                text:
                                    " \$${HelperMethods.numberCommafy(portfolioValue.toString())}",
                                style: GoogleFonts.roboto(
                                  fontSize: 18,
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold,
                                )),
                            TextSpan(
                              text:
                                  " and the included assets, a portfolio optimized for",
                              style: GoogleFonts.roboto(
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                                text: " ${widget.label}",
                                style: GoogleFonts.roboto(
                                  fontSize: 18,
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold,
                                )),
                            TextSpan(
                              text: " would suggest the following allocations:",
                              style: GoogleFonts.roboto(
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                          ]),
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
                        itemCount: retrievedWeights.length,
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
                                "${retrievedWeights[index].ticker}",
                                style: GoogleFonts.roboto(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              trailing: Container(
                                width: 80,
                                child: Text(
                                  "${_percentify(retrievedWeights[index].weight)}",
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
                  //Text title "In Detail"
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 30, right: 30),
                      child: Text("Weights in shares:",
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
                      padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: retrievedAllocations.length,
                        itemBuilder: (context, index) {
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            // color: Color(0xFFeef7ff),
                            elevation: 3,
                            child: ListTile(
                              dense: true,
                              leading: Text(
                                "${retrievedAllocations[index].ticker}",
                                style: GoogleFonts.roboto(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              trailing: Container(
                                child: Text(
                                  "${retrievedAllocations[index].shares}",
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
                      child: Text("Projections:",
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
                      padding: const EdgeInsets.only(left: 15.0, right: 15),
                      child: Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              ListTile(
                                visualDensity: VisualDensity.compact,
                                dense: true,
                                leading: Text(
                                  "Expected Annual Return",
                                  style: GoogleFonts.roboto(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                trailing: Text(
                                  "${_percentify(expAnnualReturn)}",
                                  style: GoogleFonts.roboto(
                                    color: Colors.blueAccent,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              ListTile(
                                visualDensity: VisualDensity.compact,
                                dense: true,
                                leading: Text(
                                  "Expected Annual Volatility",
                                  style: GoogleFonts.roboto(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                trailing: Text(
                                  "${_percentify(expAnnualVolatility)}",
                                  style: GoogleFonts.roboto(
                                    color: Colors.blueAccent,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              ListTile(
                                visualDensity: VisualDensity.compact,
                                dense: true,
                                leading: Text(
                                  "Expected Dollar Return",
                                  style: GoogleFonts.roboto(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                trailing: Text(
                                  "\$${HelperMethods.numberCommafy(expectedDollarReturn.toStringAsFixed(2))}",
                                  style: GoogleFonts.roboto(
                                    color: Colors.blueAccent,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              ListTile(
                                visualDensity: VisualDensity.compact,
                                dense: true,
                                leading: Text(
                                  "Principal Leftover",
                                  style: GoogleFonts.roboto(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                trailing: Text(
                                  "\$${HelperMethods.numberCommafy(principalLeftover.toStringAsFixed(2))}",
                                  style: GoogleFonts.roboto(
                                    color: Colors.blueAccent,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              ListTile(
                                visualDensity: VisualDensity.compact,
                                dense: true,
                                leading: Text(
                                  "$_ratio",
                                  style: GoogleFonts.roboto(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                trailing: Text(
                                  "$retrievedRatio",
                                  style: GoogleFonts.roboto(
                                    color: Colors.blueAccent,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

// Text('Expected Dollar Return: $expectedDollarReturn'),
  // Text('Principal Leftover: $principalLeftover'),
  // Text('Ratio: $retrievedRatio'),
  Future<void> _loadOptimization() async {
    await _getUniqueTickersData();
    await _getPortfolioValue();
    await _getPortfolioDate();
    switch (widget.functionName) {
      case 'sortino':
        print("Selected Sortino");
        await _getSortinoApi(stocks, portfolioValue, portfolioDateStarted);
        break;
      case 'minVol':
        print("Selected Min Vol");
        await _getMinVolApi(stocks, portfolioValue, portfolioDateStarted);
        break;
      case 'maxSharpe':
        print("Selected Max Sharpe");
        await _getSharpeApi(stocks, portfolioValue, portfolioDateStarted);
        break;
      default:
    }
  }

  Future<void> _getSharpeApi(
      List tickers, double portfolioValue, String startDate) async {
    var sharpeApi = new SharpeApi();
    String tickerString = stocks.join(" ");
    await sharpeApi
        .getSharpeAllocation(tickerString, portfolioValue, startDate)
        .then((value) => {
              setState(() {
                print("_getSortinoApi: => $value");
                _ratio = "Sharpe Ratio";
                expAnnualReturn =
                    double.parse(value.expAnnualReturn.toStringAsFixed(2));
                expAnnualVolatility =
                    double.parse(value.expAnnualVolatility.toStringAsFixed(2));
                expectedDollarReturn =
                    double.parse(value.expDollarReturn.toStringAsFixed(2));
                principalLeftover =
                    double.parse(value.principalLeftover.toStringAsFixed(2));
                retrievedRatio =
                    double.parse(value.sharpeRatio.toStringAsFixed(2));
                retrievedWeights = value.sharpeWeights;
                retrievedAllocations = value.sharpeAllocations;
                retrievedAllocationMap = HelperMethods.genPieChartDataMap(
                    retrievedWeights, 'weight');
                print("retrieved allocationMap: =>  $retrievedAllocationMap");
              }),
            });
  }

  Future<void> _getMinVolApi(
      List tickers, double portfolioValue, String startDate) async {
    var minVolApi = new MinVolApi();
    String tickerString = stocks.join(" ");
    await minVolApi
        .getMinVolAllocation(tickerString, portfolioValue, startDate)
        .then((value) => {
              setState(() {
                print("_getSortinoApi: => $value");
                _ratio = "Sharpe Ratio";
                expAnnualReturn =
                    double.parse(value.expAnnualReturn.toStringAsFixed(2));
                expAnnualVolatility =
                    double.parse(value.expAnnualVolatility.toStringAsFixed(2));
                expectedDollarReturn =
                    double.parse(value.expDollarReturn.toStringAsFixed(2));
                principalLeftover =
                    double.parse(value.principalLeftover.toStringAsFixed(2));
                retrievedRatio =
                    double.parse(value.sharpeRatio.toStringAsFixed(2));
                retrievedWeights = value.minVolWeights;
                retrievedAllocations = value.minVolAllocations;
                retrievedAllocationMap = HelperMethods.genPieChartDataMap(
                    retrievedWeights, 'weight');
                print("retrieved allocationMap: =>  $retrievedAllocationMap");
              }),
            });
  }

  Future<void> _getSortinoApi(
      List tickers, double portfolioValue, String startDate) async {
    var sortinoApi = new SortinoApi();
    String tickerString = stocks.join(" ");
    await sortinoApi
        .getSortinoAllocation(tickerString, portfolioValue, startDate)
        .then((value) => {
              setState(() {
                print("_getSortinoApi: => $value");
                _ratio = "Sortino Ratio";
                expAnnualReturn =
                    double.parse(value.expAnnualReturn.toStringAsFixed(2));
                expAnnualVolatility =
                    double.parse(value.expAnnualVolatility.toStringAsFixed(2));
                expectedDollarReturn =
                    double.parse(value.expDollarReturn.toStringAsFixed(2));
                principalLeftover =
                    double.parse(value.principalLeftover.toStringAsFixed(2));
                retrievedRatio =
                    double.parse(value.sortinoRatio.toStringAsFixed(2));
                retrievedWeights = value.sortinoWeights;
                retrievedAllocations = value.sortinoAllocations;
                retrievedAllocationMap = HelperMethods.genPieChartDataMap(
                    retrievedWeights, 'weight');
                print("retrieved allocationMap: =>  $retrievedAllocationMap");
              }),
            });
  }

  Future<void> _getPortfolioValue() async {
    await FireStoreRepo()
        .getPortfolioValue(widget.portfolioName)
        .then((value) => {
              setState(() {
                // print("_getPortfolioValue: => $value");
                portfolioValue = value;
              }),
            });
  }

  Future<void> _getPortfolioDate() async {
    await FireStoreRepo().getPortfolioDate(widget.portfolioName).then((value) {
      setState(() {
        print("_getPortfolioDate: => $value");
        portfolioDateStarted = value;
      });
    });
  }

  String _percentify(double value) {
    return "${(value * 100).toStringAsFixed(2)}%";
  }

  Future<void> _getUniqueTickersData() async {
    await FireStoreRepo()
        .getUniqueStockTicker(widget.portfolioName)
        .then((value) => {
              if (value.length > 0)
                {
                  setState(() {
                    print("_getUniqueTickersData: => $value");
                    stocks = value;
                  })
                }
            });
  }
}
