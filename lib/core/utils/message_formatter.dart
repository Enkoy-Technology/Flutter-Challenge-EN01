class MessageFormatter {
  /// Truncates a message to a specified length for preview
  static String truncateMessage(String message, {int maxLength = 50}) {
    if (message.length <= maxLength) {
      return message;
    }
    return '${message.substring(0, maxLength)}...';
  }
  
  /// Formats a message based on its type
  static String formatMessagePreview(String message, String messageType) {
    switch (messageType) {
      case 'image':
        return '📷 Photo';
      case 'video':
        return '🎥 Video';
      case 'text':
      default:
        return truncateMessage(message);
    }
  }
  
  /// Validates if a message is not empty
  static bool isValidMessage(String message) {
    return message.trim().isNotEmpty;
  }
  
  /// Sanitizes a message by trimming whitespace
  static String sanitizeMessage(String message) {
    return message.trim();
  }
}

