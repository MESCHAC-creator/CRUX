import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/colors.dart';
import '../models/user_model.dart';
import '../models/meeting_model.dart';
import '../services/jitsi_service.dart';

class MeetingScreen extends StatefulWidget {
  final MeetingModel meeting;
  final UserModel user;

  const MeetingScreen({
    super.key,
    required this.meeting,
    required this.user,
  });

  @override
  State<MeetingScreen> createState() => _MeetingScreenState();
}

class _MeetingScreenState extends State<MeetingScreen> {
  final JitsiService _jitsiService = JitsiService();
  bool _isJoining = false;
  bool _hasJoined = false;
  bool _hasLeft = false;

  @override
  void initState() {
    super.initState();
    _joinMeeting();
  }

  Future<void> _joinMeeting() async {
    setState(() {
      _isJoining = true;
      _hasLeft = false;
    });
    try {
      await _jitsiService.joinMeeting(
        roomName: 'crux-${widget.meeting.id}',
        displayName: widget.user.name,
        userEmail: widget.user.email,
        onConferenceJoined: () {
          if (mounted) setState(() => _hasJoined = true);
        },
        onConferenceTerminated: () {
          if (mounted) {
            setState(() {
              _hasJoined = false;
              _hasLeft = true;
            });
          }
        },
      );
      if (mounted) setState(() => _isJoining = false);
    } catch (e) {
      if (mounted) {
        setState(() => _isJoining = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  void _copyCode() {
    Clipboard.setData(ClipboardData(text: widget.meeting.id));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Code copie !'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Quitter la reunion ?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Voulez-vous vraiment quitter cette reunion ?',
          style: TextStyle(color: AppColors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Rester',
                style: TextStyle(color: AppColors.primary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger),
            child: const Text('Quitter',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _jitsiService.hangUp();
      return true;
    }
    return false;
  }

  Future<void> _endCall() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Quitter la reunion ?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Voulez-vous vraiment quitter cette reunion ?',
          style: TextStyle(color: AppColors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Rester',
                style: TextStyle(color: AppColors.primary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger),
            child: const Text('Quitter',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _jitsiService.hangUp();
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                color: AppColors.surface,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.meeting.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          GestureDetector(
                            onTap: _copyCode,
                            child: Row(
                              children: [
                                Text(
                                  widget.meeting.id,
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.copy,
                                    color: AppColors.primary,
                                    size: 12),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _hasJoined
                            ? AppColors.success.withOpacity(0.2)
                            : AppColors.warning.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _hasJoined
                              ? AppColors.success
                              : AppColors.warning,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.circle,
                            color: _hasJoined
                                ? AppColors.success
                                : AppColors.warning,
                            size: 8,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _isJoining
                                ? 'Connexion...'
                                : _hasJoined
                                ? 'Connecte'
                                : 'En attente',
                            style: TextStyle(
                              color: _hasJoined
                                  ? AppColors.success
                                  : AppColors.warning,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Corps
              Expanded(
                child: _isJoining
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Connexion a la reunion...',
                        style: TextStyle(
                            color: Colors.white, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Code: ${widget.meeting.id}',
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 14,
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )
                    : _hasLeft
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.videocam_off,
                          color: AppColors.warning,
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Vous avez quitte la reunion',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Voulez-vous vous reconnecter ?',
                        style: TextStyle(
                            color: AppColors.grey, fontSize: 14),
                      ),
                      const SizedBox(height: 32),
                      // Bouton reconnexion
                      ElevatedButton.icon(
                        onPressed: _joinMeeting,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Se reconnecter'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(16)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Retourner a l\'accueil',
                          style:
                          TextStyle(color: AppColors.grey),
                        ),
                      ),
                    ],
                  ),
                )
                    : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.videocam,
                          color: AppColors.success,
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Reunion en cours',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _copyCode,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius:
                            BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Code: ${widget.meeting.id}',
                                style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.copy,
                                  color: AppColors.primary,
                                  size: 16),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: _joinMeeting,
                        icon: const Icon(Icons.video_call),
                        label: const Text('Rejoindre la video'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(16)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bouton quitter
              Container(
                padding: const EdgeInsets.all(16),
                color: AppColors.surface,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _endCall,
                    icon: const Icon(Icons.call_end),
                    label: const Text('Quitter la reunion'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.danger,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}