import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:lottie/lottie.dart';
import 'package:weather_demo/components/constants/images.dart';
import 'package:weather_demo/components/global_functions/navigate.dart';
import 'package:weather_demo/components/global_functions/time_format.dart';
import 'package:weather_demo/components/global_widgets/show_message.dart';
import 'package:weather_demo/controllers/api_controllers/api_response_data.dart';
import 'package:weather_demo/controllers/api_controllers/get_api_controller.dart';
import 'package:weather_demo/main.dart';
import 'package:weather_demo/models/forecast_model.dart';
import 'package:weather_demo/views/homepage/circular_notch_clipper.dart';
import 'package:weather_demo/views/homepage/triangle.dart';
import 'package:weather_demo/views/location_tracker_page.dart';

class Homepage extends ConsumerStatefulWidget {
  const Homepage({super.key});

  @override
  ConsumerState<Homepage> createState() => _HomepageState();
}

class _HomepageState extends ConsumerState<Homepage> {
  bool isTodaySelected = true;

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  fetchData() async {
    await dotenv.load(fileName: ".env");
    String apiKey = dotenv.env['API_KEY'] ?? '';
    String apiUrl = dotenv.env['API_URL'] ?? '';
    final LatLng? location = ref.read(locationProvider);
    log('lat: ${location?.latitude}, lon: ${location?.longitude}');

    Uri url = Uri.parse(apiUrl).replace(queryParameters: {
      'key': apiKey,
      'q': '${location?.latitude},${location?.longitude}',
      'aqi': 'no',
    });

    try {
      ApiResponseData result = await getApiController(url.toString());
      if (result.statusCode == 200) {
        ref.read(forecastProvider.notifier).setForecastData(
            ForecastModel.fromJson(jsonDecode(result.responseBody)));
        log(result.responseBody);
      } else {
        try {
          showError(jsonDecode(result.responseBody)['error']['message']);
        } catch (e) {
          showError('Failed to get weather data');
        }
      }
    } catch (e) {
      showError('Api Call Failed: $e');
      log('Forecast api call: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    ForecastModel? forecastData = ref.watch(forecastProvider);
    Size size = MediaQuery.of(context).size;
    return Container(
      height: size.height,
      width: size.width,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xff97ABFF),
            Color.fromARGB(255, 118, 139, 225),
            Color(0xff123597)
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {},
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: forecastData == null
                      ? Center(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(.3),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Lottie.asset('assets/json/loader.json',
                                width: 125, fit: BoxFit.fitWidth),
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ...locationPart(forecastData),
                            ...headerPart(forecastData),
                            ...daySelector(forecastData),
                            timeScifiedResult(forecastData),
                            bottomPart(forecastData),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> locationPart(ForecastModel forecastData) {
    return [
      const Gap(8),
      Text(
        forecastData.location?.name ?? '',
        style: const TextStyle(color: Colors.white, fontSize: 32),
      ),
      const Gap(4),
      InkWell(
        onTap: () {
          if (mounted) {
            navigate(context: context, child: const LocationTrackingPage());
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(AppImages.locationIcon),
            const Gap(7),
            const Text(
              'Current Location',
              style: TextStyle(color: Colors.white, fontSize: 15),
            ),
          ],
        ),
      ),
    ];
  }

  String slashRemover(String? url) {
    if (url == null) {
      return '';
    } else if (url.startsWith("//")) {
      url = url.replaceFirst("//", "http://");
      log(url);
    } else if (url.startsWith('file:///')) {
      url = url.replaceFirst('file:///', 'http://');
    }
    return url;
  }

  List<Widget> headerPart(ForecastModel forecastData) {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CachedNetworkImage(
            imageUrl: slashRemover(forecastData.current?.condition?.icon),
            width: 90,
            fit: BoxFit.fitWidth,
            errorWidget: (context, error, child) {
              return SvgPicture.asset(
                AppImages.errorImage,
                width: 70,
              );
            },
          ),
          const Gap(10),
          Text(
            '${forecastData.current?.tempC}°',
            style: GoogleFonts.quicksand(
              textStyle: const TextStyle(fontSize: 90, color: Colors.white),
            ),
          )
        ],
      ),
      Text(
        '${forecastData.current?.condition?.text}  -  H:${(forecastData.forecast?.forecastday != null && forecastData.forecast!.forecastday!.isNotEmpty) ? ('${forecastData.forecast?.forecastday?[0].day?.maxtempC} °') : ''}  L:${(forecastData.forecast?.forecastday != null && forecastData.forecast!.forecastday!.isNotEmpty) ? ('${forecastData.forecast?.forecastday?[0].day?.mintempC} °') : ''}',
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
    ];
  }

  List<Widget> daySelector(ForecastModel forecastData) {
    return [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                if (mounted) {
                  setState(() {
                    isTodaySelected = true;
                  });
                }
              },
              style: ButtonStyle(
                padding: const WidgetStatePropertyAll(
                    EdgeInsets.symmetric(horizontal: 35)),
                backgroundColor: isTodaySelected
                    ? const WidgetStatePropertyAll(Color(0xff7087D8))
                    : const WidgetStatePropertyAll(Color(0xff4D66B8)),
                foregroundColor: const WidgetStatePropertyAll(Colors.white),
              ),
              child: const Text('Today'),
            ),
            const Gap(5),
            ElevatedButton(
              onPressed: () {
                if (mounted) {
                  setState(() {
                    isTodaySelected = false;
                  });
                }
              },
              style: ButtonStyle(
                backgroundColor: !isTodaySelected
                    ? const WidgetStatePropertyAll(Color(0xff7087D8))
                    : const WidgetStatePropertyAll(Color(0xff4D66B8)),
                foregroundColor: const WidgetStatePropertyAll(Colors.white),
              ),
              child: const Text('Next Day'),
            ),
          ],
        ),
      ),
    ];
  }

  Widget timeScifiedResult(ForecastModel forecastData) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: (forecastData.forecast?.forecastday != null &&
              forecastData.forecast!.forecastday!.isNotEmpty)
          ? Row(
              children: [
                timeSpecifiedContainer(
                  time: 'Now',
                  image: slashRemover(forecastData.current?.condition?.icon),
                  temperature: forecastData.current?.tempC,
                ),
                ...List.generate(
                  forecastData.forecast?.forecastday?[0].hour?.length ?? 0,
                  (index) {
                    Current? weatherData =
                        forecastData.forecast?.forecastday?[0].hour?[index];
                    try {
                      DateTime dateTime =
                          DateTime.parse(weatherData?.time ?? '');
                      DateTime now = DateTime.now();

                      DateTime sixPM =
                          DateTime(now.year, now.month, now.day, 18, 0);
                      if (!dateTime.isAfter(DateTime.now()) &&
                          now.isBefore(sixPM)) {
                        return Container();
                      }
                    } catch (e) {
                      log('Failed to check isAfter');
                    }
                    return timeSpecifiedContainer(
                      time: formateTimeOnly(weatherData?.time),
                      image: slashRemover(weatherData?.condition?.icon),
                      temperature: weatherData?.tempC,
                    );
                  },
                ),
              ],
            )
          : Container(),
    );
  }

  Widget timeSpecifiedContainer(
      {required String time, required String image, double? temperature}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
      child: Container(
        height: 130,
        width: 60,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.white.withOpacity(.4),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(35),
          gradient: const LinearGradient(
            colors: [
              Color(0xff97ABFF),
              Color.fromARGB(255, 109, 138, 253),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            // stops: [0.40, 1],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              time,
              style: const TextStyle(color: Colors.white),
            ),
            CachedNetworkImage(
              imageUrl: image,
              width: 45,
              fit: BoxFit.fitWidth,
              errorWidget: (context, error, child) {
                return SvgPicture.asset(
                  AppImages.errorImage,
                  width: 40,
                );
              },
            ),
            Text(
              temperature != null ? '$temperature°' : '',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget bottomPart(ForecastModel forecastData) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 18.0),
            child: ClipPath(
              clipper: CircularNotchedClipper(),
              child: Container(
                height: 270.0,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromARGB(255, 198, 209, 248),
                      Color(0xff2949A4),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: const Color(0xff9AABE3),
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.elliptical(220, 115),
                  ),
                ),
                child: Column(
                  children: [
                    const Gap(55),
                    sunsetSunriseContainer(forecastData),
                    const Gap(12),
                    uvContainer(forecastData),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Align(
              child: circularContainer(),
            ),
          )
        ],
      ),
    );
  }

  Widget circularContainer() {
    return Container(
      padding: const EdgeInsets.all(2),
      height: 47,
      width: 47,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 218, 232, 255),
            Color.fromARGB(255, 2, 62, 213),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.bottomCenter,
      child: CustomPaint(
        size: const Size(10, 10),
        painter: Triangle(),
      ),
    );
  }

  Widget sunsetSunriseContainer(ForecastModel forecastData) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: screenWidth * .85,
      height: 88,
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 177, 195, 252),
            Color.fromARGB(255, 80, 123, 243),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Image.asset(
            AppImages.sunset,
            width: 56,
          ),
          textColumn(
            title: 'Sunset',
            info:
                '${(forecastData.forecast?.forecastday != null && forecastData.forecast!.forecastday!.isNotEmpty) ? (forecastData.forecast?.forecastday?[0].astro?.sunset) : ''}',
          ),
          textColumn(
            title: 'Sunrise',
            info:
                '${(forecastData.forecast?.forecastday != null && forecastData.forecast!.forecastday!.isNotEmpty) ? (forecastData.forecast?.forecastday?[0].astro?.sunrise) : ''}',
            align: CrossAxisAlignment.end,
          ),
        ],
      ),
    );
  }

  Widget textColumn(
      {required String title,
      required String info,
      CrossAxisAlignment? align,
      Color? color}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: align ?? CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.quicksand(
            textStyle: TextStyle(
              color: color ?? Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          info,
          style: GoogleFonts.quicksand(
            textStyle: TextStyle(
              color: color ?? Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget uvContainer(ForecastModel forecastData) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: screenWidth * .85,
      height: 88,
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 177, 195, 252),
            Color.fromARGB(255, 72, 115, 234),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Image.asset(
            AppImages.sun,
            width: 56,
          ),
          textColumn(
            title: 'UV Index',
            info: '${forecastData.current?.uv?.sign} Low',
            color: Colors.white.withOpacity(.8),
          ),
          const Gap(85),
        ],
      ),
    );
  }

  showError(String message) {
    if (mounted) {
      showErrorMessage(context, message);
    }
  }
}
