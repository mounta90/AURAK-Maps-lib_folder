import 'package:maps/components/auto_complete_search_google_maps.dart';
import 'package:maps/components/location_card.dart';
import 'package:maps/constants/colors.dart';
import 'package:maps/constants/routes.dart';
import 'package:maps/models/location.dart';
import 'package:maps/services/auth/firebase_auth_service.dart';
import 'package:maps/services/data/firebase_cloud_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps/components/auto_search_text_field.dart';
import 'package:maps/components/rounded_icon_button.dart';
import 'package:maps/constants/others.dart';
import 'dart:developer' as devtools show log;
import 'package:maps/inherited_widgets/google_maps/inherited_map_tracker_google_maps.dart';

const LatLng aurakLocation = LatLng(25.788801494480953, 55.992820429464274);
const List<LatLng> aurakPerimeter = [
  LatLng(25.788778587343213, 55.99233758911718),
  LatLng(25.787690226119448, 55.99206105674722),
  LatLng(25.78687507185754, 55.99588510497764),
  LatLng(25.789410753684013, 55.99657182642769),
  LatLng(25.79043752338582, 55.99170819452127),
  LatLng(25.78906330761809, 55.99132997814498),
];
const double cameraZoom = 16.5;
const double cameraTilt = 0.0;
const double cameraBearing = 285.0;

class GoogleMapsOutdoorPage extends StatefulWidget {
  const GoogleMapsOutdoorPage({super.key});

  @override
  State<GoogleMapsOutdoorPage> createState() => _GoogleMapsOutdoorPageState();
}

class _GoogleMapsOutdoorPageState extends State<GoogleMapsOutdoorPage> {
  late final FirebaseCloudStorage _firebaseCloudStorage;
  late final FirebaseAuthService _firebaseAuthService;
  late final LatLng userCurrentPosition;
  late final GoogleMapController _controller;
  final Set<Polyline> _polylines = {};

  final PolylinePoints polylinePoints = PolylinePoints();

  @override
  void initState() {
    super.initState();

    // create a firebase cloud storage instance
    _firebaseCloudStorage = FirebaseCloudStorage();
    _firebaseAuthService = FirebaseAuthService();
  }

  @override
  Widget build(BuildContext context) {
    //
    void displayPinsByCategory({required filterCategory}) async {
      var locations = await _firebaseCloudStorage.getLocationsByCategory(
          category: filterCategory);

      setState(() {
        InheritedMapTrackerGoogleMaps.of(context)!.markers.clear();
        for (var location in locations) {
          InheritedMapTrackerGoogleMaps.of(context)!.markers.add(Marker(
                markerId: MarkerId(location.name),
                position: LatLng(
                  location.coordinates['latitude'],
                  location.coordinates['longitude'],
                ),
                icon: BitmapDescriptor.defaultMarker,
                onTap: () {
                  InheritedMapTrackerGoogleMaps.of(context)
                      ?.requestedLocation
                      .value = location;
                  devtools.log(
                      'value of requested location is ${InheritedMapTrackerGoogleMaps.of(context)?.requestedLocation.value}');
                },
              ));
        }
      });
    }

    void displayUserCoursePins() async {
      // TODO
      // var userEmail = _firebaseAuthService.user!.email;
      // var locations =
      //     await _firebaseCloudStorage.getUserCoursesByEmail(userEmail!);

      var locations = await _firebaseCloudStorage
          .getUserCoursesByEmail('a.balhasan@aurak.ac.ae');

      setState(() {
        InheritedMapTrackerGoogleMaps.of(context)!.markers.clear();
        for (var location in locations) {
          InheritedMapTrackerGoogleMaps.of(context)!.markers.add(Marker(
                markerId: MarkerId(location.name),
                position: LatLng(
                  location.coordinates['latitude'],
                  location.coordinates['longitude'],
                ),
                icon: BitmapDescriptor.defaultMarker,
                onTap: () {
                  InheritedMapTrackerGoogleMaps.of(context)
                      ?.requestedLocation
                      .value = location;
                  devtools.log(
                      'value of requested location is ${InheritedMapTrackerGoogleMaps.of(context)?.requestedLocation.value}');
                },
              ));
        }
      });
    }

    void displayUserFavoritePins() async {
      // TODO
      // var userEmail = _firebaseAuthService.user!.email;
      // var locations =
      //     await _firebaseCloudStorage.getUserFavoritesByEmail(userEmail!);

      var locations = await _firebaseCloudStorage
          .getUserFavoritesByEmail('a.balhasan@aurak.ac.ae');

      setState(() {
        InheritedMapTrackerGoogleMaps.of(context)!.markers.clear();
        for (var location in locations) {
          InheritedMapTrackerGoogleMaps.of(context)!.markers.add(Marker(
                markerId: MarkerId(location.name),
                position: LatLng(
                  location.coordinates['latitude'],
                  location.coordinates['longitude'],
                ),
                icon: BitmapDescriptor.defaultMarker,
                onTap: () {
                  InheritedMapTrackerGoogleMaps.of(context)
                      ?.requestedLocation
                      .value = location;
                  devtools.log(
                      'value of requested location is ${InheritedMapTrackerGoogleMaps.of(context)?.requestedLocation.value}');
                },
              ));
        }
      });
    }

    void showPinUsingFirebase({required name}) async {
      var location = await _firebaseCloudStorage.getLocationByName(name: name);

      setState(() {
        InheritedMapTrackerGoogleMaps.of(context)!.markers.add(Marker(
              markerId: MarkerId(location.name),
              position: LatLng(
                location.coordinates['latitude'],
                location.coordinates['longitude'],
              ),
              icon: BitmapDescriptor.defaultMarker,
              onTap: () {
                // onTappedLocation.value = location.name;
              },
            ));
      });
    }

    void displayMarkerOnMap({required Location inputlocation}) async {
      Location location = inputlocation;

      InheritedMapTrackerGoogleMaps.of(context)!.markers.add(Marker(
            markerId: MarkerId(location.name),
            position: LatLng(
              location.coordinates['latitude'],
              location.coordinates['longitude'],
            ),
            icon: BitmapDescriptor.defaultMarker,
            onTap: () {
              // onTappedLocation.value = location.name;
            },
          ));
    }

    void setPolylines({
      required LatLng userLoc,
      required LatLng destinationLoc,
    }) async {
      LatLng userLocation = userLoc;
      LatLng destinationLocation = destinationLoc;
      List<LatLng> polylineCoordinates = [];

      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey,
        PointLatLng(
          userLocation.latitude,
          userLocation.longitude,
        ),
        PointLatLng(
          destinationLocation.latitude,
          destinationLocation.longitude,
        ),
      );

      if (result.status == "OK") {
        for (var point in result.points) {
          polylineCoordinates.add(LatLng(
            point.latitude,
            point.longitude,
          ));
        }

        setState(() {
          _polylines.add(
            Polyline(
                polylineId: const PolylineId('polyline'),
                width: 2,
                color: Colors.blue,
                points: polylineCoordinates),
          );
        });
      }
    }

