import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jhc_app/Home/News.dart';
import 'package:jhc_app/widgets/Details.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

final Future<FirebaseApp> firebaseApp = Firebase.initializeApp();
final FirebaseFirestore firestore = FirebaseFirestore.instance;

class ShopPage extends StatelessWidget {
  static const String defaultImageUrl =
      'https://i.ibb.co/Y7sbhNrV/f24fe5746117.jpg';

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: firebaseApp,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return StreamBuilder<QuerySnapshot>(
            stream: firestore.collection('Shop').snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error loading data',
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
                return Center(
                  child: Text(
                    'No products available',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              return Container(
                padding: EdgeInsets.all(16.0),
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF000000),
                      Color(0xFF001020),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth > 800) {
                            return GridView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 1.5,
                                crossAxisSpacing: 20,
                                mainAxisSpacing: 20,
                              ),
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (BuildContext context, index) {
                                final doc = snapshot.data!.docs[index];
                                final data = doc.data() as Map<String, dynamic>;
                                final price = data['price']?.toString() ?? '';
                                final image = data['image']?.toString() ?? '';
                                final text = data['text']?.toString() ?? '';

                                return NewsCard(
                                  urls: price.isNotEmpty
                                      ? "Rs $price"
                                      : "Price not available",
                                  images: image.isNotEmpty
                                      ? image
                                      : defaultImageUrl,
                                  txts: text,
                                  imglist: [
                                    image.isNotEmpty ? image : defaultImageUrl
                                  ],
                                  defaultImageUrl: defaultImageUrl,
                                );
                              },
                            );
                          } else {
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (BuildContext context, index) {
                                final doc = snapshot.data!.docs[index];
                                final data = doc.data() as Map<String, dynamic>;
                                final price = data['price']?.toString() ?? '';
                                final image = data['image']?.toString() ?? '';
                                final text = data['text']?.toString() ?? '';

                                return Container(
                                  margin: EdgeInsets.symmetric(vertical: 10),
                                  height:
                                      MediaQuery.of(context).size.height * 0.3,
                                  child: NewsCard(
                                    urls: price.isNotEmpty
                                        ? "Rs $price"
                                        : "Price not available",
                                    images: image.isNotEmpty
                                        ? image
                                        : defaultImageUrl,
                                    txts: text,
                                    imglist: [
                                      image.isNotEmpty ? image : defaultImageUrl
                                    ],
                                    defaultImageUrl: defaultImageUrl,
                                  ),
                                );
                              },
                            );
                          }
                        },
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
    );
  }
}

class NewsCard extends StatefulWidget {
  final String urls;
  final List<String> imglist;
  final String images;
  final String txts;
  final String? utube;
  final String? description;
  final String defaultImageUrl;

  const NewsCard({
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
  State<NewsCard> createState() => _NewsCardState();
}

class _NewsCardState extends State<NewsCard> {
  late String _displayImage;
  bool _imageError = false;

  @override
  void initState() {
    super.initState();
    _displayImage =
        widget.images.isNotEmpty ? widget.images : widget.defaultImageUrl;
  }

  @override
  void didUpdateWidget(NewsCard oldWidget) {
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
      cacheManager: NewsCacheManager(),
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