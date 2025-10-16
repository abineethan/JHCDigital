import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jhc_app/Pages/Sportsmeet/Temporary%20Sportsmeet/gallery.dart';
import 'package:jhc_app/widgets/YoutubePlayer.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Livevideo extends StatefulWidget {
  @override
  _LivevideoState createState() => _LivevideoState();
}

class _LivevideoState extends State<Livevideo> {
  String urls = "";
  List<String> imglist = [];
  String txts = "";
  String description = "";
  String utube = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNewsData();
  }

  Future<void> fetchNewsData() async {
    try {
      var doc = await FirebaseFirestore.instance.collection('News').limit(1).get();
      if (doc.docs.isNotEmpty) {
        var data = doc.docs.first.data();
        setState(() {
          urls = data['url'] ?? "";
          imglist = List<String>.from(data['images'] ?? []);
          txts = data['text'] ?? "";
          utube = data['utube'] ?? "";
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching news: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
          ? Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                color: Colors.white,
                size: 150,
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GestureDetector(
                  
                  onTap: () {
                    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FullScreenVideoPlayer(videoId: utube),
        ),
      );
                  },
                  child: AnimatedContainer(
height: MediaQuery.of(context).size.width < 800 
                ? MediaQuery.of(context).size.width * 0.52  
                : MediaQuery.of(context).size.height * 0.85,                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    margin: EdgeInsets.symmetric(vertical: 30, horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          spreadRadius: 2,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Sports Image
                        ClipRRect(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                            bottom: Radius.circular(20),
                          ),
                          child: Image.network(
                            imglist[1],
height: MediaQuery.of(context).size.width < 800 
                ? MediaQuery.of(context).size.width * 0.52  
                : MediaQuery.of(context).size.height * 0.85,                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        // Gradient Overlay with Icon and Text
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withOpacity(0.6),
                                  Colors.transparent
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        // Sport Name and Icon
                        Positioned(
                          bottom: 16,
                          left: 16,
                          child: Row(
                            children: [
                              Text(
                                "Watch Live",
                                style: TextStyle(
                                  fontSize: MediaQuery.of(context).size.height * 0.025,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),                        
                      ],
                    ),
                  ),
                ),
                  GestureDetector(
                  
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Gallery(txts: txts, imglist: imglist)));
                    
                  },
                  child: AnimatedContainer(
height: MediaQuery.of(context).size.width < 800 
                ? MediaQuery.of(context).size.width * 0.52  
                : MediaQuery.of(context).size.height * 0.85,                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    margin: EdgeInsets.symmetric(vertical: 30, horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          spreadRadius: 2,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Sports Image
                        ClipRRect(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                            bottom: Radius.circular(20),
                          ),
                          child: Image.network(
                            imglist[0],
height: MediaQuery.of(context).size.width < 800 
                ? MediaQuery.of(context).size.width * 0.52  
                : MediaQuery.of(context).size.height * 0.85,                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        // Gradient Overlay with Icon and Text
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withOpacity(0.6),
                                  Colors.transparent
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        // Sport Name and Icon
                        Positioned(
                          bottom: 16,
                          left: 16,
                          child: Row(
                            children: [
                              Text(
                                "View Gallery",
                                style: TextStyle(
                                  fontSize: MediaQuery.of(context).size.height * 0.025,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),                        
                      ],
                    ),
                  ),
                ),
                  
                  
                  
                  const SizedBox(height: 50),
                ],
              ),
            );
  }
}