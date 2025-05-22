import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late List<CameraDescription> _cameras;
  CameraController? _controller;

  @override
  void initState() {
    super.initState();
    _initializeCameras();
  }

  Future<void> _initializeCameras() async {
    _cameras = await availableCameras();
    _controller = CameraController(_cameras[0], ResolutionPreset.max);
    await _controller!.initialize();
    if (mounted) setState(() {});
  }

  Future<void> _captureImage() async {
    final XFile file = await _controller!.takePicture();
    Navigator.pop(context, File(file.path));
  }


  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
  int _selectedCameraIdx = 0;

  void _switchCamera() async {
    final nextIndex = (_selectedCameraIdx + 1) % _cameras.length;
    _selectedCameraIdx = nextIndex;
    _controller = CameraController(
      _cameras[_selectedCameraIdx],
      ResolutionPreset.max,
    );
    await _controller!.initialize();
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
return Scaffold(
  backgroundColor: Colors.black,
  body: _controller?.value.isInitialized == true
      ? Stack(
          children: [
            CameraPreview(_controller!),
            Positioned(
                    top: 40,
                    left: 20,
                    child: IconButton(
                      icon: const Icon(
                        Icons.switch_camera,
                        color: Colors.white,
                      ),
                      onPressed: _switchCamera,
                    ),
                  ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: IconButton(
                  icon: const Icon(Icons.camera, color: Colors.white, size: 70),
                  onPressed: _captureImage,
                ),
              ),
            ),
          ],
        )
      : const Center(child: CircularProgressIndicator()),
);
  }
}
