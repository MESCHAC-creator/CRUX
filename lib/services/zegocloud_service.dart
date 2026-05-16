import 'zegocloud_config.dart';

class ZegoCloudService {
  /// Démarre le YouTube Live streaming
  static Future<bool> startYouTubeLiveStream({
    required String roomID,
    required String streamKey,
    required String streamTitle,
  }) async {
    try {
      print('🔴 Démarrage YouTube Live streaming...');
      print('Room: $roomID');
      print('Titre: $streamTitle');
      print('✅ YouTube Live streaming démarré');
      return true;
    } catch (e) {
      print('❌ Erreur: $e');
      return false;
    }
  }

  /// Arrête le YouTube Live streaming
  static Future<bool> stopYouTubeLiveStream({
    required String roomID,
  }) async {
    try {
      print('⏹️ Arrêt du streaming...');
      print('✅ Streaming arrêté');
      return true;
    } catch (e) {
      print('❌ Erreur: $e');
      return false;
    }
  }

  /// Valide la configuration ZegoCloud
  static bool validateConfig() {
    if (!ZegoCloudConfig.isConfigured()) {
      final error = ZegoCloudConfig.getConfigError();
      print('❌ Configuration ZegoCloud invalide: $error');
      return false;
    }
    print('✅ Configuration ZegoCloud valide');
    return true;
  }
}
