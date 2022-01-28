class PeriodController {
  String? period;
  String? ticker;
  String? interval;

  String? get getPeriod {
    return period;
  }

  String? get getTicker {
    return ticker;
  }

  String? get getInterval {
    return interval;
  }

  set setPeriod(String givenPeriod) {
    period = givenPeriod;
  }

  set setTicker(String givenTicker) {
    ticker = givenTicker;
  }

  set setInterval(String givenInterval) {
    interval = givenInterval;
  }
}
