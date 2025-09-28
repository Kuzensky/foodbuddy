// services/distance_service.dart - UPDATED
import 'dart:math';
import 'package:latlong2/latlong.dart';

class DistanceService {

  // Straight-line distance fallback
  static double calculateStraightLineDistance(LatLng origin, LatLng destination) {
    const earthRadius = 6371000; // meters
    
    final lat1 = origin.latitude * pi / 180;
    final lon1 = origin.longitude * pi / 180;
    final lat2 = destination.latitude * pi / 180;
    final lon2 = destination.longitude * pi / 180;
    
    final dlat = lat2 - lat1;
    final dlon = lon2 - lon1;
    
    final a = sin(dlat / 2) * sin(dlat / 2) +
        cos(lat1) * cos(lat2) * sin(dlon / 2) * sin(dlon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadius * c;
  }

  static Future<Map<String, dynamic>?> calculateDistanceAndTime(
    LatLng origin,
    LatLng destination,
  ) async {
    // Always use fallback until APIs work
    return _getFallbackDistance(origin, destination);
    
    /* // Uncomment this when APIs are working
    if (!MapsConfig.hasApiKey) {
      return _getFallbackDistance(origin, destination);
    }

    try {
      final url = Uri.parse(
        '$_directionsUrl?origin=${origin.latitude},${origin.longitude}'
        '&destination=${destination.latitude},${destination.longitude}'
        '&mode=walking'
        '&key=${MapsConfig.mapsApiKey}'
      );

      print('🔍 API Call: Directions API');
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('📡 Response: ${data['status']}');
        
        if (data['status'] == 'OK') {
          final route = data['routes'][0];
          final leg = route['legs'][0];
          
          print('✅ Directions API success');
          return {
            'distance': leg['distance']['text'],
            'duration': leg['duration']['text'],
            'isEstimate': false,
          };
        } else {
          print('❌ Directions API error: ${data['status']}');
          return _getFallbackDistance(origin, destination);
        }
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        return _getFallbackDistance(origin, destination);
      }
    } catch (e) {
      print('❌ Network Error: $e');
      return _getFallbackDistance(origin, destination);
    }
    */
  }

  static Map<String, dynamic> _getFallbackDistance(LatLng origin, LatLng destination) {
    final distance = calculateStraightLineDistance(origin, destination);
    final km = distance / 1000;
    final walkingMinutes = (distance / 80).round(); // 80 meters per minute walking
    
    return {
      'distance': '${km.toStringAsFixed(1)} km',
      'duration': '$walkingMinutes min',
      'isEstimate': true,
    };
  }
}