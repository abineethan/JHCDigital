
import 'package:flutter/material.dart';

class RankingWidget extends StatelessWidget {
  final String rank;
  final String name;
  final bool isWinner;

  const RankingWidget({
    required this.rank,
    required this.name,
    this.isWinner = false,
  });

  @override
  Widget build(BuildContext context) {
    final position = int.tryParse(rank.substring(0, rank.length - 2)) ?? 0;
    
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: _getLiquidGradient(position),
        boxShadow: [
          BoxShadow(
            color: _getRankingColor(position).withOpacity(position <= 3 ? 0.4 : 0.3),
            blurRadius: position <= 3 ? 15 : 10,
            spreadRadius: position <= 3 ? 3 : 2,
            offset: Offset(0, position <= 3 ? 6 : 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Liquid Position Badge
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: _getBadgeGradient(position),
              boxShadow: [
                BoxShadow(
                  color: _getRankingColor(position).withOpacity(0.5),
                  blurRadius: 12,
                  spreadRadius: 2,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Liquid effect inside badge
                Positioned.fill(
                  child: ClipOval(
                    child: CustomPaint(
                      painter: _LiquidPainter(color: _getRankingColor(position)),
                    ),
                  ),
                ),
                // Position Number
                Center(
                  child: Text(
                    position.toString(),
                    style: TextStyle(
                      color: _getBadgeTextColor(position),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 4,
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                ),
                // Crown for 1st place
                if (position == 1)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Color(0xFFFFD700),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.workspace_premium_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: 16),

          // Name and Position Label
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getPositionLabel(position),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 2,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Trophy Icon with glow effect
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withOpacity(0.8),
                  Colors.white.withOpacity(0.2),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: _getRankingColor(position).withOpacity(0.5),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              _getTrophyIcon(position),
              color: _getTrophyColor(position),
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods for liquid ranking UI
  String _getPositionLabel(int position) {
    switch (position) {
      case 1:
        return "🏆 CHAMPION";
      case 2:
        return "🥈 SECOND PLACE";
      case 3:
        return "🥉 THIRD PLACE";
      case 4:
        return "🎖️ FOURTH PLACE";
      case 5:
        return "⭐ FIFTH PLACE";
      default:
        return "POSITION $position";
    }
  }

  LinearGradient _getLiquidGradient(int position) {
    switch (position) {
      case 1:
        return LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFB800), Color(0xFFFFA500)],
          stops: [0.0, 0.5, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 2:
        return LinearGradient(
          colors: [Color(0xFF60A5FA), Color(0xFF3B82F6), Color(0xFF2563EB)],
          stops: [0.0, 0.5, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 3:
        return LinearGradient(
          colors: [Color(0xFFCD7F32), Color(0xFFB87333), Color(0xFF8B4513)],
          stops: [0.0, 0.5, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 4:
        return LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED), Color(0xFF6D28D9)],
          stops: [0.0, 0.5, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 5:
        return LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669), Color(0xFF047857)],
          stops: [0.0, 0.5, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF2563EB), Color(0xFF1E40AF)],
          stops: [0.0, 0.5, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  LinearGradient _getBadgeGradient(int position) {
    switch (position) {
      case 1:
        return LinearGradient(
          colors: [Color(0xFFFFF9C4), Color(0xFFFFD700)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 2:
        return LinearGradient(
          colors: [Color(0xFFDBEAFE), Color(0xFF60A5FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 3:
        return LinearGradient(
          colors: [Color(0xFFFFE0B2), Color(0xFFCD7F32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 4:
        return LinearGradient(
          colors: [Color(0xFFE9D5FF), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 5:
        return LinearGradient(
          colors: [Color(0xFFD1FAE5), Color(0xFF10B981)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return LinearGradient(
          colors: [Color(0xFFE0E7FF), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  Color _getRankingColor(int position) {
    switch (position) {
      case 1:
        return Color(0xFFFFD700);
      case 2:
        return Color(0xFF60A5FA);
      case 3:
        return Color(0xFFCD7F32);
      case 4:
        return Color(0xFF8B5CF6);
      case 5:
        return Color(0xFF10B981);
      default:
        return Color(0xFF2563EB);
    }
  }

  Color _getBadgeTextColor(int position) {
    switch (position) {
      case 1:
        return Color(0xFFB8860B);
      case 2:
        return Color(0xFF1E40AF);
      case 3:
        return Color(0xFF8B4513);
      case 4:
        return Color(0xFF6D28D9);
      case 5:
        return Color(0xFF047857);
      default:
        return Color(0xFF2563EB);
    }
  }

  Color _getTrophyColor(int position) {
    switch (position) {
      case 1:
        return Color(0xFFFFD700);
      case 2:
        return Color(0xFF60A5FA);
      case 3:
        return Color(0xFFCD7F32);
      case 4:
        return Color(0xFF8B5CF6);
      case 5:
        return Color(0xFF10B981);
      default:
        return Colors.white.withOpacity(0.8);
    }
  }

  IconData _getTrophyIcon(int position) {
    switch (position) {
      case 1:
        return Icons.workspace_premium_rounded;
      case 2:
        return Icons.emoji_events_rounded;
      case 3:
        return Icons.emoji_events_outlined;
      case 4:
        return Icons.stars_rounded;
      case 5:
        return Icons.auto_awesome_rounded;
      default:
        return Icons.star_rounded;
    }
  }
}

// Liquid Painter for the liquid effect in badges
class _LiquidPainter extends CustomPainter {
  final Color color;

  _LiquidPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    // Create multiple liquid bubbles for more dynamic effect
    final bubbles = [
      Offset(size.width * 0.2, size.height * 0.2),
      Offset(size.width * 0.7, size.height * 0.3),
      Offset(size.width * 0.3, size.height * 0.7),
      Offset(size.width * 0.8, size.height * 0.6),
    ];

    for (final center in bubbles) {
      final radius = size.width * 0.15;
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}