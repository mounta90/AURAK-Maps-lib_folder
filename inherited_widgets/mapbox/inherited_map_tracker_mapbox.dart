import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:maps/models/location.dart';
import 'package:maps/services/auth/firebase_auth_service.dart';
import 'package:maps/services/data/firebase_cloud_storage.dart';
import 'package:http/http.dart' as http;
import 'package:maps/utilities/get_user_geolocation_position.dart';

class InheritedMapTrackerMapbox extends InheritedWidget {
  final Position _aurakCampusPosition =
      Position.named(lat: 25.788839, lng: 55.993647);
  final FirebaseCloudStorage _firebaseCloudStorage = FirebaseCloudStorage();
  final FirebaseAuthService _firebaseAuthService = FirebaseAuthService();

  final ValueNotifier<MapboxMap?> inheritedMapboxMap = ValueNotifier(null);
  final ValueNotifier<Location?> userRequestedLocation = ValueNotifier(null);

  final ValueNotifier<CircleAnnotationManager?> circleAnnotationManager =
      ValueNotifier(null);
  final ValueNotifier<PointAnnotationManager?> pointAnnotationManager =
      ValueNotifier(null);
  final ValueNotifier<PolylineAnnotationManager?> polylineAnnotationManager =
      ValueNotifier(null);

  InheritedMapTrackerMapbox({
    super.key,
    required super.child,
  });

  // This inherited widget will notify its descendant widgets in the case that the mapbox object changes.
  @override
  bool updateShouldNotify(covariant InheritedMapTrackerMapbox oldWidget) {
    return inheritedMapboxMap != oldWidget.inheritedMapboxMap;
  }

