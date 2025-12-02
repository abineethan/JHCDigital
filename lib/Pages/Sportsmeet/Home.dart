import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jhc_app/Pages/Sportsmeet/Details.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class SportsmeetHome extends StatefulWidget {
  @override
  _SportsmeetHomeState createState() => _SportsmeetHomeState();
}

class _SportsmeetHomeState extends State<SportsmeetHome> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> _availableYears = [];
  Map<String, String> _firstPlaceHouses = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadYears();
  }

  Future<void> _loadYears() async {
    try {
      final doc = await _firestore.collection('Sports').doc('Sportsmeet').get();

      if (!doc.exists) {
        await _createInitialStructure();
        setState(() {
          _availableYears = [DateTime.now().year.toString()];
          _isLoading = false;
        });
        return;
      }

      final years = List<String>.from(doc.data()?['years'] ?? []);

      await _loadFirstPlaceHouses(years);

      setState(() {
        _availableYears = years..sort((a, b) => b.compareTo(a));
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadFirstPlaceHouses(List<String> years) async {
    for (String year in years) {
      try {
        final yearDoc = await _firestore
            .collection('Sports')
            .doc('Sportsmeet')
            .collection('years')
            .doc(year)
            .get();

        if (yearDoc.exists && yearDoc.data() != null) {
          final firstPlace =
              yearDoc.data()!['first']?.toString() ?? 'Not decided';
          _firstPlaceHouses[year] = firstPlace;
        } else {
          _firstPlaceHouses[year] = 'Not decided';
        }
      } catch (e) {
        _firstPlaceHouses[year] = 'Not decided';
      }
    }
  }

  Future<void> _createInitialStructure() async {
    final currentYear = DateTime.now().year.toString();

    await _firestore.collection('Sports').doc('Sportsmeet').set({
      'years': [currentYear],
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 15, 20, 25),
      appBar: AppBar(
        title: const Text(
          'Sportsmeet',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 25, 30, 32),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(25),
            bottomRight: Radius.circular(25),
          ),
        ),
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return Container(
        color: const Color.fromARGB(255, 15, 20, 25),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(30),
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
            child: LoadingAnimationWidget.staggeredDotsWave(
              color: Colors.white,
              size: 80,
            ),
          ),
        ),
      );
    }

    return Container(
      color: Color.fromARGB(255, 15, 20, 25),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_availableYears.isNotEmpty &&
                _firstPlaceHouses.containsKey(_availableYears.first))
              _buildFirstPlaceCard(_availableYears.first),
            const SizedBox(height: 20),
            Expanded(
              child: _buildYearGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFirstPlaceCard(String latestYear) {
    final firstPlaceHouse = _firstPlaceHouses[latestYear] ?? 'Not decided';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromARGB(255, 255, 215, 0),
            Color.fromARGB(255, 255, 193, 7),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 255, 215, 0).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                size: 32,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sportsmeet $latestYear Champion',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    firstPlaceHouse == 'Not decided'
                        ? 'Winner not decided yet'
                        : '$firstPlaceHouse House',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (firstPlaceHouse != 'Not decided')
              const Icon(
                Icons.celebration_rounded,
                size: 32,
                color: Colors.white,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildYearGrid() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _getCrossAxisCount(),
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 2.1,
      ),
      itemCount: _availableYears.length,
      itemBuilder: (context, index) {
        final year = _availableYears[index];
        return _buildYearCard(year);
      },
    );
  }

  int _getCrossAxisCount() {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 3;
    if (width > 800) return 2;
    if (width > 600) return 1;
    return 1;
  }

  Widget _buildYearCard(String year) {
    final firstPlaceHouse = _firstPlaceHouses[year] ?? 'Not decided';

    return InkWell(
      onTap: () => _navigateToYearDetails(context, year),
      borderRadius: BorderRadius.circular(25),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 68, 208, 255),
              Color.fromARGB(255, 32, 150, 255),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 68, 208, 255).withOpacity(0.4),
              blurRadius: 25,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: 20,
              top: 20,
              child: Opacity(
                opacity: 0.15,
                child: Icon(
                  Icons.emoji_events_rounded,
                  size: 80,
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.emoji_events_rounded,
                      size: 28,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Sportsmeet $year',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    firstPlaceHouse == 'Not decided'
                        ? 'View events and results'
                        : 'Champion: $firstPlaceHouse',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Positioned.fill(
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Colors.transparent,
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Colors.white.withOpacity(0.05),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToYearDetails(BuildContext context, String year) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SportsmeetDetails(year: year),
      ),
    );
  }
}
