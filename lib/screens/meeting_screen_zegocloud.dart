import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_video_conference/zego_uikit_prebuilt_video_conference.dart';
import '../utils/colors.dart';
import '../models/user_model.dart';
import '../models/meeting_model.dart';
import '../services/zegocloud_config.dart';

class MeetingScreenZegoCloud extends StatefulWidget {
  final MeetingModel meeting;
  final UserModel user;
  final bool isLiveStream;

  const MeetingScreenZegoCloud({
    super.key,
    required this.meeting,
    required this.user,
    this.isLiveStream = false,
  });

  @override
  State<MeetingScreenZegoCloud> createState() =>
      _MeetingScreenZegoCloudState();
}

class _MeetingScreenZegoCloudState extends State<MeetingScreenZegoCloud> {
  bool _configError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _validateConfig();
  }

  void _validateConfig() {
    if (!ZegoCloudConfig.isConfigured()) {
      setState(() {
        _configError = true;
        _errorMessage = ZegoCloudConfig.getConfigError();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ❌ ERREUR DE CONFIGURATION
    if (_configError) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Configuration requise'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: AppColors.danger,
                  size: 64,
                ),
                const SizedBox(height: 20),
                const Text(
                  '⚠️ Configuration manquante',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMessage ?? 'Erreur de configuration',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Veuillez compléter votre configuration ZegoCloud:',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '1. Allez sur https://zegocloud.com/',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '2. Copiez votre AppID et AppSign',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '3. Modifiez lib/services/zegocloud_config.dart',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '4. Remplacez APP_ID et APP_SIGN',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ✅ ÉCRAN VIDÉOCONFÉRENCE ZEGOCLOUD
    return WillPopScope(
      onWillPop: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Quitter la réunion ?',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text(
              'Êtes-vous sûr de vouloir quitter ?',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  'Rester',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger,
                ),
                child: const Text('Quitter'),
              ),
            ],
          ),
        );
        return confirmed ?? false;
      },
      child: ZegoUIKitPrebuiltVideoConference(
        appID: ZegoCloudConfig.APP_ID,
        appSign: ZegoCloudConfig.APP_SIGN,
        userID: widget.user.uid,
        userName: widget.user.name,
        conferenceID: widget.meeting.id,
        config: ZegoUIKitPrebuiltVideoConferenceConfig(
          topMenuBarConfig: ZegoTopMenuBarConfig(
            title: widget.meeting.title,
            isVisible: true,
            backgroundColor: AppColors.surface,
            showBackButton: true,
          ),
          bottomMenuBarConfig: ZegoBottomMenuBarConfig(
            maxShowCount: 5,
          ),
          layout: ZegoVideoConferenceLayout.gallery,
          showScreenSharingFullscreenMode: true,
          initialCameraFacing: ZegoUIKitCameraFacing.front,
          foreground: Container(),
          background: Container(
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
