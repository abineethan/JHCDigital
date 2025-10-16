// ignore_for_file: unused_local_variable, unused_element, must_be_immutable

import 'dart:convert';
import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CricketPage extends StatelessWidget {
  int etotalRunsTeam1 = 0;
  int etotalRunsTeam2 = 0;
  int etotalWicketTeam1 = 0;
  int etotalWicketTeam2 = 0;
  String eTeam1;
  String eTeam2;
  String eoverpointball = "";
  String eoverpointball1 = "";
  String eoverpointball2 = "";
  String matchName;
  String ebatter = "";
  String eballer = "";
  String eTotalScoreTeam1;
  String eTotalScoreTeam2;
  String eTeam1Logo;
  String eTeam2Logo;
  String ecategory;
  String ewin;
  String ematchid;

  bool fun = false;

  DatabaseReference refSports = FirebaseDatabase.instance.ref('Sports/');

  CricketPage(
      {required this.eTeam1,
      required this.eTeam2,
      required this.matchName,
      required this.eTotalScoreTeam1,
      required this.eTotalScoreTeam2,
      required this.eTeam1Logo,
      required this.eTeam2Logo,
      required this.ematchid,
      required this.ecategory,
      required this.ewin});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
        stream: refSports.onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (snapshot.hasData &&
              snapshot.data != null &&
              snapshot.data!.snapshot.value != null) {
            final data = snapshot.data!.snapshot.value;
            final screenHeight = MediaQuery.of(context).size.height;
            final screenWidth = MediaQuery.of(context).size.width;

            bool isMobile(BuildContext context) =>
                MediaQuery.of(context).size.width < 600;
            bool isTablet(BuildContext context) =>
                MediaQuery.of(context).size.width >= 600 &&
                MediaQuery.of(context).size.width < 1200;
            bool isDesktop(BuildContext context) =>
                MediaQuery.of(context).size.width >= 1200;

            String jsonData = jsonEncode(data);
            Map<String, dynamic> originalLiveScore = json.decode(jsonData);
            Map<String, dynamic> liveScore = originalLiveScore['Cricket'];

            List<int> totalWicketTeam1 = [];
            List<int> totalWicketTeam2 = [];
            List<int> totalRunsTeam1 = [];
            List<int> totalRunsTeam2 = [];
            List<String> overpointball1 = [];
            List<String> overpointball2 = [];

            List<String> Batter = [];
            List<String> Baller = [];
            List<String> Team1 = [];
            List<String> Team2 = [];
            String newLastOverKey = "";
            String lastballkey = "";
            int i = 0;

            liveScore.forEach((key, value) {
              String currentBattingTeam =
                  liveScore[matchName]['Details']['Team A'];

              liveScore[matchName]['Stats'].forEach((key2, value2) {
                if (i == 0) {
                  Map<String, dynamic> liveScoreTeam1 =
                      liveScore[matchName]['Stats'][key2];

                  Team1.add(key2);
                  int totalWicketsteam1 = 0;
                  liveScoreTeam1.forEach((over, balls) {
                    balls.forEach((ball, details) {
                      if (details['wicket'] != 'NotOut') {
                        totalWicketsteam1++;
                      }
                    });
                  });
                  totalWicketTeam1.add(totalWicketsteam1);
                  int totalRunsteam1 = 0;
                  liveScoreTeam1.forEach((over, balls) {
                    balls.forEach((ball, details) {
                      if (details is Map<String, dynamic> &&
                          details.containsKey('runs')) {
                        totalRunsteam1 += details['runs'] as int;
                      }
                    });
                  });
                  totalRunsTeam1.add(totalRunsteam1);

                  List<String> overKeys1 = liveScoreTeam1.keys.toList();
                  int compareOver(String a, String b) {
                    int numA = int.parse(a.substring(4));
                    int numB = int.parse(b.substring(4));
                    return numA.compareTo(numB);
                  }

                  overKeys1.sort(compareOver);
                  String lastOverKey1 =
                      overKeys1.isNotEmpty ? overKeys1.last : '';
                  newLastOverKey = lastOverKey1.substring(4);

                  Map<String, dynamic> lastOverData1 =
                      liveScoreTeam1[lastOverKey1];

                  List<String> ballKeys1 = lastOverData1.keys.toList();
                  ballKeys1.sort(compareOver);

                  String lastBallKey1 =
                      overKeys1.isNotEmpty ? ballKeys1.last : '';
                  lastballkey = lastBallKey1.substring(4);

                  if (lastballkey == '6') {
                    overpointball1.add(newLastOverKey);
                  } else {
                    int newLastOverKeyint = int.parse(newLastOverKey);
                    newLastOverKeyint = newLastOverKeyint - 1;
                    newLastOverKey = newLastOverKeyint.toString();
                    overpointball1.add(newLastOverKey + '.' + lastballkey);
                  }
                  Map<String, dynamic> lastBallData1 =
                      lastOverData1[lastBallKey1];
                  if (currentBattingTeam == key2) {
                    Batter.add(lastBallData1["batter"]);
                    Baller.add(lastBallData1["baller"]);
                  }
                  i = i + 1;
                } else {
                  Team2.add(key2);
                  Map<String, dynamic> liveScoreTeam2 =
                      liveScore[matchName]['Stats'][key2];
                  int totalWicketsteam2 = 0;
                  liveScoreTeam2.forEach((over, balls) {
                    balls.forEach((ball, details) {
                      if (details['wicket'] != 'NotOut') {
                        totalWicketsteam2++;
                      }
                    });
                  });
                  totalWicketTeam2.add(totalWicketsteam2);

                  int totalRunsteam2 = 0;
                  liveScoreTeam2.forEach((over, balls) {
                    balls.forEach((ball, details) {
                      if (details is Map<String, dynamic> &&
                          details.containsKey('runs')) {
                        totalRunsteam2 += details['runs'] as int;
                      }
                    });
                  });
                  totalRunsTeam2.add(totalRunsteam2);
                  List<String> overKeys = liveScoreTeam2.keys.toList();
                  int compareOver(String a, String b) {
                    int numA = int.parse(a.substring(4));
                    int numB = int.parse(b.substring(4));
                    return numA.compareTo(numB);
                  }

                  overKeys.sort(compareOver);
                  String lastOverKey = overKeys.isNotEmpty ? overKeys.last : '';
                  newLastOverKey = lastOverKey.substring(4);
                  Map<String, dynamic> lastOverData =
                      liveScoreTeam2[lastOverKey];

                  List<String> ballKeys = lastOverData.keys.toList();
                  ballKeys.sort(compareOver);

                  String lastBallKey = overKeys.isNotEmpty ? ballKeys.last : '';
                  lastballkey = lastBallKey.substring(4);
                  Map<String, dynamic> lastBallData = lastOverData[lastBallKey];
                  if (currentBattingTeam == key2) {
                    Batter.add(lastBallData["batter"]);
                    Baller.add(lastBallData["baller"]);
                  }
                  if (lastballkey == '6') {
                    overpointball2.add(newLastOverKey);
                  } else {
                    int newLastOverKeyint = int.parse(newLastOverKey);
                    newLastOverKeyint = newLastOverKeyint - 1;
                    newLastOverKey = newLastOverKeyint.toString();
                    overpointball2.add(newLastOverKey + '.' + lastballkey);
                  }

                  i = 0;
                }
              });
              String a =
                  "${totalRunsTeam1.last}/${totalWicketTeam1.last}(${overpointball1.last})";
              eTotalScoreTeam1 = a;
              String b =
                  "${totalRunsTeam2.last}/${totalWicketTeam2.last}(${overpointball2.last})";
              eTotalScoreTeam2 = b;
            });

            Map<String, dynamic> liveScoreE2 = json.decode(jsonData);
            Map<String, dynamic> liveScoreE3 =
                liveScoreE2['Cricket'][matchName]['Stats'][eTeam1];

            Map<String, num> battersTeam1 = {};
            Map<String, num> ballersTeam1 = {};

            Map<String, num> battersTeam1Balls = {};
            Map<String, num> battersTeam2Balls = {};

            Map<String, num> battersTeam2 = {};
            Map<String, num> ballersTeam2 = {};

            Map<String, String> wicketsTeam1 = {};
            Map<String, String> wicketsTeam2 = {};

            int totalBallsTeam1 = 0;
            int totalBallsTeam2 = 0;

            Map<String, num> fours = {};
            Map<String, num> sixes = {};

            Map<String, num> totalBallsBallersTeam1 = {};
            Map<String, num> totalBallsBallersTeam2 = {};

            Map<String, num> totalRunsBallersTeam1 = {};
            Map<String, num> totalRunsBallersTeam2 = {};

            liveScoreE3.forEach(
              (over, balls) {
                liveScoreE3[over].forEach((ball, data) {
                  totalBallsTeam1 += totalBallsTeam1;
                  String currentBatter =
                      liveScoreE3[over][ball]['batter'].toString();
                  if (liveScoreE3[over][ball]['runs'] != null) {
                    if (liveScoreE3[over][ball]['runs'] == 4) {
                      fours[currentBatter] = (fours[currentBatter] ?? 0) + 1;
                    }
                    if (liveScoreE3[over][ball]['runs'] == 6) {
                      sixes[currentBatter] = (sixes[currentBatter] ?? 0) + 1;
                    }
                    battersTeam1[currentBatter] =
                        (battersTeam1[currentBatter] ?? 0) +
                            liveScoreE3[over][ball]['runs'];
                    battersTeam1Balls[currentBatter] =
                        (battersTeam1Balls[currentBatter] ?? 0) + 1;
                  }

                  String currentBaller = "";
                  currentBaller = liveScoreE3[over][ball]['baller'].toString();
                  totalBallsBallersTeam1[currentBaller] =
                      (totalBallsBallersTeam1[currentBaller] ?? 0) + 1;
                  totalRunsBallersTeam1[currentBaller] =
                      (totalRunsBallersTeam1[currentBaller] ?? 0) +
                          liveScoreE3[over][ball]['runs'];
                  if (liveScoreE3[over][ball]['wicket'] != null) {
                    if (liveScoreE3[over][ball]['wicket'].toString() !=
                        "NotOut") {
                      ballersTeam1[liveScoreE3[over][ball]['baller']] =
                          (ballersTeam1[liveScoreE3[over][ball]['baller']] ??
                                  0) +
                              1;
                      String currentBall =
                          liveScoreE3[over][ball]['batter'].toString() +
                              ' ' +
                              liveScoreE3[over][ball]['baller'].toString() +
                              ' ' +
                              liveScoreE3[over][ball]['wicket'].toString() +
                              ' ' +
                              liveScoreE3[over][ball]['outby'].toString();
                      wicketsTeam1[ball] = currentBall;
                    } else {
                      ballersTeam1[liveScoreE3[over][ball]['baller']] =
                          (ballersTeam1[liveScoreE3[over][ball]['baller']] ??
                                  0) +
                              0;
                    }
                  }
                });
              },
            );

            Map<String, dynamic> liveScoreE4 =
                liveScoreE2['Cricket'][matchName]['Stats'][eTeam2];
            liveScoreE4.forEach(
              (over, balls) {
                liveScoreE4[over].forEach((ball, data) {
                  totalBallsTeam2 += totalBallsTeam2;
                  String currentBatter =
                      liveScoreE4[over][ball]['batter'].toString();
                  if (liveScoreE4[over][ball]['runs'] != null) {
                    if (liveScoreE4[over][ball]['runs'] == 4) {
                      fours[currentBatter] = (fours[currentBatter] ?? 0) + 1;
                    }
                    if (liveScoreE4[over][ball]['runs'] == 6) {
                      sixes[currentBatter] = (sixes[currentBatter] ?? 0) + 1;
                    }
                    battersTeam2[currentBatter] =
                        (battersTeam2[currentBatter] ?? 0) +
                            liveScoreE4[over][ball]['runs'];
                    battersTeam2Balls[currentBatter] =
                        (battersTeam2Balls[currentBatter] ?? 0) + 1;
                  }
                  String currentBaller = "";
                  currentBaller = liveScoreE4[over][ball]['baller'].toString();
                  totalBallsBallersTeam2[currentBaller] =
                      (totalBallsBallersTeam2[currentBaller] ?? 0) + 1;
                  totalRunsBallersTeam2[currentBaller] =
                      (totalRunsBallersTeam2[currentBaller] ?? 0) +
                          liveScoreE4[over][ball]['runs'];

                  if (liveScoreE4[over][ball]['wicket'] != null) {
                    if (liveScoreE4[over][ball]['wicket'].toString() !=
                        "NotOut") {
                      ballersTeam2[currentBaller] =
                          (ballersTeam2[currentBaller] ?? 0) + 1;
                      String currentBall =
                          liveScoreE4[over][ball]['batter'].toString() +
                              ' ' +
                              liveScoreE4[over][ball]['baller'].toString() +
                              ' ' +
                              liveScoreE4[over][ball]['wicket'].toString() +
                              ' ' +
                              liveScoreE4[over][ball]['outby'].toString();
                      wicketsTeam2[ball] = currentBall;
                    } else {
                      ballersTeam2[currentBaller] =
                          (ballersTeam2[currentBaller] ?? 0) + 0;
                    }
                  }
                });
              },
            );
            List<String> team1BattersNames = battersTeam1.keys.toList();
            List<num> team1BattersRuns = battersTeam1.values.toList();

            List<String> team2BattersNames = battersTeam2.keys.toList();
            List<num> team2BattersRuns = battersTeam2.values.toList();
            List<String> team1BallersNames = ballersTeam1.keys.toList();
            List<num> team1BallersWickets = ballersTeam1.values.toList();
            List<String> team2BallersNames = ballersTeam2.keys.toList();
            List<num> team2BallersWickets = ballersTeam2.values.toList();

            ebatter = battersTeam1.keys.toList().last.toString();
            eballer = battersTeam2.keys.toList().last.toString();
            if (totalRunsTeam1.isEmpty) {
              totalRunsTeam1.add(0);
            }
            if (totalRunsTeam2.isEmpty) {
              totalRunsTeam2.add(0);
            }
            if (totalWicketTeam1.isEmpty) {
              totalWicketTeam1.add(0);
            }
            if (totalWicketTeam2.isEmpty) {
              totalWicketTeam2.add(0);
            }
            if (overpointball1.isEmpty) {
              overpointball1.add("0");
            }
            if (overpointball2.isEmpty) {
              overpointball2.add("0");
            }
            if (team1BattersNames.isEmpty) {
              team1BattersNames.add("");
            }
            if (team2BattersNames.isEmpty) {
              team2BattersNames.add("");
            }
            if (team1BattersRuns.isEmpty) {
              team1BattersRuns.add(0);
            }
            if (team2BattersRuns.isEmpty) {
              team2BattersRuns.add(0);
            }
            if (team1BallersNames.isEmpty) {
              team1BallersNames.add("");
            }
            if (team2BallersNames.isEmpty) {
              team2BallersNames.add("");
            }
            if (team1BallersWickets.isEmpty) {
              team1BallersWickets.add(0);
            }
            if (team2BallersWickets.isEmpty) {
              team2BallersWickets.add(0);
            }
            if (totalBallsBallersTeam1.isEmpty) {
              totalBallsBallersTeam1[""] = 0;
            }
            if (totalBallsBallersTeam2.isEmpty) {
              totalBallsBallersTeam2[""] = 0;
            }
            if (totalRunsBallersTeam1.isEmpty) {
              totalRunsBallersTeam1[""] = 0;
            }
            if (totalRunsBallersTeam2.isEmpty) {
              totalRunsBallersTeam2[""] = 0;
            }
            if (battersTeam1Balls.isEmpty) {
              battersTeam1Balls[''] = 0;
            }
            if (battersTeam1Balls.isEmpty) {
              battersTeam1Balls[''] = 0;
            }

            bool isMatchFinished = ewin.isNotEmpty;

            if (fun) {
              return SizedBox();
            } else {
              return SafeArea(
                child: DefaultTabController(
                  length: 2,
                  child: Scaffold(
                    backgroundColor: Color(0xFF0A0E21),
                    appBar: AppBar(
                      title: Text(matchName.toUpperCase(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          )),
                      elevation: 0,
                      centerTitle: true,
                      backgroundColor: Color(0xFF1D1E33),
                      bottom: TabBar(
                        indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color.fromARGB(166, 21, 139, 235),
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicatorPadding:
                            EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                        labelPadding: EdgeInsets.only(left: 4.0, right: 4),
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        unselectedLabelColor: Colors.white70,
                        tabs: [
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
                        clipBehavior: Clip.antiAlias,
                        physics: NeverScrollableScrollPhysics(),
                        dragStartBehavior: DragStartBehavior.start,
                        children: <Widget>[
                          SingleChildScrollView(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              children: <Widget>[
                                _buildMatchCard(
                                    context,
                                    eTeam1,
                                    eTeam2,
                                    eTeam1Logo,
                                    eTeam2Logo,
                                    totalRunsTeam1.last,
                                    totalWicketTeam1.last,
                                    overpointball1.last,
                                    totalRunsTeam2.last,
                                    totalWicketTeam2.last,
                                    overpointball2.last,
                                    ewin),
                                SizedBox(height: 20),
                                if (isMatchFinished)
                                  _buildMatchResultCard(
                                      context, ewin, eTeam1, eTeam2)
                                else
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildPlayerCard(
                                            context,
                                            "${(team2BattersNames.last == "Batter" || team2BattersNames.last == "") ? team1BattersNames.last : team2BattersNames.last}",
                                            "Current Batter",
                                            Icons.person,
                                            Colors.green),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: _buildPlayerCard(
                                            context,
                                            "${(team2BallersNames.last == "Baller" || team2BallersNames.last == "") ? team1BallersNames.last : team2BallersNames.last}",
                                            "Current Bowler",
                                            Icons.sports_baseball,
                                            Colors.red),
                                      ),
                                    ],
                                  ),
                                SizedBox(height: 20),
                                _buildStatsTable(
                                    context,
                                    team1BattersNames,
                                    team1BattersRuns,
                                    battersTeam1Balls,
                                    fours,
                                    sixes,
                                    "batters",
                                    "Batsmen ($eTeam1)"),
                                SizedBox(height: 16),
                                _buildStatsTable(
                                    context,
                                    team1BallersNames,
                                    team1BallersWickets,
                                    totalBallsBallersTeam1,
                                    totalRunsBallersTeam1,
                                    sixes,
                                    "ballers",
                                    "Bowlers ($eTeam2)"),
                                SizedBox(height: 16),
                                _buildStatsTable(
                                    context,
                                    team2BattersNames,
                                    team2BattersRuns,
                                    battersTeam2Balls,
                                    fours,
                                    sixes,
                                    "batters",
                                    "Batsmen ($eTeam2)"),
                                SizedBox(height: 16),
                                _buildStatsTable(
                                    context,
                                    team2BallersNames,
                                    team2BallersWickets,
                                    totalBallsBallersTeam2,
                                    totalRunsBallersTeam2,
                                    sixes,
                                    "ballers",
                                    "Bowlers ($eTeam1)"),
                                SizedBox(height: 20),
                              ],
                            ),
                          ),
                          SingleChildScrollView(
                            padding: const EdgeInsets.all(16.0),
                            child: _buildSquadTab(
                                context, ematchid, ecategory, eTeam1, eTeam2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
          } else {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Color.fromARGB(166, 21, 139, 235)),
              ),
            );
          }
        });
  }

  Widget _buildMatchCard(
      BuildContext context,
      String team1,
      String team2,
      String team1Logo,
      String team2Logo,
      int team1Runs,
      int team1Wickets,
      String team1Overs,
      int team2Runs,
      int team2Wickets,
      String team2Overs,
      String winStatus) {
    final screenHeight = MediaQuery.of(context).size.height;
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
                            height: isMobile
                                ? screenHeight * 0.1
                                : screenHeight * 0.15,
                            width: isMobile
                                ? screenHeight * 0.1
                                : screenHeight * 0.15,
                            errorWidget: (context, url, error) => Icon(
                                Icons.sports_cricket,
                                size: 40,
                                color: Colors.white),
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
                            height: isMobile
                                ? screenHeight * 0.1
                                : screenHeight * 0.15,
                            width: isMobile
                                ? screenHeight * 0.1
                                : screenHeight * 0.15,
                            errorWidget: (context, url, error) => Icon(
                                Icons.sports_cricket,
                                size: 40,
                                color: Colors.white),
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
                        "$team1Runs/$team1Wickets ($team1Overs)",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isMobile ? 16 : 20,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        "$team2Runs/$team2Wickets ($team2Overs)",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isMobile ? 16 : 20,
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
                    child: _buildMatchResultIndicator(
                        winStatus, team1, team2, context),
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

  Widget _buildStatsTable(
      BuildContext context,
      List<String> names,
      List<num> runs,
      Map<String, num> balls,
      Map<String, num> fours,
      Map<String, num> sixes,
      String whatisit,
      String caption) {
    if (names.isEmpty ||
        names.first.isEmpty ||
        names.first == "Batter" ||
        names.first == "Baller") {
      return SizedBox();
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
              children:
                  _buildTableRows(names, runs, balls, fours, sixes, whatisit),
              columnWidths: {
                0: FlexColumnWidth(2.4),
                1: FlexColumnWidth(1.3),
                2: FlexColumnWidth(1),
                3: FlexColumnWidth(1),
              },
              border: TableBorder(
                horizontalInside: BorderSide(color: Colors.white12, width: 1),
              ),
            ),
          )
        ],
      ),
    );
  }

  List<TableRow> _buildTableRows(
      List<String> names,
      List<num> runs,
      Map<String, num> balls,
      Map<String, num> fours,
      Map<String, num> sixes,
      String whatisit) {
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
          _buildHeaderCell(whatisit == "batters" ? 'Runs' : 'Wickets'),
          _buildHeaderCell(whatisit == "batters" ? 'Balls' : 'Overs'),
          _buildHeaderCell(whatisit == "batters" ? '4s' : 'Runs'),
          _buildHeaderCell(whatisit == "batters" ? '6s' : 'Econ'),
        ],
      ),
    );

    for (int i = 0; i < names.length; i++) {
      final name = names[i];
      final run = runs[i];

      rows.add(
        TableRow(
          decoration: BoxDecoration(
            color: i.isEven
                ? Colors.transparent
                : Color(0xFF1D1E33).withOpacity(0.5),
          ),
          children: [
            _buildDataCell(name, TextAlign.left),
            _buildDataCell(run.toString(), TextAlign.center),
            _buildDataCell(
                whatisit == "batters"
                    ? '${balls[name] ?? 0}'
                    : '${(balls[name] != null) ? (balls[name]! ~/ 6) : ""}.${(balls[name] != null) ? (balls[name]! % 6) : ""}',
                TextAlign.center),
            _buildDataCell('${fours[name] ?? 0}', TextAlign.center),
            _buildDataCell(
                whatisit == "batters"
                    ? '${sixes[name] ?? 0}'
                    : '${(fours[name] != null && balls[name] != null && balls[name]! > 0) ? (fours[name]! / balls[name]!).toStringAsFixed(1) : "0.0"}',
                TextAlign.center),
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

  Widget _buildSquadTab(BuildContext context, String ematchId, String ecategory,
      String team1, String team2) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('Sports')
          .doc('Cricket')
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

        if (snapshot.hasError || !snapshot.hasData) {
          return Center(
            child: Text(
              "Error fetching squad data",
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
