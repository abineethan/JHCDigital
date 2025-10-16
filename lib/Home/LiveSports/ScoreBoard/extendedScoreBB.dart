import 'dart:convert';
import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:jhc_app/Home/LiveSports/ScoreBoard/extendedScoreBasketBall.dart';

class BBMatchPage extends StatelessWidget {
  final String eTeam1;
  final String eTeam2;
  final String liveScoreE;
  final String matchName;
  final String eTeam1Logo;
  final String eTeam2Logo;

  const BBMatchPage({
    Key? key,
    required this.eTeam1,
    required this.eTeam2,
    required this.liveScoreE,
    required this.matchName,
    required this.eTeam1Logo,
    required this.eTeam2Logo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> originalLiveScore = json.decode(liveScoreE);
    final Map<String, dynamic> liveScore = 
        originalLiveScore['BasketBall'][matchName]['Stats'];

    final List<String> shootersTeam1 = [];
    final Map<String, num> shootersPointsTeam1 = {};
    final Map<String, num> foulsTeam1 = {};
    final List<String> shootersTeam2 = [];
    final Map<String, num> shootersPointsTeam2 = {};
    final Map<String, num> foulsTeam2 = {};

    // Calculate total points for each team
    num totalPointsTeam1 = 0;
    num totalPointsTeam2 = 0;

    bool isMobile(BuildContext context) =>
        MediaQuery.of(context).size.width < 600;
    bool isTablet(BuildContext context) =>
        MediaQuery.of(context).size.width >= 600 &&
        MediaQuery.of(context).size.width < 1200;
    bool isDesktop(BuildContext context) =>
        MediaQuery.of(context).size.width >= 1200;

    liveScore.forEach((key, value) {
      if (value['Shooting Team'] == eTeam1) {
        if (!shootersTeam1.contains(value['Shooter'])) {
          shootersTeam1.add(value['Shooter']);
        }
        shootersPointsTeam1[value['Shooter']] =
            (shootersPointsTeam1[value['Shooter']] ?? 0) + (value['Points'] ?? 0);
        foulsTeam1[value['Shooter']] =
            (foulsTeam1[value['Shooter']] ?? 0) + (value['Fouls'] ?? 0);
        totalPointsTeam1 += (value['Points'] ?? 0);
      } else if (value['Shooting Team'] == eTeam2) {
        if (!shootersTeam2.contains(value['Shooter'])) {
          shootersTeam2.add(value['Shooter']);
        }
        shootersPointsTeam2[value['Shooter']] =
            (shootersPointsTeam2[value['Shooter']] ?? 0) + (value['Points'] ?? 0);
        foulsTeam2[value['Shooter']] =
            (foulsTeam2[value['Shooter']] ?? 0) + (value['Fouls'] ?? 0);
        totalPointsTeam2 += (value['Points'] ?? 0);
      }
    });

    final String eTotalScoreTeam1 = totalPointsTeam1.toString();
    final String eTotalScoreTeam2 = totalPointsTeam2.toString();

    return SafeArea(
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            title: Text(
              matchName,
              style: TextStyle(
                color: Colors.white,
                fontSize: isDesktop(context) ? 24 : 18,
              ),
            ),
            elevation: 0.0,
            centerTitle: true,
            foregroundColor: Colors.white,
            backgroundColor: Colors.black,
            bottom: TabBar(
              labelPadding: EdgeInsets.symmetric(
                horizontal: isDesktop(context) ? 24.0 : 4.0,
              ),
              indicatorWeight: 1.0,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white,
              labelStyle: TextStyle(
                fontSize: isDesktop(context) ? 18 : 14,
              ),
              tabs: const [
                Tab(text: "SUMMARY"),
                Tab(text: "SCORECARD"),
              ],
            ),
          ),
          body: TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            dragStartBehavior: DragStartBehavior.start,
            children: [
              // SUMMARY TAB
              SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(0),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(
                          height: isDesktop(context)
                              ? MediaQuery.of(context).size.height *
                                  0.5 // Desktop
                              : isTablet(context)
                                  ? MediaQuery.of(context).size.height *
                                      0.38 // Tablet
                                  : MediaQuery.of(context).size.height * 0.28,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.1),
                          ),
                          child: Stack(
                            children: [
                              Image.network(
                                "https://t3.ftcdn.net/jpg/01/05/51/40/360_F_105514051_uSAV0YVEVO3gd8D4PiCEZqHkkQJNRX9B.jpg",
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.cover,
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 74, 72, 75)
                                      .withOpacity(0.75),
                                ),
                                child: Column(
                                  children: [
                                    SizedBox(
                                        height: isMobile(context) ? 15 : 25),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Expanded(
                                          child: Center(
                                            child: Text(
                                              eTeam1,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: isMobile(context)
                                                    ? MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.07
                                                    : isTablet(context)
                                                        ? 24
                                                        : 32,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign.center,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                            width: isMobile(context) ? 3 : 20),
                                        Expanded(
                                          child: Center(
                                            child: Text(
                                              eTeam2,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: isMobile(context)
                                                    ? MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.07
                                                    : isTablet(context)
                                                        ? 24
                                                        : 32,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign.center,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                        height: isMobile(context) ? 10 : 20),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Image.network(
                                          eTeam1Logo,
                                          height: isMobile(context)
                                              ? 100
                                              : isTablet(context)
                                                  ? 150
                                                  : 200,
                                          width: isMobile(context)
                                              ? 100
                                              : isTablet(context)
                                                  ? 150
                                                  : 200,
                                          fit: BoxFit.contain,
                                        ),
                                        SizedBox(
                                            width: isMobile(context) ? 3 : 20),
                                        Image.network(
                                          eTeam2Logo,
                                          height: isMobile(context)
                                              ? 100
                                              : isTablet(context)
                                                  ? 150
                                                  : 200,
                                          width: isMobile(context)
                                              ? 100
                                              : isTablet(context)
                                                  ? 150
                                                  : 200,
                                          fit: BoxFit.contain,
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                        height: isMobile(context) ? 10 : 20),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Expanded(
                                          child: Center(
                                            child: Text(
                                              eTotalScoreTeam1,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'sans-serif',
                                                fontSize: isMobile(context)
                                                    ? MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.06
                                                    : isTablet(context)
                                                        ? 36
                                                        : 48,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                            width: isMobile(context) ? 3 : 10),
                                        Expanded(
                                          child: Center(
                                            child: Text(
                                              eTotalScoreTeam2,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'sans-serif',
                                                fontSize: isMobile(context)
                                                    ? MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.06
                                                    : isTablet(context)
                                                        ? 36
                                                        : 48,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                        height: isMobile(context) ? 15 : 25),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      margin: EdgeInsets.all(isDesktop(context)
                          ? 16
                          : MediaQuery.of(context).size.width * 0.01),
                      padding: EdgeInsets.all(isDesktop(context) ? 32 : 25),
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(200, 20, 21, 24),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                (shootersTeam1.isEmpty)
                                    ? " "
                                    : shootersTeam1.last,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isDesktop(context) ? 28 : 22,
                                ),
                              ),
                              Text(
                                "Last Goal",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isDesktop(context) ? 18 : 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    Container(
                      margin: EdgeInsets.all(isDesktop(context)
                          ? 16
                          : MediaQuery.of(context).size.width * 0.01),
                      padding: EdgeInsets.all(isDesktop(context) ? 32 : 25),
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(200, 20, 21, 24),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                (shootersTeam2.isEmpty)
                                    ? " "
                                    : shootersTeam2.last,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isDesktop(context) ? 28 : 22,
                                ),
                              ),
                              Text(
                                "Last Goal",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isDesktop(context) ? 18 : 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    MyTableWidget(
                      rowCount: shootersTeam1.length,
                      teamshootersnames: shootersTeam1,
                      teamshooterspoints: shootersPointsTeam1,
                      fouls: foulsTeam1,
                      caption: "Shooters ($eTeam1)",
                      isDesktop: isDesktop(context),
                    ),
                    MyTableWidget(
                      rowCount: shootersTeam2.length,
                      teamshootersnames: shootersTeam2,
                      teamshooterspoints: shootersPointsTeam2,
                      fouls: foulsTeam2,
                      caption: "Shooters ($eTeam2)",
                      isDesktop: isDesktop(context),
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
              ),

              // SCORECARD TAB
              SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 15),
                    Container(
                      height: isDesktop(context)
                          ? MediaQuery.of(context).size.height * 0.2
                          : MediaQuery.of(context).size.height * 0.15,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color.fromARGB(200, 20, 21, 24),
                      ),
                      margin: EdgeInsets.all(isDesktop(context) ? 16 : 3),
                      padding: EdgeInsets.all(isDesktop(context) ? 16 : 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SizedBox(width: isDesktop(context) ? 20 : 10),
                              Image.network(
                                eTeam2Logo,
                                width: isDesktop(context) ? 100 : 70,
                                fit: BoxFit.cover,
                              ),
                              SizedBox(width: isDesktop(context) ? 30 : 15),
                              Text(
                                eTeam2,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isDesktop(context) ? 28 : 20,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                eTotalScoreTeam1,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isDesktop(context) ? 28 : 20,
                                ),
                              ),
                              SizedBox(width: isDesktop(context) ? 20 : 8),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: isDesktop(context)
                          ? MediaQuery.of(context).size.height * 0.2
                          : MediaQuery.of(context).size.height * 0.15,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color.fromARGB(200, 20, 21, 24),
                      ),
                      padding: EdgeInsets.all(isDesktop(context) ? 16 : 8),
                      margin: EdgeInsets.all(isDesktop(context) ? 16 : 3),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SizedBox(width: isDesktop(context) ? 20 : 10),
                              Image.network(
                                eTeam1Logo,
                                width: isDesktop(context) ? 100 : 70,
                                fit: BoxFit.cover,
                              ),
                              SizedBox(width: isDesktop(context) ? 30 : 15),
                              Text(
                                eTeam1,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isDesktop(context) ? 28 : 20,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                eTotalScoreTeam2,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isDesktop(context) ? 28 : 20,
                                ),
                              ),
                              SizedBox(width: isDesktop(context) ? 20 : 8),
                            ],
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
}