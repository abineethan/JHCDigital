import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jhc_app/widgets/Details.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

final Future<FirebaseApp> firebaseApp = Firebase.initializeApp();
final FirebaseFirestore firestore = FirebaseFirestore.instance;

class Donations extends StatelessWidget {
  static const String defaultImageUrl =
      'https://i.ibb.co/Y7sbhNrV/f24fe5746117.jpg';

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: firebaseApp,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return StreamBuilder<QuerySnapshot>(
            stream: firestore
                .collection('Donations')
                .orderBy('date', descending: true)
                .snapshots(),
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
                        'Error loading Donations',
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
                        'No Donations available',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                );
              }

              final documents = snapshot.data!.docs;

              return Container(
                color: const Color.fromARGB(255, 15, 20, 25),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.05,
                    vertical: 16.0,
                  ),
                  child: CustomScrollView(
                    slivers: [
                      SliverGrid(
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
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

                            final String rawUrl = data['url']?.toString() ?? '';
                            final String rawText =
                                data['text']?.toString() ?? '';
                            final String rawUtube =
                                data['utube']?.toString() ?? '';
                            final String description =
                                data['description']?.toString() ?? '';

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

                            return DonationCard(
                              urls: rawUrl.isNotEmpty ? rawUrl : '',
                              images: firstImage,
                              txts: processedText,
                              imglist: imageList,
                              description: description,
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

class DonationCard extends StatefulWidget {
  final List<String> imglist;
  final String urls;
  final String? utube;
  final String images;
  final String txts;
  final String? description;
  final String defaultImageUrl;

  const DonationCard({
    required this.images,
    required this.txts,
    required this.urls,
    this.utube,
    this.description,
    this.imglist = const [""],
    this.defaultImageUrl = 'https://i.ibb.co/Y7sbhNrV/f24fe5746117.jpg',
    Key? key,
  }) : super(key: key);

  @override
  State<DonationCard> createState() => _DonationCardState();
}

class _DonationCardState extends State<DonationCard> {
  late String _displayImage;
  bool _imageError = false;

  @override
  void initState() {
    super.initState();
    _displayImage =
        widget.images.isNotEmpty ? widget.images : widget.defaultImageUrl;
  }

  @override
  void didUpdateWidget(DonationCard oldWidget) {
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
      cacheManager: DonationsCacheManager(),
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: Stack(
            children: [
              Hero(
                tag: _imageError ? widget.defaultImageUrl : _displayImage,
                child: Container(
                  height: double.infinity,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: _getImageProvider(),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.black],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Text(
                  widget.txts,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenHeight * 0.022,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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
  }
}

class DonationsCacheManager extends CacheManager {
  static const key = 'donationsCacheKey';
  static const Duration cacheTimeout = Duration(days: 90);

  static final DonationsCacheManager _instance = DonationsCacheManager._();

  factory DonationsCacheManager() {
    return _instance;
  }

  DonationsCacheManager._()
      : super(Config(
          key,
          stalePeriod: cacheTimeout,
          maxNrOfCacheObjects: 200,
        ));
}
