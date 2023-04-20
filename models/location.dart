import 'package:cloud_firestore/cloud_firestore.dart';

class Location {
  final String documentID;
  final String name;
  final String category;
  final Map<String, dynamic> coordinates;
  final List<dynamic> rooms;

  const Location({
    required this.documentID,
    required this.name,
    required this.category,
    required this.coordinates,
    required this.rooms,
  });

  // A named constructor that creates a Location instance from a Firestore document snapshot.
  Location.fromFirestoreDocument(
      QueryDocumentSnapshot<Map<String, dynamic>> doc)
      : documentID = doc.id,
        name = doc.data()['name'],
        category = doc.data()['category'],
        coordinates = doc.data()['coordinates'],
        rooms = doc.data()['rooms'];
}
