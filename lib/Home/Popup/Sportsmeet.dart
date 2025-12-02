import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:jhc_app/Pages/Sportsmeet/Home.dart';

class SportsmeetPopup extends StatefulWidget {
  @override
  _SportsmeetPopupState createState() => _SportsmeetPopupState();
}

class _SportsmeetPopupState extends State<SportsmeetPopup> {
  Map<String, dynamic>? popupData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPopupData();
  }

  Future<void> _fetchPopupData() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Main')
          .doc('Sportsmeet')
          .get();

      if (snapshot.exists) {
        setState(() {
          popupData = snapshot.data() as Map<String, dynamic>;
          isLoading = false;
        });

        Future.delayed(Duration(milliseconds: 500), () {
          if (popupData != null && popupData!['active'] == true) {
            List<String> imgList = [];
            if (popupData!['images'] is List) {
              imgList = List<String>.from(popupData!['images']);
            } else if (popupData!['images'] is String) {
              imgList = (popupData!['images'] as String).split(',');
            }

            String firstImage = imgList.isNotEmpty ? imgList[0] : '';

            showPopup(
              context,
              popupData!['text'] ?? '',
              firstImage,
              imgList,
            );
          }
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching popup data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void showPopup(
      BuildContext context, String text, String image, List<String> imglist) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.black.withOpacity(0.5),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: GestureDetector(
              onTap: () {},
              child: Dialog(
                backgroundColor: Colors.transparent,
                insetPadding: EdgeInsets.all(20),
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.9,
                    maxHeight: MediaQuery.of(context).size.height * 0.4,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: Stack(
                      children: [
                        CachedNetworkImage(
                          imageUrl: image,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[300],
                            child: Center(child: CircularProgressIndicator()),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[300],
                            child: Icon(Icons.error),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.2),
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                text,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  height: 1.2,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 5),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  SizedBox(width: 12),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              SportsmeetHome(),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF1A4ED5),
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 24, vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 3,
                                    ),
                                    child: Text(
                                      "VIEW DETAILS",
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 16,
                          right: 16,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: Icon(Icons.close, size: 22),
                              color: Colors.white,
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.shrink();
  }
}
