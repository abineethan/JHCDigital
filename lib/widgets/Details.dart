import 'package:flutter/material.dart';
import 'package:jhc_app/widgets/ImageView.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:jhc_app/widgets/YoutubePlayer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class Details extends StatefulWidget {
  final String urls;
  final List<String> imglist;
  final String images;
  final String txts;
  final String? description;
  final String utube;
  final String defaultImageUrl;

  const Details({
    required this.urls,
    required this.images,
    required this.txts,
    required this.utube,
    this.description,
    this.imglist = const [""],
    this.defaultImageUrl = 'https://i.ibb.co/Y7sbhNrV/f24fe5746117.jpg',
    Key? key,
  }) : super(key: key);

  @override
  State<Details> createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  final Map<String, bool> _imageErrors = {};
  bool _isExpanded = false;
  bool _showSeeMoreButton = false;
  late TextPainter _textPainter;
  final ScrollController _scrollController = ScrollController();

  bool isNumeric(String str) {
    return str.startsWith("Rs");
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkTextOverflow();
    });
  }

  void _checkTextOverflow() {
    if (widget.description == null) return;

    final maxLines = _isExpanded ? null : 5;
    final textSpan = TextSpan(
      text: widget.description,
      style: TextStyle(
        fontSize: _getDescriptionFontSize(),
        color: Colors.white70,
        height: 1.5,
      ),
    );

    _textPainter = TextPainter(
      text: textSpan,
      maxLines: maxLines,
      textDirection: TextDirection.ltr,
    );

    _textPainter.layout(maxWidth: _getMaxDescriptionWidth());

    setState(() {
      _showSeeMoreButton = _textPainter.didExceedMaxLines;
    });
  }

  double _getDescriptionFontSize() {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return width * 0.039;
    if (width < 1200) return width * 0.025;
    return width * 0.015;
  }

  double _getMaxDescriptionWidth() {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return width - 32.0;
    if (width < 1200) return width - 48.0;
    return width * 0.8 - 64.0;
  }

  Widget _buildDescription() {
    if (widget.description == null || widget.description!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: _getDescriptionPadding(),
      child: Container(
        padding: _getDescriptionInnerPadding(),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(_getBorderRadius()),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: _getShadowBlurRadius(),
              offset: Offset(0, _getShadowOffset()),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.description!,
              textAlign: TextAlign.start,
              maxLines: _isExpanded ? null : 5,
              overflow: _isExpanded ? null : TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: _getDescriptionFontSize(),
                color: Colors.white.withOpacity(0.9),
                height: 1.6,
                letterSpacing: -0.2,
              ),
            ),
            if (_showSeeMoreButton)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                      _checkTextOverflow();
                    });
                  },
                  child: Text(
                    _isExpanded ? 'See Less' : 'See More',
                    style: TextStyle(
                      color: Colors.blue[400],
                      fontSize: _getDescriptionFontSize() * 0.9,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    minimumSize: const Size(50, 36),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  EdgeInsets _getDescriptionPadding() {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return const EdgeInsets.all(20);
    if (width < 1200) return const EdgeInsets.all(24);
    return const EdgeInsets.symmetric(vertical: 32.0);
  }

  EdgeInsets _getDescriptionInnerPadding() {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return const EdgeInsets.all(20);
    if (width < 1200) return const EdgeInsets.all(24);
    return const EdgeInsets.all(32);
  }

  double _getBorderRadius() {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 20;
    if (width < 1200) return 24;
    return 28;
  }

  double _getShadowBlurRadius() {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 15;
    if (width < 1200) return 20;
    return 25;
  }

  double _getShadowOffset() {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 6;
    if (width < 1200) return 8;
    return 10;
  }

  Widget _buildImage(String imageUrl, BoxFit fit, double borderRadius) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 2,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: CachedNetworkImage(
          imageUrl: _imageErrors[imageUrl] == true
              ? widget.defaultImageUrl
              : imageUrl,
          fit: fit,
          cacheManager: DetailsCacheManager(),
          placeholder: (context, url) => Container(
            color: Colors.white.withOpacity(0.1),
            child: Center(
              child: CircularProgressIndicator(
                color: Colors.blue[400],
                strokeWidth: 2,
              ),
            ),
          ),
          errorWidget: (context, url, error) {
            if (!_imageErrors.containsKey(imageUrl)) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  _imageErrors[imageUrl] = true;
                });
              });
            }
            return Container(
              color: Colors.white.withOpacity(0.1),
              child: Icon(
                Icons.broken_image,
                color: Colors.white.withOpacity(0.3),
                size: 40,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildDescription(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                crossAxisSpacing: 20.0,
                mainAxisSpacing: 20.0,
                childAspectRatio: 0.8,
              ),
              itemCount: widget.imglist.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ImageView(
                          imageUrl: _imageErrors[widget.imglist[index]] == true
                              ? widget.defaultImageUrl
                              : widget.imglist[index],
                        ),
                      ),
                    );
                  },
                  child: Hero(
                    tag: 'image_$index',
                    child: _buildImage(
                      widget.imglist[index],
                      BoxFit.cover,
                      16.0,
                    ),
                  ),
                );
              },
            ),
          ),
          if (widget.utube.isNotEmpty && !isNumeric(widget.urls))
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          FullScreenVideoPlayer(videoId: widget.utube),
                    ),
                  );
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.3,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: _buildImage(
                        'https://img.youtube.com/vi/${widget.utube}/maxresdefault.jpg',
                        BoxFit.cover,
                        16.0,
                      ),
                    ),
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.blue[400]!.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Icon(
                        Icons.play_arrow,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (widget.urls.isNotEmpty && !isNumeric(widget.urls))
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton.icon(
                onPressed: () async {
                  final Uri uri = Uri.parse(widget.urls);
                  if (!await launchUrl(uri)) {
                    throw Exception('Could not launch ${widget.urls}');
                  }
                },
                icon: Icon(Icons.link, color: Colors.white, size: 20),
                label: Text(
                  "Visit",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[500],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  shadowColor: Colors.blue[400]!.withOpacity(0.3),
                ),
              ),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    return SingleChildScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildDescription(),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 24.0,
                mainAxisSpacing: 24.0,
                childAspectRatio: 1.3,
              ),
              itemCount: widget.imglist.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ImageView(
                          imageUrl: _imageErrors[widget.imglist[index]] == true
                              ? widget.defaultImageUrl
                              : widget.imglist[index],
                        ),
                      ),
                    );
                  },
                  child: Hero(
                    tag: 'image_$index',
                    child: _buildImage(
                      widget.imglist[index],
                      BoxFit.cover,
                      16.0,
                    ),
                  ),
                );
              },
            ),
          ),
          if (widget.utube.isNotEmpty && !isNumeric(widget.urls))
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          FullScreenVideoPlayer(videoId: widget.utube),
                    ),
                  );
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.35,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: _buildImage(
                        'https://img.youtube.com/vi/${widget.utube}/maxresdefault.jpg',
                        BoxFit.cover,
                        16.0,
                      ),
                    ),
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.blue[400]!.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Icon(
                        Icons.play_arrow,
                        size: 35,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (widget.urls.isNotEmpty && !isNumeric(widget.urls))
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final Uri uri = Uri.parse(widget.urls);
                      if (!await launchUrl(uri)) {
                        throw Exception('Could not launch ${widget.urls}');
                      }
                    },
                    icon: Icon(Icons.link, color: Colors.white, size: 24),
                    label: Text(
                      "Visit",
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w500),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[500],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      shadowColor: Colors.blue[400]!.withOpacity(0.3),
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return SingleChildScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      child: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDescription(),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 32.0, vertical: 16.0),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 32.0,
                    mainAxisSpacing: 32.0,
                    childAspectRatio: 1.6,
                  ),
                  itemCount: widget.imglist.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImageView(
                              imageUrl:
                                  _imageErrors[widget.imglist[index]] == true
                                      ? widget.defaultImageUrl
                                      : widget.imglist[index],
                            ),
                          ),
                        );
                      },
                      child: Hero(
                        tag: 'image_$index',
                        child: _buildImage(
                          widget.imglist[index],
                          BoxFit.cover,
                          20.0,
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (widget.utube.isNotEmpty && !isNumeric(widget.urls))
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  FullScreenVideoPlayer(videoId: widget.utube),
                            ),
                          );
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              height: MediaQuery.of(context).size.height * 0.45,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: _buildImage(
                                'https://img.youtube.com/vi/${widget.utube}/maxresdefault.jpg',
                                BoxFit.cover,
                                20.0,
                              ),
                            ),
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.blue[400]!.withOpacity(0.9),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  )
                                ],
                              ),
                              child: Icon(
                                Icons.play_arrow,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              if (widget.urls.isNotEmpty && !isNumeric(widget.urls))
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final Uri uri = Uri.parse(widget.urls);
                          if (!await launchUrl(uri)) {
                            throw Exception('Could not launch ${widget.urls}');
                          }
                        },
                        icon: Icon(Icons.link, color: Colors.white, size: 24),
                        label: Text(
                          "Visit",
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w500),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[500],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          shadowColor: Colors.blue[400]!.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: Colors.white,
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.txts,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1C1C1E),
              Color(0xFF2C2C2E),
            ],
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 600) {
              return _buildMobileLayout();
            } else if (constraints.maxWidth < 1200) {
              return _buildTabletLayout();
            } else {
              return _buildDesktopLayout();
            }
          },
        ),
      ),
    );
  }
}

class DetailsCacheManager extends CacheManager {
  static const key = 'DetailsCacheKey';
  static const Duration cacheTimeout = Duration(days: 90);

  static final DetailsCacheManager _instance = DetailsCacheManager._();

  factory DetailsCacheManager() {
    return _instance;
  }

  DetailsCacheManager._()
      : super(Config(
          key,
          stalePeriod: cacheTimeout,
          maxNrOfCacheObjects: 500,
        ));
}