/// Regex filter to mask phone numbers and external links in chat.
class ChatMessageFilter {
  static final _phoneRegex = RegExp(
    r'(\+?20)?[0-9]{10,11}|01[0-2]\d{8}',
  );
  static final _linkRegex = RegExp(
    r'https?://[^\s]+|www\.[^\s]+',
    caseSensitive: false,
  );

  /// Mask phone numbers and links before sending/storing.
  static String mask(String text) {
    var result = text;
    result = result.replaceAllMapped(_phoneRegex, (_) => '[PHONE]');
    result = result.replaceAllMapped(_linkRegex, (_) => '[LINK]');
    return result;
  }
}
