import 'package:flutter/material.dart';
import 'package:fyp_flutter/screens/portfolio_opt_selection.dart';
import 'package:google_fonts/google_fonts.dart';

class PortfolioOptimisationScreen extends StatefulWidget {
  @override
  _PortfolioOptimisationScreenState createState() =>
      _PortfolioOptimisationScreenState();
}

class _PortfolioOptimisationScreenState
    extends State<PortfolioOptimisationScreen> {
  @override
  Widget build(BuildContext context) {
    optionButton(String optionText, String functionName) {
      return Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Colors.blueAccent,
            onPrimary: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () async {
            await portfolioSelectionDialog(context, optionText, functionName);
          },
          child: Text('$optionText',
              style: GoogleFonts.roboto(
                fontSize: 22,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              )),
        ),
      );
    }

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
              "Portfolio Optimisations",
              style: GoogleFonts.roboto(
                textStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.2,
                ),
                Column(
                  children: <Widget>[
                    Text(
                      "Please choose method of optimization",
                      style: GoogleFonts.roboto(
                        color: Colors.grey,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    optionButton("Minimum Volatility", "minVol"),
                    SizedBox(
                      height: 20,
                    ),
                    optionButton("Maximum Sharpe Ratio", "maxSharpe"),
                    SizedBox(
                      height: 20,
                    ),
                    optionButton("Sortino Ratio Allocation", "sortino"),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future portfolioSelectionDialog(
      BuildContext context, String label, function) {
    print("$label, $function");
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return PortfolioOptSelectionScreen(
              functionName: function, label: label);
        });
  }
}
