import '../../core/config/app_config.dart';
import '../../core/constants/env.dart';
import '../../data/services/gemini_service.dart';
import '../../data/services/storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final storageServiceProvider = Provider<StorageService>((ref) => StorageService());

final geminiServiceProvider = Provider<GeminiService>((ref) => GeminiService(
      apiKey: geminiApiKey.isNotEmpty ? geminiApiKey : null,
    ));
