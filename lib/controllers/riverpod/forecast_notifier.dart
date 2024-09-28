import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather_demo/models/forecast_model.dart';

class ForecastNotifier extends StateNotifier<ForecastModel?> {
  ForecastNotifier() : super(null);

  void setForecastData(ForecastModel forecastModel) {
    state = forecastModel;
  }
}
