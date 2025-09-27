// config/maps_config.dart
import 'dart:convert';
import 'package:flutter/services.dart';

class MapsConfig {
  // For development - you can set your API key here or use the one from AndroidManifest
  static const String mapsApiKey = 'AIzaSyDGqo90jXmdeeNQ98YkUF8A9C4cpLzdRrM';

  // Check if we have a valid API key
  static bool get hasApiKey => mapsApiKey.isNotEmpty && mapsApiKey != 'AIzaSyDGqo90jXmdeeNQ98YkUF8A9C4cpLzdRrM';
}