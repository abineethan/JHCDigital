
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:url_launcher/url_launcher.dart';

class ImageView extends StatelessWidget {
  final String imageUrl;

  const ImageView({required this.imageUrl});

  Future<void> _downloadImage(BuildContext context) async {
    if (kIsWeb) {
      await launchUrl(Uri.parse(imageUrl));
    } else {
      await _downloadImageMobile(context);
    }
  }

  Future<void> _downloadImageMobile(BuildContext context) async {
    try {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        _showSnackBar(
            context, 'Storage permission is required to download images',
            isError: true);
        return;
      }

      // For mobile implementation - you can implement actual saving here
      // For now, we'll just show a success message
      _showSnackBar(context, 'Image download functionality would be implemented here');
      
    } catch (e) {
      _showSnackBar(context, 'Failed to download image', isError: true);
    }
  }

  void _showSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: isError ? 3 : 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
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
        actions: [
          IconButton(
            icon: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.download_rounded,
                size: 20,
                color: Colors.white,
              ),
            ),
            onPressed: () => _downloadImage(context),
            tooltip: 'Download image',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: PhotoView(
          imageProvider: CachedNetworkImageProvider(imageUrl),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 2,
          backgroundDecoration: const BoxDecoration(
            color: Color(0xFF1C1C1E),
          ),
          loadingBuilder: (context, event) => Center(
            child: CircularProgressIndicator(
              value: event == null
                  ? 0
                  : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
              color: Colors.blue[400],
            ),
          ),
          errorBuilder: (context, error, stackTrace) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.broken_image_rounded,
                  color: Colors.white.withOpacity(0.3),
                  size: 60,
                ),
                const SizedBox(height: 16),
                Text(
                  'Failed to load image',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
