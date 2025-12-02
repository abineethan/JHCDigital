import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jhc_app/Pages/Clubs/Home.dart';
import 'package:jhc_app/Pages/Info/Info.dart';
import 'package:jhc_app/Pages/Sports/Home.dart';
import 'package:jhc_app/Pages/News/Home.dart';
import 'package:jhc_app/Pages/Donations/Home.dart';
import 'package:jhc_app/Home/Home.dart';
import 'firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JHC Digital',
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: 1.0, // Fixed text scaling - prevents zoom
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                constraints: BoxConstraints(
                  maxWidth: constraints.maxWidth,
                  maxHeight: constraints.maxHeight,
                ),
                child: child!,
              );
            },
          ),
        );
      },
      home: MyHomePage(selectedIndex: 0),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final int selectedIndex;
  const MyHomePage({super.key, required this.selectedIndex});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late int _selectedIndex;
  List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
    _pages = [
      RealHomePage(),
      NewsPage(),
      SportsPage(),
      ClubsPage(),
      Donations(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 15, 20, 25),
      appBar: _buildFixedAppBar(isDesktop),
      body: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
    );
  }

  PreferredSizeWidget _buildFixedAppBar(bool isDesktop) {
    return AppBar(
      backgroundColor: const Color.fromARGB(255, 25, 30, 32),
      elevation: 0,
      scrolledUnderElevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      title: Text(
        'JHC DIGITAL',
        style: GoogleFonts.oswald(
          textStyle: const TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.5,
          ),
        ),
        textScaler: TextScaler.noScaling, // Prevents text zoom
      ),
      centerTitle: true,
      toolbarHeight: 60,
      actions: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => InfoPage()),
            );
          },
          icon: Icon(
            Icons.info,
            color: Colors.white.withOpacity(0.8),
            size: 24,
          ),
          tooltip: 'Info',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Container(
      color: const Color.fromARGB(255, 15, 20, 25),
      child: Row(
        children: [
          _buildDesktopVerticalNavBar(),
          Expanded(
            child: _pages[_selectedIndex],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Container(
      color: const Color.fromARGB(0, 255, 230, 0),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 86),
            child: _pages[_selectedIndex],
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: _buildFloatingMobileNavBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopVerticalNavBar() {
    return Container(
      width: 100,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 25, 30, 32),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 25,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _VerticalNavItem(
            icon: FontAwesomeIcons.house,
            activeIcon: FontAwesomeIcons.house,
            label: 'Home',
            isActive: _selectedIndex == 0,
            onTap: () => _onItemTapped(0),
          ),
          const SizedBox(height: 20),
          _VerticalNavItem(
            icon: FontAwesomeIcons.newspaper,
            activeIcon: FontAwesomeIcons.solidNewspaper,
            label: 'News',
            isActive: _selectedIndex == 1,
            onTap: () => _onItemTapped(1),
          ),
          const SizedBox(height: 20),
          _VerticalNavItem(
            icon: FontAwesomeIcons.basketball,
            activeIcon: FontAwesomeIcons.basketball,
            label: 'Sports',
            isActive: _selectedIndex == 2,
            onTap: () => _onItemTapped(2),
          ),
          const SizedBox(height: 20),
          _VerticalNavItem(
            icon: FontAwesomeIcons.buildingColumns,
            activeIcon: FontAwesomeIcons.buildingColumns,
            label: 'Clubs',
            isActive: _selectedIndex == 3,
            onTap: () => _onItemTapped(3),
          ),
          const SizedBox(height: 20),
          _VerticalNavItem(
            icon: FontAwesomeIcons.handHoldingDollar,
            activeIcon: FontAwesomeIcons.handHoldingDollar,
            label: 'Donations',
            isActive: _selectedIndex == 4,
            onTap: () => _onItemTapped(4),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingMobileNavBar() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 25, 30, 32),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 25,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavBarItem(
            icon: FontAwesomeIcons.house,
            activeIcon: FontAwesomeIcons.house,
            label: 'Home',
            isActive: _selectedIndex == 0,
            onTap: () => _onItemTapped(0),
          ),
          _NavBarItem(
            icon: FontAwesomeIcons.newspaper,
            activeIcon: FontAwesomeIcons.solidNewspaper,
            label: 'News',
            isActive: _selectedIndex == 1,
            onTap: () => _onItemTapped(1),
          ),
          _NavBarItem(
            icon: FontAwesomeIcons.basketball,
            activeIcon: FontAwesomeIcons.basketball,
            label: 'Sports',
            isActive: _selectedIndex == 2,
            onTap: () => _onItemTapped(2),
          ),
          _NavBarItem(
            icon: FontAwesomeIcons.buildingColumns,
            activeIcon: FontAwesomeIcons.buildingColumns,
            label: 'Clubs',
            isActive: _selectedIndex == 3,
            onTap: () => _onItemTapped(3),
          ),
          _NavBarItem(
            icon: FontAwesomeIcons.handHoldingDollar,
            activeIcon: FontAwesomeIcons.handHoldingDollar,
            label: 'Donations',
            isActive: _selectedIndex == 4,
            onTap: () => _onItemTapped(4),
          ),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

class _VerticalNavItem extends StatefulWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _VerticalNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_VerticalNavItem> createState() => _VerticalNavItemState();
}

class _VerticalNavItemState extends State<_VerticalNavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool showLabel = _isHovered || widget.isActive;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: 80,
          height: showLabel ? 70 : 50,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            gradient: widget.isActive
                ? const LinearGradient(
                    colors: [
                      Color.fromARGB(255, 68, 208, 255),
                      Color.fromARGB(255, 32, 150, 255),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : _isHovered
                    ? const LinearGradient(
                        colors: [
                          Color.fromARGB(255, 40, 45, 50),
                          Color.fromARGB(255, 50, 55, 60),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      )
                    : null,
            color: (widget.isActive || _isHovered) ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(15),
            border: widget.isActive
                ? Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  )
                : _isHovered
                    ? Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      )
                    : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.isActive ? widget.activeIcon : widget.icon,
                color: widget.isActive
                    ? Colors.white
                    : _isHovered
                        ? Colors.white
                        : Colors.white70,
                size: widget.isActive ? 24 : 22,
              ),
              const SizedBox(height: 4),
              if (showLabel)
                Text(
                  widget.label,
                  style: GoogleFonts.inter(
                    color: widget.isActive
                        ? Colors.white
                        : _isHovered
                            ? Colors.white
                            : Colors.white70,
                    fontSize: 11,
                    fontWeight:
                        widget.isActive ? FontWeight.w600 : FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textScaler: TextScaler.noScaling, // Prevents text zoom
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isActive
              ? const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 68, 208, 255),
                    Color.fromARGB(255, 32, 150, 255),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isActive ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: isActive
              ? Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                )
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(
              isActive ? activeIcon : icon,
              color: isActive ? Colors.white : Colors.white70,
              size: isActive ? 22 : 20,
            ),
            if (isActive) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textScaler: TextScaler.noScaling, // Prevents text zoom
              ),
            ],
          ],
        ),
      ),
    );
  }
}
