class TranslationService {
  Map<String, String> _translationCache = {};

  Future<String> translateFRtoEN(String text) async {
    if (_translationCache.containsKey(text)) {
      return _translationCache[text]!;
    }

    final translations = {
      'bonjour': 'hello',
      'au revoir': 'goodbye',
      'merci': 'thank you',
      'oui': 'yes',
      'non': 'no',
      'comment ca va': 'how are you',
      'bienvenue': 'welcome',
      'bonsoir': 'good evening',
      'bonne nuit': 'good night',
      'excusez moi': 'excuse me',
      'reunion': 'meeting',
      'participer': 'join',
      'quitter': 'leave',
      'chat': 'chat',
      'video': 'video',
    };

    String result = text;
    translations.forEach((fr, en) {
      if (text.toLowerCase().contains(fr)) {
        result = text.replaceAll(
          RegExp(fr, caseSensitive: false),
          en,
        );
      }
    });

    _translationCache[text] = result;
    return result;
  }

  Future<String> translateENtoFR(String text) async {
    final translations = {
      'hello': 'bonjour',
      'goodbye': 'au revoir',
      'thank you': 'merci',
      'yes': 'oui',
      'no': 'non',
      'how are you': 'comment ca va',
      'welcome': 'bienvenue',
      'good evening': 'bonsoir',
      'good night': 'bonne nuit',
      'excuse me': 'excusez moi',
      'meeting': 'reunion',
      'join': 'participer',
      'leave': 'quitter',
      'chat': 'chat',
      'video': 'video',
    };

    String result = text;
    translations.forEach((en, fr) {
      if (text.toLowerCase().contains(en)) {
        result = text.replaceAll(
          RegExp(en, caseSensitive: false),
          fr,
        );
      }
    });

    return result;
  }

  void clearCache() => _translationCache.clear();
}