    void initializeUserCurrentPosition() async {
      // get user's current position, if location services are allowed for access.
      userCurrentPosition = await InheritedMapTrackerGoogleMaps.of(context)!
          .getUserCurrentPosition();
      devtools.log('User position initialized');
    }

    Future<bool> showLogoutDialog(BuildContext context) {
      return showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              "LOGOUT",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Text("ARE YOU SURE YOU WANT TO LOGOUT?"),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text("CANCEL")),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text("LOGOUT"))
            ],
          );
        },
      ).then((value) => value ?? false);
    }

    return Scaffold(
      body: Stack(
        children: [
          // Filled Google Map Background
          Positioned.fill(
            child: GoogleMap(
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              compassEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              markers: InheritedMapTrackerGoogleMaps.of(context)!.markers,
              polylines: _polylines,
              polygons: {
                Polygon(
                  polygonId: const PolygonId('aurakPerimeter'),
                  points: aurakPerimeter,
                  fillColor: primaryRedColor.withOpacity(0.1),
                  strokeColor: primaryRedColor,
                  strokeWidth: 1,
                )
              },
              initialCameraPosition: const CameraPosition(
                zoom: cameraZoom,
                tilt: cameraTilt,
                bearing: cameraBearing,
                target: aurakLocation,
              ),
              onMapCreated: (GoogleMapController controller) async {
                _controller = controller;
                initializeUserCurrentPosition();
              },
              onTap: (argument) {
                InheritedMapTrackerGoogleMaps.of(context)
                    ?.requestedLocation
                    .value = null;
                InheritedMapTrackerGoogleMaps.of(context)
                            ?.requestedLocation
                            .value ==
                        null
                    ? devtools.log('no requested location')
                    : devtools.log('error');
              },
            ),
          ),
          // Shortcuts & Search Bars @ top
          Positioned(
            height: MediaQuery.of(context).size.height * 0.2,
            top: MediaQuery.of(context).size.height * 0.1,
            left: 0,
            right: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon Button Search Category Filters
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 4.0,
                    horizontal: 4.0,
                  ),
                  width: (MediaQuery.of(context).size.width - 32),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(50.0)),
                    boxShadow: [
                      BoxShadow(
                        blurStyle: BlurStyle.outer,
                        color: Colors.grey,
                        blurRadius: 2.0,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RoundedIconButton(
                        iconName: Icons.favorite_border,
                        onPressed: _firebaseAuthService.user?.email == null
                            ? null
                            : () {
                                displayUserFavoritePins();
                              },
                        fillColor: Colors.pink,
                        iconColor: Colors.white,
                      ),
                      RoundedIconButton(
                        iconName: Icons.business_sharp,
                        onPressed: () {
                          displayPinsByCategory(filterCategory: 'building');
                        },
                        fillColor: Colors.green,
                        iconColor: Colors.white,
                      ),
                      RoundedIconButton(
                        iconName: Icons.local_restaurant_sharp,
                        onPressed: () {
                          displayPinsByCategory(filterCategory: 'food');
                        },
                        fillColor: Colors.orange,
                        iconColor: Colors.white,
                      ),
                      RoundedIconButton(
                        iconName: Icons.sports_tennis_outlined,
                        onPressed: () {
                          displayPinsByCategory(
                              filterCategory: 'entertainment');
                        },
                        fillColor: Colors.purple,
                        iconColor: Colors.white,
                      ),
                      RoundedIconButton(
                        iconName: Icons.menu_book_sharp,
                        onPressed: _firebaseAuthService.user?.email == null
                            ? null
                            : () {
                                displayUserCoursePins();
                              },
                        fillColor: Colors.blue,
                        iconColor: Colors.white,
                      ),
                    ],
                  ),
                ),
                // Search Text Field
                Container(
                  width: (MediaQuery.of(context).size.width - 32),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(50.0)),
                    boxShadow: [
                      BoxShadow(
                        blurStyle: BlurStyle.outer,
                        color: Colors.grey,
                        blurRadius: 2.0,
                      ),
                    ],
                  ),
                  child: const AutoCompleteSearchGoogleMaps(),
                ),
              ],
            ),
          ),
          // Logout Button
          Positioned(
            bottom: 100,
            right: 20,
            child: Material(
              borderRadius: BorderRadius.circular(50.0),
              color: Colors.black,
              child: IconButton(
                color: Colors.black,
                onPressed: () async {
                  final willLogout = await showLogoutDialog(context);
                  if (willLogout) {
                    await _firebaseAuthService.logOut();
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil(loginRoute, (route) => false);
                  }
                },
                icon: const Icon(
                  Icons.logout_outlined,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ),
          // A card that is displayed when a marker is tapped... updates based on a ValueNotifier
          // The ValueNotifier will be 'RequestedLocation.of(context)!.requestedLocation'.
          // The '!.' will enforce a non-null requestedLocation as in our case requestedLocation is always non-null... see RequestedLocation widget.
          ValueListenableBuilder(
            valueListenable:
                InheritedMapTrackerGoogleMaps.of(context)!.requestedLocation,
            builder: (context, value, child) {
              return AnimatedPositioned(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                bottom: value == null ? -300 : 100,
                width: MediaQuery.of(context).size.width,
                child: value != null
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: LocationCard(
                          cardLocationName: value.name,
                          onNavigationButtonPressed: () async {
                            setPolylines(
                              userLoc: userCurrentPosition,
                              destinationLoc: LatLng(
                                value.coordinates['latitude'],
                                value.coordinates['longitude'],
                              ),
                            );
                          },
                        ),
                      )
                    : const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: LocationCard(
                          cardLocationName: '',
                          onNavigationButtonPressed: null,
                        ),
                      ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FutureBuilder(
        // There lies a bug in this implementation... specifically when you enable location, get the future, then disable... the button should be disabled.
        future:
            InheritedMapTrackerGoogleMaps.of(context)!.getUserCurrentPosition(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return FloatingActionButton(
                onPressed: () {},
                backgroundColor: Colors.grey,
                foregroundColor: Colors.white,
                child: const Icon(Icons.location_disabled_outlined),
              );

            case ConnectionState.waiting:
              return FloatingActionButton(
                onPressed: () {},
                backgroundColor: Colors.grey,
                foregroundColor: Colors.white,
                child: const CircularProgressIndicator(
                  backgroundColor: Colors.grey,
                  color: Colors.white,
                ),
              );

            case ConnectionState.active:
              return FloatingActionButton(
                onPressed: () {},
                backgroundColor: Colors.grey,
                foregroundColor: Colors.white,
                child: const CircularProgressIndicator(
                  backgroundColor: Colors.grey,
                  color: Colors.white,
                ),
              );

            case ConnectionState.done:
              if (snapshot.hasError) {
                devtools.log(snapshot.error.toString());
                return FloatingActionButton(
                  onPressed: () async {
                    await InheritedMapTrackerGoogleMaps.of(context)!
                        .getUserCurrentPosition();
                  },
                  tooltip: snapshot.error.toString(),
                  backgroundColor: Colors.grey,
                  splashColor: Colors.grey,
                  child: const Icon(
                    Icons.location_disabled_outlined,
                    color: Colors.white,
                  ),
                );
              } else {
                devtools.log('Successful future... i think.');
                return FloatingActionButton(
                  onPressed: () {
                    devtools.log(snapshot.data.toString());

                    _controller.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target: LatLng(
                            snapshot.data!.latitude,
                            snapshot.data!.longitude,
                          ),
                          zoom: cameraZoom,
                          bearing: cameraBearing,
                        ),
                      ),
                    );
                  },
                  backgroundColor: primaryRedColor,
                  child: const Icon(
                    Icons.my_location_outlined,
                    color: Colors.white,
                    size: 32,
                  ),
                );
              }
          }
        },
      ),
      resizeToAvoidBottomInset: false,
    );
  }
}
