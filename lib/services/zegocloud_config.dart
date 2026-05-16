/// ZegoCloud Configuration
/// Credentials pour CRUX
/// 
/// AppID: 2042049519
/// AppSign: 6b31cd6a4b710f79fe96031c0e116b445dca5d9c385b976eadd8c3e7d3b79242

class ZegoCloudConfig {
  // ✅ CREDENTIALS ZEGOCLOUD - CRUX
  static const int APP_ID = 2042049519;
  static const String APP_SIGN =
      '6b31cd6a4b710f79fe96031c0e116b445dca5d9c385b976eadd8c3e7d3b79242';

  // Configuration app
  static const String APP_NAME = 'CRUX';

  // Endpoints
  static const String ZEGOCLOUD_URL = 'https://zegocloud.com';

  /// Valide que la configuration est complète
  static bool isConfigured() {
    return APP_ID != 0 && APP_SIGN.isNotEmpty && APP_SIGN.length > 20;
  }

  /// Retourne le message d'erreur si non configuré
  static String? getConfigError() {
    if (APP_ID == 0) {
      return '❌ ZegoCloud AppID manquant!\n\nAllez à zegocloud_config.dart et ajoutez votre AppID';
    }
    if (APP_SIGN.isEmpty) {
      return '❌ ZegoCloud AppSign manquant!\n\nAllez à zegocloud_config.dart et ajoutez votre AppSign';
    }
    if (APP_SIGN.length < 20) {
      return '❌ ZegoCloud AppSign invalide!\n\nLe AppSign doit avoir au moins 32 caractères';
    }
    return null;
  }

  /// Retourne les infos de configuration
  static Map<String, dynamic> getConfigInfo() {
    return {
      'appName': APP_NAME,
      'appID': APP_ID,
      'appSignLength': APP_SIGN.length,
      'isConfigured': isConfigured(),
      'zegoCloudUrl': ZEGOCLOUD_URL,
    };
  }

  /// Valide et retourne un message
  static void printConfig() {
    if (isConfigured()) {
      print('✅ ZegoCloud Configuration Valid');
      print('   App ID: $APP_ID');
      print('   App Sign: ${APP_SIGN.substring(0, 16)}...${APP_SIGN.substring(APP_SIGN.length - 8)}');
      print('   Status: READY FOR USE');
    } else {
      print('❌ ZegoCloud Configuration Invalid');
      print(getConfigError());
    }
  }
}
