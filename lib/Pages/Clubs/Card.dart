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
      'https://i.ibb.co/R42fQnMh/86b4166adc3b.jpg';

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
        backgroundColor: Colors.black,
      ),
      body: FutureBuilder(
        future: firebaseApp,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return StreamBuilder<DocumentSnapshot>(
              stream: firestore.collection('Clubs').doc(clubName).snapshots(),
              builder: (context, clubSnapshot) {
                if (clubSnapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading club information',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                if (clubSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: LoadingAnimationWidget.staggeredDotsWave(
                      color: Colors.white,
                      size: 150,
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
                      return Center(
                        child: Text(
                          'Error loading $clubName content',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    if (activitiesSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(
                        child: LoadingAnimationWidget.staggeredDotsWave(
                          color: Colors.white,
                          size: 150,
                        ),
                      );
                    }

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
                      child: CustomScrollView(
                        slivers: [
                          SliverToBoxAdapter(
                            child: InkWell(
                              onTap: clubWebsiteUrl != null &&
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
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                        color: Colors.white.withOpacity(0.2)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 130,
                                        height: 130,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: CachedNetworkImage(
                                            imageUrl: logoUrl,
                                            placeholder: (context, url) =>
                                                Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                            errorWidget: (context, url,
                                                    error) =>
                                                Image.network(defaultImageUrl),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            _buildLeaderRow(
                                                'President', president),
                                            const SizedBox(height: 8),
                                            _buildLeaderRow(
                                                'Secretary', secretary),
                                            const SizedBox(height: 8),
                                            _buildLeaderRow(
                                                'Treasurer', treasurer),
                                            const SizedBox(height: 8),
                                            _buildLeaderRow('Vice President',
                                                vicePresident),
                                            const SizedBox(height: 8),
                                            _buildLeaderRow('Vice Secretary',
                                                viceSecretary),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (!activitiesSnapshot.hasData ||
                              activitiesSnapshot.data!.docs.isEmpty)
                            SliverToBoxAdapter(
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Text(
                                    'No content available for $clubName',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            )
                          else
                            SliverPadding(
                              padding: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.of(context).size.width * 0.05,
                                vertical: 16.0,
                              ),
                              sliver: SliverGrid(
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

  Widget _buildLeaderRow(String title, String name) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 100,
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
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
