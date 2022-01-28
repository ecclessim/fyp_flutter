import 'package:candlesticks/candlesticks.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp_flutter/helper_screen/candle_chart_screen.dart';
import 'package:fyp_flutter/helper_screen/company_info_screen.dart';
import 'package:fyp_flutter/helper_screen/helper_methods.dart';
import 'package:fyp_flutter/models/user_model.dart';
import 'package:fyp_flutter/screens/select_portfolio_screen.dart';
import 'package:fyp_flutter/webservices/web_services.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController tickerController = new TextEditingController();
  String ticker = "";
  String _searchTitle = "Search";
  String _searchSubtitle = "Search for stocks";
  String logoUrl = "default";
  bool isLoading = false;
  var weekChange52 = 0.0;
  var avgVolume = 0;
  var country = "-";
  var currentPrice = 0.0;
  double? divRate;
  double? divYield;
  var forwardPE = 0.0;
  var longSummary = "-";
  var mktCap = 0;
  var open = 0.0;
  var previousClose = 0.0;
  var sector = "-";
  var sharesOuts = 0;
  double volume = 0;
  List<Candle> timeSeries = [];
  String decomposedMktCap = "0";
  String decomposedSharesOuts = "0";
  String decomposedVolume = "0";
  String decomposedAvgVol = "0";
  double dailyChange = 0;
  double dailyPctChange = 0.0;

  Future _callCompanyInfoApi(ticker) async {
    if (_formKey.currentState!.validate()) {
      HelperMethods.showSnackBar(context, "Searching...");
      var api = new CompanyInfoApi();
      await api.getCompanyInfo(ticker).then((value) => {
            setState(() {
              _searchTitle = value.ticker;
              _searchSubtitle = value.companyName;
              logoUrl = value.logoUrl;
              weekChange52 = value.weekChange52 as double;
              avgVolume = value.avgVolume as int;
              country = value.country;
              currentPrice = value.currentPrice as double;
              divRate = value.divRate as double;
              divYield = value.divYield as double;
              forwardPE = value.forwardPE as double;
              longSummary = value.longSummary;
              mktCap = value.marketCap as int;
              open = value.open as double;
              previousClose = value.previousClose as double;
              sector = value.sector;
              sharesOuts = value.sharesOutst as int;
              volume = value.volume as double;

              decomposedMktCap = HelperMethods.numberDecompose(mktCap);
              decomposedSharesOuts = HelperMethods.numberDecompose(sharesOuts);
              decomposedVolume = HelperMethods.numberDecompose(volume);
              decomposedAvgVol = HelperMethods.numberDecompose(avgVolume);

              dailyChange = currentPrice - previousClose;
              dailyPctChange = dailyChange / previousClose * 100;
            })
          });
      print("Company Info retrieved");
      _callTimeSeriesApi(tickerController.text, "1d", "5m");
    }
  }

  Future _callTimeSeriesApi(ticker, period, interval) async {
    var api = new TimeSeriesApi();
    await api.getTimeSeries(ticker, period, interval).then((value) => {
          setState(() {
            timeSeries = value;
            print("Time Series retrieved");
          })
        });
  }

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get()
        .then((value) {
      this.loggedInUser = UserModel.fromMap(value.data());
      setState(() {});
    });
  }

  Widget build(BuildContext context) {
    final submitButton = Material(
      borderRadius: BorderRadius.only(
          topRight: Radius.circular(15), bottomRight: Radius.circular(15)),
      color: Colors.blueAccent,
      child: Container(
        child: MaterialButton(
          onPressed: () async {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
            ticker = tickerController.text;
            await _callCompanyInfoApi(tickerController.text);
            tickerController.clear();
          },
          child: Text(
            "Search",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );

    final tickerField = TextFormField(
      autofocus: false,
      controller: tickerController,
      validator: (value) {
        if (value!.isEmpty) {
          return ("Ticker field cannot be blank");
        }
        return null;
      },
      onSaved: (value) {
        tickerController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          suffixIcon: IconButton(
              onPressed: tickerController.clear, icon: Icon(Icons.clear)),
          prefixIcon: Icon(Icons.search),
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Ticker",
          border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blueAccent, width: 1),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  bottomLeft: Radius.circular(15)))),
    );
    MaterialColor greenOrRed(value1, value2) {
      if (value1 - value2 > 0) {
        return Colors.green;
      } else if (value1 - value2 < 0) {
        return Colors.red;
      } else {
        return Colors.grey;
      }
    }

    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 25),
        child: FloatingActionButton(
          mini: true,
          elevation: 0,
          onPressed: () async {
            await showSelectPortfolioDialog(context, ticker);
          },
          child: Icon(Icons.add),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Color(0x00FFFFFF),
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
                          alignment: AlignmentDirectional(-1, 0),
                          child: Row(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 5, right: 15),
                                child: setCompanyLogo(logoUrl),
                              ),
                              Text(
                                _searchTitle,
                                textAlign: TextAlign.start,
                                style: GoogleFonts.roboto(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: AlignmentDirectional(-1, 0),
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Text(
                              _searchSubtitle,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.roboto(
                                fontWeight: FontWeight.w400,
                                fontSize: 18,
                                color: Colors.grey[800],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Form(
                  key: _formKey,
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 4, child: tickerField),
                          Expanded(child: submitButton),
                        ],
                      ),
                    ),
                  )),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("\$$currentPrice",
                          style: GoogleFonts.roboto(
                            fontSize: 36,
                            fontWeight: FontWeight.w600,
                            color: greenOrRed(
                                double.tryParse(
                                  currentPrice.toString(),
                                ),
                                double.tryParse(previousClose.toString())),
                          )),
                      Column(
                        children: [
                          Text("${dailyChange.toStringAsFixed(2)}",
                              style: GoogleFonts.roboto(
                                  fontSize: 24,
                                  color: greenOrRed(
                                      double.tryParse(dailyChange.toString()),
                                      0))),
                          Text("${dailyPctChange.toStringAsFixed(2)}%",
                              style: GoogleFonts.roboto(
                                  fontSize: 16,
                                  color: greenOrRed(
                                      double.tryParse(
                                        dailyPctChange.toString(),
                                      ),
                                      0))),
                        ],
                      ),
                    ]),
              ),
              Container(
                height: 395,
                width: MediaQuery.of(context).size.width * 0.90 + 10,
                child: CandleChartScreen(
                    ticker: ticker, timeSeries: timeSeries, interval: ""),
              ),
              CompanyInfoWidget(
                open: open.toString(),
                previousClose: previousClose.toString(),
                mktCap: decomposedMktCap.toString(),
                forwardPE: forwardPE.toString(),
                volume: decomposedVolume.toString(),
                avgVolume: decomposedAvgVol.toString(),
                divYield: divYield.toString(),
                divRate: divRate.toString(),
                sector: sector.toString(),
                sharesOuts: decomposedSharesOuts.toString(),
                country: country.toString(),
                weekChange52: weekChange52.toString(),
                longSummary: longSummary.toString(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future showSelectPortfolioDialog(BuildContext context, ticker) {
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return SelectPortfolioScreen(ticker: ticker);
      });
}

setCompanyLogo(String logoUrl) {
  if (logoUrl == "default") {
    return Icon(Icons.search);
  } else {
    return Image.network(
      logoUrl,
      width: 50,
      height: 50,
      errorBuilder: (context, url, error) {
        return Icon(Icons.search);
      },
    );
  }
}
