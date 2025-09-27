// config/maps_config.dart
class MapsConfig {
  static const String mapsApiKey = "AIzaSyDWQVUEvHRih2jgyhAiclJyDFi7TgTVDI4";

  // Better validation
  static bool get hasApiKey {
    if (mapsApiKey.isEmpty) return false;
    if (mapsApiKey.contains('YOUR_')) return false;
    if (mapsApiKey.length < 30) return false; 
    return true;
  }
}