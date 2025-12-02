import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jhc_app/Pages/Sportsmeet/Categories.dart';
import 'package:jhc_app/Pages/Sportsmeet/Service.dart';
import 'package:jhc_app/Pages/Sportsmeet/View.dart';
import 'package:jhc_app/widgets/Ranking.dart';
import 'package:jhc_app/widgets/ImageView.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class SportsmeetDetails extends StatefulWidget {
  final String year;

  const SportsmeetDetails({required this.year});

  @override
  _SportsmeetDetailsState createState() => _SportsmeetDetailsState();
}

class _SportsmeetDetailsState extends State<SportsmeetDetails> {
  final SportsmeetService _sportsmeetService = SportsmeetService();
  List<String> _availableCategory = [];
  bool _isLoading = true;
  List<String> _headerImages = [];
  Map<String, dynamic> _houseRankings = {};

  final Color _surfaceColor = Color(0xFF1A1F24);
  final Color _primaryColor = Color(0xFF2563EB);
  final Color _accentColor = Color(0xFFF59E0B);
  final Color _textPrimary = Colors.white;

  @override
  void initState() {
    super.initState();
    _loadYearData();
  }

  Future<void> _loadYearData() async {
    try {
      final Category = await _sportsmeetService.getCategoryForYear(widget.year);
      final headerImages =
          await _sportsmeetService.getYearHeaderImages(widget.year);
      final rankings = await _sportsmeetService.getHouseRankings(widget.year);

      setState(() {
        _availableCategory = Category;
        _headerImages = headerImages;
        _houseRankings = rankings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _availableCategory = [];
        _headerImages = [];
        _houseRankings = {};
      });
    }
  }

