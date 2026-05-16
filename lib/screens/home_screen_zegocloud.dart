import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/colors.dart';
import '../models/user_model.dart';
import '../models/meeting_model.dart';
import 'meeting_screen_zegocloud.dart';
import 'settings_screen.dart';

class HomeScreenZegoCloud extends StatefulWidget {
  final UserModel user;

  const HomeScreenZegoCloud({super.key, required this.user});

  @override
  State<HomeScreenZegoCloud> createState() => _HomeScreenZegoCloudState();
}

class _HomeScreenZegoCloudState extends State<HomeScreenZegoCloud> {
  String _selectedMode = 'standard';
  bool _isLiveStream = false;

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
    {
      'name': 'YouTube Live',
      'icon': '🔴',
      'value': 'youtube_live',
      'color': const Color(0xFFFF0000),
    },
  ];

  void _createMeeting() {
    final codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Créer Une Réunion',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Entrez un CODE pour votre réunion',
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
                hintText: 'Ex: REUNION-JANVIER',
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
            onPressed: () {
              if (codeController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Entrez un code'),
                      backgroundColor: AppColors.danger),
                );
                return;
              }
              Navigator.pop(context);
              _showCodeAndJoin(codeController.text.trim());
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary),
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }

  void _showCodeAndJoin(String code) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: Text(
          _isLiveStream ? '🔴 Live YouTube' : '✅ Réunion Créée',
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'CODE DE LA RÉUNION',
              style: TextStyle(
                color: AppColors.grey,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              child: Text(
                code,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: code));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Code copié: $code'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.copy,
                      color: AppColors.primary,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Copier le code',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_isLiveStream) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF0000).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFFF0000),
                    width: 1,
                  ),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🔴 YouTube Live',
                      style: TextStyle(
                        color: Color(0xFFFF0000),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'En direct sur YouTube avec votre audience',
                      style: TextStyle(
                        color: AppColors.grey,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Fermer',
              style: TextStyle(color: AppColors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _joinRoom(code);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary),
            child: const Text('Rejoindre'),
          ),
        ],
      ),
    );
  }

  void _joinMeeting() {
    final codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Rejoindre Une Réunion',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Entrez le code de la réunion',
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
                hintText: 'Ex: REUNION-JANVIER',
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
            onPressed: () {
              if (codeController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Entrez un code'),
                      backgroundColor: AppColors.danger),
                );
                return;
              }
              Navigator.pop(context);
              _joinRoom(codeController.text.trim());
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary),
            child: const Text('Rejoindre'),
          ),
        ],
      ),
    );
  }

  void _joinRoom(String roomID) {
    final meeting = MeetingModel(
      id: roomID,
      title: _isLiveStream ? '🔴 Live - $roomID' : 'Réunion $roomID',
      hostId: widget.user.uid,
      hostName: widget.user.name,
      createdAt: DateTime.now(),
      mode: _selectedMode,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MeetingScreenZegoCloud(
          meeting: meeting,
          user: widget.user,
          isLiveStream: _isLiveStream,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              'Bienvenue, ${widget.user.name}',
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
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text('MODE DE RÉUNION',
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
                onTap: () {
                  setState(() {
                    _selectedMode = mode['value'];
                    _isLiveStream =
                        mode['value'] == 'youtube_live';
                  });
                },
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
          ElevatedButton(
            onPressed: _createMeeting,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(
                  vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add),
                SizedBox(width: 8),
                Text(
                  'NOUVELLE RÉUNION',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _joinMeeting,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surfaceLight,
              padding: const EdgeInsets.symmetric(
                  vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.login,
                    color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'REJOINDRE RÉUNION',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
