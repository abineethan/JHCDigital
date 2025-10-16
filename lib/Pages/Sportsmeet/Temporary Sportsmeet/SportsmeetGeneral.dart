import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:carousel_slider/carousel_slider.dart' as carousel_lib;
import 'package:jhc_app/Unused/breakingCard.dart';

final firebaseApp = Firebase.app();
FirebaseFirestore firestore = FirebaseFirestore.instance;
CollectionReference sportsCollection = firestore.collection('Sportsmeet2024 UGeneral');

class SportsmeetPageHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: sportsCollection.snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          final screenHeight = MediaQuery.of(context).size.height;
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
              height: screenHeight * 0.51,
              autoPlay: false,
              enableInfiniteScroll: true,
              enlargeCenterPage: true,
            ),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
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
  }
}