  void _openHeaderImageViewer(BuildContext context, int initialIndex) {
    if (_headerImages.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageView(
          imageUrl: _headerImages[initialIndex],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 15, 20, 25),
      appBar: AppBar(
        title: Text(
          'Sportsmeet ${widget.year}',
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
      body: _isLoading
          ? Container(
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
            )
          : _buildMainContent(),
    );
  }

  Widget _buildMainContent() {
    return CustomScrollView(
      slivers: [
        if (_headerImages.isNotEmpty)
          SliverToBoxAdapter(
            child: _buildHeaderImagesGallery(),
          ),
        if (_hasHouseRankings()) _buildLiquidRankingsSection(),
        SliverToBoxAdapter(
          child: _buildCategorySection(),
        ),
        SliverToBoxAdapter(
          child: SizedBox(height: 32),
        ),
      ],
    );
  }

  Widget _buildHeaderImagesGallery() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                        color: _primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.photo_library_rounded,
                          color: _primaryColor, size: 24),
                    ),
                    SizedBox(width: 12),
                    Text(
                      "Gallery",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 250,
                child: Column(
                  children: [
                    Expanded(
                      child: CarouselSlider.builder(
                        itemCount: _headerImages.length,
                        itemBuilder: (context, index, realIndex) {
                          return _HeaderImageCard(
                            imageUrl: _headerImages[index],
                            index: index,
                            onTap: () => _openHeaderImageViewer(context, index),
                          );
                        },
                        options: CarouselOptions(
                          aspectRatio: 16 / 9,
                          height: 190,
                          autoPlay: _headerImages.length > 1,
                          autoPlayInterval: Duration(seconds: 4),
                          autoPlayAnimationDuration:
                              Duration(milliseconds: 800),
                          autoPlayCurve: Curves.fastOutSlowIn,
                          enableInfiniteScroll: _headerImages.length > 1,
                          enlargeCenterPage: true,
                          enlargeFactor: 0.18,
                          viewportFraction: 0.78,
                          scrollDirection: Axis.horizontal,
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    if (_headerImages.length > 1)
                      _buildCustomDotsIndicator(_headerImages.length),
                    SizedBox(height: 12),
                  ],
                ),
              ),
            ],
          ),
        ));
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
            color: Colors.white.withOpacity(0.6),
          ),
        );
      }),
    );
  }

  Widget _buildLiquidRankingsSection() {
    final rankings = _getFullRankingsList();

    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.all(16),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _surfaceColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.emoji_events_rounded,
                      color: _accentColor, size: 24),
                ),
                SizedBox(width: 12),
                Text(
                  "House Rankings",
                  style: TextStyle(
                    color: _textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Column(
              children: rankings.map((house) {
                return RankingWidget(
                  rank: "${house['position']}st",
                  name: house['houseName'],
                  isWinner: house['position'] == 1,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.category, color: _primaryColor, size: 24),
              ),
              SizedBox(width: 12),
              Text(
                "Categories",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
        ),
        ..._buildCategoryCards(),
      ],
    );
  }

  List<Widget> _buildCategoryCards() {
    return _availableCategory.map((category) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Color(0xFF1A1F24),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _sportsmeetService.getCategoryDisplayName(category),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => _navigateToCategories(category),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Color(0xFF2563EB).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.arrow_forward_ios_rounded,
                              color: Color(0xFF2563EB), size: 16),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 16),
                  SportsmeetCarousel(
                    year: widget.year,
                    category: category,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  bool _hasHouseRankings() {
    return _houseRankings.isNotEmpty &&
        _houseRankings.containsKey('first') &&
        _houseRankings['first'] != null &&
        _houseRankings['first'].toString().isNotEmpty;
  }

  List<Map<String, dynamic>> _getFullRankingsList() {
    List<Map<String, dynamic>> rankings = [];

    if (_houseRankings.containsKey('first') &&
        _houseRankings['first'] != null) {
      rankings.add({
        'position': 1,
        'houseName': _houseRankings['first'],
      });
    }

    if (_houseRankings.containsKey('second') &&
        _houseRankings['second'] != null) {
      rankings.add({
        'position': 2,
        'houseName': _houseRankings['second'],
      });
    }

    if (_houseRankings.containsKey('third') &&
        _houseRankings['third'] != null) {
      rankings.add({
        'position': 3,
        'houseName': _houseRankings['third'],
      });
    }

    if (_houseRankings.containsKey('fourth') &&
        _houseRankings['fourth'] != null) {
      rankings.add({
        'position': 4,
        'houseName': _houseRankings['fourth'],
      });
    }

    if (_houseRankings.containsKey('fifth') &&
        _houseRankings['fifth'] != null) {
      rankings.add({
        'position': 5,
        'houseName': _houseRankings['fifth'],
      });
    }

    return rankings;
  }

  void _navigateToCategories(String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SportsmeetCategories(
          year: widget.year,
          category: category,
        ),
      ),
    );
  }
}

class _HeaderImageCard extends StatefulWidget {
  final String imageUrl;
  final int index;
  final VoidCallback onTap;

  const _HeaderImageCard({
    required this.imageUrl,
    required this.index,
    required this.onTap,
  });

  @override
  __HeaderImageCardState createState() => __HeaderImageCardState();
}

class __HeaderImageCardState extends State<_HeaderImageCard> {
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
          tag: 'header-${widget.index}-${widget.imageUrl}',
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

class SportsmeetCarousel extends StatefulWidget {
  final String year;
  final String category;
  final SportsmeetService _sportsmeetService;

  SportsmeetCarousel({
    required this.year,
    required this.category,
    Key? key,
  })  : _sportsmeetService = SportsmeetService(),
        super(key: key);

