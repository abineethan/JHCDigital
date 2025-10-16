// ignore_for_file: unused_element, unused_local_variable

import 'dart:convert';
import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyTableWidget extends StatelessWidget {
  final int rowCount;
  final List<String> teamshootersnames;
  final Map<String, num> teamshooterspoints;
  final Map<String, num> fouls;
  final String caption;
  final bool isDesktop;

  const MyTableWidget({
    Key? key,
    required this.rowCount,
    required this.teamshootersnames,
    required this.teamshooterspoints,
    required this.fouls,
    required this.caption,
    required this.isDesktop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (rowCount == 0) {
      return const SizedBox(height: 1);
    }
    
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF1D1E33),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
            child: Text(
              caption,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Table(
              border: TableBorder(
                horizontalInside: BorderSide(color: Colors.white12, width: 1),
              ),
              children: _buildRows(),
              columnWidths: const {
                0: FlexColumnWidth(2.4),
                1: FlexColumnWidth(1.3),
                2: FlexColumnWidth(1),
              },
            ),
          ),
        ],
      ),
    );
  }

  List<TableRow> _buildRows() {
    List<TableRow> rows = [];

    rows.add(
      TableRow(
        decoration: BoxDecoration(
          color: Color.fromARGB(166, 21, 139, 235).withOpacity(0.2),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
        ),
        children: [
          _buildHeaderCell('Players'),
          _buildHeaderCell('Points'),
          _buildHeaderCell('Fouls'),
        ],
      ),
    );

    for (int i = 0; i < rowCount; i++) {
      rows.add(
        TableRow(
          decoration: BoxDecoration(
            color: i.isEven
                ? Colors.transparent
                : Color(0xFF1D1E33).withOpacity(0.5),
          ),
          children: [
            _buildDataCell(teamshootersnames[i], TextAlign.left),
            _buildDataCell('${teamshooterspoints[teamshootersnames[i]] ?? 0}', TextAlign.center),
            _buildDataCell('${fouls[teamshootersnames[i]] ?? 0}', TextAlign.center),
          ],
        ),
      );
    }

    return rows;
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildDataCell(String text, TextAlign align) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 13,
        ),
        textAlign: align,
      ),
    );
  }
}

class BasketBallPage extends StatelessWidget {
  final String eTeam1;
  final String eTeam2;
  final String liveScoreE;
  final String matchName;
  final String eTeam1Logo;
  final String eTeam2Logo;
  final String ematchid;
  final String ecategory;
  final String ewin;

