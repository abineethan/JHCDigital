import 'dart:convert';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:jhc_app/Home/LiveSports/ScoreBoardCricket.dart';
import 'package:jhc_app/Home/LiveSports/ScoreBoardBasketBall.dart';
import 'package:google_fonts/google_fonts.dart';

final rtdb = FirebaseDatabase.instance;

class SportsPopup extends StatefulWidget {
  @override
  _SportsPopupState createState() => _SportsPopupState();
}

class _SportsPopupState extends State<SportsPopup> {
  List<Map<String, dynamic>> liveMatches = [];
  bool isLoading = true;
  bool hasLiveMatches = false;

  @override
  void initState() {
    super.initState();
    _fetchLiveMatches();
  }

  Future<void> _fetchLiveMatches() async {
    try {
      final DatabaseReference refSports = FirebaseDatabase.instance.ref('Sports/');
      
      final snapshot = await refSports.once();
      
      if (snapshot.snapshot.value != null) {
        final data = snapshot.snapshot.value;
        final jsonData = jsonEncode(data);
        final originalLiveScore = json.decode(jsonData);

        List<Map<String, dynamic>> matches = [];

        // Process Cricket matches
        Map<String, dynamic> cricketScore = originalLiveScore['Cricket'] ?? {};
        cricketScore.forEach((key, value) {
          if (_isValidCricketMatch(value)) {
            String team1 = value['Details']['Team A'] ?? '';
            String team2 = value['Details']['Team B'] ?? '';
            
            // Calculate cricket scores
            int totalWicketsTeam1 = 0;
            int totalRunsTeam1 = 0;
            int totalBallsTeam1 = 0;

            int totalWicketsTeam2 = 0;
            int totalRunsTeam2 = 0;
            int totalBallsTeam2 = 0;

            if (value['Stats'][team1] != null) {
              value['Stats'][team1].forEach((overKey, overValue) {
                overValue.forEach((ballKey, ballValue) {
                  if (ballValue['wicket'] != 'NotOut') {
                    totalWicketsTeam1++;
                  }
                  totalRunsTeam1 += ballValue['runs'] as int;
                  totalBallsTeam1++;
                });
              });
            }

            if (value['Stats'][team2] != null) {
              value['Stats'][team2].forEach((overKey, overValue) {
                overValue.forEach((ballKey, ballValue) {
                  if (ballValue['wicket'] != 'NotOut') {
                    totalWicketsTeam2++;
                  }
                  totalRunsTeam2 += ballValue['runs'] as int;
                  totalBallsTeam2++;
                });
              });
            }

            String overPointBall1 = '${totalBallsTeam1 ~/ 6}.${totalBallsTeam1 % 6}';
            String overPointBall2 = '${totalBallsTeam2 ~/ 6}.${totalBallsTeam2 % 6}';

            matches.add({
              'matchName': key,
              'sportType': 'Cricket',
              'team1': team1,
              'team2': team2,
              'team1Logo': value['Details']['team1logo'] ?? '',
              'team2Logo': value['Details']['team2logo'] ?? '',
              'team1Score': "${totalRunsTeam1}/${totalWicketsTeam1}",
              'team1Overs': "($overPointBall1)",
              'team2Score': "${totalRunsTeam2}/${totalWicketsTeam2}",
              'team2Overs': "($overPointBall2)",
              'category': value['Details']['category'] ?? '',
              'win': value['Details']['win'] ?? '',
              'matchid': value['Details']['matchid'] ?? '',
              'timestamp': DateTime.now().millisecondsSinceEpoch,
            });
          }
        });

        // Process Basketball matches
        Map<String, dynamic> basketballScore = originalLiveScore['BasketBall'] ?? {};
        basketballScore.forEach((key, value) {
          if (_isValidBasketballMatch(value)) {
            String team1 = value['Details']['Team A'] ?? '';
            String team2 = value['Details']['Team B'] ?? '';
            
            int team1TotalPoints = 0;
            int team2TotalPoints = 0;

            value['Stats'].forEach((key2, value2) {
              if (value2['Shooting Team'] == team1) {
                team1TotalPoints += (value2['Points'] as int? ?? 0);
              } else {
                team2TotalPoints += (value2['Points'] as int? ?? 0);
              }
            });

            matches.add({
              'matchName': key,
              'sportType': 'Basketball',
              'team1': team1,
              'team2': team2,
              'team1Logo': value['Details']['team1logo'] ?? '',
              'team2Logo': value['Details']['team2logo'] ?? '',
              'team1Score': team1TotalPoints.toString(),
              'team2Score': team2TotalPoints.toString(),
              'category': value['Details']['category'] ?? '',
              'win': value['Details']['win'] ?? '',
              'matchid': value['Details']['matchid'] ?? '',
              'timestamp': DateTime.now().millisecondsSinceEpoch,
            });
          }
        });

        setState(() {
          liveMatches = matches;
          hasLiveMatches = matches.isNotEmpty;
          isLoading = false;
        });

        // Show popup if there are live matches
        if (matches.isNotEmpty) {
          Future.delayed(Duration(milliseconds: 500), () {
            _showLiveMatchesPopup();
          });
        }
      } else {
        setState(() {
          isLoading = false;
          hasLiveMatches = false;
        });
      }
    } catch (e) {
      print('Error fetching live matches: $e');
      setState(() {
        isLoading = false;
        hasLiveMatches = false;
      });
    }
  }

