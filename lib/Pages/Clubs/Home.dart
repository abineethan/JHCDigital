import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:jhc_app/Pages/Clubs/Card.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

final Future<FirebaseApp> firebaseApp = Firebase.initializeApp();
final FirebaseFirestore firestore = FirebaseFirestore.instance;

class ClubsPage extends StatelessWidget {
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

  double _getTextScaleFactor(BuildContext context) {
    // Get the user's text scale factor from system settings
    return MediaQuery.of(context).textScaleFactor;
  }

  double _getResponsiveTextSize(BuildContext context) {
    final double textScaleFactor = _getTextScaleFactor(context);
    final double screenWidth = MediaQuery.of(context).size.width;
    
    // Base font sizes
    double baseFontSize = screenWidth > 600 ? 20 : 16;
    
    // Adjust font size based on text scale factor
    if (textScaleFactor > 1.5) {
      // If user has large text enabled, reduce the base size
      baseFontSize *= 0.7;
    } else if (textScaleFactor > 1.2) {
      baseFontSize *= 0.8;
    } else if (textScaleFactor > 1.0) {
      baseFontSize *= 0.9;
    }
    
    // Ensure minimum readable font size
    return baseFontSize.clamp(12, 24).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: firebaseApp,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return StreamBuilder<QuerySnapshot>(
            stream: firestore.collection('Clubs').orderBy('name').snapshots(),
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
                        'Error loading Clubs',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: _getResponsiveTextSize(context),
                        ),
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
                        'No Clubs available',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: _getResponsiveTextSize(context),
                        ),
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
                          final clubName = data['name'] ?? 'No Name';
                          final imageUrl = data['imageUrl'] ?? '';

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ClubDetailsPage(clubName: clubName),
                                ),
                              );
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
                                        cacheManager: ClubsCacheManager(),
                                        placeholder: (context, url) =>
                                            Container(
                                          color: Colors.grey[800],
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Container(),
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
                                    child: Container(
                                      constraints: BoxConstraints(
                                        minHeight: _getResponsiveTextSize(context) * 2,
                                      ),
                                      child: Text(
                                        clubName,
                                        style: TextStyle(
                                          fontSize: _getResponsiveTextSize(context),
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          height: 1.2,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.left,
                                      ),
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
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: _getResponsiveTextSize(context),
                  ),
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

class ClubsCacheManager extends CacheManager {
  static const key = 'clubsKey';
  static const Duration cacheTimeout = Duration(days: 90);

  static final ClubsCacheManager _instance = ClubsCacheManager._();

  factory ClubsCacheManager() {
    return _instance;
  }

  ClubsCacheManager._()
      : super(Config(
          key,
          stalePeriod: cacheTimeout,
          maxNrOfCacheObjects: 100,
        ));
}