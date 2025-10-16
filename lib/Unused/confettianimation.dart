import 'dart:math';

import 'package:flutter/material.dart';

class ConfettiScreen extends StatefulWidget {
  @override
  _ConfettiScreenState createState() => _ConfettiScreenState();
}

class _ConfettiScreenState extends State<ConfettiScreen>
    with TickerProviderStateMixin {
  List<Confetto> confetti = [];
  Random random = Random();
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    );

    _controller.addListener(() {
      if (_controller.isAnimating) {
        setState(() {
          confetti.add(Confetto(
            angle: random.nextDouble() * 2 * pi,
            distance: random.nextDouble() * 300,
            color: Colors.primaries[random.nextInt(Colors.primaries.length)],
            width: random.nextDouble() * 8 + 4,
            height: random.nextDouble() * 14 + 8,
          ));
        });
      }
    });

    _controller.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ...confetti.map((c) {
            return Positioned(
              left: MediaQuery.of(context).size.width / 2 +
                  cos(c.angle) * c.distance,
              top: MediaQuery.of(context).size.height / 2 +
                  sin(c.angle) * c.distance,
              child: Transform.rotate(
                angle: c.angle + pi / 4,
                child: Container(
                  width: c.width,
                  height: c.height,
                  decoration: BoxDecoration(
                    color: c.color,
                    shape: BoxShape.rectangle,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class Confetto {
  final double angle;
  final double distance;
  final Color color;
  final double width;
  final double height;

  Confetto({
    required this.angle,
    required this.distance,
    required this.color,
    required this.width,
    required this.height,
  });
}
