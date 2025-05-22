import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late List<CameraDescription> _cameras;
  CameraController? _controller;
  double _zoom = 1.0;
  double _minZoom = 1.0;
  double _maxZoom = 1.0;
  bool _isZoomSupported = false;


  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _initializeCameras();
  }

  Future<void> _initializeCameras() async {
    _minZoom = await _controller!.getMinZoomLevel();
    _maxZoom = await _controller!.getMaxZoomLevel();
    _isZoomSupported = _maxZoom > _minZoom;
    _zoom = _minZoom;
    await _controller!.setZoomLevel(_zoom);
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
  FlashMode _flashMode = FlashMode.off;

  void _toggleFlash() async {
    FlashMode next =
        _flashMode == FlashMode.off
            ? FlashMode.auto
            : _flashMode == FlashMode.auto
            ? FlashMode.always
            : FlashMode.off;
    await _controller!.setFlashMode(next);
    setState(() => _flashMode = next);
  }
  void _setZoom(double value) async {
    if (!_isZoomSupported) return;
    _zoom = value.clamp(_minZoom, _maxZoom);
    await _controller!.setZoomLevel(_zoom);
    setState(() {});
  }
  void _handleTap(TapDownDetails details, BoxConstraints constraints) {
    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    _controller?.setFocusPoint(offset);
    _controller?.setExposurePoint(offset);
  }



  IconData _flashIcon() {
    switch (_flashMode) {
      case FlashMode.auto:
        return Icons.flash_auto;
      case FlashMode.always:
        return Icons.flash_on;
      default:
        return Icons.flash_off;
    }
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
                  Positioned(
                    top: 40,
                    right: 20,
                    child: IconButton(
                      icon: Icon(_flashIcon(), color: Colors.white),
                      onPressed: _toggleFlash,
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
