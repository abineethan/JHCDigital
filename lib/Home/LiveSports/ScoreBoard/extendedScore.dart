import 'dart:convert';
import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:jhc_app/Home/LiveSports/ScoreBoard/extendedScoreCricket.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ignore: must_be_immutable
class SecondPage extends StatelessWidget {
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
  String matchid;
  bool fun = false;

  DatabaseReference refSports = FirebaseDatabase.instance.ref('Sports/');

  SecondPage(
      {required this.eTeam1,
      required this.eTeam2,
      required this.matchName,
      required this.eTotalScoreTeam1,
      required this.eTotalScoreTeam2,
      required this.eTeam1Logo,
      required this.eTeam2Logo,
      required this.matchid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
        stream: refSports.onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (snapshot.hasData &&
              snapshot.data != null &&
              snapshot.data!.snapshot.value != null) {
            // Assuming your data is stored in the 'value' property
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

            // Convert DataSnapshot to JSON
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
                      // Check if the wicket status is "out"
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
                      // Check if the wicket status is "out"
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

            if (fun) {
              return SizedBox();
            } else {
              return SafeArea(
                child: DefaultTabController(
                  length: (matchid == "match") ? 2 : 3,
                  child: Scaffold(
                    backgroundColor: Colors.black,
                    appBar: AppBar(
                      title: Text(matchName.toUpperCase(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          )),
                      elevation: 1.0,
                      centerTitle: true,
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.black,
                      bottom: TabBar(
                        labelPadding: EdgeInsets.only(left: 4.0, right: 4),
                        indicatorWeight: 1.0,
                        indicatorColor: Colors.white,
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.white,
                        tabs: [
                          Tab(
                            text: "SUMMARY",
                          ),
                          if (matchid != "match")
                            Tab(
                              text: "SQUAD",
                            ),
                          Tab(
                            text: "SCORECARD",
                          ),
                        ],
                      ),
                    ),
                    body: TabBarView(
                      clipBehavior: Clip.antiAlias,
                      physics: NeverScrollableScrollPhysics(),
                      dragStartBehavior: DragStartBehavior.start,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.all(0),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(
                                  height: 15,
                                ),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(0),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                        sigmaX: 15, sigmaY: 15),
                                    child: Container(
                                      height: isDesktop(context)
                                          ? MediaQuery.of(context).size.height *
                                              0.6
                                          : isTablet(context)
                                              ? MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.42
                                              : MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.3,
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.1),
                                      ),
                                      child: Stack(
                                        children: <Widget>[
                                          Container(
                                            margin: EdgeInsets.all(
                                                isMobile(context)
                                                    ? screenWidth * 0.02
                                                    : screenWidth * 0.05),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      isMobile(context)
                                                          ? 5
                                                          : 15),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Color.fromARGB(
                                                          100, 22, 21, 25)
                                                      .withOpacity(0.2),
                                                  spreadRadius: 5,
                                                  blurRadius: 10,
                                                  offset: Offset(0, 3),
                                                ),
                                              ],
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      isMobile(context)
                                                          ? 15
                                                          : 25),
                                              child: Container(
                                                color: Colors.white
                                                    .withOpacity(0.1),
                                                child: Column(
                                                  children: <Widget>[
                                                    SizedBox(
                                                      height: isMobile(context)
                                                          ? 15
                                                          : 25,
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      children: [
                                                        Text(
                                                          eTeam1.toUpperCase(),
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: isMobile(
                                                                    context)
                                                                ? screenWidth *
                                                                    0.07
                                                                : isTablet(
                                                                        context)
                                                                    ? 24
                                                                    : 32,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width:
                                                              isMobile(context)
                                                                  ? 3
                                                                  : 20,
                                                        ),
                                                        Text(
                                                          eTeam2.toUpperCase(),
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: isMobile(
                                                                    context)
                                                                ? screenWidth *
                                                                    0.07
                                                                : isTablet(
                                                                        context)
                                                                    ? 24
                                                                    : 32,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: isMobile(context)
                                                          ? 10
                                                          : 20,
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      children: [
                                                        CachedNetworkImage(
                                                          imageUrl: eTeam1Logo,
                                                          height: isMobile(
                                                                  context)
                                                              ? screenHeight *
                                                                  0.12
                                                              : isTablet(
                                                                      context)
                                                                  ? screenHeight *
                                                                      0.15
                                                                  : screenHeight *
                                                                      0.18,
                                                          width: isMobile(
                                                                  context)
                                                              ? screenHeight *
                                                                  0.12
                                                              : isTablet(
                                                                      context)
                                                                  ? screenHeight *
                                                                      0.15
                                                                  : screenHeight *
                                                                      0.18,
                                                        ),
                                                        SizedBox(
                                                          width:
                                                              isMobile(context)
                                                                  ? 3
                                                                  : 20,
                                                        ),
                                                        CachedNetworkImage(
                                                          imageUrl: eTeam2Logo,
                                                          height: isMobile(
                                                                  context)
                                                              ? screenHeight *
                                                                  0.12
                                                              : isTablet(
                                                                      context)
                                                                  ? screenHeight *
                                                                      0.15
                                                                  : screenHeight *
                                                                      0.18,
                                                          width: isMobile(
                                                                  context)
                                                              ? screenHeight *
                                                                  0.12
                                                              : isTablet(
                                                                      context)
                                                                  ? screenHeight *
                                                                      0.15
                                                                  : screenHeight *
                                                                      0.18,
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: isMobile(context)
                                                          ? 10
                                                          : 20,
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      children: [
                                                        Text(
                                                          "${totalRunsTeam1.last}/${totalWicketTeam1.last}(${(team1BattersNames.first == "Batter") ? 0 : (overpointball1.last == "0.1") ? 0 : overpointball1.last})",
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontFamily:
                                                                'sans-serif',
                                                            fontSize: isMobile(
                                                                    context)
                                                                ? screenWidth *
                                                                    0.05
                                                                : isTablet(
                                                                        context)
                                                                    ? 20
                                                                    : 28,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width:
                                                              isMobile(context)
                                                                  ? 3
                                                                  : 20,
                                                        ),
                                                        Text(
                                                          "${totalRunsTeam2.last}/${totalWicketTeam2.last}(${(team2BattersNames.first == "Batter") ? 0 : (overpointball2.last == "0.1") ? 0 : overpointball2.last})",
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontFamily:
                                                                'sans-serif',
                                                            fontSize: isMobile(
                                                                    context)
                                                                ? screenWidth *
                                                                    0.05
                                                                : isTablet(
                                                                        context)
                                                                    ? 20
                                                                    : 28,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: isMobile(context)
                                                          ? 15
                                                          : 25,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Container(
                                    margin: EdgeInsets.all(screenWidth * 0.02),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color.fromARGB(100, 22, 21, 25)
                                              .withOpacity(0.2),
                                          spreadRadius: 5,
                                          blurRadius: 10,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: Container(
                                          color: Colors.white.withOpacity(0.1),
                                          child: Container(
                                            margin: EdgeInsets.all(
                                                screenWidth * 0.01),
                                            padding: EdgeInsets.all(25),
                                            width: screenWidth,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: <Widget>[
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Text(
                                                        "${(team2BattersNames.last == "Batter" || team2BattersNames.last == "") ? team1BattersNames.last : team2BattersNames.last}",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 22,
                                                        )),
                                                    Text("Current Batter",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 14,
                                                        )),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                        ))),
                                SizedBox(height: screenHeight * 0.01),
                                Container(
                                    margin: EdgeInsets.all(screenWidth * 0.02),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color.fromARGB(100, 22, 21, 25)
                                              .withOpacity(0.2),
                                          spreadRadius: 5,
                                          blurRadius: 10,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: Container(
                                          color: Colors.white.withOpacity(0.1),
                                          child: Container(
                                            margin: EdgeInsets.all(
                                                screenWidth * 0.01),
                                            padding: EdgeInsets.all(25),
                                            width: screenWidth,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: <Widget>[
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Text(
                                                        "${(team2BallersNames.last == "Baller" || team2BallersNames.last == "") ? team1BallersNames.last : team2BallersNames.last}",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 22,
                                                        )),
                                                    Text("Current Baller",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 14,
                                                        )),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ))),
                                SizedBox(
                                  height: 10,
                                ),
                                MyTableWidget(
                                    rowCount: team1BattersNames.length,
                                    teambattersnames: team1BattersNames,
                                    teambattersruns: team1BattersRuns,
                                    balls: battersTeam1Balls,
                                    fours: fours,
                                    sixes: sixes,
                                    whatisit: "batters",
                                    caption: "Batsmen ($eTeam1)"),
                                SizedBox(height: 10),
                                MyTableWidget(
                                    rowCount: team1BallersNames.length,
                                    teambattersnames: team1BallersNames,
                                    teambattersruns: team1BallersWickets,
                                    balls: totalBallsBallersTeam1,
                                    fours: totalRunsBallersTeam1,
                                    sixes: sixes,
                                    whatisit: "ballers",
                                    caption: "Bowlers ($eTeam2)"),
                                SizedBox(height: 10),
                                MyTableWidget(
                                    rowCount: team2BattersNames.length,
                                    teambattersnames: team2BattersNames,
                                    teambattersruns: team2BattersRuns,
                                    balls: battersTeam2Balls,
                                    fours: fours,
                                    sixes: sixes,
                                    whatisit: "batters",
                                    caption: "Batsmen ($eTeam2)"),
                                SizedBox(height: 10),
                                MyTableWidget(
                                    rowCount: team2BallersNames.length,
                                    teambattersnames: team2BallersNames,
                                    teambattersruns: team2BallersWickets,
                                    balls: totalBallsBallersTeam2,
                                    fours: totalRunsBallersTeam2,
                                    sixes: sixes,
                                    whatisit: "ballers",
                                    caption: "Bowlers ($eTeam1)"),
                                SizedBox(
                                  height: 15,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (matchid != "match")
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Container(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FutureBuilder<DocumentSnapshot>(
                                    future: FirebaseFirestore.instance
                                        .collection('Cricket')
                                        .doc(matchid)
                                        .get(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                            child: CircularProgressIndicator());
                                      }
                                      if (snapshot.hasError ||
                                          !snapshot.hasData) {
                                        return const Center(
                                            child: Text("Error fetching data"));
                                      }

                                      var data = snapshot.data!.data()
                                          as Map<String, dynamic>;
                                      List<dynamic> team1Players =
                                          data['team1players'] ?? [];
                                      List<dynamic> team2Players =
                                          data['team2players'] ?? [];

                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          // Team 1 Players List
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 8.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Center(
                                                      child: Text(
                                                    eTeam1,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  )),
                                                  const SizedBox(height: 8),
                                                  for (int i = 0;
                                                      i < team1Players.length;
                                                      i++)
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 6.0),
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white
                                                              .withOpacity(0.1),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 8.0,
                                                                horizontal:
                                                                    16.0),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text(
                                                              team1Players[i],
                                                              style:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),

                                          // Team 2 Players List
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Center(
                                                      child: Text(
                                                    eTeam2,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  )),
                                                  const SizedBox(height: 8),
                                                  for (int i = 0;
                                                      i < team2Players.length;
                                                      i++)
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 6.0),
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white
                                                              .withOpacity(0.1),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 8.0,
                                                                horizontal:
                                                                    16.0),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text(
                                                              team2Players[i],
                                                              style:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        SingleChildScrollView(
                          child: Column(
                            children: <Widget>[
                              SizedBox(
                                height: 15,
                              ),
                              Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color.fromARGB(100, 32, 1, 75)
                                            .withOpacity(0.2),
                                        spreadRadius: 5,
                                        blurRadius: 10,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(25),
                                      child: BackdropFilter(
                                          filter: ImageFilter.blur(
                                              sigmaX: 15, sigmaY: 15),
                                          child: Container(
                                            color:
                                                Colors.white.withOpacity(0.1),
                                            child: Container(
                                              height: screenHeight * 0.15,
                                              margin: EdgeInsets.all(3),
                                              padding: EdgeInsets.all(8),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: <Widget>[
                                                  Row(
                                                    children: <Widget>[
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      CachedNetworkImage(
                                                        imageUrl: eTeam1Logo,
                                                        height:
                                                            screenHeight * 0.09,
                                                        width:
                                                            screenHeight * 0.09,
                                                        fit: BoxFit.cover,
                                                      ),
                                                      SizedBox(
                                                        width: 15,
                                                      ),
                                                      Text("$eTeam1",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 20))
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Text(
                                                          "${totalRunsTeam1.last}/${totalWicketTeam1.last}(${(team1BattersNames.first == "Batter") ? 0 : (overpointball1.last == "0.1") ? 0 : overpointball1.last})",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 20)),
                                                      SizedBox(
                                                        width: 5,
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )))),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color.fromARGB(100, 32, 1, 75)
                                            .withOpacity(0.2),
                                        spreadRadius: 5,
                                        blurRadius: 10,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(25),
                                      child: BackdropFilter(
                                          filter: ImageFilter.blur(
                                              sigmaX: 15, sigmaY: 15),
                                          child: Container(
                                            color:
                                                Colors.white.withOpacity(0.1),
                                            child: Container(
                                              height: screenHeight * 0.15,
                                              padding: EdgeInsets.all(8),
                                              margin: EdgeInsets.all(3),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: <Widget>[
                                                  Row(
                                                    children: <Widget>[
                                                      SizedBox(width: 10),
                                                      CachedNetworkImage(
                                                        imageUrl: eTeam2Logo,
                                                        height:
                                                            screenHeight * 0.09,
                                                        width:
                                                            screenHeight * 0.09,
                                                        fit: BoxFit.cover,
                                                      ),
                                                      SizedBox(width: 15),
                                                      Text("$eTeam2",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 20))
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Text(
                                                          "${totalRunsTeam2.last}/${totalWicketTeam2.last}(${(team2BattersNames.first == "Batter") ? 0 : (overpointball2.last == "0.1") ? 0 : overpointball2.last})",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 20)),
                                                      SizedBox(
                                                        width: 8,
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
          } else {
            return SizedBox(width: 10);
          }
        });
  }
}
