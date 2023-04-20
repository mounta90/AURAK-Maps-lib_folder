import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:maps/components/auto_search_text_field.dart';
import 'package:maps/constants/colors.dart';
import 'package:maps/inherited_widgets/mapbox/inherited_map_tracker_mapbox.dart';
import 'package:maps/models/location.dart';
import 'package:maps/services/data/firebase_cloud_storage.dart';

class AutoCompleteSearchMapbox extends StatefulWidget {
  const AutoCompleteSearchMapbox({super.key});

  @override
  State<AutoCompleteSearchMapbox> createState() =>
      _AutoCompleteSearchMapboxState();
}

class _AutoCompleteSearchMapboxState extends State<AutoCompleteSearchMapbox> {
  final FirebaseCloudStorage _firebaseCloudStorage = FirebaseCloudStorage();
  Iterable<Location> _searchLocations = const Iterable.empty();

  _AutoCompleteSearchMapboxState();

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
        return option.name.toUpperCase();
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
            padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            itemCount: options.length,
            itemBuilder: (context, index) {
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 32.0,
                  vertical: 8.0,
                ),
                textColor: Colors.blueGrey,
                splashColor: primaryGrey,
                onTap: () => onSelected(options.elementAt(index)),
                title: Text(options.elementAt(index).name.toUpperCase()),
              );
            },
          ),
        );
      },
      onSelected: (option) async {
        Location selectedLocation = option;
        InheritedMapTrackerMapbox.of(context)!.userRequestedLocation.value =
            selectedLocation;
        double locationLatitude = selectedLocation.coordinates['latitude'];
        double locationLongitude = selectedLocation.coordinates['longitude'];

        InheritedMapTrackerMapbox.of(context)!.inheritedMapboxMap.value!.easeTo(
              CameraOptions(
                center: Point(
                  coordinates: Position.named(
                      lat: locationLatitude, lng: locationLongitude),
                ).toJson(),
                zoom: 17.5,
              ),
              MapAnimationOptions(),
            );

        InheritedMapTrackerMapbox.of(context)!
            .pointAnnotationManager
            .value!
            .deleteAll();

        InheritedMapTrackerMapbox.of(context)!
            .circleAnnotationManager
            .value!
            .deleteAll();

        InheritedMapTrackerMapbox.of(context)!
            .polylineAnnotationManager
            .value!
            .deleteAll();

        final ByteData imageBytes =
            await rootBundle.load('./lib/assets/images/searched_location1.png');
        final Uint8List image = imageBytes.buffer.asUint8List();

        InheritedMapTrackerMapbox.of(context)!
            .pointAnnotationManager
            .value!
            .create(
              PointAnnotationOptions(
                image: image,
                geometry: Point(
                  coordinates: Position.named(
                    lat: locationLatitude,
                    lng: locationLongitude,
                  ),
                ).toJson(),
              ),
            );
      },
    );
  }
}
