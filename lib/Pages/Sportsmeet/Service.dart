import 'package:cloud_firestore/cloud_firestore.dart';

class SportsmeetService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String sportsCollection = 'Sports';
  static const String sportsmeetDocument = 'Sportsmeet';
  static const String yearsSubcollection = 'years';
  static const String CategorySubcollection = 'Category';
  static const String eventsSubcollection = 'events';

  Future<List<String>> getAvailableYears() async {
    try {
      final doc = await _firestore
          .collection(sportsCollection)
          .doc(sportsmeetDocument)
          .get();

      if (!doc.exists) {
        await _createInitialStructure();
        return [DateTime.now().year.toString()];
      }

      final years = List<String>.from(doc.data()?['years'] ?? []);
      return years..sort((a, b) => b.compareTo(a));
    } catch (e) {
      print('Error fetching years: $e');
      return [DateTime.now().year.toString()];
    }
  }

  Future<void> _createInitialStructure() async {
    final currentYear = DateTime.now().year.toString();

    await _firestore.collection(sportsCollection).doc(sportsmeetDocument).set({
      'years': [currentYear],
      'lastUpdated': FieldValue.serverTimestamp(),
    });

    await _firestore
        .collection(sportsCollection)
        .doc(sportsmeetDocument)
        .collection(yearsSubcollection)
        .doc(currentYear)
        .set({
      'year': currentYear,
      'name': 'Sportsmeet $currentYear',
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> addYear(String year) async {
    try {
      final docRef =
          _firestore.collection(sportsCollection).doc(sportsmeetDocument);

      await docRef.update({
        'years': FieldValue.arrayUnion([year]),
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      await docRef.collection(yearsSubcollection).doc(year).set({
        'year': year,
        'name': 'Sportsmeet $year',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding year: $e');
      throw e;
    }
  }

  Stream<QuerySnapshot> getEventsStream(String year, String category) {
    return _firestore
        .collection(sportsCollection)
        .doc(sportsmeetDocument)
        .collection(yearsSubcollection)
        .doc(year)
        .collection(CategorySubcollection)
        .doc(category)
        .collection(eventsSubcollection)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<QuerySnapshot> getCategoryEvents(String year, String category) async {
    return await _firestore
        .collection(sportsCollection)
        .doc(sportsmeetDocument)
        .collection(yearsSubcollection)
        .doc(year)
        .collection(CategorySubcollection)
        .doc(category)
        .collection(eventsSubcollection)
        .orderBy('timestamp', descending: true)
        .get();
  }

  Future<void> addEvent({
    required String year,
    required String category,
    required String title,
    required List<String> images,
    required String first,
    required String second,
    required String third,
    required String fourth,
    required String fifth,
    required String description,
  }) async {
    try {
      await _firestore
          .collection(sportsCollection)
          .doc(sportsmeetDocument)
          .collection(yearsSubcollection)
          .doc(year)
          .collection(CategorySubcollection)
          .doc(category)
          .collection(eventsSubcollection)
          .add({
        'title': title,
        'images': images,
        'first': first,
        'second': second,
        'third': third,
        'fourth': fourth,
        'fifth': fifth,
        'description': description,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding event: $e');
      throw e;
    }
  }

  Map<String, dynamic> parseEventData(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    String safeGetString(String key, String defaultValue) {
      final value = data[key];
      if (value == null) return defaultValue;
      if (value is String) return value;
      return value.toString();
    }

    List<String> images = [];
    try {
      final imagesData = data['images'] ?? data['image'];
      if (imagesData is List<String>) {
        images = imagesData;
      } else if (imagesData is List) {
        images = imagesData.whereType<String>().toList();
      } else if (imagesData is String) {
        images = [imagesData];
      }
    } catch (e) {
      print('Error parsing images: $e');
      images = [];
    }

    return {
      'id': doc.id,
      'title': safeGetString('title', 'No Title'),
      'images': images,
      'firstImage': images.isNotEmpty
          ? images.first
          : 'https://via.placeholder.com/400x300?text=Sports+Event',
      'first': safeGetString('first', ''),
      'second': safeGetString('second', ''),
      'third': safeGetString('third', ''),
      'fourth': safeGetString('fourth', ''),
      'fifth': safeGetString('fifth', ''),
      'description': safeGetString('description', ''),
      'timestamp': data['timestamp'],
    };
  }

  Future<Map<String, dynamic>> getYearStatistics(String year) async {
    try {
      int totalEvents = 0;
      final Category = await getCategoryForYear(year);

      for (final category in Category) {
        final events = await getCategoryEvents(year, category);
        totalEvents += events.docs.length;
      }

      return {
        'totalEvents': totalEvents,
        'Category': Category.length,
        'hasData': totalEvents > 0,
      };
    } catch (e) {
      print('Error getting statistics: $e');
      return {'totalEvents': 0, 'Category': 0, 'hasData': false};
    }
  }

  Future<List<String>> getCategoryForYear(String year) async {
    try {
      final snapshot = await _firestore
          .collection(sportsCollection)
          .doc(sportsmeetDocument)
          .collection(yearsSubcollection)
          .doc(year)
          .collection(CategorySubcollection)
          .get();

      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      print('Error getting age groups: $e');
      return [];
    }
  }

  Future<bool> hasEventsForCategory(String year, String category) async {
    try {
      final snapshot = await _firestore
          .collection(sportsCollection)
          .doc(sportsmeetDocument)
          .collection(yearsSubcollection)
          .doc(year)
          .collection(CategorySubcollection)
          .doc(category)
          .collection(eventsSubcollection)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking events: $e');
      return false;
    }
  }

  String getCategoryDisplayName(String category) {
    const displayNames = {
      'UGeneral': 'General',
      'U19': 'Under 19',
      'U18': 'Under 18',
      'U17': 'Under 17',
      'U16': 'Under 16',
      'U15': 'Under 15',
      'U14': 'Under 14',
      'U13': 'Under 13',
    };

    return displayNames[category] ?? category;
  }

  List<String> getAllCategory() {
    return ['UGeneral', 'U19', 'U18', 'U17', 'U16', 'U15', 'U14', 'U13'];
  }

  Future<Map<String, dynamic>> getHouseRankings(String year) async {
    try {
      final doc = await _firestore
          .collection(sportsCollection)
          .doc(sportsmeetDocument)
          .collection(yearsSubcollection)
          .doc(year)
          .get();

      if (!doc.exists) {
        return {};
      }

      final data = doc.data() ?? {};

      return {
        'first': data['first'] ?? '',
        'second': data['second'] ?? '',
        'third': data['third'] ?? '',
        'fourth': data['fourth'] ?? '',
        'fifth': data['fifth'] ?? '',
      };
    } catch (e) {
      print('Error getting house rankings: $e');
      return {};
    }
  }

  Future<List<String>> getYearHeaderImages(String year) async {
    try {
      final doc = await _firestore
          .collection(sportsCollection)
          .doc(sportsmeetDocument)
          .collection(yearsSubcollection)
          .doc(year)
          .get();

      if (!doc.exists) {
        return [];
      }

      final data = doc.data() ?? {};

      if (data['headerImages'] != null && data['headerImages'] is List) {
        final images = List<String>.from(data['headerImages']);
        if (images.isNotEmpty) {
          return images.where((img) => img.isNotEmpty).toList();
        }
      }

      return [];
    } catch (e) {
      print('Error getting header images: $e');
      return [];
    }
  }

  Future<void> setYearHeaderImages(String year, List<String> imageUrls) async {
    try {
      await _firestore
          .collection(sportsCollection)
          .doc(sportsmeetDocument)
          .collection(yearsSubcollection)
          .doc(year)
          .update({
        'headerImages': imageUrls,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error setting header images: $e');
      throw e;
    }
  }

  Future<void> addYearHeaderImage(String year, String imageUrl) async {
    try {
      final currentImages = await getYearHeaderImages(year);
      final updatedImages = [...currentImages, imageUrl];

      await _firestore
          .collection(sportsCollection)
          .doc(sportsmeetDocument)
          .collection(yearsSubcollection)
          .doc(year)
          .update({
        'headerImages': updatedImages,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding header image: $e');
      throw e;
    }
  }

  Future<void> removeYearHeaderImage(String year, String imageUrl) async {
    try {
      final currentImages = await getYearHeaderImages(year);
      final updatedImages =
          currentImages.where((img) => img != imageUrl).toList();

      await _firestore
          .collection(sportsCollection)
          .doc(sportsmeetDocument)
          .collection(yearsSubcollection)
          .doc(year)
          .update({
        'headerImages': updatedImages,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error removing header image: $e');
      throw e;
    }
  }

  Future<void> updateHouseRankings({
    required String year,
    required String first,
    required String second,
    required String third,
    required String fourth,
    required String fifth,
  }) async {
    try {
      await _firestore
          .collection(sportsCollection)
          .doc(sportsmeetDocument)
          .collection(yearsSubcollection)
          .doc(year)
          .update({
        'first': first,
        'second': second,
        'third': third,
        'fourth': fourth,
        'fifth': fifth,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating house rankings: $e');
      throw e;
    }
  }
}
