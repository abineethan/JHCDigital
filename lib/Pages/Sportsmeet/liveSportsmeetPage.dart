import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:jhc_app/Pages/Sportsmeet/SportsmeetViewPage.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final Future<FirebaseApp> firebaseApp = Firebase.initializeApp();
final FirebaseFirestore firestore = FirebaseFirestore.instance;

class LiveScoreWidgetSportsmeetPage extends StatefulWidget {
  final String parameter;
  LiveScoreWidgetSportsmeetPage({required this.parameter});

  @override
  State<LiveScoreWidgetSportsmeetPage> createState() =>
      _LiveScoreWidgetCricketPage(parameter: parameter);
}

class _LiveScoreWidgetCricketPage extends State<LiveScoreWidgetSportsmeetPage> {
  final String parameter;

  _LiveScoreWidgetCricketPage({required this.parameter});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(parameter),
      ),
      body: FutureBuilder(
        future: firebaseApp,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return StreamBuilder<QuerySnapshot>(
              stream: firestore
                  .collection("Sportsmeet2024 U${parameter.split(' ')[1]}")
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  final docs = snapshot.data!.docs;
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF000000), // Pure black
                              Color(0xFF001020), // Dark blackish-blue
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final data =
                                docs[index].data() as Map<String, dynamic>;
                            final first = data['first'] ?? "Unknown";
                            final second = data['second'] ?? "Unknown";
                            final third = data['third'] ?? "Unknown";
                            final fourth = data['fourth'] ?? "Unknown";
                            final fifth = data['fifth'] ?? "Unknown";
                            final image = data['image'] ?? "";
                            final title = data['title'] ?? "Unknown Match";
                            final description = data['description'] ?? 'Description';
                            return StatefulBuilder(
                              builder: (context, setState) {

                                return InkWell(
                                  onTap: () {
                                   Navigator.push(
                                    context, 
                                    MaterialPageRoute(
                                      builder: (context) => ViewPageSportsmeet(
                                        first: first,
                                        second: second,
                                        third: third,
                                        fourth: fourth,
                                        fifth: fifth,
                                        txts: title,
                                        images: image,
                                        description: description,
                                      )
                                    )
                                  );
                                  },
                                
                                  
                                  child: Container(
                                    height: MediaQuery.of(context).size.height * 0.2,
                                    margin: EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: NetworkImage(
                                            image), // Background image from URL
                                        fit: BoxFit.cover,
                                      ),
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          spreadRadius: 5,
                                          blurRadius: 10,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: Container(
                                          color: Colors.white.withOpacity(0.1),
                                          padding: EdgeInsets.all(12),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                                mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              Text(
                                                title.toUpperCase(),
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),                                              
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                } else {
                  return Center(
                    child: LoadingAnimationWidget.staggeredDotsWave(
                      color: Colors.white,
                      size: 150,
                    ),
                  );
                }
              },
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                color: Colors.white,
                size: 150,
              ),
            );
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
                child: Text(
                  'No Data Found',
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
              ),
            );
          } else {
            return Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                color: Colors.white,
                size: 150,
              ),
            );
          }
        },
      ),
    );
  }
}