  @override
  _SportsmeetCarouselState createState() => _SportsmeetCarouselState();
}

class _SportsmeetCarouselState extends State<SportsmeetCarousel> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: widget._sportsmeetService
          .getEventsStream(widget.year, widget.category),
      builder: (context, snapshot) {
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

        if (snapshot.hasError) {
          return _buildErrorWidget("Failed to load events");
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyWidget(widget.category);
        }

        return _buildNewsStyleCarousel(snapshot.data!.docs, context);
      },
    );
  }

  Widget _buildNewsStyleCarousel(
      List<QueryDocumentSnapshot> docs, BuildContext context) {
    return Container(
      height: 220,
      child: Column(
        children: [
          Expanded(
            child: CarouselSlider.builder(
              itemCount: docs.length,
              itemBuilder: (context, index, realIndex) {
                final eventData =
                    widget._sportsmeetService.parseEventData(docs[index]);
                return _EventCard(
                  eventData: eventData,
                  eventId: docs[index].id,
                  onTap: () => _navigateToEventDetails(
                      context, eventData, docs[index].id),
                );
              },
              options: CarouselOptions(
                aspectRatio: 16 / 9,
                height: 190,
                autoPlay: docs.length > 1,
                autoPlayInterval: Duration(seconds: 4),
                autoPlayAnimationDuration: Duration(milliseconds: 800),
                autoPlayCurve: Curves.fastOutSlowIn,
                enableInfiniteScroll: docs.length > 1,
                enlargeCenterPage: true,
                enlargeFactor: 0.18,
                viewportFraction: 0.78,
                scrollDirection: Axis.horizontal,
              ),
            ),
          ),
          SizedBox(height: 12),
          if (docs.length > 1) _buildCustomDotsIndicator(docs.length),
        ],
      ),
    );
  }

  void _navigateToEventDetails(
      BuildContext context, Map<String, dynamic> eventData, String eventId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SportsmeetView(
          txts: eventData['title'] ?? 'Event Details',
          images: eventData['images'] ?? [defaultImageUrl],
          first: eventData['first'] ?? '',
          second: eventData['second'] ?? '',
          third: eventData['third'] ?? '',
          fourth: eventData['fourth'] ?? '',
          fifth: eventData['fifth'] ?? '',
          description: eventData['description'] ?? '',
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
            color: Colors.white.withOpacity(0.6),
          ),
        );
      }),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Container(
      height: 180,
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: Colors.red,
              size: 32,
            ),
            SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget(String category) {
    final displayName =
        widget._sportsmeetService.getCategoryDisplayName(category);

    return Container(
      height: 180,
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Color(0xFF1A1F24),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sports_score_rounded,
              color: Colors.white54,
              size: 40,
            ),
            SizedBox(height: 8),
            Text(
              "No events for $displayName",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventCard extends StatefulWidget {
  final Map<String, dynamic> eventData;
  final String eventId;
  final VoidCallback onTap;

  const _EventCard({
    required this.eventData,
    required this.eventId,
    required this.onTap,
  });

  @override
  __EventCardState createState() => __EventCardState();
}

const String defaultImageUrl = 'https://i.ibb.co/Y7sbhNrV/f24fe5746117.jpg';

class __EventCardState extends State<_EventCard> {
  bool _imageError = false;
  late String _displayImage;

  @override
  void initState() {
    super.initState();
    _displayImage = _getSafeImageUrl(widget.eventData);
  }

  String _getSafeImageUrl(Map<String, dynamic> eventData) {
    if (eventData['images'] != null && eventData['images'] is List) {
      final images = List<String>.from(eventData['images']);
      if (images.isNotEmpty && images.first.isNotEmpty) {
        return images.first;
      }
    }

    if (eventData['image'] != null && eventData['image'] is String) {
      final image = eventData['image'] as String;
      if (image.isNotEmpty) {
        return image;
      }
    }

    return defaultImageUrl;
  }

  ImageProvider _getImageProvider() {
    if (_imageError) {
      return NetworkImage(defaultImageUrl);
    }

    try {
      return NetworkImage(_displayImage);
    } catch (e) {
      if (mounted) {
        setState(() {
          _imageError = true;
          _displayImage = defaultImageUrl;
        });
      }
      return NetworkImage(defaultImageUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.eventData['title']?.toString() ?? 'Untitled Event';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 6),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(20),
        child: Hero(
          tag: '${widget.eventId}-$_displayImage',
          child: Container(
            height: 180,
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
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.8),
                          blurRadius: 6,
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
