class TimeSeries {
  final String? dateTime;
  final double? open;
  final double? high;
  final double? low;
  final double? close;
  final num? volume;

  TimeSeries({
    this.dateTime,
    this.open,
    this.high,
    this.low,
    this.close,
    this.volume,
  });

  factory TimeSeries.fromJson(Map<String, dynamic> json) {
    if (json.containsKey("Datetime")) {
      return TimeSeries(
        dateTime: json["Datetime"],
        open: json["Open"],
        high: json["High"],
        low: json["Low"],
        close: json["Close"],
        volume: json["Volume"],
      );
    } else {
      return TimeSeries(
        dateTime: json["Date"],
        open: json["Open"],
        high: json["High"],
        low: json["Low"],
        close: json["Close"],
        volume: json["Volume"],
      );
    }
  }
}
