import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../models/user_model.dart';
import '../models/meeting_model.dart';
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

  void _createMeeting() async {
    final meeting = await _meetingService.createMeeting(
      'Réunion CRUX',
      widget.user.uid,
      widget.user.name,
    );
    if (meeting != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MeetingScreen(
            meeting: meeting,
            user: widget.user,
          ),
        ),
      );
    }
  }

  void _joinMeeting() async {
    final meeting = await _meetingService.joinMeeting(_codeController.text);
    if (meeting != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MeetingScreen(
            meeting: meeting,
            user: widget.user,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Réunion introuvable')),
      );
    }
  }

  void _logout() async {
    await _authService.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
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
              'Bonjour, ${widget.user.name} 👋',
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 48),
            CustomButton(
              text: AppConstants.newMeeting,
              onPressed: _createMeeting,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _codeController,
              style: const TextStyle(color: AppColors.white),
              decoration: InputDecoration(
                hintText: AppConstants.meetingCode,
                hintStyle: const TextStyle(color: AppColors.grey),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: AppConstants.joinMeeting,
              onPressed: _joinMeeting,
            ),
          ],
        ),
      ),
    );
  }
}