import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jhc_app/Home/Clubs.dart';
import 'package:jhc_app/Home/Sports.dart';
import 'package:jhc_app/Home/LiveSports/LiveSports.dart';
import 'package:jhc_app/Home/Popup/Notification.dart';
import 'package:jhc_app/main.dart';
import 'package:jhc_app/Home/News.dart';

class RealHomePage extends StatefulWidget {
  @override
  _RealHomePageState createState() => _RealHomePageState();
}

class _RealHomePageState extends State<RealHomePage> {

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
            gradient: LinearGradient(
              colors: [Color(0xFF000000), Color(0xFF001020)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: screenHeight * 0.05),
                    _buildSectionHeader(context, "Recent Events",
                        MyHomePage(selectedIndex: 2), titleFontSize),
                    SizedBox(height: screenHeight * 0.02),
                    Container(
                      width: isDesktop ? screenWidth * 0.8 : screenWidth,
                      child: NewsHome(),
                    ),
                    
                    SizedBox(height: screenHeight * 0.05),
                    _buildSectionHeader(context, "Live Sports",
                        MyHomePage(selectedIndex: 1), titleFontSize),
                    SizedBox(height: screenHeight * 0.02),
                    Container(
                      width: isDesktop ? screenWidth * 0.8 : screenWidth,
                      child: LiveSports(parameter: true,),
                    ),

                    SizedBox(height: screenHeight * 0.05),
                    _buildSectionHeader(context, "Clubs Activities",
                        MyHomePage(selectedIndex: 3), titleFontSize),
                    SizedBox(height: screenHeight * 0.02),
                    Container(
                      width: isDesktop ? screenWidth * 0.8 : screenWidth,
                      child: ClubsHome(),
                    ),

                    SizedBox(height: screenHeight * 0.05),
                    _buildSectionHeader(context, "Sports Activities",
                        MyHomePage(selectedIndex: 1), titleFontSize),
                    Container(
                      width: isDesktop ? screenWidth * 0.8 : screenWidth,
                      child: SportsHome(),
                    ),

                    SizedBox(height: screenHeight * 0.05),
                  ],
                ),
              ),
              NotificationPopup(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, String title, Widget page, double fontSize) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            textStyle: TextStyle(
              fontSize: 22,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        FloatingActionButton(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Icon(
            Icons.arrow_outward_outlined,
            color: Colors.white,
            size: fontSize * 1.2,
          ),
          onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (context) => page)),
        ),
      ],
    );
  }
}