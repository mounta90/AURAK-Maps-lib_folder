import 'package:geolocator/geolocator.dart';

Future<Map<String, double>> getUserGeolocationCoordinates() async {
  bool serviceEnabled;
  LocationPermission locationPermission;
  Position userCurrentPosition;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();

  if (!serviceEnabled) {
    return Future.error(
        'LOCATION SERVICES ARE DISABLED: TURN ON LOCATION SERVICES');
  } else {
    locationPermission = await Geolocator.checkPermission();
    if (locationPermission == LocationPermission.deniedForever) {
      return Future.error(
          'LOCATION PERMISSION IS DENIED PERMANENTLY: ENABLE PERMISSION FROM DEVICE SETTINGS');
    } else if (locationPermission == LocationPermission.denied) {
      locationPermission = await Geolocator.requestPermission();

      if (locationPermission == LocationPermission.denied) {
        return Future.error(
            'LOCATION PERMISSION IS DENIED: ACCEPT LOCATION PERMISSION TO USE LOCATION SERVICES');
      } else {
        userCurrentPosition = await Geolocator.getCurrentPosition();
        return {
          "latitude": userCurrentPosition.latitude,
          "longitude": userCurrentPosition.longitude,
        };
      }
    } else {
      userCurrentPosition = await Geolocator.getCurrentPosition();
      return {
        "latitude": userCurrentPosition.latitude,
        "longitude": userCurrentPosition.longitude,
      };
    }
  }
}
