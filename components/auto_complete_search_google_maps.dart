import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps/components/auto_search_text_field.dart';
import 'package:maps/constants/colors.dart';
import 'package:maps/models/location.dart';
import 'package:maps/services/data/firebase_cloud_storage.dart';
import 'package:maps/inherited_widgets/google_maps/inherited_map_tracker_google_maps.dart';

class AutoCompleteSearchGoogleMaps extends StatefulWidget {
  const AutoCompleteSearchGoogleMaps({super.key});

  @override
  State<AutoCompleteSearchGoogleMaps> createState() =>
      _AutoCompleteSearchGoogleMapsState();
}

class _AutoCompleteSearchGoogleMapsState
    extends State<AutoCompleteSearchGoogleMaps> {
  final FirebaseCloudStorage _firebaseCloudStorage = FirebaseCloudStorage();
  Iterable<Location> _searchLocations = const Iterable.empty();

  // Since firebase has no way to query for data which contains searched substrings, all documents from location collection will be queried with getAllLocations, then the documents will be filtered based on the substring using the Autocomplete widget's optionsBuilder.
  void _getAllLocations() async {
    _searchLocations = await _firebaseCloudStorage.getAllLocations();
  }

  @override
  void initState() {
    super.initState();
    // On the opening of the autocomplete search bar, all locations will be retrieved from the firestore cloud.
    _getAllLocations();
  }

  @override
  Widget build(BuildContext context) {
    return Autocomplete<Location>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text == '') {
          return const Iterable<Location>.empty();
        }
        return _searchLocations.where(
          (location) {
            return location.name
                .toLowerCase()
                .contains(textEditingValue.text.toLowerCase());
          },
        ).toList();
      },
      displayStringForOption: (option) {
        return option.name;
      },
      fieldViewBuilder:
          (context, textEditingController, focusNode, onFieldSubmitted) {
        return AutoSearchTextField(
          searchHintText: 'SEARCH LOCATION',
          textEditingController: textEditingController,
          focusNode: focusNode,
          onFieldSubmitted: onFieldSubmitted,
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Material(
          child: ListView.builder(
            padding: const EdgeInsets.all(4.0),
            shrinkWrap: true,
            itemExtent: 50,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: options.length,
            itemBuilder: (context, index) {
              return ListTile(
                textColor: Colors.blueGrey,
                splashColor: primaryGrey,
                onTap: () => onSelected(options.elementAt(index)),
                title: Text(options.elementAt(index).name),
              );
            },
          ),
        );
      },
      onSelected: (option) {
        InheritedMapTrackerGoogleMaps.of(context)!.markers.clear();
        InheritedMapTrackerGoogleMaps.of(context)!.markers.add(
              Marker(
                markerId: MarkerId(option.name),
                position: LatLng(
                  option.coordinates['latitude'],
                  option.coordinates['longitude'],
                ),
                icon: BitmapDescriptor.defaultMarker,
                onTap: () {
                  InheritedMapTrackerGoogleMaps.of(context)!
                      .requestedLocation
                      .value = option;
                  InheritedMapTrackerGoogleMaps.of(context)!
                      .getUserCurrentPosition();
                },
              ),
            );
      },
    );
  }
}
