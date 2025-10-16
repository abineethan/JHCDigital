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
      backgroundColor: Colors.black,
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
          bool isDraw = true; // Default to draw

          // Check if win field exists and has a valid value
          if (data.containsKey('win') && winData != null) {
            try {
              // Convert to string first, then try to parse
              String winString = winData.toString().trim();
              if (winString == '1') {
                isTeam1Winner = true;
                isDraw = false;
              } else if (winString == '2') {
                isTeam2Winner = true;
                isDraw = false;
              }
              // Any other value remains as draw
            } catch (e) {
              print('Error parsing win value: $e');
              // Keep default draw value on error
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
          color: Colors.blueGrey.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              categoryName,
              style: const TextStyle(
                color: Colors.orange,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.topRight,
                        children: [
                          CachedNetworkImage(
                            imageUrl: eTeam1Logo,
                            height: 120,
                            width: 120,
                            placeholder: (context, url) =>
                                const CircularProgressIndicator(),
                            errorWidget: (context, url, error) => const Icon(
                                Icons.sports_cricket,
                                color: Colors.white),
                          ),
                          if (isTeam1Winner)
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 1, 96, 55),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                "WIN",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        eTeam1,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      Text(
                        "$eTeam1Score - $eTeam2Score",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isDraw)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey[700],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            "DRAW",
                            style: TextStyle(
                              color: Colors.white,
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
                        alignment: Alignment.topRight,
                        children: [
                          CachedNetworkImage(
                            imageUrl: eTeam2Logo,
                            height: 120,
                            width: 120,
                            placeholder: (context, url) =>
                                const CircularProgressIndicator(),
                            errorWidget: (context, url, error) => const Icon(
                                Icons.sports_cricket,
                                color: Colors.white),
                          ),
                          if (isTeam2Winner)
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 1, 96, 55),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                "WIN",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        eTeam2,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
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
      padding: const EdgeInsets.all(16.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.blueGrey.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            const Text(
              "Man of the Match",
              style: TextStyle(
                color: Colors.orange,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              manOfTheMatch,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
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
          color: Colors.blueGrey.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
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
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            eTeam1,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        for (int i = 0; i < team1Players.length; i++)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                                horizontal: 16.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    team1Players[i].toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
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
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            eTeam2,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        for (int i = 0; i < team2Players.length; i++)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                                horizontal: 16.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    team2Players[i].toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
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
            ),
          ],
        ),
      ),
    );
  }
}
