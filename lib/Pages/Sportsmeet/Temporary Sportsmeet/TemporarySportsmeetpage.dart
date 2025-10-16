import 'package:flutter/material.dart';
import 'package:jhc_app/Home/SportsmeetPageHome.dart';
import 'package:jhc_app/Pages/Sportsmeet/SportsmeetViewPage.dart';
import 'package:jhc_app/Pages/Sportsmeet/Sportsmeetdedicated.dart';
import 'package:jhc_app/Pages/Sportsmeet/Temporary%20Sportsmeet/gallery.dart';
import 'package:jhc_app/Pages/Sportsmeet/Temporary%20Sportsmeet/livevideo.dart';
import 'package:jhc_app/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
  import 'dart:ui';

class RealSportsmeetHomePage extends StatefulWidget {
  @override
  _RealSportsmeetHomePageState createState() => _RealSportsmeetHomePageState();
}

class _RealSportsmeetHomePageState extends State<RealSportsmeetHomePage> {
  String? latestMessage; // To store the latest message
  String? lastShownId; // To track last shown document

  @override
  void initState() {
    super.initState();
    listenForUpdates();
  }

  void listenForUpdates() {
    FirebaseFirestore.instance
        .collection("Sportsmeet2024") // Replace with actual Firestore collection
        .orderBy("timestamp", descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        var doc = snapshot.docs.first;
        String docId = doc.id;
        String title = doc["title"]; 
        String image = doc["image"];
        String first = doc['first'];
        String second = doc['second'];
        String third = doc['third'];
        String fourth = doc['fourth'];
        String fifth = doc['fifth'];
        String description = doc['description'];
        DateTime now = DateTime.now();
        DateTime targetTime = DateTime(now.year, now.month, now.day, 18, 00); // 4:30 PM

  if (now.isBefore(targetTime)) {
    showPopup3(context);
  } else {
    
        if (lastShownId != docId) {
          lastShownId = docId;
          if(docId == "Sportsmeet 2025"){
          showPopup2(context, title, image, first, second, third, fourth, fifth, description);

          }
          else{
          showPopup(context, title, image, first, second, third, fourth, fifth, description);

          }
        }
        }
      }
    });
  }

void showPopup(BuildContext context, String message, String image, String first, String second, String third, String fourth, String fifth, String description) {
  showDialog(
    context: context,
    barrierDismissible: true, // Allows dismissing the dialog by tapping outside
    builder: (context) => Stack(
      children: [
        // Blurred background
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15), // Adjust blur intensity
            child: GestureDetector(
              onTap: () {
              },
              child: Container(
                color: Colors.black.withOpacity(0.5), // Adds a dim background
              ),
            ),
          ),
        ),

        // Dialog with image and message
        Center(
          child: GestureDetector(
            onTap: () {}, // Prevent tapping inside the dialog from closing it
            child: Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
              child: Stack(
                children: [
                  Container(
height: MediaQuery.of(context).size.width < 800 
                ? MediaQuery.of(context).size.width * 0.52  
                : MediaQuery.of(context).size.height * 0.85,                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      image: DecorationImage(
                        image: NetworkImage(image),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        color: Colors.black.withOpacity(0.5), // Overlay for text readability
                      ),
                      child: Align(
                        alignment: Alignment.bottomLeft, // Aligns the text to the bottom
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            message,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 7, 25, 56),
                      ),
                      onPressed: () {
                        Navigator.pop(context); // Closes the dialog
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewPageSportsmeet(
                              txts: message,
                              images: image,
                              first: first,
                              description: description,
                              second: second,
                              third: third,
                              fourth: fourth,
                              fifth: fifth,
                            ),
                          ),
                        );
                      },
                      child: Text("VIEW", style: TextStyle(color: Colors.white),),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: IconButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(200, 0, 0, 0),
                        padding: EdgeInsets.all(0)
                      ),
                      onPressed: () {
                        Navigator.pop(context); // Closes the dialog
                      },
                      icon: Icon(Icons.close, size: 20,)),
                    ),
                  
                  
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
void showPopup2(BuildContext context, String message, String image, String first, String second, String third, String fourth, String fifth, String description) {
  showDialog(
    context: context,
    barrierDismissible: false, // Allows dismissing the dialog by tapping outside
    builder: (context) => Stack(
      children: [
        // Blurred background
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15), // Adjust blur intensity
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                color: Colors.black.withOpacity(0.5), // Adds a dim background
              ),
            ),
          ),
        ),

        Center(
          child: GestureDetector(
            onTap: () {}, // Prevent tapping inside the dialog from closing it
            child: Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
              child: Stack(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.width < 800 
                ? MediaQuery.of(context).size.width * 0.52  
                : MediaQuery.of(context).size.height * 0.85,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      image: DecorationImage(
                        image: NetworkImage(image),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        color: Colors.black.withOpacity(0.5), // Overlay for text readability
                      ),
                      child: Align(
                        alignment: Alignment.bottomLeft, // Aligns the text to the bottom
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            message,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 7, 25, 56),
                      ),
                      onPressed: () {                        
                      },
                      child: Text("View at 1PM", style: TextStyle(color: Colors.white),),
                    ),
                  ),
                  
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

