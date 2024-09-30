import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:weather_demo/components/constants/colors.dart';
import 'package:weather_demo/components/global_functions/navigate.dart';
import 'package:weather_demo/controllers/database/database_service.dart';
import 'package:weather_demo/main.dart';
import 'package:weather_demo/models/database_model.dart';
import 'package:weather_demo/views/homepage/homepage.dart';
import 'package:weather_demo/views/location_tracker_page.dart';
import 'package:weather_demo/views/splash_screen.dart/animated_logo.dart';
import 'package:stylish_text/stylish_text.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    fetchDatabase();

    super.initState();
  }

  fetchDatabase() async {
    DatabaseService databaseService = DatabaseService.instance;
    final List<DatabaseModel> forecasts = await databaseService.getForecast();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        if (forecasts.isEmpty) {
          replaceNavigate(
              context: context, child: const LocationTrackingPage());
        } else {
          ref
              .read(locationProvider.notifier)
              .setLocation(forecasts[0].lat, forecasts[0].long);
          replaceNavigate(context: context, child: const Homepage());
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 250, child: AnimatedLogo()),
            Text(
              'Weather App',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(65),
            const TypewriterText(
              'Loading...',
              style: TextStyle(color: Colors.blue),
            ),
            const Gap(15),
          ],
        ),
      ),
    );
  }
}
