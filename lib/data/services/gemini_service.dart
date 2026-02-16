import 'package:image_picker/image_picker.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

/// Gemini API for image analysis and AI-generated property descriptions.
class GeminiService {
  GeminiService({String? apiKey}) : _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey ?? '',
      );

  final GenerativeModel _model;

  /// Generate a property description from an image.
  Future<String> generateDescriptionFromImage(XFile imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final content = [
      Content.multi([
        TextPart(
          'Analyze this real estate property image and write a concise, '
          'professional description (2-4 sentences) suitable for a listing. '
          'Mention: type of property, key features, condition, and appeal. '
          'Write in English.',
        ),
        DataPart('image/jpeg', bytes),
      ]),
    ];
    final response = await _model.generateContent(content);
    return response.text ?? 'No description generated.';
  }

  /// Generate a property description from multiple images.
  Future<String> generateDescriptionFromImages(List<XFile> images) async {
    if (images.isEmpty) return '';
    return generateDescriptionFromImage(images.first);
  }

  /// Moderate chat message for safety (e.g. detect inappropriate content).
  Future<bool> isMessageSafe(String message) async {
    final response = await _model.generateContent([
      Content.text(
        'Reply with only YES or NO: Is this message appropriate for a '
        'professional real estate chat? No spam, no harassment, no scams. '
        'Message: "$message"',
      ),
    ]);
    final text = (response.text ?? '').toUpperCase();
    return text.contains('YES');
  }
}
