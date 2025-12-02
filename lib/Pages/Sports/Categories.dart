import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'Matches.dart';

final FirebaseFirestore firestore = FirebaseFirestore.instance;

class Categories extends StatefulWidget {
  final String sportName;

  const Categories({Key? key, required this.sportName}) : super(key: key);

  @override
  _CategoriesState createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  late Future<List<String>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _getAvailableCategories();
  }

  Future<List<String>> _getAvailableCategories() async {
    try {
      final doc = await firestore
          .collection('Sports')
          .doc(widget.sportName)
          .collection('Scores')
          .doc('Categories')
          .get();

      if (doc.exists) {
        return List<String>.from(doc.data()?['Categories'] ?? []);
      }
      return [];
    } catch (e) {
      print('Error getting categories: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.sportName} Scores',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
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
      body: Container(
        color: const Color.fromARGB(255, 15, 20, 25),
        child: FutureBuilder<List<String>>(
          future: _categoriesFuture,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Container(
                color: const Color.fromARGB(255, 15, 20, 25),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
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
                    child: Text(
                      'Error loading categories',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
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

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.emoji_events_rounded,
                          size: 60,
                          color: Colors.white.withOpacity(0.5),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'No categories available',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Check back later for updates',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            final categories = snapshot.data!;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final categoryName = categories[index];
                  final colorScheme = [
                    [
                      const Color.fromARGB(255, 68, 208, 255),
                      const Color.fromARGB(255, 32, 150, 255)
                    ],
                    [
                      const Color.fromARGB(255, 255, 107, 107),
                      const Color.fromARGB(255, 255, 64, 129)
                    ],
                    [
                      const Color.fromARGB(255, 119, 255, 107),
                      const Color.fromARGB(255, 64, 255, 129)
                    ],
                    [
                      const Color.fromARGB(255, 255, 203, 107),
                      const Color.fromARGB(255, 255, 164, 64)
                    ],
                  ][index % 4];

                  return Container(
                    height: 140,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      gradient: LinearGradient(
                        colors: colorScheme,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme[0].withOpacity(0.4),
                          blurRadius: 25,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(25),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Matches(
                                sportName: widget.sportName,
                                categoryName: categoryName,
                              ),
                            ),
                          );
                        },
                        child: Stack(
                          children: [
                            Positioned(
                              right: 16,
                              top: 16,
                              child: Opacity(
                                opacity: 0.15,
                                child: Icon(
                                  _getCategoryIcon(categoryName),
                                  size: 70,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: Icon(
                                      _getCategoryIcon(categoryName),
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          categoryName,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                            height: 1.2,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'View match details and scores',
                                          style: TextStyle(
                                            color:
                                                Colors.white.withOpacity(0.9),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
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
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    final lowerName = categoryName.toLowerCase();
    if (lowerName.contains('big match')) {
      return Icons.sports_cricket;
    } else if (lowerName.contains('tournament')) {
      return Icons.sports_basketball;
    }
    return Icons.emoji_events;
  }
}
