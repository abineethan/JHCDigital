import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jhc_app/widgets/Details.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AlertPopup extends StatefulWidget {
  @override
  _AlertPopupState createState() => _AlertPopupState();
}

class _AlertPopupState extends State<AlertPopup> {
  Map<String, dynamic>? popupData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPopupData();
  }

  bool _isWithinLastWeek(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    DateTime now = DateTime.now();
    DateTime oneWeekAgo = now.subtract(Duration(days: 7));
    
    return date.isAfter(oneWeekAgo) && date.isBefore(now);
  }

  Future<void> _fetchPopupData() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Main') 
          .doc('Alert')
          .get();

      if (snapshot.exists) {
        setState(() {
          popupData = snapshot.data() as Map<String, dynamic>;
          isLoading = false;
        });
        
        if (popupData != null && 
            popupData!.containsKey('date') && 
            popupData!['date'] is Timestamp &&
            _isWithinLastWeek(popupData!['date'])) {
          
          Future.delayed(Duration(milliseconds: 500), () {
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
              popupData!['url'] ?? '',
              popupData!['utube'] ?? '',
              popupData!['description'] ?? '',
              imgList,
            );
          });
        } else {
          setState(() {
            isLoading = false;
          });
        }
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

  void showPopup(BuildContext context, String text, String image, 
      String urls, String utube, String description, List<String> imglist) {
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
                    maxHeight: MediaQuery.of(context).size.height * 0.3,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: Stack(
                      children: [
                        // Background image with gradient overlay
                        Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: CachedNetworkImageProvider(image),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Container(
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
                        ),
                        
                        // Content
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Text with improved styling (using 'text' field)
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
                              
                              // Action buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  SizedBox(width: 12),
                                  
                                  // View button
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Details(
                                            txts: text, // Use text field
                                            images: image,
                                            urls: urls,
                                            utube: utube,
                                            description: description,
                                            imglist: imglist, // Pass full image array
                                          ),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF1A4ED5),
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
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
                        
                        // Close icon button
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