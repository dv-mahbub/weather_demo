import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
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
import 'package:weather_demo/controllers/database/database_service.dart';
import 'package:weather_demo/main.dart';
import 'package:weather_demo/models/database_model.dart';
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
  final DatabaseService databaseService = DatabaseService.instance;

  @override
  void initState() {
    checkConnection();
    super.initState();
  }

  checkConnection() async {
    ref.read(dataAvailablityProvider.notifier).state = true;

    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.first == ConnectivityResult.mobile ||
        connectivityResult.first == ConnectivityResult.wifi) {
      // Connected to the internet
      fetchData();
    } else {
      // Not connected to any network
      showError('No internet connect');
      loadDataFromLocalDatabase();
    }
  }

  fetchData() async {
    await dotenv.load(fileName: ".env");
    String apiKey = dotenv.env['API_KEY'] ?? '';
    String apiUrl = dotenv.env['API_URL'] ?? '';
    final LatLng? location = ref.read(locationProvider);
    // log('lat: ${location?.latitude}, lon: ${location?.longitude}');

    Uri url = Uri.parse(apiUrl).replace(queryParameters: {
      'key': apiKey,
      'q': '${location?.latitude},${location?.longitude}',
      'aqi': 'no',
      'days': '2'
    });

    try {
      ApiResponseData result = await getApiController(url.toString());
      if (result.statusCode == 200) {
        ref.read(forecastProvider.notifier).setForecastData(
            ForecastModel.fromJson(jsonDecode(result.responseBody)));
        //save in databse
        if (location != null) {
          databaseService.addForecast(
            lat: location.latitude,
            long: location.longitude,
            json: result.responseBody,
          );
        }
      } else {
        loadDataFromLocalDatabase();
        try {
          showError(jsonDecode(result.responseBody)['error']['message']);
        } catch (e) {
          showError('Failed to get weather data');
        }
      }
    } catch (e) {
      loadDataFromLocalDatabase();
      showError('Api Call Failed: $e');
      log('Forecast api call: $e');
    }
  }

  loadDataFromLocalDatabase() async {
    final List<DatabaseModel> forecasts = await databaseService.getForecast();
    if (forecasts.isNotEmpty) {
      try {
        ref.read(forecastProvider.notifier).setForecastData(
            ForecastModel.fromJson(jsonDecode(forecasts[0].json)));
      } catch (e) {
        ref.read(dataAvailablityProvider.notifier).state = false;

        log('Failed to assign json in Data Model from databse');
      }
    } else {
      ref.read(dataAvailablityProvider.notifier).state = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    ForecastModel? forecastData = ref.watch(forecastProvider);
    bool isDataAvailable = ref.watch(dataAvailablityProvider);
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
            onRefresh: () async {
              await checkConnection();
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: !isDataAvailable
                      ? Center(
                          child: Text(
                            'Please Turn On Internet Connection',
                            style: TextStyle(
                                color: Colors.red.shade50,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : forecastData == null
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
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Text(
          '${forecastData.current?.condition?.text}  -  H:${(forecastData.forecast?.forecastday != null && forecastData.forecast!.forecastday!.isNotEmpty) ? ('${forecastData.forecast?.forecastday?[0].day?.maxtempC}°') : ''}  L:${(forecastData.forecast?.forecastday != null && forecastData.forecast!.forecastday!.isNotEmpty) ? ('${forecastData.forecast?.forecastday?[0].day?.mintempC}°') : ''}',
          style: TextStyle(fontSize: 18, color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    ];
  }

  List<Widget> daySelector(ForecastModel forecastData) {
    final isTodaySelected = ref.watch(daySelectorProvider);

    return [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                ref.read(daySelectorProvider.notifier).state = true;
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
                ref.read(daySelectorProvider.notifier).state = false;
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
    final isTodaySelected = ref.watch(daySelectorProvider);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: isTodaySelected
          ? (forecastData.forecast?.forecastday != null &&
                  forecastData.forecast!.forecastday!.isNotEmpty)
              ? Row(
                  children: [
                    timeSpecifiedContainer(
                      time: 'Now',
                      image:
                          slashRemover(forecastData.current?.condition?.icon),
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
              : Container(height: 134)
          : (forecastData.forecast?.forecastday != null &&
                  forecastData.forecast!.forecastday!.isNotEmpty &&
                  forecastData.forecast!.forecastday!.length > 1)
              ? Row(
                  children: [
                    ...List.generate(
                      forecastData.forecast?.forecastday?[1].hour?.length ?? 0,
                      (index) {
                        Current? weatherData =
                            forecastData.forecast?.forecastday?[1].hour?[index];

                        return timeSpecifiedContainer(
                          time: formateTimeOnly(weatherData?.time),
                          image: slashRemover(weatherData?.condition?.icon),
                          temperature: weatherData?.tempC,
                        );
                      },
                    ),
                  ],
                )
              : Container(height: 134),
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
    final isTodaySelected = ref.watch(daySelectorProvider);
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
            info: isTodaySelected
                ? '${(forecastData.forecast?.forecastday != null && forecastData.forecast!.forecastday!.isNotEmpty) ? (forecastData.forecast?.forecastday?[0].astro?.sunset) : ''}'
                : '${(forecastData.forecast?.forecastday != null && forecastData.forecast!.forecastday!.isNotEmpty && forecastData.forecast!.forecastday!.length > 1) ? (forecastData.forecast?.forecastday?[1].astro?.sunset) : ''}',
          ),
          textColumn(
            title: 'Sunrise',
            info: isTodaySelected
                ? '${(forecastData.forecast?.forecastday != null && forecastData.forecast!.forecastday!.isNotEmpty) ? (forecastData.forecast?.forecastday?[0].astro?.sunrise) : ''}'
                : '${(forecastData.forecast?.forecastday != null && forecastData.forecast!.forecastday!.isNotEmpty && forecastData.forecast!.forecastday!.length > 1) ? (forecastData.forecast?.forecastday?[1].astro?.sunrise) : ''}',
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
    final isTodaySelected = ref.watch(daySelectorProvider);
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
            info:
                '${isTodaySelected ? forecastData.current?.uv?.sign : (forecastData.forecast != null && forecastData.forecast!.forecastday != null && forecastData.forecast!.forecastday!.isNotEmpty && forecastData.forecast!.forecastday!.length > 1) ? forecastData.forecast!.forecastday![1].day?.uv?.sign ?? '' : ''} Low',
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
