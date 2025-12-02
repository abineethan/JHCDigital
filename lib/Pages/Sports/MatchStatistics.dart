import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class MatchStatistics extends StatelessWidget {
  final String eTeam1;
  final String eTeam2;
  final String matchName;
  final String eTeam1Logo;
  final String eTeam2Logo;
  final String eTeam1Score;
  final String eTeam2Score;
  final String matchid;
  final String parameter;
  final String categoryName;

  const MatchStatistics({
    Key? key,
    required this.eTeam1,
    required this.eTeam2,
    required this.matchName,
    required this.eTeam1Logo,
    required this.eTeam2Logo,
    required this.eTeam1Score,
    required this.eTeam2Score,
    required this.matchid,
    required this.parameter,
    required this.categoryName,
  }) : super(key: key);

  Future<Map<String, dynamic>> _fetchMatchData() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('Sports')
          .doc(parameter)
          .collection('Scores')
          .doc('Categories')
          .collection(categoryName)
          .doc(matchid)
          .get();

      if (snapshot.exists) {
        return snapshot.data() as Map<String, dynamic>;
      }

      return {};
    } catch (e) {
      print('Error fetching match data: $e');
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 15, 20, 25),
      appBar: AppBar(
        title: Text(
          matchName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 15, 20, 25),
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchMatchData(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading match details',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                color: Colors.white,
                size: 150,
              ),
            );
          }

          final data = snapshot.data ?? {};

          String manOfTheMatch =
              data['manofthematch']?.toString() ?? "Not available";

          dynamic winData = data['win'];
          bool isTeam1Winner = false;
          bool isTeam2Winner = false;
          bool isDraw = true;

          if (data.containsKey('win') && winData != null) {
            try {
              String winString = winData.toString().trim();
              if (winString == '1') {
                isTeam1Winner = true;
                isDraw = false;
              } else if (winString == '2') {
                isTeam2Winner = true;
                isDraw = false;
              }
            } catch (e) {
              print('Error parsing win value: $e');
            }
          }

          List<dynamic> team1Players =
              data['team1players'] as List<dynamic>? ?? [];
          List<dynamic> team2Players =
              data['team2players'] as List<dynamic>? ?? [];

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildMatchSummaryCard(
                  context,
                  isTeam1Winner,
                  isTeam2Winner,
                  isDraw,
                ),
                _buildManOfTheMatchCard(context, manOfTheMatch),
                _buildPlayersCard(
                  context,
                  team1Players,
                  team2Players,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMatchSummaryCard(
    BuildContext context,
    bool isTeam1Winner,
    bool isTeam2Winner,
    bool isDraw,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.orange.withOpacity(0.3),
                ),
              ),
              child: Text(
                categoryName,
                style: const TextStyle(
                  color: Colors.orange,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          CachedNetworkImage(
                            imageUrl: eTeam1Logo,
                            width: MediaQuery.of(context).size.width * 0.2,
                            height: MediaQuery.of(context).size.width * 0.2,
                            errorWidget: (context, url, error) => Icon(
                                Icons.sports_cricket,
                                color: Colors.white.withOpacity(0.7)),
                          ),
                          if (isTeam1Winner)
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 1, 96, 55),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  "WIN",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        eTeam1,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "$eTeam1Score - $eTeam2Score",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (isDraw)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            "DRAW",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          CachedNetworkImage(
                            imageUrl: eTeam2Logo,
                            width: MediaQuery.of(context).size.width * 0.2,
                            height: MediaQuery.of(context).size.width * 0.2,
                            errorWidget: (context, url, error) => Icon(
                                Icons.sports_cricket,
                                color: Colors.white.withOpacity(0.7)),
                          ),
                          if (isTeam2Winner)
                            Positioned(
                              top: 0,
                              left: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 1, 96, 55),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  "WIN",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        eTeam2,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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
          ],
        ),
      ),
    );
  }

  Widget _buildManOfTheMatchCard(BuildContext context, String manOfTheMatch) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            const Text(
              "Man of the Match",
              style: TextStyle(
                color: Colors.orange,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  manOfTheMatch,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayersCard(
    BuildContext context,
    List<dynamic> team1Players,
    List<dynamic> team2Players,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                "Players",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.orange.withOpacity(0.5),
                              width: 2,
                            ),
                          ),
                        ),
                        child: Text(
                          eTeam1,
                          style: const TextStyle(
                            color: Colors.orange,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...team1Players.asMap().entries.map((entry) {
                        // ignore: unused_local_variable
                        final index = entry.key;
                        final player = entry.value;
                        return Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            player.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.orange.withOpacity(0.5),
                              width: 2,
                            ),
                          ),
                        ),
                        child: Text(
                          eTeam2,
                          style: const TextStyle(
                            color: Colors.orange,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...team2Players.asMap().entries.map((entry) {
                        // ignore: unused_local_variable
                        final index = entry.key;
                        final player = entry.value;
                        return Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            player.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}