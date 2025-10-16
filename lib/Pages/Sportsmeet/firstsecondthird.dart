import 'package:flutter/material.dart';

Widget buildRankingText(String rank, String text) {
  IconData rankIcon;
  Color rankColor;

  // Choose icon and color based on the rank
  if (rank == '1st') {
    rankIcon = Icons.emoji_events;
    rankColor = Colors.amber; // Gold
  } else if (rank == '2nd') {
    rankIcon = Icons.emoji_events;
    rankColor = Colors.grey; // Silver
  } else if (rank == '3rd') {
    rankIcon = Icons.emoji_events;
    rankColor = Colors.brown; // Bronze
  } else {
    rankIcon = Icons.star_border; // Default star for others
    rankColor = Colors.white; // White color for other ranks
  }

  return Padding(
    padding: const EdgeInsets.only(bottom: 10.0),
    child: Row(
      children: [
        Icon(rankIcon, color: rankColor, size: 24), // Different icons and colors
        SizedBox(width: 10),
        Text(
          "$rank: $text", // Display rank and text together
          textAlign: TextAlign.start,
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}
