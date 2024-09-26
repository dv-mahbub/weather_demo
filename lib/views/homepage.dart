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
        body: RefreshIndicator(
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
                    Container(
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
                            'Now',
                            style: TextStyle(color: Colors.white),
                          ),
                          Image.asset(
                            AppImages.slightTouchHappyDay,
                            width: 55,
                          ),
                          Text(
                            '13°',
                            style: TextStyle(color: Colors.white),
                          ),
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
}
