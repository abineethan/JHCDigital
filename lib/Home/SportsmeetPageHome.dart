import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:carousel_slider/carousel_slider.dart' as carousel_lib;
import 'package:jhc_app/Unused/breakingCard.dart';

final firebaseApp = Firebase.app();
FirebaseFirestore firestore = FirebaseFirestore.instance;

// ignore: must_be_immutable
class SportsmeetPageHome extends StatelessWidget {
  String fun;

  SportsmeetPageHome({required this.fun});

  @override
  Widget build(BuildContext context) {
    CollectionReference sportsCollection =
        firestore.collection('Sportsmeet2024 U$fun');

    return StreamBuilder(
      stream: sportsCollection
          .orderBy("timestamp", descending: true)
          .limit(3)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        try {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                color: Colors.white,
                size: 150,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text("Something went wrong!",
                  style: TextStyle(color: Colors.white)),
            );
          }

          if (!snapshot.hasData ||
              snapshot.data == null ||
              snapshot.data!.docs.isEmpty) {
            return Center(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.5,
                width: MediaQuery.of(context).size.width * 0.9,
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                    child: Text(
                  "Events have not started yet",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                )),
              ),
            );
          }

          final docs = snapshot.data!.docs;

          List<String> urls = [];
          List<String> imgURLs = [];
          List<String> descriptions = [];
          List<String> first = [];
          List<String> second = [];
          List<String> third = [];
          List<String> fourth = [];
          List<String> fifth = [];
          List<String> txts = [];

          for (var doc in docs) {
            var eventData = doc.data() as Map<String, dynamic>;
            txts.add(eventData['title'] ?? '');
            urls.add('1st Place ' + (eventData['first'] ?? ''));
            imgURLs.add(eventData['image'] ?? '');
            descriptions.add(eventData['description'] ?? '');
            first.add(eventData['first'] ?? '');
            second.add(eventData['second'] ?? '');
            third.add(eventData['third'] ?? '');
            fourth.add(eventData['fourth'] ?? '');
            fifth.add(eventData['fifth'] ?? '');
          }

          return carousel_lib.CarouselSlider.builder(
            itemCount: urls.length,
            itemBuilder: (context, index, id) => BreakingNewsCard(
              urls: urls[index],
              images: imgURLs[index],
              txts: txts[index],
              first: first[index],
              second: second[index],
              third: third[index],
              fourth: fourth[index],
              fifth: fifth[index],
              description: descriptions[index],
            ),
            options: carousel_lib.CarouselOptions(
              aspectRatio: 16 / 9,
              height: MediaQuery.of(context).size.height * 0.25,
              autoPlay: false,
              enableInfiniteScroll: false,
              enlargeCenterPage: true,
            ),
          );
        } catch (error) {
          return Center(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.5,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.5)),
              ),
              child: Text(
                "Events have not started yet",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
          );
        }
      },
    );
  }
}
