import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jhc_app/Pages/Sports/SportOptions.dart';
import 'package:jhc_app/Pages/Sportsmeet/Home.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:jhc_app/Pages/Sports/Card.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

final Future<FirebaseApp> firebaseApp = Firebase.initializeApp();
final FirebaseFirestore firestore = FirebaseFirestore.instance;

class SportsPage extends StatelessWidget {
  int _getCrossAxisCount(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 1200) {
      return 4;
    } else if (screenWidth > 800) {
      return 3;
    } else {
      return 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: firebaseApp,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return StreamBuilder<QuerySnapshot>(
            stream: firestore.collection('Sports').orderBy('name').snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
                        'Error loading Sports',
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

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
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
                        'No Sports available',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                );
              }

              final documents = snapshot.data!.docs;
              final crossAxisCount = _getCrossAxisCount(context);

              return Container(
                color: const Color.fromARGB(255, 15, 20, 25),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      double childAspectRatio = 1.1;
                      if (constraints.maxWidth > 800) {
                        childAspectRatio = 1.3;
                      }

                      return GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: childAspectRatio,
                        ),
                        itemCount: documents.length,
                        itemBuilder: (context, index) {
                          final doc = documents[index];
                          final data = doc.data() as Map<String, dynamic>;
                          final sportName = data['name'] ?? 'No Name';
                          final imageUrl = data['imageUrl'] ?? '';

                          return GestureDetector(
                            onTap: () {
  final name = sportName.toLowerCase();

  // For cricket & basketball → SportOptions
  if (name == 'cricket' || name == 'basketball') {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SportOptions(sportName: sportName),
      ),
    );
  }
  else if (name == 'sportsmeet') {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SportsmeetHome(),
      ),
    );
  }
  else {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SportsDetailsPage(sportName: sportName),
      ),
    );
  }
},

                            child: Container(
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
                              child: Stack(
                                children: [
                                  if (imageUrl.isNotEmpty &&
                                      imageUrl.startsWith('http'))
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(25),
                                      child: CachedNetworkImage(
                                        imageUrl: imageUrl,
                                        width: double.infinity,
                                        height: double.infinity,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            Container(
                                          color: Colors.grey[800],
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Container(
                                          color: Colors.grey[800],
                                          child: Icon(Icons.error,
                                              color: Colors.white),
                                        ),
                                        cacheManager: CustomCacheManager(),
                                      ),
                                    ),
                                  if (imageUrl.isEmpty ||
                                      !imageUrl.startsWith('http'))
                                    Container(
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                            255, 40, 45, 50),
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                    ),
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(25),
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.black.withOpacity(0.6),
                                            Colors.transparent
                                          ],
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 12,
                                    left: 12,
                                    right: 12,
                                    child: Text(
                                      sportName,
                                      style: TextStyle(
                                        fontSize: constraints.maxWidth > 600
                                            ? 20
                                            : 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              );
            },
          );
        } else if (snapshot.hasError) {
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
                  'Error initializing Firebase',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          );
        } else {
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
      },
    );
  }
}

class CustomCacheManager extends CacheManager {
  static const key = 'SportsKey';
  static const Duration cacheTimeout = Duration(days: 90);

  static final CustomCacheManager _instance = CustomCacheManager._();

  factory CustomCacheManager() {
    return _instance;
  }

  CustomCacheManager._()
      : super(Config(
          key,
          stalePeriod: cacheTimeout,
          maxNrOfCacheObjects: 100,
        ));
}
