import 'package:candlesticks/candlesticks.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fyp_flutter/webservices/web_services.dart';

// ignore: must_be_immutable
class CandleChartScreen extends StatefulWidget {
  List<Candle> timeSeries;
  final String ticker;
  final String interval;

  CandleChartScreen(
      {Key? key,
      required this.ticker,
      required this.timeSeries,
      required this.interval})
      : super(key: key);

  @override
  State<CandleChartScreen> createState() => _CandleChartScreenState();
}

class _CandleChartScreenState extends State<CandleChartScreen> {
  void fetchTimeSeries(String period, String interval) {
    var api = TimeSeriesApi();
    api.getTimeSeries(widget.ticker, period, interval).then((value) {
      print("${widget.ticker}, $interval, $period");
      setState(() {
        print("fetchTimeSeries: => ${value.length}");
        widget.timeSeries = value;
      });
    });
  }

  Future<void> updatePeriod(String msg) {
    return Fluttertoast.showToast(msg: msg);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: widget.timeSeries.isEmpty
            ? Text("No data available to chart")
            : Column(
                children: [
                  Expanded(
                    flex: 8,
                    child: Container(
                      child: AspectRatio(
                        aspectRatio: 1.2,
                        child: Candlesticks(
                          candles: widget.timeSeries,
                          onIntervalChange: (String msg) async {
                            updatePeriod(msg);
                          },
                          interval: widget.interval,
                          showIntervalButton: false,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.9 + 10,
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: OutlinedButton(
                                onPressed: () {
                                  fetchTimeSeries('1D', "5m");
                                },
                                child: Text("1D"),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: OutlinedButton(
                                onPressed: () {
                                  fetchTimeSeries('1mo', "60m");
                                },
                                child: Text("1M"),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: OutlinedButton(
                                onPressed: () {
                                  fetchTimeSeries('3mo', "1d");
                                },
                                child: Text("3M"),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: OutlinedButton(
                                onPressed: () {
                                  fetchTimeSeries('1y', "1wk");
                                },
                                child: Text("1Y"),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: OutlinedButton(
                                onPressed: () {
                                  fetchTimeSeries('5y', "1mo");
                                },
                                child: Text("5Y"),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
