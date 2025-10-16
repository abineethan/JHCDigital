import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoPage extends StatelessWidget {
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          'About Us',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF000000),
              Color(0xFF001020),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Container(
                      child: Image.asset(
                        "images/jhc.png",
                        height: 125,
                        width: 125,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'JHC Digital',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32),
              _buildSectionTitle('About'),
              SizedBox(height: 12),
              _buildInfoCard(
                'JHC Digital is a mobile application developed by the IT Club of Jaffna Hindu College to digitalize sports events, club activities, donations, and the latest news.',
              ),
              SizedBox(height: 32),
              _buildSectionTitle('Developers'),
              SizedBox(height: 16),
              _buildTeamMember(
                name: 'Kanujan',
                color: Colors.cyanAccent,
              ),
              _buildTeamMember(
                name: 'Karthigan',
                color: Colors.orangeAccent,
              ),
              _buildTeamMember(
                name: 'Abineethan',
                color: Color(0xFF56FF40),
              ),
              SizedBox(height: 32),
              _buildSectionTitle('Contact Us'),
              SizedBox(height: 12),
              _buildContactItem(
                icon: Icons.mail_outline,
                text: 'jhcitclub28@gmail.com',
                onTap: () => _launchURL('mailto:jhcitclub28@gmail.com'),
              ),
              _buildContactItem(
                icon: Icons.language,
                text: 'Visit our Website',
                onTap: () => _launchURL('https://jhcitclub.web.app/'),
              ),
              _buildContactItem(
                icon: Icons.copyright,
                text: 'JHC IT Club',
              ),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildInfoCard(String text) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Colors.white.withOpacity(0.9),
          height: 1.6,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTeamMember({
    required String name,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 12),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(6),
                child: Icon(Icons.person_outline, color: color, size: 20),
              ),
              SizedBox(width: 12),
              Text(
                name,
                style: GoogleFonts.lobster(
                  fontSize: 22,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String text,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white.withOpacity(0.9), size: 20),
            ),
            SizedBox(width: 16),
            Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            if (onTap != null) ...[
              Spacer(),
              Icon(Icons.open_in_new,
                  size: 16, color: Colors.white.withOpacity(0.6)),
            ],
          ],
        ),
      ),
    );
  }
}
