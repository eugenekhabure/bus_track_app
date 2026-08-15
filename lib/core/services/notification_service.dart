// Stub – will be implemented with Firebase on mobile later
class NotificationService {
  static Future<String?> initialize() async {
    print('⚠️ Notification service disabled (web)');
    return null;
  }

  static Future<void> registerToken(String token) async {
    print('⚠️ Notification registerToken disabled');
  }

  static void listen() {}
}