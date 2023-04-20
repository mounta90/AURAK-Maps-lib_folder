import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:maps/components/auto_complete_search_mapbox.dart';
import 'package:maps/components/rounded_icon_button.dart';
import 'package:maps/components/transparent_location_card.dart';
import 'package:maps/constants/colors.dart';
import 'package:maps/constants/icons.dart';
import 'package:maps/inherited_widgets/mapbox/inherited_map_tracker_mapbox.dart';
import 'package:maps/services/auth/firebase_auth_service.dart';
import 'package:maps/utilities/get_user_geolocation_position.dart';

class MapboxOutdoorPage extends StatefulWidget {
  const MapboxOutdoorPage({super.key});

  @override
  State<MapboxOutdoorPage> createState() => _MapboxOutdoorPageState();
}

class _MapboxOutdoorPageState extends State<MapboxOutdoorPage> {
  final FirebaseAuthService _firebaseAuthService = FirebaseAuthService();
  final Position _aurakCampusPosition =
      Position.named(lat: 25.788839, lng: 55.993647);

  _onMapCreated(MapboxMap mapboxMap) async {
    InheritedMapTrackerMapbox.of(context)!.inheritedMapboxMap.value = mapboxMap;

    InheritedMapTrackerMapbox.of(context)!.circleAnnotationManager.value =
        await mapboxMap.annotations.createCircleAnnotationManager();

    InheritedMapTrackerMapbox.of(context)!.pointAnnotationManager.value =
        await mapboxMap.annotations.createPointAnnotationManager();

    InheritedMapTrackerMapbox.of(context)!.polylineAnnotationManager.value =
        await mapboxMap.annotations.createPolylineAnnotationManager();

    InheritedMapTrackerMapbox.of(context)!
        .inheritedMapboxMap
        .value!
        .location
        .updateSettings(
          LocationComponentSettings(
            enabled: true,
          ),
        );

    InheritedMapTrackerMapbox.of(context)!
        .inheritedMapboxMap
        .value!
        .scaleBar
        .updateSettings(
          ScaleBarSettings(
            enabled: false,
          ),
        );

    InheritedMapTrackerMapbox.of(context)!
        .inheritedMapboxMap
        .value!
        .compass
        .updateSettings(
          CompassSettings(
            enabled: false,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: [
          // Mapbox View
          Positioned.fill(
            child: MapWidget(
              textureView: true,
              styleUri:
                  "mapbox://styles/mounta90/clf1dq2jd001o01mrblt3iuyb/draft",
              resourceOptions: ResourceOptions(
                accessToken: dotenv.env['MAPBOX_ACCESS_TOKEN']!,
              ),
              onMapCreated: _onMapCreated,
              cameraOptions: CameraOptions(
                center: Point(coordinates: _aurakCampusPosition).toJson(),
                bearing: 282.0,
                pitch: 50,
                zoom: 15.5,
              ),
            ),
          ),
          // Category Icon Buttons & Search Bar
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
                        iconName: favoriteIcon,
                        onPressed: _firebaseAuthService.user == null
                            ? null
                            : () {
                                InheritedMapTrackerMapbox.of(context)!
                                    .displayUserFavoriteSymbols();
                                InheritedMapTrackerMapbox.of(context)!
                                    .userRequestedLocation
                                    .value = null;
                              },
                        fillColor: Colors.pink,
                        iconColor: Colors.white,
                      ),
                      RoundedIconButton(
                        iconName: buildingIcon,
                        onPressed: () {
                          InheritedMapTrackerMapbox.of(context)!
                              .displaySymbolsByCategory(
                            filterCategory: 'building',
                          );

                          InheritedMapTrackerMapbox.of(context)!
                              .userRequestedLocation
                              .value = null;
                        },
                        fillColor: Colors.green,
                        iconColor: Colors.white,
                      ),
                      RoundedIconButton(
                        iconName: foodIcon,
                        onPressed: () {
                          InheritedMapTrackerMapbox.of(context)!
                              .displaySymbolsByCategory(
                            filterCategory: 'food',
                          );

                          InheritedMapTrackerMapbox.of(context)!
                              .userRequestedLocation
                              .value = null;
                        },
                        fillColor: Colors.orange,
                        iconColor: Colors.white,
                      ),
                      RoundedIconButton(
                        iconName: recreationIcon,
                        onPressed: () {
                          InheritedMapTrackerMapbox.of(context)!
                              .displaySymbolsByCategory(
                            filterCategory: 'entertainment',
                          );

                          InheritedMapTrackerMapbox.of(context)!
                              .userRequestedLocation
                              .value = null;
                        },
                        fillColor: Colors.purple,
                        iconColor: Colors.white,
                      ),
                      RoundedIconButton(
                        iconName: coursesIcon,
                        onPressed: _firebaseAuthService.user == null
                            ? null
                            : () {
                                InheritedMapTrackerMapbox.of(context)!
                                    .displayUserCourseSymbols();

                                InheritedMapTrackerMapbox.of(context)!
                                    .userRequestedLocation
                                    .value = null;
                              },
                        fillColor: Colors.blue,
                        iconColor: Colors.white,
                      ),
                    ],
                  ),
                ),
                // Search Text Field
                Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: const BoxDecoration(
                    // borderRadius: BorderRadius.all(Radius.circular(50.0)),
                    color: Colors.transparent,
                    boxShadow: [
                      BoxShadow(
                        blurStyle: BlurStyle.outer,
                        color: Colors.grey,
                        blurRadius: 2.0,
                      ),
                    ],
                  ),
                  child: const AutoCompleteSearchMapbox(),
                ),
              ],
            ),
          ),
          // Tilt Up Camera Button
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.4,
            right: 16,
            child: FloatingActionButton(
              onPressed: () async {
                InheritedMapTrackerMapbox.of(context)!
                    .inheritedMapboxMap
                    .value!
                    .getCameraState()
                    .then((value) {
                  double pitchValue = value.pitch - 2.5;
                  InheritedMapTrackerMapbox.of(context)!
                      .inheritedMapboxMap
                      .value!
                      .setCamera(CameraOptions(
                        pitch: pitchValue,
                      ));
                });
              },
              backgroundColor: Colors.white,
              child: const Icon(
                Icons.keyboard_double_arrow_up_rounded,
                color: Colors.blueGrey,
                size: 32,
              ),
            ),
          ),
          // Tilt Down Camera Button
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.275,
            right: 16,
            child: FloatingActionButton(
              onPressed: () async {
                InheritedMapTrackerMapbox.of(context)!
                    .inheritedMapboxMap
                    .value!
                    .getCameraState()
                    .then((value) {
                  double pitchValue = value.pitch + 2.5;
                  InheritedMapTrackerMapbox.of(context)!
                      .inheritedMapboxMap
                      .value!
                      .setCamera(CameraOptions(
                        pitch: pitchValue,
                      ));
                });
              },
              backgroundColor: Colors.white,
              child: const Icon(
                Icons.keyboard_double_arrow_down_rounded,
                color: Colors.blueGrey,
                size: 32,
              ),
            ),
          ),
          // AURAK Campus Finder Button
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.15,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                InheritedMapTrackerMapbox.of(context)!
                    .inheritedMapboxMap
                    .value!
                    .flyTo(
                      CameraOptions(
                        center:
                            Point(coordinates: _aurakCampusPosition).toJson(),
                        bearing: 282.0,
                        pitch: 50,
                        zoom: 15.5,
                      ),
                      MapAnimationOptions(),
                    );
              },
              backgroundColor: primaryRedColor,
              child: const Icon(
                Icons.all_out_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
          // User Location Finder Button
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.025,
            right: 16,
            child: FloatingActionButton(
              onPressed: () async {
                try {
                  Map<String, double> userGeolocationCoords =
                      await getUserGeolocationCoordinates();

                  Position userPosition = Position.named(
                    lat: userGeolocationCoords['latitude']!,
                    lng: userGeolocationCoords['longitude']!,
                  );

                  InheritedMapTrackerMapbox.of(context)!
                      .inheritedMapboxMap
                      .value!
                      .flyTo(
                        CameraOptions(
                          center: Point(coordinates: userPosition).toJson(),
                        ),
                        MapAnimationOptions(),
                      );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        e.toString(),
                        style: const TextStyle(
                          fontFamily: 'MavenPro',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }
              },
              backgroundColor: Colors.white,
              child: const Icon(
                Icons.my_location_outlined,
                color: Colors.blueGrey,
                size: 32,
              ),
            ),
          ),
          // User Requested Location Card
          Positioned(
            top: MediaQuery.of(context).size.height * 0.4,
            left: 0,
            child: ValueListenableBuilder(
              valueListenable:
                  InheritedMapTrackerMapbox.of(context)!.userRequestedLocation,
              builder: (context, value, child) {
                bool isLocationNull = value == null;
                if (isLocationNull) {
                  return const SizedBox(
                    height: 1,
                    width: 1,
                  );
                } else {
                  return TransparentLocationCard(
                    cardHeight: MediaQuery.of(context).size.height * 0.4,
                    cardWidth: MediaQuery.of(context).size.width * 0.3,
                    location: value,
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
