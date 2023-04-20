import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:maps/inherited_widgets/mapbox/inherited_map_tracker_mapbox.dart';
import 'package:maps/models/location.dart';
import 'package:maps/services/auth/firebase_auth_service.dart';
import 'package:maps/services/data/firebase_cloud_storage.dart';

class TransparentLocationCard extends StatefulWidget {
  final double cardHeight;
  final double cardWidth;
  final Location location;

  const TransparentLocationCard({
    super.key,
    required this.cardHeight,
    required this.cardWidth,
    required this.location,
  });

  @override
  State<TransparentLocationCard> createState() =>
      _TransparentLocationCardState();
}

class _TransparentLocationCardState extends State<TransparentLocationCard> {
  final FirebaseAuthService _firebaseAuthService = FirebaseAuthService();
  final FirebaseCloudStorage _firebaseCloudStorage = FirebaseCloudStorage();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
      child: SizedBox(
        height: widget.cardHeight,
        width: widget.cardWidth,
        child: Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 3.0,
                sigmaY: 3.0,
              ),
              child: Container(),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.blueGrey.withOpacity(0.2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.location.name.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Divider(
                    color: Colors.white.withOpacity(0.5),
                    thickness: 2.0,
                  ),
                  // Favorites Icon Button
                  IconButton(
                    disabledColor: Colors.grey.shade300,
                    onPressed: _firebaseAuthService.user == null
                        ? null
                        : () async {
                            String userEmail =
                                _firebaseAuthService.user!.email!;

                            List<Location> favoriteLocations =
                                await _firebaseCloudStorage
                                    .getUserFavoritesByEmail(userEmail);

                            bool favLocationsContainsLocation = false;
                            for (var favLocation in favoriteLocations) {
                              if (favLocation.name == widget.location.name) {
                                favLocationsContainsLocation = true;
                                break;
                              }
                            }

                            if (favLocationsContainsLocation) {
                              // Delete favorite (BEGINNING).
                              _firebaseCloudStorage.removeFavoriteByEmail(
                                email: _firebaseAuthService.user!.email!,
                                favoriteLocation: widget.location.name,
                              );
                              // Delete favorite (END).
                            } else {
                              // Add favorite (BEGINNING).
                              _firebaseCloudStorage.addFavoriteByEmail(
                                email: _firebaseAuthService.user!.email!,
                                favoriteLocation: widget.location.name,
                              );
                              // Add Favorite (END).
                            }
                          },
                    icon: const Icon(
                      Icons.favorite_rounded,
                      size: 32,
                      color: Colors.pink,
                    ),
                  ),
                  // Info Icon Button
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.info_rounded,
                      size: 32,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  // Pathfinding Icon Button
                  IconButton(
                    onPressed: () async {
                      var locationInformation =
                          await InheritedMapTrackerMapbox.of(context)!
                              .getDirectionInfo(
                                  destinationLocation: widget.location);

                      List<dynamic> pathCoordinates =
                          locationInformation['routes'][0]['geometry']
                              ['coordinates'];

                      InheritedMapTrackerMapbox.of(context)!
                          .displayPath(pathCoordinates: pathCoordinates);
                    },
                    icon: Icon(
                      Icons.assistant_navigation,
                      size: 32,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
