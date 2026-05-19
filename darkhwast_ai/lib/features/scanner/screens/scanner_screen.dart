import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/providers/service_providers.dart';

enum ScannerMode { camera, voice }

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key, this.initialMode});

  /// Optional: open directly in voice mode from home shortcuts.
  final ScannerMode? initialMode;

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  CameraController? _controller;
  bool _isInitialized = false;
  bool _isInitializing = true;
  String? _cameraError;
  ScannerMode _currentMode = ScannerMode.camera;
  final ImagePicker _picker = ImagePicker();

  bool _isListening = false;
  bool _voiceReady = false;
  String? _voiceError;
  String _transcription = '';
  bool _isReading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialMode == ScannerMode.voice) {
      _currentMode = ScannerMode.voice;
      WidgetsBinding.instance.addPostFrameCallback((_) => _startVoiceMode());
    } else {
      // Wait for layout so CameraPreview gets non-zero constraints (fixes
      // Android "Width is zero" / black texture).
      WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrapCamera());
    }
  }

  void _onCameraValueChanged() {
    if (!mounted || _controller == null) return;
    final ready = _controller!.value.isInitialized &&
        _controller!.value.previewSize != null;
    if (ready != _isInitialized) {
      setState(() => _isInitialized = ready);
    }
  }

  Future<void> _bootstrapCamera() async {
    await _controller?.dispose();
    _controller = null;

    if (!mounted) return;
    setState(() {
      _isInitialized = false;
      _isInitializing = true;
      _cameraError = null;
    });

    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (!mounted) return;
      setState(() {
        _isInitializing = false;
        _cameraError =
            'Camera permission denied. Neeche capture dabayen ya gallery use karen.';
      });
      return;
    }

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw CameraException('no_camera', 'No camera found on this device');
      }

      final camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      controller.addListener(_onCameraValueChanged);
      await controller.initialize();

      if (!mounted) {
        controller.removeListener(_onCameraValueChanged);
        await controller.dispose();
        return;
      }

      _controller = controller;
      final previewReady = controller.value.previewSize != null;
      setState(() {
        _isInitialized = previewReady;
        _isInitializing = false;
        _cameraError = previewReady
            ? null
            : 'Preview load ho raha hai — capture button ab bhi kaam karega.';
      });
    } catch (e) {
      debugPrint('Camera init error: $e');
      if (!mounted) return;
      setState(() {
        _isInitializing = false;
        _isInitialized = false;
        _cameraError =
            'Live preview nahi chal saka. Neeche capture dabayen — camera khul jayega.';
      });
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_onCameraValueChanged);
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _captureImage() async {
    if (_controller != null && _controller!.value.isInitialized) {
      try {
        final image = await _controller!.takePicture();
        await _processImage(File(image.path));
        return;
      } catch (e) {
        debugPrint('Camera capture error: $e');
      }
    }

    // Fallback: native camera sheet (works on simulator / when preview fails)
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (image != null) {
      await _processImage(File(image.path));
    }
  }

  Future<void> _pickFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image != null) {
      await _processImage(File(image.path));
    }
  }

  Future<void> _processImage(File file) async {
    setState(() => _isReading = true);

    final ocrService = ref.read(ocrServiceProvider);
    final text = await ocrService.extractText(file);

    if (!mounted) return;
    setState(() => _isReading = false);

    context.push('/agent-trace', extra: {
      'file': file,
      'voiceText': text,
    });
  }

  Future<void> _startVoiceMode() async {
    final mic = await Permission.microphone.request();
    if (!mic.isGranted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Microphone ki ijazat voice input ke liye zaroori hai.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _currentMode = ScannerMode.voice;
      _isListening = false;
      _voiceReady = false;
      _voiceError = null;
      _transcription = '';
    });

    final voiceService = ref.read(voiceServiceProvider);
    final ok = await voiceService.init();
    if (!mounted) return;

    if (!ok) {
      setState(() {
        _voiceError = voiceService.lastError ??
            'Voice recognition is not available on this device.';
        _currentMode = ScannerMode.camera;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_voiceError!)),
      );
      return;
    }

    final started = await voiceService.startListening(
      onResult: (text, isFinal) {
        if (!mounted) return;
        setState(() {
          _transcription = text;
          if (isFinal && text.trim().isNotEmpty) {
            _isListening = false;
          }
        });
      },
    );

    if (!mounted) return;

    if (!started) {
      setState(() {
        _voiceError = voiceService.lastError ?? 'Microphone start nahi hua.';
        _currentMode = ScannerMode.camera;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_voiceError!)),
      );
      return;
    }

    setState(() {
      _isListening = true;
      _voiceReady = true;
    });
  }

  Future<void> _stopVoiceMode() async {
    final voiceService = ref.read(voiceServiceProvider);
    final lastWords = await voiceService.stopListening();
    final text =
        (_transcription.trim().isNotEmpty ? _transcription : lastWords ?? '')
            .trim();

    if (text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kuch sunai nahi diya. Dobara koshish karen.'),
          ),
        );
        setState(() {
          _isListening = false;
          _voiceReady = false;
          _currentMode = ScannerMode.camera;
        });
      }
      return;
    }

    setState(() {
      _isListening = false;
      _isReading = true;
    });

    if (!mounted) return;
    setState(() => _isReading = false);

    context.push('/agent-trace', extra: {
      'voiceText': text,
    });
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_currentMode == ScannerMode.camera)
            _buildCameraLayer()
          else
            const ColoredBox(color: Colors.black),
          if (_currentMode == ScannerMode.camera &&
              (_isInitialized || _isInitializing))
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(painter: ScannerOverlayPainter()),
              ),
            ),
          // Top bar floats over full-bleed preview (no SafeArea shrink on camera).
          Positioned(
            top: topInset,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                  ),
                  const Spacer(),
                  if (_currentMode == ScannerMode.camera &&
                      _controller != null &&
                      _isInitialized)
                    IconButton(
                      onPressed: () async {
                        final mode = _controller!.value.flashMode;
                        await _controller!.setFlashMode(
                          mode == FlashMode.off
                              ? FlashMode.torch
                              : FlashMode.off,
                        );
                        if (mounted) setState(() {});
                      },
                      icon: Icon(
                        _controller!.value.flashMode == FlashMode.torch
                            ? Icons.flash_on_rounded
                            : Icons.flash_off_rounded,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
          ),
          _buildBottomControls(),
          if (_isReading) _buildProcessingOverlay(),
        ],
      ),
    );
  }

  Widget _buildCameraLayer() {
    if (_controller != null && _controller!.value.isInitialized) {
      return Positioned.fill(
        child: _FullscreenCameraPreview(controller: _controller!),
      );
    }

    return Positioned.fill(
      child: Container(
        color: const Color(0xFF111111),
        padding: const EdgeInsets.fromLTRB(32, 100, 32, 160),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isInitializing)
              const CircularProgressIndicator(color: AppColors.accent)
            else
              const Icon(Icons.photo_camera_outlined,
                  color: Colors.white54, size: 64),
            const SizedBox(height: 24),
            Text(
              _isInitializing
                  ? 'Camera start ho raha hai...'
                  : (_cameraError ?? 'Camera tayyar nahi'),
              style: AppTextStyles.body.copyWith(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            if (!_isInitializing && _cameraError != null) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: _bootstrapCamera,
                child: const Text('Dobara koshish karen'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.85)
              ],
            ),
          ),
          child: _currentMode == ScannerMode.camera
              ? _buildCameraControls()
              : _buildVoiceControls(),
        ),
      ),
    );
  }

  Widget _buildCameraControls() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Bill ya notice ko frame ke andar rakhein',
          style: AppTextStyles.caption.copyWith(color: Colors.white70),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),
        GestureDetector(
          onTap: _isReading ? null : _captureImage,
          child: Container(
            width: 72,
            height: 72,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _ModeButton(
              icon: Icons.photo_library_outlined,
              label: 'Gallery',
              onTap: _isReading ? () {} : _pickFromGallery,
            ),
            _ModeButton(
              icon: Icons.mic_none_rounded,
              label: 'Voice',
              onTap: _isReading ? () {} : _startVoiceMode,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVoiceControls() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          _isListening ? Icons.mic_rounded : Icons.mic_off_rounded,
          color: _isListening ? AppColors.accent : Colors.white38,
          size: 40,
        ),
        const SizedBox(height: 12),
        Text(
          _isListening
              ? 'Boliye — khatam hone par stop dabayen'
              : (_voiceReady ? 'Processing...' : 'Voice tayyar ho raha hai...'),
          style: AppTextStyles.caption.copyWith(color: Colors.white70),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Container(
          constraints: const BoxConstraints(minHeight: 80, maxHeight: 140),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white24),
          ),
          child: SingleChildScrollView(
            child: Text(
              _transcription.isEmpty
                  ? 'Masla yahan dikhega jab aap bolenge...'
                  : _transcription,
              style: AppTextStyles.body.copyWith(
                color: _transcription.isEmpty ? Colors.white38 : Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(height: 28),
        GestureDetector(
          onTap: _isReading || !_isListening ? null : _stopVoiceMode,
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: _isListening ? AppColors.urgent : Colors.white24,
              shape: BoxShape.circle,
            ),
            child:
                const Icon(Icons.stop_rounded, color: Colors.white, size: 36),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: _isReading
              ? null
              : () async {
                  await ref.read(voiceServiceProvider).cancel();
                  if (mounted) {
                    setState(() {
                      _currentMode = ScannerMode.camera;
                      _isListening = false;
                    });
                  }
                },
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      ],
    );
  }

  Widget _buildProcessingOverlay() {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.accent),
            const SizedBox(height: 20),
            Text(
              'Document parh rahe hain...',
              style: AppTextStyles.title.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full-bleed camera preview — scales to cover entire screen in portrait.
class _FullscreenCameraPreview extends StatelessWidget {
  const _FullscreenCameraPreview({required this.controller});

  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return const ColoredBox(color: Colors.black);
    }

    final screen = MediaQuery.sizeOf(context);
    final previewRatio = controller.value.aspectRatio;

    // BoxFit.cover math: scale until preview fills width AND height.
    var scale = screen.aspectRatio * previewRatio;
    if (scale < 1) scale = 1 / scale;

    return ColoredBox(
      color: Colors.black,
      child: SizedBox.expand(
        child: ClipRect(
          child: Transform.scale(
            scale: scale,
            alignment: Alignment.center,
            child: Center(
              child: AspectRatio(
                aspectRatio: previewRatio,
                child: CameraPreview(controller),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ModeButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 26),
            const SizedBox(height: 6),
            Text(label,
                style: AppTextStyles.caption.copyWith(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;

    // Viewfinder uses most of the screen between top bar and bottom controls.
    final topPad = size.height * 0.12;
    final bottomPad = size.height * 0.28;
    final frameHeight = size.height - topPad - bottomPad;
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, topPad + frameHeight / 2),
      width: size.width * 0.88,
      height: frameHeight.clamp(size.height * 0.45, size.height * 0.72),
    );

    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()
          ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(12))),
      ),
      paint,
    );

    final cornerPaint = Paint()
      ..color = AppColors.accent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    const cornerSize = 28.0;

    void drawCorner(Offset start, Offset corner, Offset end) {
      canvas.drawPath(
        Path()
          ..moveTo(start.dx, start.dy)
          ..lineTo(corner.dx, corner.dy)
          ..lineTo(end.dx, end.dy),
        cornerPaint,
      );
    }

    drawCorner(
      Offset(rect.left, rect.top + cornerSize),
      rect.topLeft,
      Offset(rect.left + cornerSize, rect.top),
    );
    drawCorner(
      Offset(rect.right - cornerSize, rect.top),
      rect.topRight,
      Offset(rect.right, rect.top + cornerSize),
    );
    drawCorner(
      Offset(rect.left, rect.bottom - cornerSize),
      rect.bottomLeft,
      Offset(rect.left + cornerSize, rect.bottom),
    );
    drawCorner(
      Offset(rect.right - cornerSize, rect.bottom),
      rect.bottomRight,
      Offset(rect.right, rect.bottom - cornerSize),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
