import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

class LocationNotifier extends StateNotifier<LatLng?> {
  LocationNotifier() : super(null);

  void setLocation(double latitude, double longitude) {
    state = LatLng(latitude, longitude);
  }
}
