import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jhc_app/widgets/Details.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:carousel_slider/carousel_slider.dart' as carousel_lib;

final Future<FirebaseApp> firebaseApp = Firebase.initializeApp();
final FirebaseFirestore firestore = FirebaseFirestore.instance;

class ShopPageHome extends StatelessWidget {
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

              final screenHeight = MediaQuery.of(context).size.height;
              final documents = snapshot.data!.docs;

              return Container(
                child: carousel_lib.CarouselSlider.builder(
                  itemCount: documents.length,
                  itemBuilder: (context, index, id) {
                    final doc = documents[index];
                    final data = doc.data() as Map<String, dynamic>;

                    final price = data['price']?.toString() ?? '';
                    final image = data['image']?.toString() ?? '';
                    final text = data['text']?.toString() ?? '';

                    final displayImage =
                        image.isEmpty ? defaultImageUrl : image;

                    return Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Card(
                        urls: price.isNotEmpty
                            ? "Rs $price"
                            : "Price not available",
                        images: displayImage,
                        txts: text,
                        imglist: [displayImage],
                      ),
                    );
                  },
                  options: carousel_lib.CarouselOptions(
                    aspectRatio: 16 / 9,
                    height: MediaQuery.of(context).size.width > 800
                        ? screenHeight * 0.6
                        : screenHeight * 0.28,
                    autoPlay: true,
                    enableInfiniteScroll: true,
                    enlargeCenterPage: true,
                    viewportFraction:
                        MediaQuery.of(context).size.width > 800 ? 0.7 : 0.9,
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
    this.defaultImageUrl = 'https://i.ibb.co/Y7sbhNrV/f24fe5746117.jpg',
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

    final imageProvider = CachedNetworkImageProvider(_displayImage);
    final stream = imageProvider.resolve(ImageConfiguration.empty);
    stream.addListener(ImageStreamListener(
      (image, synchronousCall) {},
      onError: (exception, stackTrace) {
        if (!_imageError) {
          setState(() {
            _imageError = true;
            _displayImage = widget.defaultImageUrl;
          });
        }
      },
    ));

    return imageProvider;
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
