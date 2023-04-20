import 'package:flutter/material.dart';
import 'package:maps/constants/colors.dart';
import 'package:maps/models/location.dart';
import 'package:maps/pages/indoor_floor_plan_page.dart';
import 'package:maps/services/data/firebase_cloud_storage.dart';

class IndoorNavigationPage extends StatefulWidget {
  const IndoorNavigationPage({super.key});

  @override
  State<IndoorNavigationPage> createState() => _IndoorNavigationPageState();
}

class _IndoorNavigationPageState extends State<IndoorNavigationPage> {
  final FirebaseCloudStorage _firebaseCloudStorage = FirebaseCloudStorage();
  late final List<Location> _locations;
  Location? pressedLocation;
  final PageController _pageController = PageController();

  Future<void> _getAllLocations() async {
    var locations = await _firebaseCloudStorage.getAllLocations();
    _locations = locations.toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _pageController,
        children: [
          FutureBuilder(
            future: _getAllLocations(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.done:
                  return ListView.builder(
                    itemBuilder: (context, index) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 8.0,
                        ),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 16.0,
                        ),
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 1 / 5,
                        decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.blueGrey.withOpacity(0.3),
                              Colors.blueGrey,
                              Colors.blueGrey.withOpacity(0.3),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade500,
                              blurStyle: BlurStyle.outer,
                              blurRadius: 2.0,
                            )
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              _locations[index].name.toUpperCase(),
                              style: TextStyle(
                                color: Colors.grey.shade800,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                _pageController.nextPage(
                                  duration: const Duration(
                                    milliseconds: 500,
                                  ),
                                  curve: Curves.linear,
                                );

                                setState(() {
                                  pressedLocation = _locations[index];
                                });
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                              ),
                              child: const Text(
                                'NAVIGATE INDOORS',
                                style: TextStyle(
                                  color: primaryRedColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                    itemCount: _locations.length,
                  );

                default:
                  return const Center(
                    child: CircularProgressIndicator(
                      color: primaryRedColor,
                    ),
                  );
              }
            },
          ),
          IndoorFloorPlanPage(
            location: pressedLocation,
            pageController: _pageController,
          ),
        ],
      ),
    );
  }
}
