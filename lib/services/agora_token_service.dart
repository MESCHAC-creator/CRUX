import 'package:agora_token/agora_token.dart';

class AgoraTokenService {
  // Votre App ID
  static const String APP_ID = '729bb936e5084d53897e43c58ee8e946';
  
  // IMPORTANT: En production, cette clé doit être sur un serveur sécurisé
  // Pour le test, on va la laisser vide (APP ID only mode)
  static const String APP_CERTIFICATE = '';

  static Future<String> generateToken(
    String channelName, {
    int uid = 0,
    int expireTime = 3600, // 1 heure
  }) async {
    try {
      print('🔐 Generating token for channel: $channelName');

      final token = AgoraToken.buildTokenWithUid(
        appId: APP_ID,
        appCertificate: APP_CERTIFICATE,
        channelName: channelName,
        uid: uid,
        role: Role.publisher, // Publisher = broadcaster
        privilegeExpiredSecond: expireTime,
      );

      print('✅ Token generated successfully');
      return token;
    } catch (e) {
      print('❌ Error generating token: $e');
      rethrow;
    }
  }
}
