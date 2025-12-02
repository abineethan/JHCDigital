import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:jhc_app/widgets/Details.dart';
import 'dart:ui';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

final Future<FirebaseApp> firebaseApp = Firebase.initializeApp();
final FirebaseFirestore firestore = FirebaseFirestore.instance;

class SportsDetailsPage extends StatelessWidget {
  final String sportName;
  static const String defaultImageUrl =
      'https://i.ibb.co/Y7sbhNrV/f24fe5746117.jpg';

  const SportsDetailsPage({Key? key, required this.sportName})
      : super(key: key);

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

  Widget _buildEmptyWidget(String sportName) {
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
            Text(
              'No content available for $sportName',
              style: TextStyle(color: Colors.white60, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          sportName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        toolbarHeight: 55,
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
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 15, 20, 25),
          // gradient: LinearGradient(
          //   colors: [
          //     Color(0xFF000000),
          //     Color(0xFF001020),
          //     Color(0xFF002040),
          //   ],
          //   begin: Alignment.topCenter,
          //   end: Alignment.bottomCenter,
          //   stops: [0.0, 0.6, 1.0],
          // ),
        ),
        child: FutureBuilder(
          future: firebaseApp,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return StreamBuilder<QuerySnapshot>(
                stream: firestore
                    .collection('Sports')
                    .doc(sportName)
                    .collection('Activities')
                    .orderBy('date', descending: true)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return _buildErrorWidget(
                        'Error loading $sportName content');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingWidget();
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return _buildEmptyWidget(sportName);
                  }

                  final documents = snapshot.data!.docs;

                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.05,
                      vertical: 16.0,
                    ),
                    child: CustomScrollView(
                      physics: BouncingScrollPhysics(),
                      slivers: [
                        SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 600,
                            mainAxisExtent:
                                MediaQuery.of(context).size.width > 800
                                    ? 400
                                    : 300,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (BuildContext context, index) {
                              final doc = documents[index];
                              final data = doc.data() as Map<String, dynamic>;

                              final String rawUrl =
                                  data['url']?.toString() ?? '';
                              final String rawText =
                                  data['text']?.toString() ?? '';
                              final String description =
                                  data['description']?.toString() ?? '';
                              final String rawUtube =
                                  data['utube']?.toString() ?? '';

                              List<dynamic>? images = data['images'];
                              String firstImage = defaultImageUrl;
                              List<String> imageList = [defaultImageUrl];

                              if (images != null && images.isNotEmpty) {
                                imageList =
                                    images.map((e) => e.toString()).toList();
                                firstImage = imageList.isNotEmpty
                                    ? imageList[0]
                                    : defaultImageUrl;
                              }

                              String processedText = rawText;
                              if (rawUrl.isEmpty) {
                                processedText = rawText.replaceAll(
                                    RegExp(r'https?://\S+'), '');
                              }

                              String? processedUtube;
                              if (rawUtube.isNotEmpty) {
                                final regExp = RegExp(
                                    r'.*((youtu.be\/)|(v\/)|(\/u\/\w\/)|(embed\/)|(watch\?))\??v?=?([^#&?]*).*');
                                final match = regExp.firstMatch(rawUtube);
                                if (match != null && match.groupCount >= 7) {
                                  processedUtube = match.group(7);
                                } else {
                                  processedUtube = rawUtube;
                                }
                              }

                              return LiquidSportsCard(
                                urls: rawUrl.isNotEmpty ? rawUrl : '',
                                images: firstImage,
                                txts: processedText,
                                description: description,
                                imglist: imageList,
                                utube: processedUtube ?? '',
                                defaultImageUrl: defaultImageUrl,
                              );
                            },
                            childCount: documents.length,
                          ),
                        ),
                      ],
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
          vertical: 8,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 2,
              offset: Offset(0, 10),
            ),
          ],
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

class SportsCacheManager extends CacheManager {
  static const key = 'sportsCacheKey';
  static final SportsCacheManager _instance = SportsCacheManager._();

  factory SportsCacheManager() => _instance;

  SportsCacheManager._()
      : super(Config(
          key,
          stalePeriod: const Duration(days: 90),
          maxNrOfCacheObjects: 200,
        ));
}
