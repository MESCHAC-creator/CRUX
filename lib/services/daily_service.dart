class DailyService {
  static const String SUBDOMAIN = 'crux';

  // Utiliser une room statique pour les tests
  static Future<String?> getRoom(String roomName) async {
    try {
      print('🔍 Getting Daily room: $roomName');

      // Pour les tests, utiliser directement l'URL de la room
      final roomUrl = 'https://$SUBDOMAIN.daily.co/$roomName';
      
      print('✅ Room URL: $roomUrl');
      return roomUrl;
    } catch (e) {
      print('❌ Error: $e');
      return null;
    }
  }

  // Créer une room (optionnel)
  static Future<String?> createRoom(String roomName) async {
    try {
      print('🔐 Creating Daily room: $roomName');

      final roomUrl = 'https://$SUBDOMAIN.daily.co/$roomName';
      print('✅ Room created: $roomUrl');
      return roomUrl;
    } catch (e) {
      print('❌ Error creating room: $e');
      return null;
    }
  }
}
