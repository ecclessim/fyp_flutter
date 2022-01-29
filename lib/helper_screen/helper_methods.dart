import 'package:flutter/material.dart';
import 'package:fyp_flutter/screens/new_stock_screen.dart';

// These are methods that are often used across multiple widgets. So we can define them in a separate file and import it here.

class HelperMethods {
// Decompose numbers into string affixed formats. E.g. 1000000 = 1M, 100000 = 100K, 1000 = 1K etc...
  static String numberDecompose(num value) {
    if (value >= 1000000000) {
      return (value / 1000000000).toStringAsFixed(2) + 'B';
    } else if (value >= 1000000) {
      return (value / 1000000).toStringAsFixed(2) + 'M';
    } else if (value >= 1000) {
      return (value / 1000).toStringAsFixed(2) + 'K';
    } else {
      return value.toStringAsFixed(2);
    }
  }

// percentify
  static String percentify(num value) {
    return (value * 100).toStringAsFixed(2) + '%';
  }

// Show a custom styled snackbar to display messages to the user.
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBar(
      BuildContext context, String msg) {
    return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: const Duration(milliseconds: 1000),
        backgroundColor: Colors.blue,
        content: Text(
          "$msg",
        )));
  }

// Affix commas to large numbers. Eg. 1000000 = 1,0000,000, etc...
  static String numberCommafy(String value) {
    return value.replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }

  static Future onLoading(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: new Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              new CircularProgressIndicator(),
              new Text("Loading"),
            ],
          ),
        );
      },
    );
  }

  static MaterialColor greenOrRed(value1, value2) {
    if (value1 - value2 > 0) {
      return Colors.green;
    } else if (value1 - value2 < 0) {
      return Colors.red;
    } else {
      return Colors.grey;
    }
  }

  static MaterialColor binaryGreenOrRed(value) {
    if (value > 0) {
      return Colors.green;
    } else if (value < 0) {
      return Colors.red;
    } else {
      return Colors.grey;
    }
  }

  static int dollarsToCents(double value) {
    return (value * 100).round();
  }

  static double calculateWeight(
      double totalAssetValue, double totalPortfolioValue) {
    return double.parse(
        (totalAssetValue / totalPortfolioValue).toStringAsFixed(2));
  }

  static double centsToDollars(int value) {
    double converted = double.parse((value / 100).toStringAsFixed(2));
    print("centsToDollars: $value -> $converted");
    return converted;
  }

  static Map<String, double> genPieChartDataMap(
      List<dynamic> weightedData, String valueIdentifier) {
    final Map<String, double> dataMap = new Map();
    if (weightedData.length == 0) {
      return dataMap;
    } else {
      if (valueIdentifier == "weight") {
        for (var i = 0; i < weightedData.length; i++) {
          dataMap[weightedData[i].ticker] = weightedData[i].weight;
        }
      } else if (valueIdentifier == "shares") {
        for (var i = 0; i < weightedData.length; i++) {
          print("FOR RUN");
          dataMap[weightedData[i].ticker] = weightedData[i].shares.toDouble();
        }
      }
      print("genPieChartDataMap: $dataMap");
      return dataMap;
    }
  }

  static Future showAddNewStockDialog(
      BuildContext context, ticker, portfolioName) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return NewStockScreen(
              ticker: ticker, selectedPortfolio: portfolioName);
        });
  }
}
