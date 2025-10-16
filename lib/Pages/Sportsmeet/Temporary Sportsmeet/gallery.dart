import 'package:flutter/material.dart';
import 'package:jhc_app/Unused/PhotoView.dart';

// ignore: must_be_immutable
class Gallery extends StatefulWidget {
  String urls = "";
  List<String>? imglist = [""];
  String images = "";
  String txts = "";
  String? description = "";
  String? first = "";
  String? second = "";
  String? third = "";
  String? fourth = "";
  String? fifth = "";
  String utube = "";
  Gallery({
      required this.txts,
     
      required this.imglist});

  @override
  // ignore: library_private_types_in_public_api, no_logic_in_create_state
  _Interior createState() =>  _Interior(urls: urls,
      txts: txts,
      imglist: imglist ?? [""],
      );
}

class _Interior extends State<Gallery> {
   String urls = "";
  String images = "";
  String txts = "";
  List<String> imglist = [""];

  String description = "";
  String first = "";
  String second = "";
  String third = "";
  String fourth = "";
  String fifth = "";
  String utube = "";
    _Interior( {required this.urls,
      required this.txts,
      required this.imglist,
      });

   
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 66,
        backgroundColor: Colors.black,
        title: Text(
          "Sportsmeet 2025",
          style:  TextStyle(
                                    fontSize: MediaQuery.of(context).size.height * 0.035,

            color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [            // Image Grid
            Padding(
              padding: const EdgeInsets.all(0.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                ),
                itemCount: imglist.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context, 
                        MaterialPageRoute(
                          builder: (context) => ImageFromUrl(imageUrl: imglist[index])
                        )
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(16.0),
                      child:ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Image.network(
                        imglist[index],
                        fit: BoxFit.cover ,
                      ),
                    )),
                  );
                },
              ),
            ),

            
            
          ],
        ),
      ),
      backgroundColor: Colors.grey[900], // Background color for contrast
    );
  }
}