  static InheritedMapTrackerMapbox? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType();
  }

  void displayPath({required List<dynamic> pathCoordinates}) async {
    polylineAnnotationManager.value!.deleteAll();

    List<Point> pathPoints = [];
    for (var coordinate in pathCoordinates) {
      Position pathPosition =
          Position.named(lat: coordinate[1], lng: coordinate[0]);
      Point pathPoint = Point(coordinates: pathPosition);
      pathPoints.add(pathPoint);
    }

    polylineAnnotationManager.value!.create(
      PolylineAnnotationOptions(
        geometry: LineString.fromPoints(points: pathPoints).toJson(),
        lineColor: Colors.blue.value,
        lineJoin: LineJoin.ROUND,
        lineWidth: 5.0,
      ),
    );
  }

  void displaySymbolsByCategory({required filterCategory}) async {
    var locations = await _firebaseCloudStorage.getLocationsByCategory(
        category: filterCategory);

    pointAnnotationManager.value!.deleteAll();
    polylineAnnotationManager.value!.deleteAll();
    circleAnnotationManager.value!.deleteAll();

    for (var location in locations) {
      double locationLatitude = location.coordinates['latitude'];
      double locationLongitude = location.coordinates['longitude'];

      final ByteData imageBytes = await rootBundle
          .load('./lib/assets/images/colored_${filterCategory}_icon.png');

      final Uint8List image = imageBytes.buffer.asUint8List();

      inheritedMapboxMap.value!.easeTo(
        CameraOptions(
          center: Point(
            coordinates: Position.named(
              lat: _aurakCampusPosition.lat,
              lng: _aurakCampusPosition.lng,
            ),
          ).toJson(),
          zoom: 15.5,
        ),
        MapAnimationOptions(),
      );

      pointAnnotationManager.value!.create(
        PointAnnotationOptions(
          textField: location.name,
          textOpacity: 0,
          image: image,
          geometry: Point(
              coordinates: Position.named(
            lat: locationLatitude,
            lng: locationLongitude,
          )).toJson(),
        ),
      );
    }

    pointAnnotationManager.value!
        .addOnPointAnnotationClickListener(PointListener(
      userRequestedLocation: userRequestedLocation,
    ));
  }

  void displayUserCourseSymbols() async {
    var userEmail = _firebaseAuthService.user!.email;

    var locations =
        await _firebaseCloudStorage.getUserCoursesByEmail(userEmail!);

    polylineAnnotationManager.value!.deleteAll();
    circleAnnotationManager.value!.deleteAll();
    pointAnnotationManager.value!.deleteAll();

    for (var location in locations) {
      double locationLatitude = location.coordinates['latitude'];
      double locationLongitude = location.coordinates['longitude'];

      final ByteData imageBytes =
          await rootBundle.load('./lib/assets/images/colored_courses_icon.png');
      final Uint8List image = imageBytes.buffer.asUint8List();

      await pointAnnotationManager.value!.create(
        PointAnnotationOptions(
          textField: location.name,
          textOpacity: 0,
          image: image,
          geometry: Point(
            coordinates: Position.named(
              lat: locationLatitude,
              lng: locationLongitude,
            ),
          ).toJson(),
        ),
      );
    }

    pointAnnotationManager.value!
        .addOnPointAnnotationClickListener(PointListener(
      userRequestedLocation: userRequestedLocation,
    ));

    inheritedMapboxMap.value!.easeTo(
      CameraOptions(
        center: Point(
          coordinates: Position.named(
            lat: _aurakCampusPosition.lat,
            lng: _aurakCampusPosition.lng,
          ),
        ).toJson(),
        zoom: 15.5,
      ),
      MapAnimationOptions(),
    );
  }

  void displayUserFavoriteSymbols() async {
    var userEmail = _firebaseAuthService.user!.email;
    var locations =
        await _firebaseCloudStorage.getUserFavoritesByEmail(userEmail!);

    polylineAnnotationManager.value!.deleteAll();
    circleAnnotationManager.value!.deleteAll();
    pointAnnotationManager.value!.deleteAll();

    for (var location in locations) {
      double locationLatitude = location.coordinates['latitude'];
      double locationLongitude = location.coordinates['longitude'];

      final ByteData imageBytes = await rootBundle
          .load('./lib/assets/images/colored_favorite_icon.png');
      final Uint8List image = imageBytes.buffer.asUint8List();

      pointAnnotationManager.value!.create(
        PointAnnotationOptions(
          textField: location.name,
          textOpacity: 0,
          image: image,
          geometry: Point(
            coordinates: Position.named(
              lat: locationLatitude,
              lng: locationLongitude,
            ),
          ).toJson(),
        ),
      );
    }

    pointAnnotationManager.value!
        .addOnPointAnnotationClickListener(PointListener(
      userRequestedLocation: userRequestedLocation,
    ));

    inheritedMapboxMap.value!.easeTo(
      CameraOptions(
        center: Point(
          coordinates: Position.named(
            lat: _aurakCampusPosition.lat,
            lng: _aurakCampusPosition.lng,
          ),
        ).toJson(),
        zoom: 15.5,
      ),
      MapAnimationOptions(),
    );
  }

  Future<dynamic> getDirectionInfo(
      {required Location destinationLocation}) async {
    double destinationLatitude = destinationLocation.coordinates['latitude'];
    double destinationLongitude = destinationLocation.coordinates['longitude'];
    Map<String, double>? userCurrentCoordinates;

    try {
      userCurrentCoordinates = await getUserGeolocationCoordinates();
    } catch (e) {
      return null;
    }

    double userCurrentLatitude = userCurrentCoordinates['latitude']!;
    double userCurrentLongitude = userCurrentCoordinates['longitude']!;

    String routingCoordinates =
        '$userCurrentLongitude, $userCurrentLatitude; $destinationLongitude, $destinationLatitude';

    String routingProfile = 'mapbox/walking';

    String accessToken = dotenv.env['MAPBOX_ACCESS_TOKEN']!;

    var apiResponse = await http.get(
      Uri.https(
        'api.mapbox.com',
        'directions/v5/$routingProfile/$routingCoordinates',
        {
          'geometries': 'geojson',
          'access_token': accessToken,
          'overview': 'full',
          'steps': 'false'
        },
      ),
    );

    var jsonData = jsonDecode(apiResponse.body);

    return jsonData;
  }
}

class PointListener extends OnPointAnnotationClickListener {
  final FirebaseCloudStorage _firebaseCloudStorage = FirebaseCloudStorage();
  final ValueNotifier<Location?> userRequestedLocation;

  PointListener({
    required this.userRequestedLocation,
  });

  @override
  void onPointAnnotationClick(PointAnnotation annotation) async {
    userRequestedLocation.value = await _firebaseCloudStorage.getLocationByName(
        name: annotation.textField!);
  }
}