void showPopup3(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false, // Allows dismissing the dialog by tapping outside
    builder: (context) => Stack(
      children: [
        // Blurred background
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15), // Adjust blur intensity
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                color: Colors.black.withOpacity(0.5), // Adds a dim background
              ),
            ),
          ),
        ),

        Center(
          child: GestureDetector(
            onTap: () {}, // Prevent tapping inside the dialog from closing it
            child: Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
              child: Stack(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.width < 800 
                ? MediaQuery.of(context).size.width * 0.52  
                : MediaQuery.of(context).size.height * 0.85,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      image: DecorationImage(
                        image: NetworkImage("https://i.imgur.com/IESClei.jpeg"),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        color: Colors.black.withOpacity(0.5), // Overlay for text readability
                      ),
                      child: Align(
                        alignment: Alignment.bottomLeft, // Aligns the text to the bottom
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            "Karate Programme",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 7, 25, 56),
                      ),
                      onPressed: () {  
                                            Navigator.push(context, MaterialPageRoute(builder: (context) => Gallery(txts: "Interval Programme", imglist: ["https://i.imgur.com/IESClei.jpeg",
                                  "https://i.imgur.com/ODpJ2XJ.jpeg", "https://i.imgur.com/lYNpbgf.jpeg", 
          
])));
                      
                      },
                      child: Text("View", style: TextStyle(color: Colors.white),),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: IconButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(200, 0, 0, 0),
                        padding: EdgeInsets.all(0)
                      ),
                      onPressed: () {
                        Navigator.pop(context); // Closes the dialog
                      },
                      icon: Icon(Icons.close, size: 20,)),
                    ),
                  
                  
                ],
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
    return LayoutBuilder(
      builder: (context, constraints) {
        double screenHeight = constraints.maxHeight;
        double titleFontSize = screenHeight * 0.045;

        return Container(
          height: screenHeight,
          padding: EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF000000), Color(0xFF001020)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Livevideo(),
                _buildSectionHeader(context, "General", Sportsmeetdedicated(), titleFontSize),
                SportsmeetPageHome(fun: "General"),
                SizedBox(height: screenHeight * 0.05),
                _buildSectionHeader(context, "Under 19", MyHomePage(selectedIndex: 2), titleFontSize),
                SportsmeetPageHome(fun: "19"),
                SizedBox(height: screenHeight * 0.05),
                _buildSectionHeader(context, "Under 18", MyHomePage(selectedIndex: 1), titleFontSize),
                SportsmeetPageHome(fun: "18"),
                _buildSectionHeader(context, "Under 17", MyHomePage(selectedIndex: 2), titleFontSize),
                SportsmeetPageHome(fun: "17"),
                SizedBox(height: screenHeight * 0.05),
                _buildSectionHeader(context, "Under 16", MyHomePage(selectedIndex: 1), titleFontSize),
                SportsmeetPageHome(fun: "16"),
                _buildSectionHeader(context, "Under 15", MyHomePage(selectedIndex: 2), titleFontSize),
                SportsmeetPageHome(fun: "15"),
                SizedBox(height: screenHeight * 0.05),
                _buildSectionHeader(context, "Under 14", MyHomePage(selectedIndex: 1), titleFontSize),
                SportsmeetPageHome(fun: "14"),
                SizedBox(height: screenHeight * 0.05),
                _buildSectionHeader(context, "Under 13", MyHomePage(selectedIndex: 3), titleFontSize),
                SportsmeetPageHome(fun: "13"),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, Widget page, double fontSize) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "  $title",
          style: TextStyle(
            fontSize: fontSize,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
