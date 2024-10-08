import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:weather_demo/controllers/riverpod/location_notifier.dart';
import 'package:weather_demo/controllers/riverpod/forecast_notifier.dart';
import 'package:weather_demo/models/forecast_model.dart';
import 'package:weather_demo/views/splash_screen.dart/splash_screen.dart';

final locationProvider =
    StateNotifierProvider<LocationNotifier, LatLng?>((ref) {
  return LocationNotifier();
});

final daySelectorProvider = StateProvider<bool>((ref) => true);
final dataAvailablityProvider = StateProvider<bool>((ref) => true);

final forecastProvider =
    StateNotifierProvider<ForecastNotifier, ForecastModel?>((ref) {
  return ForecastNotifier();
});

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
