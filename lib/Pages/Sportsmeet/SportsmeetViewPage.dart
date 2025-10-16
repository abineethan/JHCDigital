import 'package:flutter/material.dart';
import 'package:jhc_app/Pages/Sportsmeet/firstsecondthird.dart';
import 'dart:ui';
import 'package:jhc_app/Unused/PhotoView.dart';

class ViewPageSportsmeet extends StatelessWidget {
  final String txts; 
  final String images; // URL of the image
  final String first; // Content text
    final String second; // Content text
  final String third; // Content text
  final String fourth; // Content text
  final String fifth; // Content text
final String description;

  // Constructor with required parameters
  ViewPageSportsmeet({
    required this.txts,
    required this.images,
    required this.first,
    required this.description,
        required this.second,
    required this.third,
    required this.fourth,
    required this.fifth,

  });

  @override
  Widget build(BuildContext context) {

   return Scaffold(
  appBar: AppBar(
    toolbarHeight: 66,
    backgroundColor: Colors.black,
    title: Text(
      txts,
      style: TextStyle(color: Colors.white, fontSize: MediaQuery.of(context).size.height * 0.035
, fontWeight: FontWeight.bold),
    ),
  ),
  body: SingleChildScrollView(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Image section
        Padding(
          padding: EdgeInsets.all(16),
          child: 
        ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context, 
                        MaterialPageRoute(
                          builder: (context) => ImageFromUrl(imageUrl: images)
                        )
                      );
                    },
                    child: Image.network(
            images,
            fit: BoxFit.cover,
            width: double.infinity,
            height: MediaQuery.of(context).size.width < 800 
                ? MediaQuery.of(context).size.width * 0.52  
                : MediaQuery.of(context).size.height * 0.85,
          ),
        ))),
        
        // Content Section
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        // Description text
                        Text(
                          description,
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
          
                        SizedBox(height: 20),
                        
                        buildRankingText("1st", first),
                        buildRankingText("2nd", second),
                        buildRankingText("3rd", third),
                        buildRankingText("4th", fourth),
                        buildRankingText("5th", fifth),
                        
                        SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  ),
);

// Helper method to create ranking texts


  }
  
}
