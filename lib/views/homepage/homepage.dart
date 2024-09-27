import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weather_demo/components/constants/images.dart';
import 'package:weather_demo/views/homepage/circular_notch_clipper.dart';
import 'package:weather_demo/views/homepage/triangle.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  bool isTodaySelected = true;
  @override
  Widget build(BuildContext context) {
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ...locationPart(),
                      ...headerPart(),
                      ...daySelector(),
                      timeScifiedResult(),
                      bottomPart(),
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

  List<Widget> locationPart() {
    return [
      const Text(
        'Dhaka',
        style: TextStyle(color: Colors.white, fontSize: 32),
      ),
      const Gap(12),
      InkWell(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/svg/location.svg'),
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

  List<Widget> headerPart() {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            AppImages.partlyCloudy,
            width: 135,
            fit: BoxFit.fitWidth,
          ),
          const Gap(10),
          Text(
            '13°',
            style: GoogleFonts.quicksand(
              textStyle: const TextStyle(fontSize: 102, color: Colors.white),
            ),
          )
        ],
      ),
      const Text(
        'Partly Cloud  -  H:17o  L:4o',
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
    ];
  }

  List<Widget> daySelector() {
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

  Widget timeScifiedResult() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          timeSpecifiedContainer(
              time: 'Now',
              image: AppImages.slightTouchHappyDay,
              temperature: 30),
          timeSpecifiedContainer(
              time: 'Now',
              image: AppImages.slightTouchHappyDay,
              temperature: 30),
          timeSpecifiedContainer(
              time: 'Now',
              image: AppImages.slightTouchHappyDay,
              temperature: 30),
          timeSpecifiedContainer(
              time: 'Now',
              image: AppImages.slightTouchHappyDay,
              temperature: 30),
          timeSpecifiedContainer(
              time: 'Now',
              image: AppImages.slightTouchHappyDay,
              temperature: 30),
          timeSpecifiedContainer(
              time: 'Now',
              image: AppImages.slightTouchHappyDay,
              temperature: 30),
        ],
      ),
    );
  }

  Widget timeSpecifiedContainer(
      {required String time,
      required String image,
      required double temperature}) {
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
            Image.asset(
              image,
              width: 55,
            ),
            Text(
              '$temperature°',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget bottomPart() {
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
                    sunsetSunriseContainer(),
                    const Gap(12),
                    uvContainer(),
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

  Widget sunsetSunriseContainer() {
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
            info: '5:51PM',
          ),
          textColumn(
            title: 'Sunrise',
            info: '7:00AM',
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
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget uvContainer() {
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
            info: '1 Low',
            color: Colors.white.withOpacity(.8),
          ),
          const Gap(85),
        ],
      ),
    );
  }
}
