import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/messaging/data/services/messaging_service.dart';

final messagingServiceProvider = Provider<MessagingService>((ref) {
  return MessagingService();
});