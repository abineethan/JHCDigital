import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jhc_app/widgets/Details.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:carousel_slider/carousel_slider.dart' as carousel_lib;
import 'package:rxdart/rxdart.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

final Future<FirebaseApp> firebaseApp = Firebase.initializeApp();
final FirebaseFirestore firestore = FirebaseFirestore.instance;

class SportsCacheManager extends CacheManager {
  static const key = 'sportsCachehomehKey';
  static const Duration cacheTimeout = Duration(days: 90);

  static final SportsCacheManager _instance = SportsCacheManager._();

  factory SportsCacheManager() {
    return _instance;
  }

  SportsCacheManager._()
      : super(Config(
          key,
          stalePeriod: cacheTimeout,
          maxNrOfCacheObjects: 200,
        ));
}

class SportsHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: firebaseApp,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final SportsQuery = firestore.collection('Sports');

          final activitiesStream =
              SportsQuery.snapshots().switchMap((SportsSnapshot) {
            if (SportsSnapshot.docs.isEmpty) {
              return Stream.value(<QueryDocumentSnapshot>[]);
            }

            final activityStreams = SportsSnapshot.docs.map((clubDoc) {
              return clubDoc.reference
                  .collection('Activities')
                  .orderBy('date', descending: true)
                  .snapshots();
            }).toList();

            return Rx.combineLatest(activityStreams,
                (List<QuerySnapshot> snapshots) {
              final allActivities =
                  snapshots.expand((snap) => snap.docs).toList();

              allActivities.sort((a, b) {
                final aDate = (a['date'] as Timestamp).toDate();
                final bDate = (b['date'] as Timestamp).toDate();
                return bDate.compareTo(aDate);
              });

              return allActivities.take(10).toList();
            });
          });

          return StreamBuilder<List<QueryDocumentSnapshot>>(
            stream: activitiesStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return _buildErrorWidget('Error loading sports activities');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingWidget();
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return _buildEmptyWidget();
              }

              final screenHeight = MediaQuery.of(context).size.height;
              final activities = snapshot.data!;

              return carousel_lib.CarouselSlider.builder(
                itemCount: activities.length,
                itemBuilder: (context, index, id) {
                  final doc = activities[index];
                  final data = doc.data() as Map<String, dynamic>;

                  return LiquidSportsCard(
                    urls: data['url'] ?? '',
                    images: (data['images']?.isNotEmpty ?? false)
                        ? data['images'][0].toString()
                        : '',
                    txts: data['text'] ?? '',
                    description: data['description'] ?? '',
                    imglist: (data['images'] != null)
                        ? List<String>.from(
                            data['images'].map((e) => e.toString()))
                        : [],
                    utube: data['utube'] ?? '',
                  );
                },
                options: carousel_lib.CarouselOptions(
                  aspectRatio: 16 / 9,
                  height: MediaQuery.of(context).size.width > 800
                      ? screenHeight * 0.7
                      : screenHeight * 0.28,
                  autoPlay: true,
                  enableInfiniteScroll: true,
                  enlargeCenterPage: true,
                  viewportFraction: 0.9,
                  autoPlayInterval: Duration(seconds: 5),
                  autoPlayAnimationDuration: Duration(milliseconds: 800),
                  pauseAutoPlayOnTouch: true,
                  scrollPhysics: BouncingScrollPhysics(),
                ),
              );
            },
          );
        } else if (snapshot.hasError) {
          return _buildErrorWidget('Error initializing Firebase');
        } else {
          return _buildLoadingWidget();
        }
      },
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue.withOpacity(0.1),
              Colors.purple.withOpacity(0.1)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: LoadingAnimationWidget.fallingDot(
          color: Colors.white,
          size: 60,
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.red.withOpacity(0.1),
              Colors.orange.withOpacity(0.1)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: Text(
          error,
          style: TextStyle(color: Colors.white70),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Container(
        padding: EdgeInsets.all(25),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.grey.withOpacity(0.1),
              Colors.blueGrey.withOpacity(0.1)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sports_baseball_rounded,
                size: 50, color: Colors.white30),
            SizedBox(height: 10),
            Text(
              'No sports activities available',
              style: TextStyle(color: Colors.white60, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class LiquidSportsCard extends StatefulWidget {
  final String urls;
  final List<String> imglist;
  final String images;
  final String txts;
  final String? utube;
  final String? description;
  final String defaultImageUrl;

  const LiquidSportsCard({
    required this.urls,
    required this.images,
    required this.txts,
    this.description,
    this.imglist = const [""],
    this.utube,
    this.defaultImageUrl = 'https://i.ibb.co/Y7sbhNrV/f24fe5746117.jpg',
    Key? key,
  }) : super(key: key);

  @override
  State<LiquidSportsCard> createState() => _LiquidSportsCardState();
}

class _LiquidSportsCardState extends State<LiquidSportsCard> {
  late String _displayImage;
  bool _imageError = false;

  @override
  void initState() {
    super.initState();
    _displayImage =
        widget.images.isNotEmpty ? widget.images : widget.defaultImageUrl;
  }

  @override
  void didUpdateWidget(LiquidSportsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.images != widget.images ||
        oldWidget.defaultImageUrl != widget.defaultImageUrl) {
      _displayImage =
          widget.images.isNotEmpty ? widget.images : widget.defaultImageUrl;
      _imageError = false;
    }
  }

  ImageProvider _getImageProvider() {
    if (_imageError) {
      return NetworkImage(widget.defaultImageUrl);
    }

    return CachedNetworkImageProvider(
      _displayImage,
      cacheManager: SportsCacheManager(),
      errorListener: (err) => setState(() {
        _imageError = true;
        _displayImage = widget.defaultImageUrl;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => Details(
              urls: widget.urls,
              images: _imageError ? widget.defaultImageUrl : _displayImage,
              txts: widget.txts,
              description: widget.description ?? "",
              imglist: widget.imglist,
              utube: widget.utube ?? "",
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(
          vertical: 6,
          horizontal: 2,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: _getImageProvider(),
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.1),
                        Colors.black.withOpacity(0.8),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange.withOpacity(0.05),
                      Colors.red.withOpacity(0.05),
                      Colors.transparent,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.txts,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenHeight * 0.022,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.8),
                            blurRadius: 10,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
