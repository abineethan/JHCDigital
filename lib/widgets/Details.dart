import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
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
    this.defaultImageUrl = 'https://i.ibb.co/R42fQnMh/86b4166adc3b.jpg',
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
      return SizedBox.shrink();
    }

    return Padding(
      padding: _getDescriptionPadding(),
      child: Container(
        padding: _getDescriptionInnerPadding(),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey[850]!, Colors.grey[900]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(_getBorderRadius()),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
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
                color: Colors.white70,
                height: 1.5,
              ),
            ),
            if (_showSeeMoreButton)
              TextButton(
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
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size(50, 30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
          ],
        ),
      ),
    );
  }

  EdgeInsets _getDescriptionPadding() {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return EdgeInsets.all(16.0);
    if (width < 1200) return EdgeInsets.all(24.0);
    return EdgeInsets.symmetric(vertical: 32.0);
  }

  EdgeInsets _getDescriptionInnerPadding() {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return EdgeInsets.all(16.0);
    if (width < 1200) return EdgeInsets.all(24.0);
    return EdgeInsets.all(32.0);
  }

  double _getBorderRadius() {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 12;
    if (width < 1200) return 16;
    return 20;
  }

  double _getShadowBlurRadius() {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 10;
    if (width < 1200) return 15;
    return 20;
  }

  double _getShadowOffset() {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 4;
    if (width < 1200) return 8;
    return 10;
  }

  Widget _buildImage(String imageUrl, BoxFit fit, double borderRadius) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 2,
              offset: Offset(0, 4),
            )
          ],
        ),
        child: CachedNetworkImage(
          imageUrl: _imageErrors[imageUrl] == true
              ? widget.defaultImageUrl
              : imageUrl,
          fit: fit,
          cacheManager: DetailsCacheManager(),
          placeholder: (context, url) => Center(
            child: CircularProgressIndicator(
                color: const Color.fromARGB(255, 255, 255, 255)),
          ),
          errorWidget: (context, url, error) {
            if (!_imageErrors.containsKey(imageUrl)) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  _imageErrors[imageUrl] = true;
                });
              });
            }
            return Image.network(
              widget.defaultImageUrl,
              fit: fit,
            );
          },
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildDescription(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 0.8,
              ),
              itemCount: widget.imglist.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ImageFromUrl(
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
              padding: const EdgeInsets.all(16.0),
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
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: _buildImage(
                        'https://img.youtube.com/vi/${widget.utube}/maxresdefault.jpg',
                        BoxFit.cover,
                        12.0,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: Icon(
                        Icons.play_arrow,
                        size: 40,
                        color: Colors.blue[400],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (widget.urls.isNotEmpty && !isNumeric(widget.urls))
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () async {
                  final Uri uri = Uri.parse(widget.urls);
                  if (!await launchUrl(uri)) {
                    throw Exception('Could not launch ${widget.urls}');
                  }
                },
                icon: Icon(Icons.link, color: Colors.white),
                label: Text(
                  "Visit Website",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    return SingleChildScrollView(
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
                crossAxisSpacing: 20.0,
                mainAxisSpacing: 20.0,
                childAspectRatio: 1.3,
              ),
              itemCount: widget.imglist.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ImageFromUrl(
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
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(20.0),
                      child: Icon(
                        Icons.play_arrow,
                        size: 50,
                        color: Colors.blue[400],
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
                    icon: Icon(Icons.link, color: Colors.white, size: 28),
                    label: Text(
                      "Visit Website",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[800],
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return SingleChildScrollView(
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
                            builder: (context) => ImageFromUrl(
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
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(24.0),
                              child: Icon(
                                Icons.play_arrow,
                                size: 60,
                                color: Colors.blue[400],
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
                        icon: Icon(Icons.link, color: Colors.white, size: 30),
                        label: Text(
                          "Visit Website",
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[800],
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: Colors.grey[900],
        elevation: 0,
        title: Text(
          widget.txts,
          style: TextStyle(
            color: const Color.fromARGB(255, 255, 255, 255),
            fontSize: 21,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        iconTheme:
            IconThemeData(color: const Color.fromARGB(255, 255, 255, 255)),
      ),
      body: Container(
        constraints: BoxConstraints.expand(),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.grey[850]!, Colors.grey[900]!],
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

class ImageFromUrl extends StatelessWidget {
  final String imageUrl;

  const ImageFromUrl({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme:
            IconThemeData(color: const Color.fromARGB(255, 255, 255, 255)),
      ),
      body: Center(
        child: PhotoView(
          imageProvider: CachedNetworkImageProvider(
            imageUrl,
            cacheManager: DetailsCacheManager(),
          ),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 2,
          backgroundDecoration: BoxDecoration(
            color: Colors.grey[900],
          ),
          loadingBuilder: (context, event) => Center(
            child: CircularProgressIndicator(
              value: event == null
                  ? 0
                  : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
              color: const Color.fromARGB(255, 255, 255, 255),
            ),
          ),
          errorBuilder: (context, error, stackTrace) => Center(
            child: Icon(
              Icons.broken_image,
              color: const Color.fromARGB(255, 255, 255, 255),
              size: 60,
            ),
          ),
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
