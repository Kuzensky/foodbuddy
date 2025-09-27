import 'dart:convert';
import 'package:flutter/services.dart';

class MapsConfig {
  static const String _serviceAccountPath = 'assets/credentials/google-maps-service-account.json';

  static Map<String, dynamic>? _serviceAccountData;

  // Load the service account credentials
  static Future<Map<String, dynamic>?> getServiceAccountCredentials() async {
    if (_serviceAccountData != null) {
      return _serviceAccountData;
    }

    try {
      final String response = await rootBundle.loadString(_serviceAccountPath);
      _serviceAccountData = json.decode(response);
      return _serviceAccountData;
    } catch (e) {
      print('Error loading service account credentials: $e');
      return null;
    }
  }

  // Get project ID from service account
  static Future<String?> getProjectId() async {
    final credentials = await getServiceAccountCredentials();
    return credentials?['project_id'];
  }

  // Get client email from service account
  static Future<String?> getClientEmail() async {
    final credentials = await getServiceAccountCredentials();
    return credentials?['client_email'];
  }

  // For development purposes - you might want to add your Maps API key here
  static const String? mapsApiKey = null; // Add your API key if needed
}