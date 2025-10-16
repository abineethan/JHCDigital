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
      SportsPage(),
      NewsPage(),
      ClubsPage(),
      Donations(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop =
        MediaQuery.of(context).size.width > 800; 

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 19, 24, 26),
                Color.fromARGB(255, 11, 17, 21),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'JHC DIGITAL',
          style: GoogleFonts.oswald(
            textStyle: TextStyle(
              fontSize: 25,
              color: Colors.white,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        centerTitle: true,
        toolbarOpacity: 0.7,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => InfoPage()),
              );
            },
            icon: const Icon(Icons.info, color: Colors.white),
            tooltip: 'Info',
          ),
        ],
      ),
      body: Row(
        children: [
          if (isDesktop)
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              labelType: NavigationRailLabelType.all,
              backgroundColor: Colors.black,
              selectedIconTheme: const IconThemeData(
                  color: Color.fromARGB(255, 68, 208, 255), size: 32),
              unselectedIconTheme:
                  const IconThemeData(color: Colors.white, size: 28),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(FontAwesomeIcons.house),
                  selectedIcon: Icon(FontAwesomeIcons.house),
                  label: Text("Home"),
                ),
                NavigationRailDestination(
                  icon: Icon(FontAwesomeIcons.basketball),
                  selectedIcon: Icon(FontAwesomeIcons.basketball),
                  label: Text("Sports"),
                ),
                NavigationRailDestination(
                  icon: Icon(FontAwesomeIcons.newspaper),
                  selectedIcon: Icon(FontAwesomeIcons.solidNewspaper),
                  label: Text("News"),
                ),
                NavigationRailDestination(
                  icon: Icon(FontAwesomeIcons.buildingColumns),
                  selectedIcon: Icon(FontAwesomeIcons.buildingColumns),
                  label: Text("Clubs"),
                ),
                NavigationRailDestination(
                  icon: Icon(FontAwesomeIcons.handHoldingDollar),
                  selectedIcon: Icon(FontAwesomeIcons.handHoldingDollar),
                  label: Text("Donations"),
                ),
              ],
            ),

          Expanded(
            child: _pages[_selectedIndex], 
          ),
        ],
      ),
      bottomNavigationBar: isDesktop ? null : _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      selectedLabelStyle: const TextStyle(fontSize: 16),
      unselectedLabelStyle: const TextStyle(fontSize: 16),
      showUnselectedLabels: false,
      backgroundColor: Colors.black,
      unselectedItemColor: Colors.white,
      currentIndex: _selectedIndex,
      elevation: 10,
      fixedColor: const Color.fromARGB(255, 68, 208, 255),
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          label: "Home",
          icon: Icon(FontAwesomeIcons.house),
        ),
        BottomNavigationBarItem(
          label: "Sports",
          icon: Icon(FontAwesomeIcons.basketball),
        ),
        BottomNavigationBarItem(
          label: "News",
          icon: Icon(FontAwesomeIcons.newspaper),
          activeIcon: Icon(FontAwesomeIcons.solidNewspaper),
        ),
        BottomNavigationBarItem(
          label: "Clubs",
          icon: Icon(FontAwesomeIcons.buildingColumns),
        ),
        BottomNavigationBarItem(
          label: "Donations",
          icon: Icon(FontAwesomeIcons.handHoldingDollar),
        ),
      ],
      onTap: (int index) {
        setState(() {
          _selectedIndex = index;
        });
      },
    );
  }
}
