import 'package:flutter/material.dart';
import 'package:maps/constants/colors.dart';
import 'package:maps/inherited_widgets/mapbox/inherited_map_tracker_mapbox.dart';
import 'package:maps/pages/account_page.dart';
import 'package:maps/pages/indoor_navigation_page.dart';
import 'package:maps/pages/mapbox_outdoor_page.dart';

class NavigatorPage extends StatefulWidget {
  const NavigatorPage({super.key});

  @override
  State<NavigatorPage> createState() => _NavigatorPageState();
}

class _NavigatorPageState extends State<NavigatorPage> {
  int navBarIndex = 0;

  final mainAppPages = [
    InheritedMapTrackerMapbox(child: const MapboxOutdoorPage()),
    const IndoorNavigationPage(),
    const AccountPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: mainAppPages[navBarIndex],
      bottomNavigationBar: BottomNavigationBar(
        elevation: 5,
        currentIndex: navBarIndex,
        onTap: (value) {
          setState(() {
            navBarIndex = value;
          });
        },
        selectedItemColor: primaryRedColor,
        unselectedItemColor: Colors.blueGrey.withOpacity(0.5),
        backgroundColor: Colors.white,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          BottomNavigationBarItem(
            icon: Image(
              image: const AssetImage('./lib/assets/images/gps-navigation.png'),
              color: navBarIndex == 0
                  ? primaryRedColor
                  : Colors.blueGrey.withOpacity(0.5),
              height: 30,
            ),
            label: 'OUTDOOR',
          ),
          BottomNavigationBarItem(
            icon: Image(
              image: const AssetImage('./lib/assets/images/indoor.png'),
              color: navBarIndex == 1
                  ? primaryRedColor
                  : Colors.blueGrey.withOpacity(0.5),
              height: 30,
            ),
            label: 'INDOOR',
          ),
          BottomNavigationBarItem(
            icon: Image(
              image: const AssetImage('./lib/assets/images/user.png'),
              color: navBarIndex == 2
                  ? primaryRedColor
                  : Colors.blueGrey.withOpacity(0.5),
              height: 30,
            ),
            label: 'ACCOUNT',
          ),
        ],
      ),
    );
  }
}
