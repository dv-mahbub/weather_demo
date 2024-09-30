import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:weather_demo/components/global_functions/navigate.dart';
import 'package:weather_demo/components/global_widgets/show_message.dart';
import 'package:weather_demo/main.dart';
import 'package:weather_demo/views/homepage/homepage.dart';

class LocationTrackingPage extends StatefulWidget {
  const LocationTrackingPage({super.key});

  @override
  State<LocationTrackingPage> createState() => _LocationTrackingPageState();
}

class _LocationTrackingPageState extends State<LocationTrackingPage> {
  LatLng currentLocation = const LatLng(23.8041, 90.4152);
  double zoom = 4;
  Key mapKey = UniqueKey();
  var isLoaded = false;

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Flexible(
                child: SizedBox(
                  width: screenSize.width * .9,
                  child: Stack(
                    children: [
                      FlutterMap(
                        key: mapKey,
                        options: MapOptions(
                          initialCenter: currentLocation,
                          maxZoom: zoom,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.app',
                          ),
                          MarkerLayer(markers: [
                            Marker(
                              point: currentLocation,
                              width: 80.0,
                              height: 80.0,
                              child: const Icon(Icons.location_on,
                                  size: 34, color: Colors.red),
                            )
                          ])
                        ],
                      ),
                      Positioned(
                        bottom: 16.0,
                        right: 16.0,
                        child: FloatingActionButton(
                          onPressed: locate,
                          child: const Icon(Icons.my_location),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Gap(8),
              Consumer(
                builder: (context, ref, child) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: isLoaded ? Colors.blue : Colors.grey,
                        foregroundColor: Colors.white),
                    onPressed: isLoaded
                        ? () {
                            ref.read(locationProvider.notifier).setLocation(
                                currentLocation.latitude,
                                currentLocation.longitude);

                            navigate(context: context, child: const Homepage());
                          }
                        : () {
                            if (mounted) {
                              showErrorMessage(
                                  context, 'Current location not fetched yet');
                            }
                          },
                    child: const Text('Use current location'),
                  );
                },
              ),
              Gap(5),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> locate() async {
    Position position = await determinePosition();
    setState(() {
      zoom = 14;
      currentLocation = LatLng(position.latitude, position.longitude);
      mapKey = UniqueKey();
      isLoaded = true;
    });
  }

  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    Location location = Location();
    await location.requestService();
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      showError('Location services are disabled');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        showError('Location permission is not granted');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      showError('Location permissions are permanently denied');
    }
    return await Geolocator.getCurrentPosition();
  }

  showError(String message) {
    if (mounted) {
      showErrorMessage(context, message);
    }
  }
}
