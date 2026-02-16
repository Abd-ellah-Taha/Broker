/// API keys - use --dart-define or environment variables in production.
const String geminiApiKey = String.fromEnvironment(
  'GEMINI_API_KEY',
  defaultValue: '',
);
