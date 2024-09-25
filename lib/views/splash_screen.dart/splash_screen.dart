import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:weather_demo/components/constants/colors.dart';
import 'package:weather_demo/components/global_functions/navigate.dart';
import 'package:weather_demo/views/location_tracker_page.dart';
import 'package:weather_demo/views/splash_screen.dart/animated_logo.dart';
import 'package:stylish_text/stylish_text.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        replaceNavigate(context: context, child: const LocationTrackingPage());
      }
    });
    super.initState();
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
