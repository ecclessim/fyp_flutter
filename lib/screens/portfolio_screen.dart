import 'package:flutter/material.dart';
import 'package:fyp_flutter/firebase_controller/firestore_repo.dart';
import 'package:fyp_flutter/helper_screen/helper_methods.dart';
import 'package:fyp_flutter/screens/stock_records_screen.dart';
import 'package:fyp_flutter/webservices/web_services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:developer';

class PortfolioScreen extends StatefulWidget {
  final currentPortfolio;
  final portfolioPrincipal;

  PortfolioScreen({this.currentPortfolio, this.portfolioPrincipal});
  @override
  _PortfolioScreenState createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  List stocks = [];

  @override
  void initState() {
    super.initState();
    _getUniqueTickersData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  onPressed: () => {
                        FireStoreRepo()
                            .calculateStockWeights(widget.currentPortfolio),
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
                  Container(
                    width: 100,
                    height: 85,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 50,
                          spreadRadius: 2,
                        ),
                      ],
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(15, 12, 15, 0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: Align(
                              alignment: AlignmentDirectional(0, 0),
                              child: ListTile(
                                title: Text(
                                  "${widget.currentPortfolio}",
                                  style: GoogleFonts.montserrat(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
                  print("Combined tickers: " + tickerString),
                  await api.getDailyStock(tickerString).then((value) {
                    print("FETCHED DAILY STOCK DATA");
                    print("$value");
                    setState(() {
                      HelperMethods.showSnackBar(context, "Loaded Stocks");
                      stocks = value;
                    });
                  }),
                }
            });
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
}
