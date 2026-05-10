import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../models/user_model.dart';
import '../services/meeting_service.dart';
import '../services/auth_service.dart';
import '../widgets/custom_button.dart';
import '../screens/meeting_screen.dart';
import '../screens/login_screen.dart';

class HomeScreen extends StatefulWidget {
  final UserModel user;
  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MeetingService _meetingService = MeetingService();
  final AuthService _authService = AuthService();
  final TextEditingController _codeController = TextEditingController();
  bool _isCreating = false;
  bool _isJoining = false;

  void _createMeeting() async {
    setState(() => _isCreating = true);
    try {
      final meeting = await _meetingService.createMeeting(
        'Reunion CRUX',
        widget.user.uid,
        widget.user.name,
      );
      if (meeting != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MeetingScreen(
              meeting: meeting,
              user: widget.user,
            ),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible de creer la reunion')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  void _joinMeeting() async {
    if (_codeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entrez un code de reunion')),
      );
      return;
    }
    setState(() => _isJoining = true);
    try {
      final meeting = await _meetingService.joinMeeting(
        _codeController.text.trim().toUpperCase(),
      );
      if (meeting != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MeetingScreen(
              meeting: meeting,
              user: widget.user,
            ),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reunion introuvable')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isJoining = false);
    }
  }

  void _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text(
          'CRUX',
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bonjour, ${widget.user.name} !',
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Que voulez-vous faire ?',
              style: TextStyle(color: AppColors.grey, fontSize: 14),
            ),
            const SizedBox(height: 48),
            // Nouvelle reunion
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.video_call, color: AppColors.primary, size: 28),
                      SizedBox(width: 12),
                      Text(
                        'Nouvelle reunion',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Demarrez une reunion instantanee',
                    style: TextStyle(color: AppColors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: AppConstants.newMeeting,
                    onPressed: _createMeeting,
                    isLoading: _isCreating,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Rejoindre reunion
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.group_add, color: AppColors.primary, size: 28),
                      SizedBox(width: 12),
                      Text(
                        'Rejoindre une reunion',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Entrez le code de la reunion',
                    style: TextStyle(color: AppColors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _codeController,
                    style: const TextStyle(
                      color: AppColors.white,
                      letterSpacing: 4,
                      fontWeight: FontWeight.bold,
                    ),
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: AppConstants.meetingCode,
                      hintStyle: const TextStyle(color: AppColors.grey),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(
                        Icons.tag,
                        color: AppColors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: AppConstants.joinMeeting,
                    onPressed: _joinMeeting,
                    isLoading: _isJoining,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}