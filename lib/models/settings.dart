import 'package:flutter/foundation.dart';

enum Metric { wer, levenshtein }

class AppSettings extends ChangeNotifier {
  AppSettings({this.metric = Metric.levenshtein, this.localeId = 'ru_RU'});

  Metric metric;
  String localeId;

  void updateMetric(Metric value) {
    metric = value;
    notifyListeners();
  }

  void updateLocale(String value) {
    localeId = value;
    notifyListeners();
  }
}
