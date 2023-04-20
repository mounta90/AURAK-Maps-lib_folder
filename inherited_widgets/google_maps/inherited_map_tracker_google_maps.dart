import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps/models/location.dart';

class InheritedMapTrackerGoogleMaps extends InheritedWidget {
  final ValueNotifier<Location?> requestedLocation = ValueNotifier(null);
  final Set<Marker> markers = {};

  InheritedMapTrackerGoogleMaps({
    super.key,
    required super.child,
  });

  // This inherited widget will notify its descendant widgets in the case that the searchedLocation object changes.
  // The searchedLocation object should change when the user searches for a location or taps on a location marker.
  @override
  bool updateShouldNotify(covariant InheritedMapTrackerGoogleMaps oldWidget) {
    return requestedLocation != oldWidget.requestedLocation ||
        markers != oldWidget.markers;
  }

  static InheritedMapTrackerGoogleMaps? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType();
  }

  // ------------------------

  Future<LatLng> getUserCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission locationPermission;
    Position userCurrentPosition;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return Future.error(
          'Location Services are Disabled: Turn On Location Services');
    } else {
      locationPermission = await Geolocator.checkPermission();

      if (locationPermission == LocationPermission.deniedForever) {
        return Future.error(
            'Location Permission is Denied Permanentally: Enable Permission from Device Settings');
      } else if (locationPermission == LocationPermission.denied) {
        locationPermission = await Geolocator.requestPermission();

        if (locationPermission == LocationPermission.denied) {
          return Future.error(
              'Location Permission is Denied: Accept Location Permission to Use Location Services');
        } else {
          userCurrentPosition = await Geolocator.getCurrentPosition();
          return LatLng(
              userCurrentPosition.latitude, userCurrentPosition.longitude);
        }
      } else {
        userCurrentPosition = await Geolocator.getCurrentPosition();
        return LatLng(
            userCurrentPosition.latitude, userCurrentPosition.longitude);
      }
    }
  }
}
