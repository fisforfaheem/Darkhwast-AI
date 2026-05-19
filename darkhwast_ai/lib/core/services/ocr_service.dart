import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OCRService {
  final TextRecognizer _textRecognizer = TextRecognizer();

  Future<String> extractText(File imageFile) async {
    try {
      final InputImage inputImage = InputImage.fromFilePath(imageFile.path);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      
      // Preprocessing: Normalize whitespace and handle basic cleaning
      String result = recognizedText.text
          .replaceAll(RegExp(r'\n+'), '\n')
          .trim();
          
      return result;
    } catch (e) {
      return "OCR Error: ${e.toString()}";
    }
  }

  void dispose() {
    _textRecognizer.close();
  }
}
