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
      'https://i.ibb.co/R42fQnMh/86b4166adc3b.jpg';

  const SportsDetailsPage({Key? key, required this.sportName})
      : super(key: key);

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
        backgroundColor: Colors.black,
      ),
      body: FutureBuilder(
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
                  return Center(
                    child: Text(
                      'Error loading $sportName content',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: LoadingAnimationWidget.staggeredDotsWave(
                      color: Colors.white,
                      size: 150,
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return DecoratedBox(
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
                    child: Center(
                      child: Text(
                        'No content available for $sportName',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                }

                final documents = snapshot.data!.docs;

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
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.05,
                      vertical: 16.0,
                    ),
                    child: CustomScrollView(
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

                              return Card(
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
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error initializing Firebase',
                style: TextStyle(color: Colors.white),
              ),
            );
          } else {
            return Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                color: Colors.white,
                size: 150,
              ),
            );
          }
        },
      ),
    );
  }
}

class Card extends StatefulWidget {
  final String urls;
  final List<String> imglist;
  final String images;
  final String txts;
  final String? utube;
  final String? description;
  final String defaultImageUrl;

  const Card({
    required this.urls,
    required this.images,
    required this.txts,
    this.description,
    this.imglist = const [""],
    this.utube,
    this.defaultImageUrl = 'https://i.ibb.co/R42fQnMh/86b4166adc3b.jpg',
    Key? key,
  }) : super(key: key);

  @override
  State<Card> createState() => _CardState();
}

class _CardState extends State<Card> {
  late String _displayImage;
  bool _imageError = false;

  @override
  void initState() {
    super.initState();
    _displayImage =
        widget.images.isNotEmpty ? widget.images : widget.defaultImageUrl;
  }

  @override
  void didUpdateWidget(Card oldWidget) {
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

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Details(
              urls: widget.urls,
              images: _imageError ? widget.defaultImageUrl : _displayImage,
              txts: widget.txts,
              description: widget.description ?? "",
              imglist: widget.imglist,
              utube: widget.utube ?? "",
            ),
          ),
        );
      },
      child: Hero(
        tag: _imageError ? widget.defaultImageUrl : _displayImage,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              margin: EdgeInsets.symmetric(
                vertical: constraints.maxHeight * 0.02,
              ),
              height: constraints.maxHeight * 0.43,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30.0),
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: _getImageProvider(),
                ),
                border: Border.all(width: 0),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30.0),
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                padding: const EdgeInsets.all(16.0),
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
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
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