  bool _isValidCricketMatch(Map<String, dynamic> value) {
    return value['Details'] != null &&
        value['Details']['Team A'] != null &&
        value['Details']['Team B'] != null &&
        value['Details']['team1logo'] != null &&
        value['Details']['team2logo'] != null &&
        value['Stats'] != null;
  }

  bool _isValidBasketballMatch(Map<String, dynamic> value) {
    return value['Details'] != null &&
        value['Details']['Team A'] != null &&
        value['Details']['Team B'] != null &&
        value['Details']['team1logo'] != null &&
        value['Details']['team2logo'] != null &&
        value['Stats'] != null;
  }

  void _showLiveMatchesPopup() {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(20),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.95,
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1a2b6d),
                Color(0xFF0d1b4d),
                Color(0xFF070e2d),
              ],
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 5,
                offset: Offset(0, 10),
              ),
            ],
            border: Border.all(
              color: Colors.blue.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with animated background
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF00c6ff),
                      Color(0xFF0072ff),
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.4),
                      blurRadius: 15,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Animated sports icon
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.sports_score, color: Colors.white, size: 28),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'LIVE SPORTS SCORES',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '${liveMatches.length} match${liveMatches.length > 1 ? 'es' : ''} in progress',
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Live indicator
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.6),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 6),
                          Text(
                            'LIVE',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Close button
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(Icons.close, size: 20),
                    color: Colors.white,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),

              // Matches list
              Expanded(
                child: liveMatches.isEmpty
                    ? _buildEmptyState()
                    : Padding(
                        padding: EdgeInsets.all(16),
                        child: ListView.builder(
                          physics: BouncingScrollPhysics(),
                          itemCount: liveMatches.length,
                          itemBuilder: (context, index) {
                            return _buildMatchCard(liveMatches[index], context, index);
                          },
                        ),
                      ),
              ),

              // Footer
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                ),
                child: Text(
                  'Scores update automatically • Tap to view details',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sports_baseball,
            size: 80,
            color: Colors.white.withOpacity(0.3),
          ),
          SizedBox(height: 20),
          Text(
            'No Live Matches',
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.7),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Check back later for live sports action',
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchCard(Map<String, dynamic> match, BuildContext context, int index) {
    bool isCricket = match['sportType'] == 'Cricket';
    
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => isCricket
                    ? CricketPage(
                        eTotalScoreTeam1: match['team1Score'],
                        eTotalScoreTeam2: match['team2Score'],
                        eTeam1: match['team1'],
                        eTeam2: match['team2'],
                        matchName: match['matchName'],
                        eTeam1Logo: match['team1Logo'],
                        eTeam2Logo: match['team2Logo'],
                        ematchid: match['matchid'],
                        ecategory: match['category'],
                        ewin: match['win'],
                      )
                    : BasketBallPage(
                        eTeam1: match['team1'],
                        eTeam2: match['team2'],
                        eTeam1Logo: match['team1Logo'],
                        eTeam2Logo: match['team2Logo'],
                        liveScoreE: jsonEncode(match),
                        matchName: match['matchName'],
                        ematchid: match['matchid'],
                        ecategory: match['category'],
                        ewin: match['win'],
                      ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 15,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                // Sport type and match info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isCricket
                              ? [Color(0xFF4CAF50), Color(0xFF45a049)]
                              : [Color(0xFFFF9800), Color(0xFFF57C00)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isCricket ? Icons.sports_cricket : Icons.sports_basketball,
                            color: Colors.white,
                            size: 16,
                          ),
                          SizedBox(width: 6),
                          Text(
                            match['sportType'],
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'LIVE',
                      style: GoogleFonts.poppins(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 16),
                
                // Match name
                Text(
                  match['matchName'][0].toUpperCase() + 
                  match['matchName'].substring(1),
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                SizedBox(height: 20),
                
                // Teams and scores
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Team 1
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 2,
                              ),
                            ),
                            child: CachedNetworkImage(
                              imageUrl: match['team1Logo'],
                              fit: BoxFit.contain,
                              errorWidget: (context, url, error) => Icon(
                                isCricket ? Icons.sports_cricket : Icons.sports_basketball,
                                color: Colors.white.withOpacity(0.5),
                                size: 40,
                              ),
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            match['team1'].toUpperCase(),
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 8),
                          Column(
                            children: [
                              Text(
                                match['team1Score'],
                                style: GoogleFonts.poppins(
                                  color: Colors.yellow[300],
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              if (isCricket && match['team1Overs'] != null)
                                Text(
                                  match['team1Overs'],
                                  style: GoogleFonts.poppins(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // VS separator
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        children: [
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(height: 4),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'VS',
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 8),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(height: 4),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Team 2
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 2,
                              ),
                            ),
                            child: CachedNetworkImage(
                              imageUrl: match['team2Logo'],
                              fit: BoxFit.contain,
                              errorWidget: (context, url, error) => Icon(
                                isCricket ? Icons.sports_cricket : Icons.sports_basketball,
                                color: Colors.white.withOpacity(0.5),
                                size: 40,
                              ),
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            match['team2'].toUpperCase(),
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 8),
                          Column(
                            children: [
                              Text(
                                match['team2Score'],
                                style: GoogleFonts.poppins(
                                  color: Colors.yellow[300],
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              if (isCricket && match['team2Overs'] != null)
                                Text(
                                  match['team2Overs'],
                                  style: GoogleFonts.poppins(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 20),
                
                // View Details button
                Container(
                  width: double.infinity,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => isCricket
                                ? CricketPage(
                                    eTotalScoreTeam1: match['team1Score'],
                                    eTotalScoreTeam2: match['team2Score'],
                                    eTeam1: match['team1'],
                                    eTeam2: match['team2'],
                                    matchName: match['matchName'],
                                    eTeam1Logo: match['team1Logo'],
                                    eTeam2Logo: match['team2Logo'],
                                    ematchid: match['matchid'],
                                    ecategory: match['category'],
                                    ewin: match['win'],
                                  )
                                : BasketBallPage(
                                    eTeam1: match['team1'],
                                    eTeam2: match['team2'],
                                    eTeam1Logo: match['team1Logo'],
                                    eTeam2Logo: match['team2Logo'],
                                    liveScoreE: jsonEncode(match),
                                    matchName: match['matchName'],
                                    ematchid: match['matchid'],
                                    ecategory: match['category'],
                                    ewin: match['win'],
                                  ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF00c6ff),
                              Color(0xFF0072ff),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.4),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.scoreboard, color: Colors.white, size: 20),
                            SizedBox(width: 10),
                            Text(
                              'VIEW FULL SCOREBOARD',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.shrink();
  }
}