import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:jhc_app/Pages/Sportsmeet/SportsmeetViewPage.dart';
import 'package:jhc_app/Unused/interior.dart';

class BreakingNewsCard extends StatefulWidget {
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
  final String? utube;
  final String defaultImageUrl;

  const BreakingNewsCard({
    required this.urls,
    required this.images,
    required this.txts,
    this.description,
    this.fifth,
    this.first,
    this.fourth,
    this.second,
    this.third,
    this.imglist = const [""],
    this.utube,
    this.defaultImageUrl = 'https://i.ibb.co/R42fQnMh/86b4166adc3b.jpg',
    Key? key,
  }) : super(key: key);

  @override
  State<BreakingNewsCard> createState() => _BreakingNewsCardState();
}

class _BreakingNewsCardState extends State<BreakingNewsCard> {
  late String _displayImage;
  bool _imageError = false;

  @override
  void initState() {
    super.initState();
    _displayImage =
        widget.images.isNotEmpty ? widget.images : widget.defaultImageUrl;
  }

  @override
  void didUpdateWidget(BreakingNewsCard oldWidget) {
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
        if (widget.urls.startsWith('1st')) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewPageSportsmeet(
                first: widget.first ?? "",
                second: widget.second ?? "",
                third: widget.third ?? "",
                fourth: widget.fourth ?? "",
                fifth: widget.fifth ?? "",
                txts: widget.txts,
                images: _imageError ? widget.defaultImageUrl : _displayImage,
                description: widget.description ?? "",
              ),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Interior(
                urls: widget.urls,
                images: _imageError ? widget.defaultImageUrl : _displayImage,
                txts: widget.txts,
                description: widget.description ?? "",
                first: widget.first ?? "",
                second: widget.second ?? "",
                third: widget.third ?? "",
                fourth: widget.fourth ?? "",
                fifth: widget.fifth ?? "",
                imglist: widget.imglist,
                utube: widget.utube ?? "",
              ),
            ),
          );
        }
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
                      widget.txts.split(',').first,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenHeight * 0.022,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      widget.urls,
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: screenHeight * 0.02,
                        fontWeight: FontWeight.normal,
                      ),
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
