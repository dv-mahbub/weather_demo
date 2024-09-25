import 'package:flutter/material.dart';

class AnimatedLogo extends StatefulWidget {
  const AnimatedLogo({super.key});

  @override
  State<AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<AnimatedLogo> {
  double logoWidth = 130;

  @override
  void initState() {
    Future.delayed(const Duration(seconds: 1), () {
      increaseSize();
    });
    super.initState();
  }

  void increaseSize() {
    if (mounted) {
      setState(() {
        logoWidth += 85;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      width: logoWidth,
      duration: const Duration(seconds: 2),
      curve: Curves.bounceOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Image.asset('assets/images/logo.png'),
    );
  }
}
