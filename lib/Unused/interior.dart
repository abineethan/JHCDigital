import 'package:flutter/material.dart';
import 'package:jhc_app/Unused/PhotoView.dart';
import 'package:jhc_app/widgets/YoutubePlayer.dart';
import 'package:url_launcher/url_launcher.dart';

class Interior extends StatefulWidget {
  final String urls;
  final List<String> imglist;
  final String images;
  final String txts;
  final String? description;
  final String? first;
  final String? second;
  final String? third;
  final String? fourth;
  final String? fifth;
  final String utube;
  final String defaultImageUrl;

  const Interior({
    required this.urls,
    required this.images,
    required this.txts,
    required this.utube,
    this.description,
    this.fifth,
    this.first,
    this.fourth,
    this.second,
    this.third,
    this.imglist = const [""],
    this.defaultImageUrl = 'https://i.ibb.co/R42fQnMh/86b4166adc3b.jpg',
    Key? key,
  }) : super(key: key);

  @override
  State<Interior> createState() => _InteriorState();
}

class _InteriorState extends State<Interior> {
  final Map<String, bool> _imageErrors = {};

  bool isNumeric(String str) {
    return str.startsWith("Rs");
  }

  Widget _buildImage(String imageUrl, BoxFit fit, double borderRadius) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.network(
        _imageErrors[imageUrl] == true ? widget.defaultImageUrl : imageUrl,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
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
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color:
                        const Color.fromARGB(255, 69, 68, 68).withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Text(
                widget.txts.split(',')[1],
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.045,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(0.0),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
              ),
              itemCount: widget.imglist.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
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
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildImage(
                      widget.imglist[index],
                      BoxFit.cover,
                      12.0,
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
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: _buildImage(
                    'https://img.youtube.com/vi/${widget.utube}/maxresdefault.jpg',
                    BoxFit.cover,
                    8.0,
                  ),
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
                icon: const Icon(Icons.link, color: Colors.white),
                label: const Text(
                  "Visit",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color:
                        const Color.fromARGB(255, 69, 68, 68).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Text(
                widget.txts.split(',')[1],
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.035,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 1.2,
              ),
              itemCount: widget.imglist.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
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
                  child: _buildImage(
                    widget.imglist[index],
                    BoxFit.cover,
                    12.0,
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
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: _buildImage(
                    'https://img.youtube.com/vi/${widget.utube}/maxresdefault.jpg',
                    BoxFit.cover,
                    12.0,
                  ),
                ),
              ),
            ),
          if (widget.urls.isNotEmpty && !isNumeric(widget.urls))
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.4,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final Uri uri = Uri.parse(widget.urls);
                    if (!await launchUrl(uri)) {
                      throw Exception('Could not launch ${widget.urls}');
                    }
                  },
                  icon: const Icon(Icons.link, color: Colors.white, size: 28),
                  label: const Text(
                    "Visit Website",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 60),
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
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32.0),
                child: Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(255, 69, 68, 68)
                            .withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Text(
                    widget.txts.split(',')[1],
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.02,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 32.0, vertical: 16.0),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 24.0,
                    mainAxisSpacing: 24.0,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: widget.imglist.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
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
                      child: _buildImage(
                        widget.imglist[index],
                        BoxFit.cover,
                        12.0,
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
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.5,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: _buildImage(
                            'https://img.youtube.com/vi/${widget.utube}/maxresdefault.jpg',
                            BoxFit.cover,
                            12.0,
                          ),
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
                        icon: const Icon(Icons.link,
                            color: Colors.white, size: 30),
                        label: const Text(
                          "Visit Website",
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 80),
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
        toolbarHeight: 66,
        backgroundColor: Colors.black,
        title: Text(
          widget.txts.split(',')[0],
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: LayoutBuilder(
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
      backgroundColor: Colors.grey[900],
    );
  }
}
