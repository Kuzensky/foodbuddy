// services/distance_service.dart
import 'dart:math';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../config/maps_config.dart';

class DistanceService {
  static const String _directionsUrl = 'https://maps.googleapis.com/maps/api/directions/json';

  static Future<Map<String, dynamic>?> calculateDistanceAndTime(
    LatLng origin,
    LatLng destination,
  ) async {
    // Check if we have a valid API key
    if (!MapsConfig.hasApiKey) {
      print('Warning: Google Maps API key not configured');
      return _getFallbackDistanceInfo(origin, destination);
    }

    try {
      final response = await http.get(
        Uri.parse(
          '$_directionsUrl?origin=${origin.latitude},${origin.longitude}'
          '&destination=${destination.latitude},${destination.longitude}'
          '&key=${MapsConfig.mapsApiKey}',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK') {
          final route = data['routes'][0];
          final leg = route['legs'][0];
          
          return {
            'distance': leg['distance']['text'],
            'duration': leg['duration']['text'],
            'distanceValue': leg['distance']['value'], // in meters
            'durationValue': leg['duration']['value'], // in seconds
            'viaApi': true,
          };
        }
      }
      
      // If API call fails, fall back to straight-line distance
      return _getFallbackDistanceInfo(origin, destination);
    } catch (e) {
      print('Error calculating distance: $e');
      return _getFallbackDistanceInfo(origin, destination);
    }
  }

  static Map<String, dynamic> _getFallbackDistanceInfo(LatLng origin, LatLng destination) {
    final distance = calculateStraightLineDistance(origin, destination);
    final distanceKm = distance / 1000;
    
    // Estimate time based on average walking speed (5 km/h)
    final estimatedMinutes = (distanceKm / 5 * 60).round();
    
    return {
      'distance': '${distanceKm.toStringAsFixed(1)} km',
      'duration': '${estimatedMinutes} min',
      'distanceValue': distance.round(),
      'durationValue': estimatedMinutes * 60,
      'viaApi': false,
      'isEstimate': true,
    };
  }

  // Calculate straight-line distance (as crow flies)
  static double calculateStraightLineDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371000; // meters
    
    double lat1 = point1.latitude * pi / 180;
    double lon1 = point1.longitude * pi / 180;
    double lat2 = point2.latitude * pi / 180;
    double lon2 = point2.longitude * pi / 180;
    
    double dLat = lat2 - lat1;
    double dLon = lon2 - lon1;
    
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadius * c;
  }
}