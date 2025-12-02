import 'package:flutter/material.dart';
import 'package:jhc_app/widgets/Ranking.dart';
import 'package:jhc_app/widgets/ImageView.dart';
import 'package:carousel_slider/carousel_slider.dart';

class SportsmeetView extends StatefulWidget {
  final String txts;
  final List<String> images;
  final String first;
  final String second;
  final String third;
  final String fourth;
  final String fifth;
  final String description;

  const SportsmeetView._({
    required this.txts,
    required this.images,
    required this.first,
    required this.second,
    required this.third,
    required this.fourth,
    required this.fifth,
    required this.description,
  });

  factory SportsmeetView({
    required String txts,
    required dynamic images,
    required String first,
    required String second,
    required String third,
    required String fourth,
    required String fifth,
    required String description,
  }) {
    final List<String> imageList = _convertImages(images);

    final String safeFirst = first;
    final String safeSecond = second;
    final String safeThird = third;
    final String safeFourth = fourth;
    final String safeFifth = fifth;
    final String safeDescription = description;

    return SportsmeetView._(
      txts: txts,
      images: imageList,
      first: safeFirst,
      second: safeSecond,
      third: safeThird,
      fourth: safeFourth,
      fifth: safeFifth,
      description: safeDescription,
    );
  }

  static List<String> _convertImages(dynamic imagesData) {
    if (imagesData == null) return [];
    if (imagesData is List<String>) return imagesData;
    if (imagesData is List) return imagesData.whereType<String>().toList();
    if (imagesData is String) return [imagesData];
    return [];
  }

  @override
  _SportsmeetViewState createState() => _SportsmeetViewState();
}

class _SportsmeetViewState extends State<SportsmeetView> {
  int _currentImageIndex = 0;

  void _openImageViewer(BuildContext context, int initialIndex) {
    if (widget.images.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageView(
          imageUrl: widget.images[initialIndex],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasImages = widget.images.isNotEmpty;
    final displayImages = hasImages ? widget.images : [defaultImageUrl];

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 15, 20, 25),
      appBar: AppBar(
        title: Text(
          widget.txts,
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
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
      body: CustomScrollView(
        slivers: [
          // Gallery Section - Matching sportsmeet_year_details style
          if (displayImages.isNotEmpty)
            SliverToBoxAdapter(
              child: _buildGallerySection(displayImages),
            ),
          // Event Title Card
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                color: Color(0xFF1A1F24),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Color(0xFF2563EB).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.event_rounded,
                                color: Color(0xFF2563EB), size: 24),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              widget.txts,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      if (widget.description.isNotEmpty)
                        Text(
                          widget.description,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                            height: 1.4,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Results Section
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: _buildResultsSection(),
            ),
          ),

          SliverToBoxAdapter(
            child: SizedBox(height: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildGallerySection(List<String> displayImages) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Color(0xFF1A1F24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Color(0xFF2563EB).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.photo_library_rounded,
                        color: Color(0xFF2563EB), size: 24),
                  ),
                  SizedBox(width: 12),
                  Text(
                    "Event Gallery",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Event-style Photo Cards Carousel
            Container(
              height: 250,
              child: Column(
                children: [
                  Expanded(
                    child: CarouselSlider.builder(
                      itemCount: displayImages.length,
                      itemBuilder: (context, index, realIndex) {
                        return _EventImageCard(
                          imageUrl: displayImages[index],
                          index: index,
                          onTap: () => _openImageViewer(context, index),
                        );
                      },
                      options: CarouselOptions(
                        aspectRatio: 16 / 9,
                        height: 200,
                        autoPlay: displayImages.length > 1,
                        autoPlayInterval: Duration(seconds: 4),
                        autoPlayAnimationDuration: Duration(milliseconds: 800),
                        autoPlayCurve: Curves.fastOutSlowIn,
                        enableInfiniteScroll: displayImages.length > 1,
                        enlargeCenterPage: true,
                        enlargeFactor: 0.18,
                        viewportFraction: 0.78,
                        scrollDirection: Axis.horizontal,
                        onPageChanged: (index, reason) {
                          setState(() {
                            _currentImageIndex = index;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  if (displayImages.length > 1)
                    _buildCustomDotsIndicator(displayImages.length),
                  SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomDotsIndicator(int itemCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(itemCount, (index) {
        return Container(
          width: 6,
          height: 6,
          margin: EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentImageIndex == index
                ? Colors.white
                : Colors.white.withOpacity(0.6),
          ),
        );
      }),
    );
  }

  Widget _buildResultsSection() {
    final hasResults = widget.first.isNotEmpty ||
        widget.second.isNotEmpty ||
        widget.third.isNotEmpty ||
        widget.fourth.isNotEmpty ||
        widget.fifth.isNotEmpty;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Color(0xFF1A1F24),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xFFF59E0B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.emoji_events_rounded,
                      color: Color(0xFFF59E0B), size: 24),
                ),
                SizedBox(width: 12),
                Text(
                  "Event Results",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            if (hasResults) ...[
              // All Rankings with Liquid UI
              Column(
                children: [
                  if (widget.first.isNotEmpty)
                    RankingWidget(
                        rank: "1st", name: widget.first, isWinner: true),
                  if (widget.second.isNotEmpty)
                    RankingWidget(rank: "2nd", name: widget.second),
                  if (widget.third.isNotEmpty)
                    RankingWidget(rank: "3rd", name: widget.third),
                  if (widget.fourth.isNotEmpty)
                    RankingWidget(rank: "4th", name: widget.fourth),
                  if (widget.fifth.isNotEmpty)
                    RankingWidget(rank: "5th", name: widget.fifth),
                ],
              ),
            ] else ...[
              // No Results State
              Container(
                margin: EdgeInsets.all(30),
                padding: EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(Icons.schedule_rounded,
                        size: 60, color: Colors.white54),
                    SizedBox(height: 16),
                    Text(
                      "Results Pending",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "The results for this event will be announced soon",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Event Image Card matching the _HeaderImageCard style
class _EventImageCard extends StatefulWidget {
  final String imageUrl;
  final int index;
  final VoidCallback onTap;

  const _EventImageCard({
    required this.imageUrl,
    required this.index,
    required this.onTap,
  });

  @override
  __EventImageCardState createState() => __EventImageCardState();
}

class __EventImageCardState extends State<_EventImageCard> {
  bool _imageError = false;

  ImageProvider _getImageProvider() {
    if (_imageError) {
      return NetworkImage(defaultImageUrl);
    }

    try {
      return NetworkImage(widget.imageUrl);
    } catch (e) {
      if (mounted) {
        setState(() {
          _imageError = true;
        });
      }
      return NetworkImage(defaultImageUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 6),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(20),
        child: Hero(
          tag: 'event-${widget.index}-${widget.imageUrl}',
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              image: DecorationImage(
                fit: BoxFit.cover,
                image: _getImageProvider(),
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 15,
                  offset: Offset(0, 8),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

const String defaultImageUrl = 'https://i.ibb.co/Y7sbhNrV/f24fe5746117.jpg';
