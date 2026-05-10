import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import '../utils/colors.dart';
import '../models/user_model.dart';
import '../models/meeting_model.dart';
import '../services/agora_service.dart';

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
  final AgoraService _agoraService = AgoraService();
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final List<int> _remoteUsers = [];
  bool _isMuted = false;
  bool _isVideoOff = false;
  bool _showChat = false;
  bool _isJoined = false;

  @override
  void initState() {
    super.initState();
    _initAgora();
  }

  Future<void> _initAgora() async {
    try {
      await _agoraService.initialize();
      _agoraService.registerEventHandler(
        onUserJoined: (uid) {
          setState(() => _remoteUsers.add(uid));
        },
        onUserOffline: (uid) {
          setState(() => _remoteUsers.remove(uid));
        },
        onJoinSuccess: () {
          setState(() => _isJoined = true);
        },
      );
      await _agoraService.joinChannel(widget.meeting.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur video: ${e.toString()}')),
        );
      }
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    setState(() {
      _messages.add({
        'sender': widget.user.name,
        'message': _messageController.text.trim(),
        'time': TimeOfDay.now().format(context),
      });
    });
    _messageController.clear();
  }

  void _toggleMute() async {
    setState(() => _isMuted = !_isMuted);
    await _agoraService.muteLocalAudio(_isMuted);
  }

  void _toggleVideo() async {
    setState(() => _isVideoOff = !_isVideoOff);
    await _agoraService.muteLocalVideo(_isVideoOff);
  }

  void _endCall() async {
    await _agoraService.leaveChannel();
    await _agoraService.dispose();
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _agoraService.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Widget _buildVideoView() {
    return Stack(
      children: [
        Container(
          color: Colors.black,
          child: _remoteUsers.isEmpty
              ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person, color: Colors.white54, size: 80),
                SizedBox(height: 16),
                Text(
                  'En attente de participants...',
                  style: TextStyle(color: Colors.white54, fontSize: 16),
                ),
              ],
            ),
          )
              : AgoraVideoView(
            controller: VideoViewController.remote(
              rtcEngine: _agoraService.engine!,
              canvas: VideoCanvas(uid: _remoteUsers.first),
              connection: RtcConnection(channelId: widget.meeting.id),
            ),
          ),
        ),
        Positioned(
          top: 16,
          right: 16,
          child: Container(
            width: 100,
            height: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            clipBehavior: Clip.hardEdge,
            child: _isVideoOff
                ? Container(
              color: Colors.black,
              child: const Icon(
                Icons.videocam_off,
                color: Colors.white54,
                size: 30,
              ),
            )
                : AgoraVideoView(
              controller: VideoViewController(
                rtcEngine: _agoraService.engine!,
                canvas: const VideoCanvas(uid: 0),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChatPanel() {
    return Container(
      color: const Color(0xFF1E1E2E),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.surface,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Chat',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => setState(() => _showChat = false),
                ),
              ],
            ),
          ),
          Expanded(
            child: _messages.isEmpty
                ? const Center(
              child: Text(
                'Aucun message',
                style: TextStyle(color: Colors.white54),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isMe = msg['sender'] == widget.user.name;
                return Align(
                  alignment: isMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    constraints: const BoxConstraints(maxWidth: 250),
                    decoration: BoxDecoration(
                      color: isMe
                          ? AppColors.primary
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isMe)
                          Text(
                            msg['sender']!,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        Text(
                          msg['message']!,
                          style:
                          const TextStyle(color: Colors.white),
                        ),
                        Text(
                          msg['time']!,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            color: AppColors.surface,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Ecrire un message...',
                      hintStyle:
                      const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: const Color(0xFF2A2A3E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: IconButton(
                    icon: const Icon(Icons.send,
                        color: Colors.white, size: 18),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _controlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding:
      const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      color: const Color(0xFF1E1E2E),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _controlButton(
            icon: _isMuted ? Icons.mic_off : Icons.mic,
            label: _isMuted ? 'Activer' : 'Muet',
            color: _isMuted ? Colors.red : Colors.white,
            onTap: _toggleMute,
          ),
          _controlButton(
            icon: _isVideoOff ? Icons.videocam_off : Icons.videocam,
            label: _isVideoOff ? 'Activer' : 'Video',
            color: _isVideoOff ? Colors.red : Colors.white,
            onTap: _toggleVideo,
          ),
          _controlButton(
            icon: Icons.chat_bubble_outline,
            label: 'Chat',
            color: _showChat ? AppColors.primary : Colors.white,
            onTap: () => setState(() => _showChat = !_showChat),
          ),
          _controlButton(
            icon: Icons.screen_share_outlined,
            label: 'Partager',
            color: Colors.white,
            onTap: () {},
          ),
          GestureDetector(
            onTap: _endCall,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child:
                  const Icon(Icons.call_end, color: Colors.white),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Quitter',
                  style:
                  TextStyle(color: Colors.white, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              color: const Color(0xFF1E1E2E),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.meeting.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Code: ${widget.meeting.id}',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.circle,
                          color: Colors.green, size: 10),
                      const SizedBox(width: 4),
                      Text(
                        _isJoined ? 'Connecte' : 'Connexion...',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: _showChat
                  ? Row(
                children: [
                  Expanded(
                      flex: 3, child: _buildVideoView()),
                  Expanded(
                      flex: 2, child: _buildChatPanel()),
                ],
              )
                  : _buildVideoView(),
            ),
            _buildControls(),
          ],
        ),
      ),
    );
  }
}