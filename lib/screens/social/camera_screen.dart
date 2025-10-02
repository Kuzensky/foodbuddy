import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        _controller = CameraController(
          _cameras.first,
          ResolutionPreset.high,
          enableAudio: false,
        );
        await _controller!.initialize();
        if (mounted) {
          setState(() {
            _isInitialized = true;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to initialize camera: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    try {
      final XFile image = await _controller!.takePicture();
      if (mounted) {
        Navigator.of(context).pop(File(image.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to take picture: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Take Photo',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : !_isInitialized
              ? const Center(
                  child: Text(
                    'Camera not available',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                )
              : Stack(
                  children: [
                    // Camera preview
                    SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: CameraPreview(_controller!),
                    ),

                    // Camera controls
                    Positioned(
                      bottom: 50,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const SizedBox(width: 60), // Spacer

                          // Capture button
                          GestureDetector(
                            onTap: _takePicture,
                            child: Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                              child: const Icon(
                                Icons.camera,
                                color: Colors.white,
                                size: 35,
                              ),
                            ),
                          ),

                          // Switch camera button (if multiple cameras available)
                          if (_cameras.length > 1)
                            GestureDetector(
                              onTap: _switchCamera,
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black.withValues(alpha: 0.5),
                                ),
                                child: const Icon(
                                  Icons.flip_camera_ios,
                                  color: Colors.white,
                                  size: 25,
                                ),
                              ),
                            )
                          else
                            const SizedBox(width: 60), // Spacer
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;

    try {
      setState(() {
        _isInitialized = false;
      });

      await _controller?.dispose();

      // Switch to the other camera
      final currentIndex = _cameras.indexOf(_controller!.description);
      final nextIndex = (currentIndex + 1) % _cameras.length;

      _controller = CameraController(
        _cameras[nextIndex],
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to switch camera: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}