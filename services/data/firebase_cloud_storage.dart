import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:maps/models/location.dart';

class FirebaseCloudStorage {
  final _locationsCollection =
      FirebaseFirestore.instance.collection('locations');
  final _aurakUsersCollection =
      FirebaseFirestore.instance.collection('aurak_users');

  void addFavoriteByEmail({
    required String email,
    required String favoriteLocation,
  }) {
    _aurakUsersCollection.doc(email).update({
      "favorites": FieldValue.arrayUnion([favoriteLocation])
    });
  }

  void removeFavoriteByEmail({
    required String email,
    required String favoriteLocation,
  }) {
    _aurakUsersCollection.doc(email).update({
      "favorites": FieldValue.arrayRemove([favoriteLocation])
    });
  }

  Future<List<Location>> getUserFavoritesByEmail(String email) async {
    var locationNames =
        await _aurakUsersCollection.doc(email).get().then((value) {
      return value.data()!['favorites'];
    });

    List<Location> locations = [];
    for (var locationName in locationNames) {
      Location location = await getLocationByName(name: locationName);
      locations.add(location);
    }
    return locations;
  }

  Future<List<Location>> getUserCoursesByEmail(String email) async {
    var locationNames =
        await _aurakUsersCollection.doc(email).get().then((value) {
      return value.data()!['courses'];
    });

    List<Location> locations = [];
    for (var locationName in locationNames) {
      Location location = await getLocationByName(name: locationName);
      locations.add(location);
    }
    return locations;
  }

  Future<Iterable<Location>> getLocationsByCategory({required category}) async {
    return await _locationsCollection
        .where('category', isEqualTo: category)
        .get()
        .then((value) =>
            value.docs.map((doc) => Location.fromFirestoreDocument(doc)));
  }

  Future<Location> getLocationByName({required name}) async {
    var doc = await _locationsCollection
        .where('name', isEqualTo: name)
        .get()
        .then((value) => value.docs.single);
    return Location.fromFirestoreDocument(doc);
  }

  Future<Iterable<Location>> getAllLocations() async {
    return await _locationsCollection.get().then((value) =>
        value.docs.map((doc) => Location.fromFirestoreDocument(doc)));
  }
}
