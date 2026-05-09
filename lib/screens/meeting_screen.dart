import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../models/user_model.dart';
import '../models/meeting_model.dart';

class MeetingScreen extends StatelessWidget {
  final MeetingModel meeting;
  final UserModel user;

  const MeetingScreen({
    super.key,
    required this.meeting,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(
          'Code: ${meeting.id}',
          style: const TextStyle(color: AppColors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call_end, color: Colors.red),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.videocam,
              color: AppColors.primary,
              size: 100,
            ),
            const SizedBox(height: 24),
            Text(
              'Réunion : ${meeting.title}',
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hôte : ${meeting.hostName}',
              style: const TextStyle(color: AppColors.grey),
            ),
            const SizedBox(height: 48),
            const Text(
              'Visioconférence bientôt disponible',
              style: TextStyle(color: AppColors.grey),
            ),
          ],
        ),
      ),
    );
  }
}