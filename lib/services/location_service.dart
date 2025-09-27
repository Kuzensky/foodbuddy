// services/location_service.dart
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  /// ✅ Get current location with proper checks
  static Future<Position> getCurrentLocation() async {
    // Ensure location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('❌ Location services are disabled. Please enable GPS.');
    }

    // Check location permissions
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('❌ Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        '❌ Location permissions are permanently denied. '
        'Go to settings and enable them.',
      );
    }

    // ✅ Get current position with timeout
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 15),
    );
  }

  /// ✅ Convert LatLng -> human-readable address
  static Future<String> getAddressFromLatLng(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        List<String> addressParts = [];

        if (place.street != null && place.street!.isNotEmpty) {
          addressParts.add(place.street!);
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          addressParts.add(place.locality!);
        }
        if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty) {
          addressParts.add(place.administrativeArea!);
        }

        return addressParts.isNotEmpty
            ? addressParts.join(', ')
            : 'Unknown location';
      }
      return 'Unknown location';
    } catch (e) {
      print('❌ Error fetching address: $e');
      return 'Unknown location';
    }
  }

  /// ✅ Location stream (updates every 10 meters OR 30 sec)
  static Stream<Position> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // meters
      ),
    );
  }

  /// ✅ Quick check: has location permission?
  static Future<bool> hasLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  /// ✅ Open app settings (for deniedForever case)
  static Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }
}
