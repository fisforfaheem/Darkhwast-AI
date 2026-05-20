import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/demo/demo_scenario_catalog.dart';
import '../../../core/providers/demo_provider.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/services/native_camera_capture.dart';
import '../utils/image_capture_utils.dart';
import '../widgets/camera_permission_dialog.dart';
import '../widgets/voice_waveform.dart';

enum ScannerMode { camera, voice }

/// Default crop hint for document review (not tied to a fake viewfinder).
const _defaultReviewCrop = Rect.fromLTWH(0.08, 0.12, 0.84, 0.7);

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key, this.initialMode, this.demoLaunch});

  final ScannerMode? initialMode;
  final DemoScanLaunch? demoLaunch;

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  bool _cameraGranted = false;
  bool _checkingPermission = true;
  String? _cameraError;
  ScannerMode _currentMode = ScannerMode.camera;
  final ImagePicker _picker = ImagePicker();

  /// Shown when user cancels native camera or on demo picker (no fake viewfinder).
  bool _showCaptureHub = false;

  bool _isListening = false;
  bool _isSubmittingVoice = false;
  String? _voiceError;
  String _transcription = '';
  bool _isReading = false;
  bool _isCapturing = false;
  bool _autoCameraAttempted = false;
  Timer? _voiceFinalizeTimer;
  bool _voiceStopInFlight = false;

  DemoScenario? get _demoScenario =>
      DemoScenarioCatalog.byId(widget.demoLaunch?.scenarioId ?? '');

  bool get _isDemo => widget.demoLaunch != null;

  @override
  void dispose() {
    _voiceFinalizeTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.demoLaunch != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _initDemoLaunch());
    } else if (widget.initialMode == ScannerMode.voice) {
      _currentMode = ScannerMode.voice;
      WidgetsBinding.instance.addPostFrameCallback((_) => _startVoiceMode());
    } else {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _launchNativeCameraFlow(),
      );
    }
  }

  Future<void> _initDemoLaunch() async {
    final launch = widget.demoLaunch!;
    await ref
        .read(demoScenarioProvider.notifier)
        .setScenario(launch.scenarioId);
    if (!mounted) return;
    await _ensureCameraAccess();
    if (!mounted) return;
    setState(() => _showCaptureHub = true);
  }

  /// Opens the device camera immediately — no intermediate viewfinder UI.
  Future<void> _launchNativeCameraFlow() async {
    if (_autoCameraAttempted) return;
    _autoCameraAttempted = true;

    await _ensureCameraAccess();
    if (!mounted) return;

    if (!_cameraGranted) {
      setState(() => _showCaptureHub = true);
      return;
    }

    final captured = await _captureFromNativeCamera();
    if (!mounted) return;

    if (!captured) {
      setState(() => _showCaptureHub = true);
    }
  }

  Future<void> _ensureCameraAccess() async {
    setState(() {
      _checkingPermission = true;
      _cameraError = null;
    });

    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
    }

    if (!status.isGranted && mounted) {
      final permanentlyDenied = status.isPermanentlyDenied;
      final retry = await showCameraPermissionDialog(
        context,
        permanentlyDenied: permanentlyDenied,
      );
      if (!mounted) return;
      if (retry) {
        status = permanentlyDenied
            ? await Permission.camera.status
            : await Permission.camera.request();
      }
    }

    if (!mounted) return;
    setState(() {
      _checkingPermission = false;
      _cameraGranted = status.isGranted;
      _cameraError = status.isGranted
          ? null
          : 'Camera band hai. Gallery se photo chunain ya Settings se ijazat den.';
    });
  }

  Future<void> _continueDemoWithImage(File file) async {
    final scenario = _demoScenario;
    if (scenario == null) return;
    setState(() => _isReading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _isReading = false);
    context.push(
      '/agent-trace',
      extra: {'file': file, 'voiceText': scenario.demoOcrText},
    );
  }

  Future<void> _openReview(File file) async {
    final path = await context.push<String>(
      '/document-review',
      extra: {'file': file, 'crop': _defaultReviewCrop},
    );
    if (path != null && mounted) {
      await _processImage(File(path));
    } else if (mounted && _currentMode == ScannerMode.camera) {
      setState(() => _showCaptureHub = true);
    }
  }

  /// Returns true if a photo was taken and handed to review.
  Future<bool> _captureFromNativeCamera() async {
    if (_isCapturing || _isReading) return false;

    if (!_cameraGranted) {
      await _ensureCameraAccess();
      if (!_cameraGranted) return false;
    }

    setState(() => _isCapturing = true);
    try {
      final path = await NativeCameraCapture.capture();
      if (path == null || !mounted) return false;

      final normalized = await normalizeImageFile(File(path));
      await _openReview(normalized);
      return true;
    } catch (e) {
      debugPrint('Camera capture error: $e');
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Photo nahi li ja saki. Gallery se chunain.'),
        ),
      );
      return false;
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  Future<void> _pickFromGallery() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 95,
    );
    if (image == null || !mounted) return;
    final normalized = await normalizeImageFile(File(image.path));
    await _openReview(normalized);
  }

  Future<void> _openUploadSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Document upload',
                style: AppTextStyles.headline.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Gallery se bill ya notice ki photo chunain',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(
                  Icons.photo_library_outlined,
                  color: AppColors.primary,
                ),
                title: const Text('Gallery se chunain'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickFromGallery();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _processImage(File file) async {
    if (widget.demoLaunch != null && _demoScenario != null) {
      await _continueDemoWithImage(file);
      return;
    }

    setState(() => _isReading = true);

    final ocrService = ref.read(ocrServiceProvider);
    final text = await ocrService.extractText(file);

    if (!mounted) return;
    setState(() => _isReading = false);

    context.push('/agent-trace', extra: {'file': file, 'voiceText': text});
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
      _showCaptureHub = false;
      _isListening = false;
      _isSubmittingVoice = false;
      _voiceError = null;
      _transcription = '';
    });

    final voiceService = ref.read(voiceServiceProvider);
    voiceService.onStatus = _onSpeechStatus;
    final ok = await voiceService.init();
    if (!mounted) return;

    if (!ok) {
      setState(() {
        _voiceError =
            voiceService.lastError ??
            'Voice recognition is not available on this device.';
        _currentMode = ScannerMode.camera;
        _showCaptureHub = true;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_voiceError!)));
      return;
    }

    final started = await voiceService.startListening(
      onResult: (text, isFinal) {
        if (!mounted) return;
        setState(() => _transcription = text);
        if (isFinal && text.trim().isNotEmpty) {
          _scheduleVoiceFinish(delayMs: 400);
        }
      },
    );

    if (!mounted) return;

    if (!started) {
      setState(() {
        _voiceError = voiceService.lastError ?? 'Microphone start nahi hua.';
        _currentMode = ScannerMode.camera;
        _showCaptureHub = true;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_voiceError!)));
      return;
    }

    setState(() => _isListening = true);
  }

  void _onSpeechStatus(String status) {
    if (status == 'done' ||
        status == 'notListening' ||
        status == 'doneNoResult') {
      _scheduleVoiceFinish(delayMs: 500);
    }
  }

  void _scheduleVoiceFinish({int delayMs = 800}) {
    if (_voiceStopInFlight || _isSubmittingVoice) return;
    _voiceFinalizeTimer?.cancel();
    _voiceFinalizeTimer = Timer(Duration(milliseconds: delayMs), () {
      if (mounted && _currentMode == ScannerMode.voice) {
        unawaited(_stopVoiceMode());
      }
    });
  }

  Future<void> _stopVoiceMode() async {
    if (_voiceStopInFlight) return;
    _voiceStopInFlight = true;
    _voiceFinalizeTimer?.cancel();

    if (mounted) {
      setState(() {
        _isListening = false;
        _isSubmittingVoice = true;
      });
    }

    final voiceService = ref.read(voiceServiceProvider);
    String? lastWords;
    try {
      lastWords = await voiceService.stopListening();
    } catch (e) {
      debugPrint('stopListening failed: $e');
      await voiceService.cancel();
    }

    final text =
        (_transcription.trim().isNotEmpty ? _transcription : lastWords ?? '')
            .trim();

    if (!mounted) {
      _voiceStopInFlight = false;
      return;
    }

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kuch sunai nahi diya. Dobara koshish karen.'),
        ),
      );
      setState(() {
        _isSubmittingVoice = false;
        _currentMode = ScannerMode.camera;
        _showCaptureHub = true;
      });
      _voiceStopInFlight = false;
      return;
    }

    await context.push('/agent-trace', extra: {'voiceText': text});

    if (!mounted) {
      _voiceStopInFlight = false;
      return;
    }

    setState(() {
      _isSubmittingVoice = false;
      _currentMode = ScannerMode.camera;
      _showCaptureHub = true;
      _transcription = '';
    });
    _voiceStopInFlight = false;
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_currentMode == ScannerMode.camera)
            _buildCameraBody(padding)
          else
            _buildVoiceBody(padding),
          if (widget.demoLaunch != null &&
              _demoScenario != null &&
              _currentMode == ScannerMode.camera)
            Positioned(
              left: 16,
              right: 16,
              top: padding.top + 56 + 8,
              child: _DemoScenarioBanner(scenario: _demoScenario!),
            ),
          if (_currentMode == ScannerMode.camera) _buildBottomControls(),
          if (_isReading || _isCapturing || _isSubmittingVoice)
            _buildProcessingOverlay(),
        ],
      ),
    );
  }

  Widget _buildCameraBody(EdgeInsets padding) {
    if (!_showCaptureHub && (_checkingPermission || _isCapturing)) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.accent),
            const SizedBox(height: 20),
            Text(
              _isCapturing
                  ? 'Camera khul raha hai...'
                  : 'Camera tayyar ho raha hai...',
              style: AppTextStyles.body.copyWith(color: Colors.white70),
            ),
          ],
        ),
      );
    }

    return _buildCaptureHub(padding);
  }

  Widget _buildCaptureHub(EdgeInsets padding) {
    final ready = _cameraGranted && !_checkingPermission;

    return Column(
      children: [
        SizedBox(height: padding.top + 8),
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            onPressed: _isReading ? null : () => context.pop(),
            icon: const Icon(Icons.close_rounded, color: Colors.white),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  ready
                      ? Icons.document_scanner_outlined
                      : Icons.no_photography_outlined,
                  size: 72,
                  color: Colors.white54,
                ),
                const SizedBox(height: 24),
                Text(
                  _isDemo
                      ? 'Curated demo — document ki photo len'
                      : 'Bill ya notice ki photo len',
                  style: AppTextStyles.title.copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  ready
                      ? 'Neeche shutter dabayen — seedha phone camera khulega'
                      : (_cameraError ??
                            'Camera ijazat chahiye ya gallery se photo chunain'),
                  style: AppTextStyles.body.copyWith(color: Colors.white60),
                  textAlign: TextAlign.center,
                ),
                if (_cameraError != null) ...[
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _ensureCameraAccess,
                    child: const Text('Ijazat dubara mangen'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
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
              colors: [Colors.transparent, Colors.black.withValues(alpha: 0.9)],
            ),
          ),
          child: _buildCameraControls(),
        ),
      ),
    );
  }

  Widget _buildCameraControls() {
    final ready = _cameraGranted && !_checkingPermission && !_isCapturing;
    final demo = _isDemo;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          demo
              ? 'Shutter se photo len ya Gallery se bill chunain'
              : 'Shutter — native camera turant khulega',
          style: AppTextStyles.caption.copyWith(color: Colors.white70),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: ready && !_isReading ? _captureFromNativeCamera : null,
          child: Container(
            width: 70,
            height: 70,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: ready ? AppColors.accent : Colors.white38,
                width: 3,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: ready ? AppColors.accent : Colors.white24,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _ModeButton(
              icon: Icons.photo_library_outlined,
              label: 'Upload',
              onTap: _isReading ? () {} : _openUploadSheet,
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

  Widget _buildVoiceBody(EdgeInsets padding) {
    return Padding(
      padding: EdgeInsets.only(top: padding.top),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: _isReading ? null : () => context.pop(),
              icon: const Icon(Icons.close_rounded, color: Colors.white),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 200),
              child: _buildVoiceControls(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceControls() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        VoiceWaveform(isActive: _isListening),
        const SizedBox(height: 16),
        Text(
          _isSubmittingVoice
              ? 'Agents shuru ho rahe hain...'
              : _isListening
              ? 'Bol rahe hain — khatam par stop dabayen'
              : 'Microphone tayyar ho raha hai...',
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
          onTap: _isSubmittingVoice || _isReading ? null : _stopVoiceMode,
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: _isListening || _transcription.isNotEmpty
                  ? AppColors.urgent
                  : Colors.white24,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.stop_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: _isSubmittingVoice || _isReading
              ? null
              : () async {
                  _voiceFinalizeTimer?.cancel();
                  _voiceStopInFlight = false;
                  await ref.read(voiceServiceProvider).cancel();
                  if (mounted) {
                    setState(() {
                      _currentMode = ScannerMode.camera;
                      _isListening = false;
                      _isSubmittingVoice = false;
                      _showCaptureHub = true;
                      _transcription = '';
                    });
                  }
                },
          child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
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
              _isCapturing
                  ? 'Camera khul raha hai...'
                  : _isSubmittingVoice
                  ? 'Voice se agents chal rahe hain...'
                  : 'Document parh rahe hain...',
              style: AppTextStyles.title.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _DemoScenarioBanner extends StatelessWidget {
  const _DemoScenarioBanner({required this.scenario});

  final DemoScenario scenario;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(scenario.icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Curated demo: ${scenario.titleUrdu}',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

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
            Text(
              label,
              style: AppTextStyles.caption.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
