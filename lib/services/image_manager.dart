import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class ImageManager {
  static const List<String> _demoImages = [
    'assets/demo_images/picture-1.jpg',
    'assets/demo_images/picture-2.jpg',
    'assets/demo_images/picture-3.jpg',
    'assets/demo_images/picture-4.jpg',
    'assets/demo_images/picture-5.jpg',
    'assets/demo_images/picture-6.jpg',
    'assets/demo_images/picture-7.jpg',
    'assets/demo_images/picture-8.jpg',
    'assets/demo_images/picture-9.jpg',
    'assets/demo_images/picture-10.jpg',
    'assets/demo_images/picture-11.jpg',
    'assets/demo_images/picture-12.jpg',
    'assets/demo_images/picture-13.jpg',
    'assets/demo_images/picture-14.jpg',
    'assets/demo_images/picture-15.jpg',
    'assets/demo_images/picture-16.jpg',
    'assets/demo_images/picture-17.jpg',
    'assets/demo_images/picture-18.jpg',
    'assets/demo_images/picture-19.jpg',
    'assets/demo_images/picture-20.jpg',
    'assets/demo_images/picture-21.jpg',
    'assets/demo_images/picture-22.jpg',
    'assets/demo_images/picture-23.jpg',
    'assets/demo_images/picture-24.jpg',
    'assets/demo_images/picture-25.jpg',
    'assets/demo_images/picture-26.jpg',
    'assets/demo_images/picture-27.jpg',
    'assets/demo_images/picture-28.jpg',
    'assets/demo_images/picture-29.jpg',
    'assets/demo_images/picture-30.jpg',
    'assets/demo_images/picture-31.jpg',
    'assets/demo_images/picture-32.jpg',
    'assets/demo_images/picture-33.jpg',
    'assets/demo_images/picture-34.jpg',
    'assets/demo_images/picture-35.jpg',
    'assets/demo_images/picture-36.jpg',
    'assets/demo_images/picture-37.jpg',
    'assets/demo_images/picture-38.jpg',
    'assets/demo_images/picture-39.jpg',
    'assets/demo_images/picture-40.jpg',
    'assets/demo_images/picture-41.jpg',
    'assets/demo_images/picture-42.jpg',
    'assets/demo_images/picture-43.jpg',
    'assets/demo_images/picture-44.jpg',
    'assets/demo_images/picture-45.jpg',
    'assets/demo_images/picture-46.jpg',
  ];

  /// Check if we're running on emulator or in debug mode
  static bool get isDevelopmentMode {
    return kDebugMode;
  }

  /// Check if we should use demo images
  static bool get shouldUseDemoImages {
    // Use demo images in debug mode or when running on emulator
    return isDevelopmentMode;
  }

  /// Get all available demo images
  static List<String> get demoImages => _demoImages;

  /// Get a random demo image
  static String getRandomDemoImage() {
    final random = Random();
    return _demoImages[random.nextInt(_demoImages.length)];
  }

  /// Get demo image by index (for selection)
  static String getDemoImageByIndex(int index) {
    if (index >= 0 && index < _demoImages.length) {
      return _demoImages[index];
    }
    return _demoImages[0]; // Fallback to first image
  }

  /// Get the number of available demo images
  static int get demoImageCount => _demoImages.length;

  /// Check if an asset exists
  static Future<bool> assetExists(String assetPath) async {
    try {
      await rootBundle.load(assetPath);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Asset loading failed for $assetPath: $e');
      }
      return false;
    }
  }

  /// Test if demo images are properly loaded
  static Future<void> testAssetLoading() async {
    if (kDebugMode) {
      print('Testing demo image asset loading...');
      for (int i = 0; i < 5; i++) {
        final exists = await assetExists(_demoImages[i]);
        print('${_demoImages[i]}: ${exists ? 'OK' : 'FAILED'}');
      }
    }
  }

  /// Upload image to cloud storage (placeholder for production)
  static Future<String> uploadToCloud(File imageFile) async {
    // This will be implemented when we add Firebase Storage
    // For now, return a placeholder URL
    throw UnimplementedError('Cloud upload not implemented yet');
  }

  /// Main method to handle image selection based on environment
  static Future<String?> selectImage() async {
    if (shouldUseDemoImages) {
      // Return demo image for development
      return getRandomDemoImage();
    } else {
      // TODO: Implement real image picker + cloud upload for production
      throw UnimplementedError('Production image selection not implemented yet');
    }
  }

  /// Convert asset path to a URL-like format for consistent storage
  static String assetToUrl(String assetPath) {
    // Convert asset path to a consistent URL format
    return 'asset://$assetPath';
  }

  /// Check if a URL is an asset URL
  static bool isAssetUrl(String url) {
    return url.startsWith('asset://');
  }

  /// Extract asset path from asset URL
  static String assetUrlToPath(String assetUrl) {
    if (isAssetUrl(assetUrl)) {
      return assetUrl.substring(8); // Remove 'asset://' prefix
    }
    return assetUrl;
  }

  /// Get display-friendly name for demo images
  static String getDemoImageName(String assetPath) {
    final fileName = assetPath.split('/').last;
    final nameWithoutExtension = fileName.split('.').first;
    // Convert picture-1 to "Picture 1"
    return nameWithoutExtension
        .replaceAll('-', ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}