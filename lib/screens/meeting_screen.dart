import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final TextEditingController _streamKeyController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  final List<int> _remoteUsers = [];
  bool _isMuted = false;
  bool _isVideoOff = false;
  bool _showChat = false;
  bool _isJoined = false;
  bool _isInitializing = true;
  bool _isRecording = false;
  bool _isLive = false;
  bool _showMoreOptions = false;
  bool _isHandRaised = false;
  String? _errorMessage;
  String? _reaction;

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
          if (mounted) setState(() => _remoteUsers.add(uid));
        },
        onUserOffline: (uid) {
          if (mounted) setState(() => _remoteUsers.remove(uid));
        },
        onJoinSuccess: () {
          if (mounted) setState(() => _isJoined = true);
        },
      );
      await _agoraService.joinChannel(widget.meeting.id);
      if (mounted) setState(() => _isInitializing = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _errorMessage = e.toString();
        });
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
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _toggleMute() async {
    setState(() => _isMuted = !_isMuted);
    await _agoraService.muteLocalAudio(_isMuted);
  }

  void _toggleVideo() async {
    setState(() => _isVideoOff = !_isVideoOff);
    await _agoraService.muteLocalVideo(_isVideoOff);
  }

  void _toggleRecording() async {
    if (_isRecording) {
      await _agoraService.stopRecording();
      setState(() => _isRecording = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Enregistrement sauvegarde dans Telechargements'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } else {
      final success = await _agoraService.startRecording();
      setState(() => _isRecording = success);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Enregistrement demarre'
                : 'Erreur enregistrement'),
            backgroundColor:
                success ? AppColors.success : AppColors.danger,
          ),
        );
      }
    }
  }

  void _showYoutubeLiveDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'YouTube Live',
          style: TextStyle(color: AppColors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Entrez votre cle de stream YouTube',
              style: TextStyle(color: AppColors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _streamKeyController,
              style: const TextStyle(color: AppColors.white),
              decoration: InputDecoration(
                hintText: 'xxxx-xxxx-xxxx-xxxx',
                hintStyle: const TextStyle(color: AppColors.grey),
                filled: true,
                fillColor: AppColors.surfaceLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler',
                style: TextStyle(color: AppColors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_streamKeyController.text.trim().isEmpty) return;
              Navigator.pop(context);
              final success = await _agoraService.startYoutubeLive(
                  _streamKeyController.text.trim());
              setState(() => _isLive = success);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success
                        ? 'YouTube Live demarre !'
                        : 'Erreur YouTube Live'),
                    backgroundColor:
                        success ? AppColors.success : AppColors.danger,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger),
            child: const Text('Demarrer',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _stopYoutubeLive() async {
    await _agoraService
        .stopYoutubeLive(_streamKeyController.text.trim());
    if (mounted) setState(() => _isLive = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('YouTube Live arrete'),
          backgroundColor: AppColors.grey,
        ),
      );
    }
  }

  void _showReaction(String emoji) {
    setState(() => _reaction = emoji);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _reaction = null);
    });
  }

  void _endCall() async {
    if (_isLive) {
      await _agoraService
          .stopYoutubeLive(_streamKeyController.text.trim());
      if (mounted) setState(() => _isLive = false);
    }
    await _agoraService.dispose();
    if (mounted) Navigator.pop(context);
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

  @override
  void dispose() {
    _agoraService.dispose();
    _messageController.dispose();
    _streamKeyController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildVideoView() {
    if (_isInitializing) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text('Initialisation...',
                style: TextStyle(color: Colors.white54, fontSize: 16)),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline,
                color: AppColors.danger, size: 60),
            const SizedBox(height: 16),
            const Text('Erreur de connexion video',
                style: TextStyle(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                _errorMessage!,
                style: const TextStyle(
                    color: Colors.white54, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isInitializing = true;
                  _errorMessage = null;
                });
                _initAgora();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reessayer'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        Container(
          color: Colors.black,
          width: double.infinity,
          height: double.infinity,
          child: !_isJoined
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                          color: AppColors.primary),
                      SizedBox(height: 16),
                      Text('Connexion en cours...',
                          style: TextStyle(
                              color: Colors.white54, fontSize: 16)),
                    ],
                  ),
                )
              : _remoteUsers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceLight,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.person,
                                color: Colors.white54, size: 40),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                              'En attente de participants...',
                              style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 16)),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: _copyCode,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
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
                        ],
                      ),
                    )
                  : AgoraVideoView(
                      controller: VideoViewController.remote(
                        rtcEngine: _agoraService.engine!,
                        canvas: VideoCanvas(uid: _remoteUsers.first),
                        connection: RtcConnection(
                            channelId: widget.meeting.id),
                      ),
                    ),
        ),
        if (_isJoined && _agoraService.engine != null)
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              width: 100,
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: AppColors.primary, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 8,
                  ),
                ],
              ),
              clipBehavior: Clip.hardEdge,
              child: _isVideoOff
                  ? Container(
                      color: AppColors.surface,
                      child: Center(
                        child: Text(
                          widget.user.name.isNotEmpty
                              ? widget.user.name[0].toUpperCase()
                              : 'V',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold),
                        ),
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
        if (_reaction != null)
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Text(_reaction!,
                  style: const TextStyle(fontSize: 72)),
            ),
          ),
        if (_isLive)
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.danger,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.circle, color: Colors.white, size: 8),
                  SizedBox(width: 6),
                  Text('LIVE',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                ],
              ),
            ),
          ),
        if (_isRecording)
          Positioned(
            top: _isLive ? 52 : 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.fiber_manual_record,
                      color: Colors.white, size: 8),
                  SizedBox(width: 6),
                  Text('REC',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildChatPanel() {
    return Container(
      color: AppColors.surface,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.surfaceLight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Chat en reunion',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline,
                            color: AppColors.grey, size: 48),
                        SizedBox(height: 12),
                        Text('Aucun message',
                            style: TextStyle(color: AppColors.grey)),
                        Text('Soyez le premier a ecrire',
                            style: TextStyle(
                                color: AppColors.grey, fontSize: 12)),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final isMe =
                          msg['sender'] == widget.user.name;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          mainAxisAlignment: isMe
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (!isMe) ...[
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: AppColors.primary,
                                child: Text(
                                  msg['sender']!.isNotEmpty
                                      ? msg['sender']![0].toUpperCase()
                                      : 'U',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                                constraints: const BoxConstraints(
                                    maxWidth: 220),
                                decoration: BoxDecoration(
                                  color: isMe
                                      ? AppColors.primary
                                      : AppColors.surfaceLight,
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(18),
                                    topRight: const Radius.circular(18),
                                    bottomLeft:
                                        Radius.circular(isMe ? 18 : 4),
                                    bottomRight:
                                        Radius.circular(isMe ? 4 : 18),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    if (!isMe)
                                      Text(
                                        msg['sender']!,
                                        style: TextStyle(
                                          color: AppColors.primary
                                              .withOpacity(0.8),
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    Text(msg['message']!,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14)),
                                    const SizedBox(height: 2),
                                    Text(
                                      msg['time']!,
                                      style: TextStyle(
                                        color: isMe
                                            ? Colors.white60
                                            : AppColors.grey,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (isMe) const SizedBox(width: 8),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            color: AppColors.surfaceLight,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _messageController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Ecrire un message...',
                        hintStyle: TextStyle(color: AppColors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send,
                        color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReactionBar() {
    final reactions = ['👍', '❤️', '🎉', '👏', '😂', '😮', '🙌', '🔥'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: reactions
            .map((e) => GestureDetector(
                  onTap: () {
                    _showReaction(e);
                    setState(() => _showMoreOptions = false);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(e,
                        style: const TextStyle(fontSize: 24)),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      color: AppColors.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_showMoreOptions) ...[
            _buildReactionBar(),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _moreOptionButton(
                  icon: _isRecording
                      ? Icons.stop_circle
                      : Icons.fiber_manual_record,
                  label:
                      _isRecording ? 'Arreter REC' : 'Enregistrer',
                  color:
                      _isRecording ? AppColors.danger : Colors.white,
                  onTap: _toggleRecording,
                ),
                const SizedBox(width: 16),
                _moreOptionButton(
                  icon: _isLive ? Icons.live_tv : Icons.cast,
                  label:
                      _isLive ? 'Arreter Live' : 'YouTube Live',
                  color: _isLive ? AppColors.danger : Colors.white,
                  onTap:
                      _isLive ? _stopYoutubeLive : _showYoutubeLiveDialog,
                ),
                const SizedBox(width: 16),
                _moreOptionButton(
                  icon: _isHandRaised
                      ? Icons.back_hand
                      : Icons.back_hand_outlined,
                  label: _isHandRaised
                      ? 'Baisser main'
                      : 'Lever main',
                  color: _isHandRaised
                      ? AppColors.warning
                      : Colors.white,
                  onTap: () =>
                      setState(() => _isHandRaised = !_isHandRaised),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _controlButton(
                icon: _isMuted ? Icons.mic_off : Icons.mic,
                label: _isMuted ? 'Activer' : 'Muet',
                color: _isMuted ? AppColors.danger : Colors.white,
                backgroundColor: _isMuted
                    ? AppColors.danger.withOpacity(0.2)
                    : AppColors.surfaceLight,
                onTap: _toggleMute,
              ),
              _controlButton(
                icon: _isVideoOff
                    ? Icons.videocam_off
                    : Icons.videocam,
                label: _isVideoOff ? 'Activer' : 'Video',
                color:
                    _isVideoOff ? AppColors.danger : Colors.white,
                backgroundColor: _isVideoOff
                    ? AppColors.danger.withOpacity(0.2)
                    : AppColors.surfaceLight,
                onTap: _toggleVideo,
              ),
              _controlButton(
                icon: Icons.chat_bubble_outline,
                label: 'Chat',
                color:
                    _showChat ? AppColors.primary : Colors.white,
                backgroundColor: _showChat
                    ? AppColors.primary.withOpacity(0.2)
                    : AppColors.surfaceLight,
                onTap: () =>
                    setState(() => _showChat = !_showChat),
                badge: _messages.isNotEmpty && !_showChat
                    ? _messages.length.toString()
                    : null,
              ),
              _controlButton(
                icon: Icons.screen_share_outlined,
                label: 'Partager',
                color: Colors.white,
                backgroundColor: AppColors.surfaceLight,
                onTap: () {},
              ),
              _controlButton(
                icon: Icons.more_horiz,
                label: 'Plus',
                color: _showMoreOptions
                    ? AppColors.primary
                    : Colors.white,
                backgroundColor: _showMoreOptions
                    ? AppColors.primary.withOpacity(0.2)
                    : AppColors.surfaceLight,
                onTap: () => setState(
                    () => _showMoreOptions = !_showMoreOptions),
              ),
              GestureDetector(
                onTap: _endCall,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        color: AppColors.danger,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.call_end,
                          color: Colors.white, size: 24),
                    ),
                    const SizedBox(height: 4),
                    const Text('Quitter',
                        style: TextStyle(
                            color: Colors.white70, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _controlButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color backgroundColor,
    required VoidCallback onTap,
    String? badge,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              if (badge != null)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.danger,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(
                  color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _moreOptionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w500)),
          ],
        ),
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
                  horizontal: 16, vertical: 10),
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
                        Row(
                          children: [
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
                            const SizedBox(width: 12),
                            Icon(
                              Icons.circle,
                              color: _isJoined
                                  ? AppColors.success
                                  : AppColors.warning,
                              size: 8,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _isJoined ? 'Connecte' : 'Connexion...',
                              style: const TextStyle(
                                  color: AppColors.grey, fontSize: 11),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.people,
                            color: AppColors.grey, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${_remoteUsers.length + 1}',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 13),
                        ),
                      ],
                    ),
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
                        Container(
                            width: 1, color: AppColors.darkGrey),
                        SizedBox(
                          width: MediaQuery.of(context).size.width *
                              0.38,
                          child: _buildChatPanel(),
                        ),
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
