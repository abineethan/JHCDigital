import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:liquid_swipe/liquid_swipe.dart';

class InfoPage extends StatefulWidget {
  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  final LiquidController liquidController = LiquidController();

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<bool> _onWillPop() async {
    // If not on first page, go to previous page
    if (liquidController.currentPage > 0) {
      liquidController.animateToPage(page: liquidController.currentPage - 1);
      return false; // Prevent default back behavior
    }
    // If on first page, allow normal back navigation
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
            title: Text(
              'About',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            toolbarHeight: 55,
            backgroundColor: Colors.black),
        body: LiquidSwipe(
          pages: [
            _buildAboutPage(context),
            _buildDevelopersPage(context),
            _buildContactPage(context),
          ],
          liquidController: liquidController,
          fullTransitionValue: 880,
          enableLoop: false, // Disable loop for better back navigation
          enableSideReveal: true,
          waveType: WaveType.liquidReveal,
          positionSlideIcon: 0.5,
          slideIconWidget:
              const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPageChangeCallback: (page) => _onPageChangeCallback(page),
          ignoreUserGestureWhileAnimating: true,
        ),
      ),
    );
  }

  void _onPageChangeCallback(int page) {
    print(page);
  }

  Widget _buildAboutPage(BuildContext context) {
    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              child: Image.asset(
                "images/jhc.png",
                height: 130,
                width: 130,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              child: Text(
                'JHC Digital',
                style: GoogleFonts.poppins(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Digital Transformation',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w300,
                color: Colors.white.withOpacity(0.7),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 48),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: Colors.cyanAccent,
                    size: 32,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'About',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'JHC Digital is a mobile application developed by the IT Club of Jaffna Hindu College to digitalize sports events, club activities, donations, and the latest news.',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDot(true),
                const SizedBox(width: 8),
                _buildDot(false),
                const SizedBox(width: 8),
                _buildDot(false),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(top: 20),
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Empty container for left side spacing
                  Container(width: 48),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Swipe to continue',
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_forward_ios_rounded,
                        color: Colors.white),
                    onPressed: () => liquidController.animateToPage(page: 1),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDevelopersPage(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF001020),
            Color(0xFF002040),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border:
                    Border.all(color: Colors.white.withOpacity(0.2), width: 2),
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(
                Icons.people_alt_rounded,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Development Team',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Meet the creators',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w300,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 48),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildDeveloperCard(
                    name: 'P.Kanujan',
                    role: 'Lead Developer',
                    color: Colors.cyanAccent,
                    icon: Icons.code_rounded,
                    onTap: () => _launchURL(
                        'https://lk.linkedin.com/in/kanujan-piragadeesh'),
                  ),
                  const SizedBox(height: 20),
                  _buildDeveloperCard(
                    name: 'S.Abineethan',
                    role: 'Full-stack Lead Developer',
                    color: const Color(0xFF56FF40),
                    icon: Icons.terminal_rounded,
                    onTap: () => _launchURL('https://abineethan.is-a.dev'),
                  ),
                  const SizedBox(height: 20),
                  _buildDeveloperCard(
                    name: 'G.Karthigan',
                    role: 'Lead Developer',
                    color: Colors.orangeAccent,
                    icon: Icons.code_rounded,
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDot(false),
                const SizedBox(width: 8),
                _buildDot(true),
                const SizedBox(width: 8),
                _buildDot(false),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon:
                        Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
                    onPressed: () => liquidController.animateToPage(page: 0),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Swipe to continue',
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_forward_ios_rounded,
                        color: Colors.white),
                    onPressed: () => liquidController.animateToPage(page: 2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactPage(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF002040),
            Color(0xFF003060),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border:
                    Border.all(color: Colors.white.withOpacity(0.2), width: 2),
                gradient: const LinearGradient(
                  colors: [Color(0xFF56FF40), Color(0xFF00CC44)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(
                Icons.contact_support_rounded,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Get In Touch',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We\'d love to hear from you',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w300,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 48),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildContactCard(
                    icon: Icons.mail_outline_rounded,
                    title: 'Email Us',
                    subtitle: 'jhcitclub28@gmail.com',
                    color: Colors.blueAccent,
                    onTap: () => _launchURL('mailto:jhcitclub28@gmail.com'),
                  ),
                  const SizedBox(height: 20),
                  _buildContactCard(
                    icon: Icons.language_rounded,
                    title: 'Visit Website',
                    subtitle: 'jhcitclub.web.app',
                    color: Colors.greenAccent,
                    onTap: () => _launchURL('https://jhcitclub.web.app'),
                  ),
                  const SizedBox(height: 20),
                  _buildContactCard(
                    icon: Icons.copyright_rounded,
                    title: 'Copyright',
                    subtitle: 'JHC IT Club',
                    color: Colors.purpleAccent,
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDot(false),
                const SizedBox(width: 8),
                _buildDot(false),
                const SizedBox(width: 8),
                _buildDot(true),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon:
                        Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
                    onPressed: () => liquidController.animateToPage(page: 1),
                  ),
                  TextButton(
                    onPressed: () => liquidController.animateToPage(page: 0),
                    child: Text(
                      'Back to Start',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  // Empty container for right side spacing
                  Container(width: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeveloperCard({
    required String name,
    required String role,
    required Color color,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.15),
              color.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.2),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    role,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.15),
              color.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.2),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null) ...[
              Icon(
                Icons.open_in_new_rounded,
                color: color.withOpacity(0.7),
                size: 20,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDot(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
