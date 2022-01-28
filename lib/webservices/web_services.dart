import 'dart:convert';

import 'package:candlesticks/candlesticks.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:fyp_flutter/models/company_info_model.dart';
import 'package:fyp_flutter/models/min_vol_model.dart';
import 'package:fyp_flutter/models/sharpe_model.dart';
import 'package:fyp_flutter/models/sortino_model.dart';
import 'package:fyp_flutter/models/time_series_model.dart';
import 'package:http/http.dart' as http;
// import 'package:socket_io_client/socket_io_client.dart' as IO;

String ipAddressEmulator = 'http://10.0.2.2';
String ipAddressDevice = 'http://10.59.24.112';

// String ipAddressDevice = 'http://10.27.255.124';

class CompanyInfoApi {
  Future<CompanyInfo> getCompanyInfo(ticker) async {
    // Device URL -> ipconfig, use PC IP
    final url = "$ipAddressDevice:5000/get_company_info?ticker=$ticker";
    // final url = "$ipAddressEmulator:5000/get_company_info?ticker=$ticker";
    print(url);
    final response =
        await http.get(Uri.parse(url), headers: {'Connection': 'keep-alive'});
    if (response.statusCode == 200) {
      final responseJson = json.decode(response.body);
      return new CompanyInfo.fromJson(responseJson);
    } else {
      Fluttertoast.showToast(
          msg: "Error: Failed to load company",
          toastLength: Toast.LENGTH_SHORT);
      throw Exception('Failed to load company');
    }
  }
}

class DailyStockApi {
  Future<List> getDailyStock(String tickers) async {
    // Device URL -> ipconfig, use PC IP
    final url = "$ipAddressDevice:5000/get_stock_price?tickers=$tickers";
    // final url = "$ipAddressEmulator:5000/get_daily_stock?ticker=$ticker";
    print(url);
    final response =
        await http.get(Uri.parse(url), headers: {'Connection': 'keep-alive'});
    if (response.statusCode == 200) {
      final responseJson = json.decode(response.body);
      return responseJson.toList();
    } else {
      Fluttertoast.showToast(
          msg: "Error: Failed to load daily stock",
          toastLength: Toast.LENGTH_SHORT);
      throw Exception('Failed to load daily stock');
    }
  }
}

class TimeSeriesApi {
  Future<List<Candle>> getTimeSeries(ticker, period, interval) async {
    List<Candle> candles = [];
    var apiObject;
    final url =
        "$ipAddressDevice:5000/get_time_series?ticker=$ticker&period=$period&interval=$interval";
    // final url =
    // "http://10.0.2.2:5000/get_time_series?ticker=$ticker&period=$period&interval=$interval";
    print(url);
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final responseJson = json.decode(response.body);
      // print(responseJson[0]);

      for (var i = 0; i < responseJson.length; i++) {
        apiObject = TimeSeries.fromJson(responseJson[i]);
        if (apiObject.open != null) {
          candles.add(Candle(
              date: DateTime.parse(apiObject.dateTime),
              open: apiObject.open,
              high: apiObject.high,
              low: apiObject.low,
              close: apiObject.close,
              volume: double.parse(apiObject.volume.toString())));
        }
      }
    }
    return candles.reversed.toList();
  }
}

class MinVolApi {
  Future<MinVol> getMinVolAllocation(
      String assets, double principal, String startDate) async {
    // Device URL -> ipconfig, use PC IP
    final url =
        "$ipAddressDevice:5000/calculate_min_volatility?principal=$principal&assets=$assets&start_date=$startDate";
    // final url = "$ipAddressEmulator:5000/get_min_vol?ticker=$ticker";
    print(url);
    final response =
        await http.get(Uri.parse(url), headers: {'Connection': 'keep-alive'});
    if (response.statusCode == 200) {
      final responseJson = json.decode(response.body);
      return new MinVol.fromJson(responseJson);
    } else {
      Fluttertoast.showToast(
          msg: "Error: Failed to load min vol",
          toastLength: Toast.LENGTH_SHORT);
      throw Exception('Failed to load min vol');
    }
  }
}

class SharpeApi {
  Future<Sharpe> getSharpeAllocation(
      String assets, double principal, String startDate) async {
    // Device URL -> ipconfig, use PC IP
    final url =
        "$ipAddressDevice:5000/calculate_sharpe?principal=$principal&assets=$assets&start_date=$startDate";
    // final url = "$ipAddressEmulator:5000/get_sharpe_allocation";
    print(url);
    final response =
        await http.get(Uri.parse(url), headers: {'Connection': 'keep-alive'});
    if (response.statusCode == 200) {
      final responseJson = json.decode(response.body);
      return new Sharpe.fromJson(responseJson);
    } else {
      Fluttertoast.showToast(
          msg: "Error: Failed to load sharpe allocation",
          toastLength: Toast.LENGTH_SHORT);
      throw Exception('Failed to load sharpe allocation');
    }
  }
}

class SortinoApi {
  Future<Sortino> getSortinoAllocation(
      String assets, double principal, String startDate) async {
    final url =
        "$ipAddressDevice:5000/calculate_sortino?principal=$principal&assets=$assets&start_date=$startDate";
    // final url = "$ipAddressEmulator:5000/get_sortino_allocation";
    print(url);
    final response =
        await http.get(Uri.parse(url), headers: {'Connection': 'keep-alive'});
    if (response.statusCode == 200) {
      final responseJson = json.decode(response.body);
      return new Sortino.fromJson(responseJson);
    } else {
      Fluttertoast.showToast(
          msg: "Error: Failed to load sortino allocation",
          toastLength: Toast.LENGTH_SHORT);
      throw Exception('Failed to load sortino allocation');
    }
  }
}
