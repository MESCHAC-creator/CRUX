import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../models/user_model.dart';
import '../models/meeting_model.dart';
import '../services/permission_service.dart';
import '../services/daily_api_service.dart';
import '../widgets/custom_button.dart';
import 'meeting_screen_daily.dart';
import 'settings_screen.dart';

class HomeScreenDaily extends StatefulWidget {
  final UserModel user;

  const HomeScreenDaily({super.key, required this.user});

  @override
  State<HomeScreenDaily> createState() => _HomeScreenDailyState();
}

class _HomeScreenDailyState extends State<HomeScreenDaily>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _permissionsGranted = false;
  bool _checkingPermissions = true;
  String _selectedMode = 'standard';

  final List<Map<String, dynamic>> _modes = [
    {
      'name': 'Standard',
      'icon': '🎯',
      'value': 'standard',
      'color': const Color(0xFF2D8CFF),
    },
    {
      'name': 'Eglise',
      'icon': '⛪',
      'value': 'church',
      'color': const Color(0xFF6B5B95),
    },
    {
      'name': 'Ecole',
      'icon': '🎓',
      'value': 'education',
      'color': const Color(0xFF88B04B),
    },
    {
      'name': 'Entreprise',
      'icon': '💼',
      'value': 'enterprise',
      'color': const Color(0xFFF7CAC9),
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _requestPermissionsAtStartup();
  }

  Future<void> _requestPermissionsAtStartup() async {
    setState(() => _checkingPermissions = true);
    
    final granted = await PermissionService.requestAllPermissions();
    
    if (mounted) {
      setState(() {
        _permissionsGranted = granted;
        _checkingPermissions = false;
      });
    }

    if (!granted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'Permissions refusees. Allez aux parametres pour les accepter.'),
            backgroundColor: AppColors.danger,
            action: SnackBarAction(
              label: 'Parametres',
              onPressed: () =>
                  PermissionService.openAppSettings(),
            ),
          ),
        );
      }
    }
  }

  Future<void> _createNewMeeting() async {
    if (!_permissionsGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permissions requises'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    // Afficher le loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
                color: AppColors.primary),
            const SizedBox(height: 16),
            const Text(
              'Creation de la reunion...',
              style: TextStyle(
                  color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );

    try {
      // Générer un code unique
      final roomCode = DailyApiService.generateRoomName();
      print('⏳ Creating meeting with code: $roomCode');

      // Créer la room sur Daily.co
      final roomUrl =
          await DailyApiService.createRoom(roomCode);

      if (mounted) Navigator.pop(context); // Ferme le dialog

      if (roomUrl != null) {
        print('✅ Room created: $roomUrl');

        // Créer l'objet meeting
        final meeting = MeetingModel(
          id: roomCode,
          title: 'Reunion $roomCode',
          hostId: user.uid,
          hostName: user.name,
          createdAt: DateTime.now(),
          mode: _selectedMode,
        );

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MeetingScreenDaily(
                meeting: meeting,
                user: user,
                roomUrl: roomUrl,
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erreur: Impossible de créer la reunion'),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Error: $e');
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Future<void> _joinMeetingWithCode() async {
    final codeController = TextEditingController();

    if (!_permissionsGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permissions requises'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Rejoindre Une Reunion',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Entrez le code de la reunion',
              style: TextStyle(
                color: AppColors.grey,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: codeController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Ex: ROOM-5789',
                hintStyle: const TextStyle(color: AppColors.grey),
                filled: true,
                fillColor: AppColors.surfaceLight,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler',
                style: TextStyle(color: AppColors.primary)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (codeController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Entrez un code'),
                      backgroundColor: AppColors.danger),
                );
                return;
              }

              Navigator.pop(context);
              _joinMeetingProcess(codeController.text.trim());
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary),
            child: const Text('Rejoindre'),
          ),
        ],
      ),
    );
  }

  Future<void> _joinMeetingProcess(String code) async {
    // Afficher le loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
                color: AppColors.primary),
            const SizedBox(height: 16),
            const Text(
              'Connexion a la reunion...',
              style: TextStyle(
                  color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );

    try {
      print('🔗 Joining meeting with code: $code');

      // Obtenir ou créer la room
      final roomUrl = await DailyApiService.getRoom(code);

      if (mounted) Navigator.pop(context); // Ferme le dialog

      if (roomUrl != null) {
        print('✅ Room URL: $roomUrl');

        final meeting = MeetingModel(
          id: code,
          title: 'Reunion $code',
          hostId: user.uid,
          hostName: user.name,
          createdAt: DateTime.now(),
        );

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MeetingScreenDaily(
                meeting: meeting,
                user: user,
                roomUrl: roomUrl,
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reunion non trouvee ou erreur'),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Error: $e');
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingPermissions) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                  color: AppColors.primary),
              const SizedBox(height: 16),
              const Text(
                'Verification des permissions...',
                style: TextStyle(
                    color: Colors.white54, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('CRUX',
                style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    letterSpacing: 4)),
            Text(
              'Bienvenue, ${user.name}',
              style: const TextStyle(
                  color: Colors.white60, fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings,
                color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const SettingsScreen(),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (!_permissionsGranted)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: AppColors.danger.withOpacity(0.2),
              child: Row(
                children: [
                  const Icon(Icons.warning,
                      color: AppColors.danger, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: const Text(
                      'Permissions refusees. Allez aux parametres pour les accepter.',
                      style: TextStyle(
                          color: AppColors.danger,
                          fontSize: 12),
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        PermissionService.openAppSettings(),
                    child: const Text('Parametres',
                        style: TextStyle(
                            color: AppColors.primary)),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const Text('MODE DE REUNION',
                    style: TextStyle(
                        color: AppColors.grey,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5)),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1,
                  ),
                  itemCount: _modes.length,
                  itemBuilder: (context, index) {
                    final mode = _modes[index];
                    final isSelected =
                        _selectedMode == mode['value'];
                    return GestureDetector(
                      onTap: () => setState(() =>
                          _selectedMode = mode['value']),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? mode['color']
                              : AppColors.surface,
                          borderRadius:
                              BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? mode['color']
                                : Colors.white10,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Text(mode['icon'],
                                style: const TextStyle(
                                    fontSize: 32)),
                            const SizedBox(height: 8),
                            Text(
                              mode['name'],
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white54,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
                CustomButton(
                  text: 'NOUVELLE REUNION',
                  onPressed: _createNewMeeting,
                  color: AppColors.primary,
                  icon: Icons.add,
                ),
                const SizedBox(height: 12),
                CustomButton(
                  text: 'REJOINDRE REUNION',
                  onPressed: _joinMeetingWithCode,
                  color: AppColors.surfaceLight,
                  textColor: Colors.white,
                  icon: Icons.login,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
