import 'dart:io';
import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../utils/image_capture_utils.dart';

class DocumentReviewScreen extends StatefulWidget {
  const DocumentReviewScreen({
    super.key,
    required this.imageFile,
    this.initialCropNormalized,
  });

  final File imageFile;
  final Rect? initialCropNormalized;

  @override
  State<DocumentReviewScreen> createState() => _DocumentReviewScreenState();
}

class _DocumentReviewScreenState extends State<DocumentReviewScreen> {
  final _cropController = CropController();
  Uint8List? _imageBytes;
  bool _isCropping = false;
  String? _error;
  CropStatus _cropStatus = CropStatus.loading;

  bool get _cropEditorReady =>
      _imageBytes != null && _cropStatus == CropStatus.ready;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    setState(() {
      _error = null;
      _cropStatus = CropStatus.loading;
    });
    try {
      final raw = await widget.imageFile.readAsBytes();
      final bytes = await normalizeImageBytes(raw);
      if (!mounted) return;
      setState(() {
        _imageBytes = bytes;
        _cropStatus = CropStatus.loading;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _cropStatus = CropStatus.nothing;
        });
      }
    }
  }

  Future<void> _confirmCrop() async {
    if (!_cropEditorReady || _isCropping) return;
    setState(() => _isCropping = true);
    try {
      _cropController.crop();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isCropping = false;
        _error = 'Crop tayyar nahi — poori photo use karen.';
      });
    }
  }

  Future<void> _useFullImage() async {
    try {
      final out = await normalizeImageFile(widget.imageFile);
      if (!mounted) return;
      context.pop(out.path);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
  }

  void _onCropStatusChanged(CropStatus status) {
    if (!mounted) return;
    setState(() => _cropStatus = status);
    if (status == CropStatus.ready) {
      setState(() => _isCropping = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final initial =
        widget.initialCropNormalized ??
        const Rect.fromLTWH(0.08, 0.12, 0.84, 0.7);
    final aspect = (initial.width / initial.height).clamp(0.4, 2.5);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          'Photo theek hai?',
          style: AppTextStyles.title.copyWith(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : _imageBytes == null
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.accent),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16),
                    child: Crop(
                      key: ValueKey(_imageBytes!.length),
                      image: _imageBytes!,
                      controller: _cropController,
                      onStatusChanged: _onCropStatusChanged,
                      progressIndicator: const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.accent,
                        ),
                      ),
                      initialRectBuilder: InitialRectBuilder.withSizeAndRatio(
                        size: 0.88,
                        aspectRatio: aspect,
                      ),
                      aspectRatio: aspect,
                      withCircleUi: false,
                      baseColor: Colors.black,
                      maskColor: Colors.black.withValues(alpha: 0.55),
                      interactive: true,
                      onCropped: (result) async {
                        switch (result) {
                          case CropSuccess(:final croppedImage):
                            try {
                              final dir = widget.imageFile.parent;
                              final out = File(
                                '${dir.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.jpg',
                              );
                              await out.writeAsBytes(croppedImage);
                              if (!context.mounted) return;
                              context.pop(out.path);
                            } catch (e) {
                              if (!mounted) return;
                              setState(() {
                                _isCropping = false;
                                _error = e.toString();
                              });
                            }
                          case CropFailure(:final cause):
                            if (!mounted) return;
                            setState(() {
                              _isCropping = false;
                              _error =
                                  'Crop fail: $cause — "Poori photo" try karen.';
                            });
                        }
                      },
                    ),
                  ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Column(
                children: [
                  Text(
                    _cropEditorReady
                        ? 'Document ko crop adjust karen, phir confirm karen'
                        : 'Photo load ho rahi hai...',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white60,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isCropping ? null : () => context.pop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white70,
                            side: const BorderSide(color: Colors.white38),
                          ),
                          child: const Text('Retake'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: _cropEditorReady && !_isCropping
                              ? _confirmCrop
                              : null,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            foregroundColor: AppColors.primary,
                          ),
                          child: _isCropping
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                  ),
                                )
                              : const Text('Use photo'),
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: _isCropping ? null : _useFullImage,
                    child: const Text(
                      'Poori photo use karen (crop skip)',
                      style: TextStyle(color: Colors.white54),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
