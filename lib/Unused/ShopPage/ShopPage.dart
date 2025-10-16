import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:jhc_app/Unused/breakingCard.dart';

final Future<FirebaseApp> firebaseApp = Firebase.initializeApp();
final FirebaseFirestore firestore = FirebaseFirestore.instance;

class ShopPage extends StatelessWidget {
  static const String defaultImageUrl =
      'https://i.ibb.co/R42fQnMh/86b4166adc3b.jpg';

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: firebaseApp,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return StreamBuilder<QuerySnapshot>(
            stream: firestore.collection('Shop').snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error loading data',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: LoadingAnimationWidget.staggeredDotsWave(
                    color: Colors.white,
                    size: 150,
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Text(
                    'No products available',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              return Container(
                padding: EdgeInsets.all(16.0),
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF000000),
                      Color(0xFF001020),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth > 800) {
                            return GridView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 1.5,
                                crossAxisSpacing: 20,
                                mainAxisSpacing: 20,
                              ),
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (BuildContext context, index) {
                                final doc = snapshot.data!.docs[index];
                                final data = doc.data() as Map<String, dynamic>;
                                final price = data['price']?.toString() ?? '';
                                final image = data['image']?.toString() ?? '';
                                final text = data['text']?.toString() ?? '';

                                return BreakingNewsCard(
                                  urls: price.isNotEmpty
                                      ? "Rs $price"
                                      : "Price not available",
                                  images: image.isNotEmpty
                                      ? image
                                      : defaultImageUrl,
                                  txts: text,
                                  imglist: [
                                    image.isNotEmpty ? image : defaultImageUrl
                                  ],
                                  defaultImageUrl: defaultImageUrl,
                                );
                              },
                            );
                          } else {
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (BuildContext context, index) {
                                final doc = snapshot.data!.docs[index];
                                final data = doc.data() as Map<String, dynamic>;
                                final price = data['price']?.toString() ?? '';
                                final image = data['image']?.toString() ?? '';
                                final text = data['text']?.toString() ?? '';

                                return Container(
                                  margin: EdgeInsets.symmetric(vertical: 10),
                                  height:
                                      MediaQuery.of(context).size.height * 0.3,
                                  child: BreakingNewsCard(
                                    urls: price.isNotEmpty
                                        ? "Rs $price"
                                        : "Price not available",
                                    images: image.isNotEmpty
                                        ? image
                                        : defaultImageUrl,
                                    txts: text,
                                    imglist: [
                                      image.isNotEmpty ? image : defaultImageUrl
                                    ],
                                    defaultImageUrl: defaultImageUrl,
                                  ),
                                );
                              },
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error initializing Firebase',
              style: TextStyle(color: Colors.white),
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
  }
}
