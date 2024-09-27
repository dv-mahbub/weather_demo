import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weather_demo/components/constants/images.dart';

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
          // stops: [0.40, 1],
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
                      //   Padding(
                      //     padding: EdgeInsets.only(top: 15),
                      //     child: Stack(
                      //       children: [
                      //         Padding(
                      //           padding: const EdgeInsets.only(top: 10),
                      //           child: Container(
                      //             width: double.infinity,
                      //             height: 270,
                      //             decoration: BoxDecoration(
                      //                 gradient: LinearGradient(
                      //                     colors: [
                      //                       Color(0xff9AABE3),
                      //                       Color(0xff2949A4),
                      //                     ],
                      //                     begin: Alignment.topLeft,
                      //                     end: Alignment.bottomRight),
                      //                 border:
                      //                     Border.all(color: Color(0xff9AABE3)),
                      //                 borderRadius: BorderRadius.vertical(
                      //                     top: Radius.elliptical(220, 130))),
                      //           ),
                      //         ),
                      //         Positioned(
                      //           top: 0,
                      //           left: 0,
                      //           right: 0,
                      //           child: Container(
                      //             height: 57,
                      //             width: 57,
                      //             decoration: BoxDecoration(
                      //               color: Colors.blue,
                      //               shape: BoxShape.circle,
                      //             ),
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      Padding(
                        padding: EdgeInsets.only(top: 5),
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 18.0),
                              child: ClipPath(
                                clipper: CircularNotchedClipper(),
                                child: Container(
                                  height: 270.0,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xff9AABE3),
                                        Color(0xff2949A4),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    border: Border.all(
                                      color: Color(0xff9AABE3),
                                    ),
                                    borderRadius: BorderRadius.vertical(
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
                              child: Container(
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
                              ),
                            )
                          ],
                        ),
                      ),
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
      Text(
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
              child: Text('Today'),
              style: ButtonStyle(
                padding: WidgetStatePropertyAll(
                    EdgeInsets.symmetric(horizontal: 35)),
                backgroundColor: isTodaySelected
                    ? WidgetStatePropertyAll(Color(0xff7087D8))
                    : WidgetStatePropertyAll(Color(0xff4D66B8)),
                foregroundColor: WidgetStatePropertyAll(Colors.white),
              ),
            ),
            Gap(5),
            ElevatedButton(
              onPressed: () {
                if (mounted) {
                  setState(() {
                    isTodaySelected = false;
                  });
                }
              },
              child: Text('Next Day'),
              style: ButtonStyle(
                backgroundColor: !isTodaySelected
                    ? WidgetStatePropertyAll(Color(0xff7087D8))
                    : WidgetStatePropertyAll(Color(0xff4D66B8)),
                foregroundColor: WidgetStatePropertyAll(Colors.white),
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
      padding: EdgeInsets.symmetric(vertical: 2, horizontal: 5),
      child: Container(
        height: 130,
        width: 60,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.white.withOpacity(.4),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(35),
          gradient: LinearGradient(
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
              style: TextStyle(color: Colors.white),
            ),
            Image.asset(
              image,
              width: 55,
            ),
            Text(
              '$temperature°',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class CircularNotchedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double notchRadius = 15.0;
    double centerWidth = size.width / 2;

    final path = Path();
    path.lineTo(centerWidth - notchRadius - 20, 0);

    path.arcToPoint(
      Offset(centerWidth + notchRadius + 20, 0),
      radius: Radius.circular(notchRadius),
      clockwise: false,
    );

    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
