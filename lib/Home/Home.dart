import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jhc_app/Home/Clubs.dart';
import 'package:jhc_app/Home/Popup/Alert.dart';
import 'package:jhc_app/Home/Popup/Notification.dart';
import 'package:jhc_app/Home/Popup/Sportsmeet.dart';
import 'package:jhc_app/Home/Sports.dart';
import 'package:jhc_app/Home/LiveSports/LiveSports.dart';
import 'package:jhc_app/main.dart';
import 'package:jhc_app/Home/News.dart';

class RealHomePage extends StatefulWidget {
  @override
  _RealHomePageState createState() => _RealHomePageState();
}

class _RealHomePageState extends State<RealHomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 1.0, curve: Curves.easeInOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double screenWidth = constraints.maxWidth;
        double screenHeight = constraints.maxHeight;
        bool isDesktop = screenWidth > 800;
        double titleFontSize =
            isDesktop ? screenHeight * 0.04 : screenHeight * 0.03;
        double horizontalPadding =
            isDesktop ? screenWidth * 0.1 : screenWidth * 0.05;

        return Container(
          height: screenHeight,
          padding:
              EdgeInsets.symmetric(vertical: 16, horizontal: horizontalPadding),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 15, 20, 25),
          ),
          child: Stack(
            children: [
              _buildAnimatedBackground(screenWidth, screenHeight),
              SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _slideAnimation.value),
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: Column(
                          children: [
                            SizedBox(height: screenHeight * 0.05),
                            _buildSectionHeader(
                              context,
                              "Recent Updates",
                              MyHomePage(selectedIndex: 1),
                              titleFontSize,
                              Icons.newspaper,
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            _buildSectionContainer(
                              context,
                              NewsHome(),
                              isDesktop ? screenWidth * 0.8 : screenWidth,
                            ),
                            SizedBox(height: screenHeight * 0.05),
                            _buildSectionHeader(
                              context,
                              "Live Sports",
                              MyHomePage(selectedIndex: 2),
                              titleFontSize,
                              Icons.live_tv_rounded,
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            _buildSectionContainer(
                              context,
                              LiveSports(parameter: true),
                              isDesktop ? screenWidth * 0.8 : screenWidth,
                            ),
                            SizedBox(height: screenHeight * 0.05),
                            _buildSectionHeader(
                              context,
                              "Clubs Activities",
                              MyHomePage(selectedIndex: 3),
                              titleFontSize,
                              Icons.account_balance,
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            _buildSectionContainer(
                              context,
                              ClubsHome(),
                              isDesktop ? screenWidth * 0.8 : screenWidth,
                            ),
                            SizedBox(height: screenHeight * 0.05),
                            _buildSectionHeader(
                              context,
                              "Sports Activities",
                              MyHomePage(selectedIndex: 2),
                              titleFontSize,
                              Icons.sports_baseball_rounded,
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            _buildSectionContainer(
                              context,
                              SportsHome(),
                              isDesktop ? screenWidth * 0.8 : screenWidth,
                            ),
                            SizedBox(height: screenHeight * 0.05),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              NotificationPopup(),
              SportsmeetPopup(),
              AlertPopup(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnimatedBackground(double screenWidth, double screenHeight) {
    return Stack(
      children: [
        Positioned(
          top: screenHeight * 0.1,
          right: screenWidth * 0.1,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.blue.withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: screenHeight * 0.2,
          left: screenWidth * 0.05,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.purple.withOpacity(0.08),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: _WavePainter(_animationController),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    Widget page,
    double fontSize,
    IconData icon,
  ) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => page,
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ),
        ),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 8),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.05),
                Colors.white.withOpacity(0.02),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 15, 20, 25),
                      gradient: LinearGradient(
                        colors: [Color(0xFF00D4FF), Color(0xFF0099FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: Colors.white, size: 20),
                  ),
                  SizedBox(width: 12),
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionContainer(
      BuildContext context, Widget child, double width) {
    return MouseRegion(
      child: Container(
        width: width,
        child: ClipRRect(
          child: child,
        ),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final Animation<double> animation;

  _WavePainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Color(0xFF00D4FF).withOpacity(0.03),
          Color(0xFF0099FF).withOpacity(0.01),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final wavePath = Path();
    final baseHeight = size.height * 0.7;
    final waveAmplitude = 20.0;
    final waveFrequency = 0.01;
    final animationValue = animation.value;

    wavePath.moveTo(0, baseHeight);

    for (double i = 0; i <= size.width; i++) {
      final y = baseHeight +
          math.sin((i * waveFrequency) + (animationValue * 2 * math.pi)) *
              waveAmplitude;
      wavePath.lineTo(i, y);
    }

    canvas.drawPath(wavePath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
