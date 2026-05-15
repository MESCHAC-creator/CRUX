class AgoraTokenService {
  static const String APP_ID = '729bb936e5084d53897e43c58ee8e946';

  static Future<String> generateToken(
    String channelName, {
    int uid = 0,
  }) async {
    try {
      print('🔐 Generating token for channel: $channelName');
      
      // APP ID only mode = pas besoin de token
      // Juste une chaîne vide
      const String token = '';
      
      print('✅ Token generated (APP ID only mode)');
      return token;
    } catch (e) {
      print('❌ Error: $e');
      rethrow;
    }
  }
}
