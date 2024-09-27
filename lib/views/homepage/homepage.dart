import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weather_demo/components/constants/images.dart';
import 'package:weather_demo/views/homepage/circularNotchClipper.dart';
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
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xff9AABE3),
                      Color(0xff2949A4),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: const Color(0xff9AABE3),
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.elliptical(220, 130),
                  ),
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
              child: const Text('Today'),
              style: ButtonStyle(
                padding: const WidgetStatePropertyAll(
                    EdgeInsets.symmetric(horizontal: 35)),
                backgroundColor: isTodaySelected
                    ? const WidgetStatePropertyAll(Color(0xff7087D8))
                    : const WidgetStatePropertyAll(Color(0xff4D66B8)),
                foregroundColor: const WidgetStatePropertyAll(Colors.white),
              ),
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
              child: const Text('Next Day'),
              style: ButtonStyle(
                backgroundColor: !isTodaySelected
                    ? const WidgetStatePropertyAll(Color(0xff7087D8))
                    : const WidgetStatePropertyAll(Color(0xff4D66B8)),
                foregroundColor: const WidgetStatePropertyAll(Colors.white),
              ),
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
}
