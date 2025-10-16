import 'package:cached_network_image/cached_network_image.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:jhc_app/Home/LiveSports/ScoreBoard/extendedScore.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jhc_app/Pages/Sports/MatchStatistics.dart';

final Future<FirebaseApp> firebaseApp = Firebase.initializeApp();
final FirebaseFirestore firestore = FirebaseFirestore.instance;

class LiveScoreWidgetCricketPage extends StatefulWidget {
  final String parameter;
  LiveScoreWidgetCricketPage({required this.parameter});

  @override
  State<LiveScoreWidgetCricketPage> createState() =>
      _LiveScoreWidgetCricketPage(parameter: parameter);
}

class _LiveScoreWidgetCricketPage extends State<LiveScoreWidgetCricketPage> {
  final String parameter;
  _LiveScoreWidgetCricketPage({required this.parameter});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(parameter),
      ),
      body: FutureBuilder(
        future: firebaseApp,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return StreamBuilder<QuerySnapshot>(
              stream: firestore.collection(parameter).snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  final docs = snapshot.data!.docs;
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF000000), // Pure black
                              Color(0xFF001020), // Dark blackish-blue
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final matchid = docs[index].id;
                            final data =
                                docs[index].data() as Map<String, dynamic>;
                            final teamA = data['Team A'] ?? "Unknown";
                            final teamB = data['Team B'] ?? "Unknown";
                            final team1Logo = data['team1logo'] ?? "";
                            final team2Logo = data['team2logo'] ?? "";
                            final matchName =
                                data['MatchName'] ?? "Unknown Match";
                            final team1Score =
                                data['team1score']?.toString() ?? "-";
                            final team2Score =
                                data['team2score']?.toString() ?? "-";
                            final win = data['win'];
                            return InkWell(
                              onTap: () {
                                if (win != 0) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MatchStatistics(
                                              eTeam1: teamA,
                                              eTeam2: teamB,
                                              matchName: matchName,
                                              eTeam1Logo: team1Logo,
                                              eTeam2Logo: team2Logo,
                                              eTeam1Score: team1Score,
                                              eTeam2Score: team2Score,
                                              matchid: matchid,
                                              categoryName: "Big Match",
                                              parameter: parameter)));
                                } else {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => SecondPage(
                                                eTeam1: teamA,
                                                eTeam2: teamB,
                                                matchName: matchName,
                                                eTotalScoreTeam1: team1Score,
                                                eTotalScoreTeam2: team2Score,
                                                eTeam1Logo: team1Logo,
                                                eTeam2Logo: team2Logo,
                                                matchid: matchid,
                                              )));
                                }
                              },
                              child: Container(
                                margin: EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      spreadRadius: 5,
                                      blurRadius: 10,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                        sigmaX: 10, sigmaY: 10),
                                    child: Container(
                                      color: Colors.white.withOpacity(0.1),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(15.0),
                                            child: Column(
                                              children: [
                                                Text(
                                                  matchName.toUpperCase(),
                                                  style: TextStyle(
                                                    fontSize: 22,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                // SizedBox(height: 8),
                                                // Text(
                                                //   date,
                                                //   style: TextStyle(
                                                //     fontSize: 16,
                                                //     color: Colors.white,
                                                //     fontWeight: FontWeight.w500,
                                                //   ),
                                                // ),
                                              ],
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Column(
                                                children: [
                                                  CachedNetworkImage(
                                                    imageUrl: team1Logo,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.2,
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.2,
                                                    errorWidget: (context, url,
                                                            error) =>
                                                        Icon(Icons.broken_image,
                                                            color:
                                                                Colors.white),
                                                  ),
                                                  SizedBox(
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.03),
                                                  Text(
                                                    teamA.toUpperCase(),
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 20,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Column(
                                                children: [
                                                  Text(
                                                    "$team1Score - $team2Score",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 22,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Column(
                                                children: [
                                                  CachedNetworkImage(
                                                    imageUrl: team2Logo,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.2,
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.2,
                                                    errorWidget: (context, url,
                                                            error) =>
                                                        Icon(Icons.broken_image,
                                                            color:
                                                                Colors.white),
                                                  ),
                                                  SizedBox(
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.03),
                                                  Text(
                                                    teamB.toUpperCase(),
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 20,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 20),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                } else {
                  return Center(
                    child: LoadingAnimationWidget.staggeredDotsWave(
                      color: Colors.white,
                      size: 150,
                    ),
                  );
                }
              },
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                color: Colors.white,
                size: 150,
              ),
            );
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
                child: Text(
                  'No Data Found',
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
              ),
            );
          } else {
            return Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                color: Colors.white,
                size: 150,
              ),
            );
          }
        },
      ),
    );
  }
}
