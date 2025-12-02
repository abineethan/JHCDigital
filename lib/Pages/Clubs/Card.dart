import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:jhc_app/widgets/Details.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:url_launcher/url_launcher.dart';

final Future<FirebaseApp> firebaseApp = Firebase.initializeApp();
final FirebaseFirestore firestore = FirebaseFirestore.instance;

class ClubDetailsPage extends StatelessWidget {
  final String clubName;
  static const String defaultImageUrl =
      'https://i.ibb.co/Y7sbhNrV/f24fe5746117.jpg';

  const ClubDetailsPage({Key? key, required this.clubName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          clubName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
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
      body: FutureBuilder(
        future: firebaseApp,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return StreamBuilder<DocumentSnapshot>(
              stream: firestore.collection('Clubs').doc(clubName).snapshots(),
              builder: (context, clubSnapshot) {
                if (clubSnapshot.hasError) {
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
                          'Error loading club information',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  );
                }

                if (clubSnapshot.connectionState == ConnectionState.waiting) {
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

                final clubData =
                    clubSnapshot.data?.data() as Map<String, dynamic>? ?? {};
                final logoUrl =
                    clubData['imageUrl']?.toString() ?? defaultImageUrl;
                final president = clubData['President']?.toString() ?? '—';
                final secretary = clubData['Secretary']?.toString() ?? '—';
                final treasurer = clubData['Treasurer']?.toString() ?? '—';
                final vicePresident =
                    clubData['Vice President']?.toString() ?? '—';
                final viceSecretary =
                    clubData['Vice Secretary']?.toString() ?? '—';
                final clubWebsiteUrl = clubData['websiteUrl']?.toString();

                return StreamBuilder<QuerySnapshot>(
                  stream: firestore
                      .collection('Clubs')
                      .doc(clubName)
                      .collection('Activities')
                      .orderBy('date', descending: true)
                      .snapshots(),
                  builder: (context,
                      AsyncSnapshot<QuerySnapshot> activitiesSnapshot) {
                    if (activitiesSnapshot.hasError) {
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
                              'Error loading $clubName content',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      );
                    }

                    if (activitiesSnapshot.connectionState ==
                        ConnectionState.waiting) {
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
                      color: const Color.fromARGB(255, 15, 20, 25),
                      child: CustomScrollView(
                        slivers: [
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: LiquidClubCard(
                                imageUrl: logoUrl,
                                clubName: clubName,
                                president: president,
                                secretary: secretary,
                                treasurer: treasurer,
                                vicePresident: vicePresident,
                                viceSecretary: viceSecretary,
                                onWebsiteTap: clubWebsiteUrl != null &&
                                        clubWebsiteUrl.isNotEmpty
                                    ? () async {
                                        if (await canLaunch(clubWebsiteUrl)) {
                                          await launch(clubWebsiteUrl);
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Could not launch website')),
                                          );
                                        }
                                      }
                                    : null,
                              ),
                            ),
                          ),
                          if (!activitiesSnapshot.hasData ||
                              activitiesSnapshot.data!.docs.isEmpty)
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color:
                                        const Color.fromARGB(255, 25, 30, 32),
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
                                  child: Center(
                                    child: Text(
                                      'No content available for $clubName',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          else
                            SliverPadding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              sliver: SliverGrid(
                                gridDelegate:
                                    SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 600,
                                  mainAxisExtent:
                                      MediaQuery.of(context).size.width > 800
                                          ? 400
                                          : 300,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                ),
                                delegate: SliverChildBuilderDelegate(
                                  (BuildContext context, int index) {
                                    final documents =
                                        activitiesSnapshot.data!.docs;
                                    final doc = documents[index];
                                    final data =
                                        doc.data() as Map<String, dynamic>;

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
                                      imageList = images
                                          .map((e) => e.toString())
                                          .toList();
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
                                      processedUtube =
                                          match != null && match.groupCount >= 7
                                              ? match.group(7)
                                              : rawUtube;
                                    }

                                    return ClubActivityCard(
                                      urls: rawUrl.isNotEmpty ? rawUrl : '',
                                      images: firstImage,
                                      txts: processedText,
                                      description: description,
                                      imglist: imageList,
                                      utube: processedUtube ?? '',
                                      defaultImageUrl: defaultImageUrl,
                                    );
                                  },
                                  childCount: activitiesSnapshot.hasData
                                      ? activitiesSnapshot.data!.docs.length
                                      : 0,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
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
      ),
    );
  }
}

class LiquidClubCard extends StatefulWidget {
  final String imageUrl;
  final String clubName;
  final String president;
  final String secretary;
  final String treasurer;
  final String vicePresident;
  final String viceSecretary;
  final VoidCallback? onWebsiteTap;

  const LiquidClubCard({
    Key? key,
    required this.imageUrl,
    required this.clubName,
    required this.president,
    required this.secretary,
    required this.treasurer,
    required this.vicePresident,
    required this.viceSecretary,
    this.onWebsiteTap,
  }) : super(key: key);

  @override
  State<LiquidClubCard> createState() => _LiquidClubCardState();
}

class _LiquidClubCardState extends State<LiquidClubCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Helper method to get responsive text size for leader rows
  double _getLeaderTextSize(BuildContext context) {
    final double textScaleFactor = MediaQuery.of(context).textScaleFactor;
    double baseSize = 14;
    
    // Adjust font size based on text scale factor
    if (textScaleFactor > 1.5) {
      baseSize = 10;
    } else if (textScaleFactor > 1.3) {
      baseSize = 11;
    } else if (textScaleFactor > 1.1) {
      baseSize = 12;
    }
    
    return baseSize;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color.fromARGB(255, 25, 30, 32),
                const Color.fromARGB(255, 35, 40, 42),
                const Color.fromARGB(255, 25, 30, 32),
              ],
              stops: [0.0, _animation.value, 1.0],
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.1 + _animation.value * 0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3 + _animation.value * 0.2),
                blurRadius: 15 + _animation.value * 10,
                offset: Offset(0, 3 + _animation.value * 2),
              ),
            ],
          ),
          child: child!,
        );
      },
      child: InkWell(
        onTap: widget.onWebsiteTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: widget.imageUrl,
                      placeholder: (context, url) => Center(
                        child: CircularProgressIndicator(
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                      errorWidget: (context, url, error) =>
                          Image.network(ClubDetailsPage.defaultImageUrl),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment(-1.0 + _animation.value * 2,
                                    -1.0 + _animation.value * 2),
                                end: Alignment(1.0 - _animation.value * 2,
                                    1.0 - _animation.value * 2),
                                colors: [
                                  Colors.transparent,
                                  Colors.white.withOpacity(
                                      0.05 + _animation.value * 0.1),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLeaderRow('President', widget.president),
                  const SizedBox(height: 8),
                  _buildLeaderRow('Secretary', widget.secretary),
                  const SizedBox(height: 8),
                  _buildLeaderRow('Treasurer', widget.treasurer),
                  const SizedBox(height: 8),
                  _buildLeaderRow('Vice President', widget.vicePresident),
                  const SizedBox(height: 8),
                  _buildLeaderRow('Vice Secretary', widget.viceSecretary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

Widget _buildLeaderRow(String title, String name) {
  final textSize = _getLeaderTextSize(context);
  
  return LayoutBuilder(
    builder: (context, constraints) {
      final double screenWidth = MediaQuery.of(context).size.width;
      final bool isSmallScreen = screenWidth < 400;
      final bool needsCompactLayout = MediaQuery.of(context).textScaleFactor > 1.2 || isSmallScreen;

      if (needsCompactLayout) {
        // Always use vertical layout for small screens or high zoom
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: textSize,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              child: Text(
                name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: textSize,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
              ),
            ),
          ],
        );
      } else {
        // Horizontal layout for larger screens
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 100,
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: textSize,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                constraints: BoxConstraints(
                  minHeight: textSize * 1.5, // Ensure minimum height
                ),
                child: Text(
                  name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: textSize,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                ),
              ),
            ),
          ],
        );
      }
    },
  );
}
}

// ClubActivityCard remains exactly the same as your original
class ClubActivityCard extends StatefulWidget {
  final String urls;
  final List<String> imglist;
  final String images;
  final String txts;
  final String? utube;
  final String? description;
  final String defaultImageUrl;

  const ClubActivityCard({
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
  State<ClubActivityCard> createState() => _ClubActivityCardState();
}

class _ClubActivityCardState extends State<ClubActivityCard> {
  late String _displayImage;
  bool _imageError = false;

  @override
  void initState() {
    super.initState();
    _displayImage =
        widget.images.isNotEmpty ? widget.images : widget.defaultImageUrl;
  }

  @override
  void didUpdateWidget(ClubActivityCard oldWidget) {
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
      cacheManager: ClubsCacheManager(),
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

class ClubsCacheManager extends CacheManager {
  static const key = 'clubsCacheKey';
  static const Duration cacheTimeout = Duration(days: 90);

  static final ClubsCacheManager _instance = ClubsCacheManager._();

  factory ClubsCacheManager() {
    return _instance;
  }

  ClubsCacheManager._()
      : super(Config(
          key,
          stalePeriod: cacheTimeout,
          maxNrOfCacheObjects: 200,
        ));
}