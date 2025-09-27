// services/places_service.dart - UPDATED
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../config/maps_config.dart';

class PlacesService {
  static const String _placesUrl = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json';

  static Future<List<Map<String, dynamic>>> getNearbyRestaurants(
    LatLng location, {
    int radius = 2000,
  }) async {
    if (!MapsConfig.hasApiKey) {
      print('❌ API key not configured');
      return [];
    }

    try {
      final url = Uri.parse(
        '$_placesUrl?location=${location.latitude},${location.longitude}'
        '&radius=$radius'
        '&type=restaurant'
        '&key=${MapsConfig.mapsApiKey}'
      );

      print('🔍 API Call: Places API');
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('📡 Response: ${data['status']}');
        
        if (data['status'] == 'OK') {
          List<dynamic> results = data['results'] ?? [];
          print('✅ Success: Found ${results.length} restaurants');
          
          return _transformPlacesData(results);
        } else {
          _handleApiError(data, 'Places API');
          return [];
        }
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Network Error: $e');
      return [];
    }
  }

  static List<Map<String, dynamic>> _transformPlacesData(List<dynamic> results) {
    return results.map<Map<String, dynamic>>((result) {
      final location = result['geometry']['location'];
      
      return {
        'id': result['place_id'],
        'name': result['name'] ?? 'Unknown Restaurant',
        'address': result['vicinity'] ?? '',
        'latitude': location['lat'],
        'longitude': location['lng'],
        'rating': (result['rating'] ?? 0.0).toDouble(),
        'priceRange': _getPriceRange(result['price_level'] ?? 1),
        'cuisine': _getCuisineType(result['types'] ?? []),
        'isOpen': result['opening_hours']?['open_now'] ?? false,
      };
    }).toList();
  }

  static void _handleApiError(Map<String, dynamic> data, String apiName) {
    final status = data['status'];
    final errorMessage = data['error_message'] ?? 'No additional info';
    
    print('❌ $apiName Error: $status');
    print('💡 Error Message: $errorMessage');
    
    switch (status) {
      case 'REQUEST_DENIED':
        print('🚨 Possible causes:');
        print('   - API not enabled in Google Cloud Console');
        print('   - API key restrictions too strict');
        print('   - Billing not set up or suspended');
        print('   - Project not linked to billing account');
        break;
      case 'OVER_QUERY_LIMIT':
        print('💡 Quota exceeded - check billing account');
        break;
      case 'ZERO_RESULTS':
        print('💡 No results found for this location');
        break;
      default:
        print('💡 Check API configuration in Google Cloud Console');
    }
  }

  static String _getPriceRange(int priceLevel) {
    switch (priceLevel) {
      case 1: return '₱';
      case 2: return '₱₱';
      case 3: return '₱₱₱';
      case 4: return '₱₱₱₱';
      default: return '₱';
    }
  }

  static String _getCuisineType(List<dynamic> types) {
    for (var type in types) {
      String typeStr = type.toString().toLowerCase();
      if (typeStr.contains('italian')) return 'Italian';
      if (typeStr.contains('mexican')) return 'Mexican';
      if (typeStr.contains('chinese')) return 'Chinese';
      if (typeStr.contains('japanese')) return 'Japanese';
      if (typeStr.contains('filipino')) return 'Filipino';
    }
    return 'Restaurant';
  }
}