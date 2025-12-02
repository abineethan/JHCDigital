import 'dart:convert';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:jhc_app/Home/LiveSports/ScoreBoardCricket.dart';
import 'package:jhc_app/Home/LiveSports/ScoreBoardBasketBall.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:carousel_slider/carousel_slider.dart' as carousel_lib;

final rtdb = FirebaseDatabase.instance;

class LiveSports extends StatefulWidget {
  final bool parameter;
  const LiveSports({Key? key, required this.parameter}) : super(key: key);

  @override
  State<LiveSports> createState() => _LiveSports(parameter: parameter);
}

class _LiveSports extends State<LiveSports> {
  bool parameter = false;
  final DatabaseReference refSports = FirebaseDatabase.instance.ref('Sports/');

  _LiveSports({required this.parameter});

  bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;
  bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1200;
  bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  bool _isValidCricketMatch(Map<String, dynamic> value) {
    return value['Details'] != null &&
        value['Details']['Team A'] != null &&
        value['Details']['Team B'] != null &&
        value['Details']['team1logo'] != null &&
        value['Details']['team2logo'] != null &&
        value['Stats'] != null &&
        value['Stats'][value['Details']['Team A']] != null &&
        value['Stats'][value['Details']['Team B']] != null;
  }

  bool _isValidBasketballMatch(Map<String, dynamic> value) {
    return value['Details'] != null &&
        value['Details']['Team A'] != null &&
        value['Details']['Team B'] != null &&
        value['Details']['team1logo'] != null &&
        value['Details']['team2logo'] != null &&
        value['Stats'] != null;
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.withOpacity(0.1), Colors.purple.withOpacity(0.1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: LoadingAnimationWidget.fallingDot(
          color: Colors.white,
          size: 60,
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Text(
        'Error: $error',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Text(
        'No live matches available',
        style: TextStyle(color: Colors.white, fontSize: 20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
      stream: refSports.onValue,
      builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
        if (snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data!.snapshot.value != null) {
          final data = snapshot.data!.snapshot.value;

          final jsonData = jsonEncode(data);
          final originalLiveScore = json.decode(jsonData);

          List<String> Team1 = [];
          List<String> Team2 = [];
          List<String> Team1Logo = [];
          List<String> Team2Logo = [];
          List<String> MatchName = [];
          List<String> Category = [];
          List<String> Win = [];
          List<String> Matchid = [];
          List<String> MatchType = [];
          List<String> Team1Points = [];
          List<String> Team2Points = [];
          int matchCount = 0;

          Map<String, dynamic> cricketScore =
              originalLiveScore['Cricket'] ?? {};
          cricketScore.forEach((key, value) {
            if (_isValidCricketMatch(value)) {
              MatchName.add(key);
              MatchType.add("Cricket");
              Team1.add(value['Details']['Team A']);
              Team2.add(value['Details']['Team B']);
              Team1Logo.add(value['Details']['team1logo']);
              Team2Logo.add(value['Details']['team2logo']);
              Category.add(value['Details']['category']);
              Win.add(value['Details']['win']);
              Matchid.add(value['Details']['matchid']);

              int totalWicketsTeam1 = 0;
              int totalRunsTeam1 = 0;
              int totalBallsTeam1 = 0;
              String overPointBall1 = "0.0";

              int totalWicketsTeam2 = 0;
              int totalRunsTeam2 = 0;
              int totalBallsTeam2 = 0;
              String overPointBall2 = "0.0";

              value['Stats'][Team1.last].forEach((overKey, overValue) {
                overValue.forEach((ballKey, ballValue) {
                  if (ballValue['wicket'] != 'NotOut') {
                    totalWicketsTeam1++;
                  }
                  totalRunsTeam1 += ballValue['runs'] as int;
                  totalBallsTeam1++;
                });
              });
              overPointBall1 = '${totalBallsTeam1 ~/ 6}.${totalBallsTeam1 % 6}';

              value['Stats'][Team2.last].forEach((overKey, overValue) {
                overValue.forEach((ballKey, ballValue) {
                  if (ballValue['wicket'] != 'NotOut') {
                    totalWicketsTeam2++;
                  }
                  totalRunsTeam2 += ballValue['runs'] as int;
                  totalBallsTeam2++;
                });
              });
              overPointBall2 = '${totalBallsTeam2 ~/ 6}.${totalBallsTeam2 % 6}';

              Team1Points.add(
                  "${totalRunsTeam1}/${totalWicketsTeam1} ($overPointBall1)");
              Team2Points.add(
                  "${totalRunsTeam2}/${totalWicketsTeam2} ($overPointBall2)");
              matchCount++;
            }
          });

          Map<String, dynamic> basketballScore =
              originalLiveScore['BasketBall'] ?? {};
          basketballScore.forEach((key, value) {
            if (_isValidBasketballMatch(value)) {
              MatchName.add(key);
              MatchType.add("BasketBall");
              Team1.add(value['Details']['Team A']);
              Team2.add(value['Details']['Team B']);
              Team1Logo.add(value['Details']['team1logo']);
              Team2Logo.add(value['Details']['team2logo']);
              Category.add(value['Details']['category']);
              Win.add(value['Details']['win']);
              Matchid.add(value['Details']['matchid']);

              int team1TotalPoints = 0;
              int team2TotalPoints = 0;

              value['Stats'].forEach((key2, value2) {
                if (value2['Shooting Team'] == Team1.last) {
                  team1TotalPoints += (value2['Points'] as int? ?? 0);
                } else {
                  team2TotalPoints += (value2['Points'] as int? ?? 0);
                }
              });

              Team1Points.add(team1TotalPoints.toString());
              Team2Points.add(team2TotalPoints.toString());
              matchCount++;
            }
          });

          if (matchCount == 0) {
            return _buildEmptyWidget();
          }

          return carousel_lib.CarouselSlider.builder(
            itemCount: matchCount,
            itemBuilder: (context, index, id) {
              // ignore: unused_local_variable
              double cardHeight = isMobile(context)
                  ? MediaQuery.of(context).size.height * 0.3
                  : isTablet(context)
                      ? MediaQuery.of(context).size.height * 0.25
                      : MediaQuery.of(context).size.height * 0.3;

              double titleFontSize = isMobile(context)
                  ? MediaQuery.of(context).size.width * 0.05
                  : isTablet(context)
                      ? MediaQuery.of(context).size.width * 0.04
                      : MediaQuery.of(context).size.width * 0.025;

              double teamNameFontSize = isMobile(context)
                  ? MediaQuery.of(context).size.width * 0.04
                  : isTablet(context)
                      ? MediaQuery.of(context).size.width * 0.035
                      : MediaQuery.of(context).size.width * 0.02;

              double scoreFontSize = isMobile(context)
                  ? MediaQuery.of(context).size.width * 0.06
                  : isTablet(context)
                      ? MediaQuery.of(context).size.width * 0.035
                      : MediaQuery.of(context).size.width * 0.03;

              double logoSize = isMobile(context)
                  ? MediaQuery.of(context).size.width * 0.2
                  : isTablet(context)
                      ? MediaQuery.of(context).size.width * 0.14
                      : MediaQuery.of(context).size.width * 0.08;

              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => (MatchType[index] == "Cricket")
                          ? CricketPage(
                              eTotalScoreTeam1: Team1Points[index],
                              eTotalScoreTeam2: Team2Points[index],
                              eTeam1: Team1[index],
                              eTeam2: Team2[index],
                              matchName: MatchName[index],
                              eTeam1Logo: Team1Logo[index],
                              eTeam2Logo: Team2Logo[index],
                              ematchid: Matchid[index],
                              ecategory: Category[index],
                              ewin: Win[index],
                            )
                          : BasketBallPage(
                              eTeam1: Team1[index],
                              eTeam2: Team2[index],
                              eTeam1Logo: Team1Logo[index],
                              eTeam2Logo: Team2Logo[index],
                              liveScoreE: jsonData,
                              matchName: MatchName[index],
                              ematchid: Matchid[index],
                              ecategory: Category[index],
                              ewin: Win[index],
                            ),
                    ),
                  );
                },
                child: Container(
                  margin: EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 6,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF1a1a2e),
                            Color(0xFF16213e),
                            Color(0xFF0f3460),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Flexible(
                              child: Text(
                                MatchName[index][0].toUpperCase() +
                                    MatchName[index].substring(1),
                                style: TextStyle(
                                    fontSize: titleFontSize,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Flexible(
                                    child: Text(
                                      Team1[index].toUpperCase(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: teamNameFontSize,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Flexible(
                                    child: Text(
                                      Team2[index].toUpperCase(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: teamNameFontSize,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  CachedNetworkImage(
                                    imageUrl: Team1Logo[index],
                                    width: logoSize,
                                    height: logoSize,
                                    fit: BoxFit.contain,
                                  ),
                                  CachedNetworkImage(
                                    imageUrl: Team2Logo[index],
                                    width: logoSize,
                                    height: logoSize,
                                    fit: BoxFit.contain,
                                  )
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Flexible(
                                    child: Text(
                                      Team1Points[index],
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'sans-serif',
                                          fontSize: scoreFontSize),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Flexible(
                                    child: Text(
                                      Team2Points[index],
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'sans-serif',
                                          fontSize: scoreFontSize),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
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
                ),
              );
            },
            options: carousel_lib.CarouselOptions(
              aspectRatio: isMobile(context) ? 16 / 9 : 16 / 12,
              height: isMobile(context)
                  ? MediaQuery.of(context).size.height * 0.35
                  : isTablet(context)
                      ? MediaQuery.of(context).size.height * 0.4
                      : MediaQuery.of(context).size.height * 0.6,
              enableInfiniteScroll: true,
              autoPlay: true,
              enlargeCenterPage: true,
              viewportFraction: isMobile(context) ? 0.9 : 0.7,
            ),
          );
        } else if (snapshot.hasError) {
          return _buildErrorWidget('${snapshot.error}');
        } else {
          return _buildLoadingWidget();
        }
      },
    );
  }
}