  const BasketBallPage({
    Key? key,
    required this.eTeam1,
    required this.eTeam2,
    required this.liveScoreE,
    required this.matchName,
    required this.eTeam1Logo,
    required this.eTeam2Logo,
    required this.ematchid,
    required this.ecategory,
    required this.ewin,
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

    num totalPointsTeam1 = 0;
    num totalPointsTeam2 = 0;

    bool isMobile(BuildContext context) =>
        MediaQuery.of(context).size.width < 600;
    bool isTablet(BuildContext context) =>
        MediaQuery.of(context).size.width >= 600 &&
        MediaQuery.of(context).size.width < 1200;
    bool isDesktop(BuildContext context) =>
        MediaQuery.of(context).size.width >= 1200;

    bool isMatchFinished = ewin.isNotEmpty;

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
          backgroundColor: Color(0xFF0A0E21),
          appBar: AppBar(
            title: Text(
              matchName,
              style: TextStyle(
                color: Colors.white,
                fontSize: isDesktop(context) ? 24 : 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            elevation: 0.0,
            centerTitle: true,
            foregroundColor: Colors.white,
            backgroundColor: Color(0xFF1D1E33),
            bottom: TabBar(
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Color.fromARGB(166, 21, 139, 235),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              labelPadding: EdgeInsets.only(left: 4.0, right: 4),
              labelStyle: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              unselectedLabelColor: Colors.white70,
              tabs: const [
                Tab(text: "SUMMARY"),
                Tab(text: "SQUAD"),
              ],
            ),
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1D1E33),
                  Color(0xFF0A0E21),
                ],
              ),
            ),
            child: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              dragStartBehavior: DragStartBehavior.start,
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _buildMatchCard(
                        context,
                        eTeam1,
                        eTeam2,
                        eTeam1Logo,
                        eTeam2Logo,
                        totalPointsTeam1.toInt(),
                        totalPointsTeam2.toInt(),
                        ewin,
                      ),
                      SizedBox(height: 20),

                      if (isMatchFinished)
                        _buildMatchResultCard(context, ewin, eTeam1, eTeam2)
                      else
                        Row(
                          children: [
                            Expanded(
                              child: _buildPlayerCard(
                                context,
                                shootersTeam1.isNotEmpty ? shootersTeam1.last : "",
                                "Last Goal",
                                Icons.person,
                                Colors.green,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: _buildPlayerCard(
                                context,
                                shootersTeam2.isNotEmpty ? shootersTeam2.last : "",
                                "Last Goal",
                                Icons.person,
                                Colors.red,
                              ),
                            ),
                          ],
                        ),
                      SizedBox(height: 20),

                      MyTableWidget(
                        rowCount: shootersTeam1.length,
                        teamshootersnames: shootersTeam1,
                        teamshooterspoints: shootersPointsTeam1,
                        fouls: foulsTeam1,
                        caption: "Players ($eTeam1)",
                        isDesktop: isDesktop(context),
                      ),
                      SizedBox(height: 16),
                      
                      MyTableWidget(
                        rowCount: shootersTeam2.length,
                        teamshootersnames: shootersTeam2,
                        teamshooterspoints: shootersPointsTeam2,
                        fouls: foulsTeam2,
                        caption: "Players ($eTeam2)",
                        isDesktop: isDesktop(context),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),

                SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildSquadTab(
                    context, ematchid, ecategory, eTeam1, eTeam2
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMatchCard(
    BuildContext context,
    String team1,
    String team2,
    String team1Logo,
    String team2Logo,
    int team1Score,
    int team2Score,
    String winStatus,
  ) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF1D1E33).withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          CachedNetworkImage(
                            imageUrl: team1Logo,
                            height: isMobile ? 80 : 120,
                            width: isMobile ? 80 : 120,
                            errorWidget: (context, url, error) => Icon(
                              Icons.sports_basketball,
                              size: 40,
                              color: Colors.white
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            team1.toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isMobile ? 14 : 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        "VS",
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: isMobile ? 16 : 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          CachedNetworkImage(
                            imageUrl: team2Logo,
                            height: isMobile ? 80 : 120,
                            width: isMobile ? 80 : 120,
                            errorWidget: (context, url, error) => Icon(
                              Icons.sports_basketball,
                              size: 40,
                              color: Colors.white
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            team2.toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isMobile ? 14 : 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Text(
                        team1Score.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isMobile ? 32 : 48,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        team2Score.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isMobile ? 32 : 48,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),

                if (winStatus.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: _buildMatchResultIndicator(winStatus, team1, team2, context),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMatchResultIndicator(
    String winStatus, String team1, String team2, BuildContext context) {
    String resultText;
    Color resultColor;
    
    if (winStatus == "1") {
      resultText = "$team1 WON";
      resultColor = Colors.green;
    } else if (winStatus == "2") {
      resultText = "$team2 WON";
      resultColor = Colors.green;
    } else {
      resultText = "MATCH DRAW";
      resultColor = Colors.orange;
    }

    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth * 0.8,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: resultColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: resultColor, width: 1),
      ),
      child: Text(
        resultText,
        style: TextStyle(
          color: resultColor,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildMatchResultCard(
    BuildContext context, String winStatus, String team1, String team2) {
    String resultText;
    IconData resultIcon;
    Color resultColor;

    if (winStatus == "1") {
      resultText = "$team1 WON THE MATCH";
      resultIcon = Icons.emoji_events;
      resultColor = Colors.amber;
    } else if (winStatus == "2") {
      resultText = "$team2 WON THE MATCH";
      resultIcon = Icons.emoji_events;
      resultColor = Colors.amber;
    } else {
      resultText = "MATCH ENDED IN A DRAW";
      resultIcon = Icons.handshake;
      resultColor = Colors.blue;
    }

    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth - 32,
      decoration: BoxDecoration(
        color: Color(0xFF1D1E33),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(resultIcon, color: resultColor, size: 40),
          SizedBox(height: 12),
          Text(
            resultText,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            "Match Finished",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerCard(BuildContext context, String name, String role,
      IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF1D1E33),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              SizedBox(width: 8),
              Text(
                role.toUpperCase(),
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            name,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSquadTab(BuildContext context, String ematchId, String ecategory,
      String team1, String team2) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('Sports')
          .doc('Basketball')
          .collection('Scores')
          .doc('Categories')
          .collection(ecategory)
          .doc(ematchId)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                  Color.fromARGB(166, 21, 139, 235)),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          return Center(
            child: Text(
              "Squad data not available",
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        var data = snapshot.data!.data() as Map<String, dynamic>;
        List<dynamic> team1Players = data['team1players'] ?? [];
        List<dynamic> team2Players = data['team2players'] ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          team1,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      for (int i = 0; i < team1Players.length; i++)
                        Container(
                          margin: EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: Color(0xFF1D1E33),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(166, 21, 139, 235),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${i + 1}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                team1Players[i],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          team2,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      for (int i = 0; i < team2Players.length; i++)
                        Container(
                          margin: EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: Color(0xFF1D1E33),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(166, 21, 139, 235),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${i + 1}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                team2Players[i],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}