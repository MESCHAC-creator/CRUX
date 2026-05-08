class CruxL10n {
  CruxL10n._();

  static const Map<String, Map<String, String>> _strings = {
    'fr': {
      'appName': 'CRUX',
      'tagline': 'Des réunions vidéo fluides, sécurisées et modernes pour tout le monde.',
      'getStarted': 'Démarrer gratuitement',
      'login': 'Connexion',
      'signup': "S'inscrire",
      'featHdTitle': 'Visio HD',
      'featHdDesc': 'Réunions fluides jusqu\'à 100 participants.',
      'featScheduleTitle': 'Planification',
      'featScheduleDesc': 'Organisez et invitez en quelques clics.',
      'featChatTitle': 'Messages',
      'featChatDesc': 'Discutez avec votre équipe en temps réel.',
      'featSecureTitle': '100% sécurisé',
      'featSecureDesc': 'Chiffrement de bout en bout sur chaque appel.',
      'heroTitle1': 'Réunions vidéo',
      'heroTitle2': 'modernes',
      'footerCopyright': 'Tout en local',
      'quickJoinHint': 'Entrer le code de la réunion',
      'quickJoinBtn': 'Rejoindre',
      'newMeetingBtn': 'Nouvelle réunion',
      'statUsers': 'Utilisateurs actifs',
      'statCalls': 'Appels par jour',
      'statUptime': 'Disponibilité',
    },
    'en': {
      'appName': 'CRUX',
      'tagline': 'Smooth, secure and modern video meetings for everyone.',
      'getStarted': 'Get started',
      'login': 'Log in',
      'signup': 'Sign up',
      'featHdTitle': 'HD Video',
      'featHdDesc': 'Smooth meetings with up to 100 attendees.',
      'featScheduleTitle': 'Scheduling',
      'featScheduleDesc': 'Organise and invite in a few clicks.',
      'featChatTitle': 'Messaging',
      'featChatDesc': 'Chat with your team in real time.',
      'featSecureTitle': '100% secure',
      'featSecureDesc': 'End-to-end encryption on every call.',
      'heroTitle1': 'Video meetings',
      'heroTitle2': 'made simple',
      'footerCopyright': '100% private',
      'quickJoinHint': 'Enter meeting code',
      'quickJoinBtn': 'Join',
      'newMeetingBtn': 'New meeting',
      'statUsers': 'Active users',
      'statCalls': 'Daily calls',
      'statUptime': 'Uptime',
    },
  };

  static String t(String key, {String lang = 'fr'}) {
    return _strings[lang]?[key] ?? _strings['en']![key] ?? key;
  }
}