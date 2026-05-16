import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:videosdk/videosdk.dart';
import '../utils/colors.dart';
import '../models/user_model.dart';
import '../models/meeting_model.dart';
import '../services/videosdk_service.dart';
import '../services/videosdk_config.dart';

class MeetingScreenVideoSDK extends StatefulWidget {
  final MeetingModel meeting;
  final UserModel user;
  final bool isLiveStream;

  const MeetingScreenVideoSDK({
    super.key,
    required this.meeting,
    required this.user,
    this.isLiveStream = false,
  });

  @override
  State<MeetingScreenVideoSDK> createState() => _MeetingScreenVideoSDKState();
}

class _MeetingScreenVideoSDKState extends State<MeetingScreenVideoSDK> {
  late Room room;
  bool _permissionsGranted = false;
  bool _isLoading = true;
  bool _isStreaming = false;
  String? _errorMessage;
  String? _token;

  @override
  void initState() {
    super.initState();
    _initializeMeeting();
  }

  Future<void> _initializeMeeting() async {
    try {
      print('🎫 Initializing VideoSDK meeting...');

      // Vérifier la configuration
      if (!VideoSDKConfig.isValidApiKey()) {
        setState(() {
          _errorMessage = 'VideoSDK API Key not configured!';
          _isLoading = false;
        });
        return;
      }

      // Demander les permissions
      await _requestPermissions();

      if (!_permissionsGranted) {
        setState(() {
          _errorMessage = 'Permissions requises pour la vidéoconférence.';
          _isLoading = false;
        });
        return;
      }

      // Créer le token
      _token = await VideoSDKService.createMeetingToken(widget.meeting.id);

      if (_token == null) {
        setState(() {
          _errorMessage = 'Erreur: Impossible de créer le token.';
          _isLoading = false;
        });
        return;
      }

      // Initialiser VideoSDK
      _initializeRoom();
    } catch (e) {
      print('❌ Error: $e');
      setState(() {
        _errorMessage = 'Erreur: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _requestPermissions() async {
    try {
      print('🔐 Requesting permissions...');

      final cameraStatus = await Permission.camera.request();
      final micStatus = await Permission.microphone.request();

      print('📷 Camera: ${cameraStatus.isDenied ? 'DENIED' : 'GRANTED'}');
      print('🎤 Microphone: ${micStatus.isDenied ? 'DENIED' : 'GRANTED'}');

      setState(() {
        _permissionsGranted = cameraStatus.isGranted && micStatus.isGranted;
      });
    } catch (e) {
      print('❌ Error: $e');
    }
  }

  void _initializeRoom() {
    try {
      print('🎬 Initializing VideoSDK room...');

      room = VideoSDK.createRoom(
        roomId: widget.meeting.id,
        token: _token!,
        displayName: widget.user.name,
        mic: MicModes.REQUIRED,
        webcam: true,
        maxResolution: 'hd',
        multiStream: false,
        customParticipantId: widget.user.uid,
      );

      // Écouter les événements
      room.on('room-joined', () {
        print('✅ Room joined');
        if (mounted) {
          setState(() => _isLoading = false);
        }
      });

      room.on('room-left', () {
        print('👋 Room left');
        Navigator.pop(context);
      });

      room.on('error', (dynamic error) {
        print('❌ Room error: $error');
        if (mounted) {
          setState(() {
            _errorMessage = error.toString();
            _isLoading = false;
          });
        }
      });

      // Rejoindre la room
      room.join();
    } catch (e) {
      print('❌ Error: $e');
      setState(() {
        _errorMessage = 'Erreur: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _startYouTubeLiveStream() async {
    final streamKeyController = TextEditingController();
    final streamTitleController = TextEditingController();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('🔴 YouTube Live Stream',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Configurez votre live YouTube',
                style: TextStyle(
                  color: AppColors.grey,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: streamTitleController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Titre du live',
                  hintStyle: const TextStyle(color: AppColors.grey),
                  filled: true,
                  fillColor: AppColors.surfaceLight,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: streamKeyController,
                style: const TextStyle(color: Colors.white),
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'YouTube Stream Key',
                  hintStyle: const TextStyle(color: AppColors.grey),
                  filled: true,
                  fillColor: AppColors.surfaceLight,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'YouTube Studio > En direct > Configuration',
                style: TextStyle(
                  color: AppColors.grey,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler',
                style: TextStyle(color: AppColors.primary)),
          ),
          ElevatedButton(
            onPressed: () {
              if (streamKeyController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Entrez votre stream key'),
                      backgroundColor: AppColors.danger),
                );
                return;
              }
              Navigator.pop(context);
              _activateYouTubeStream(
                streamKeyController.text.trim(),
                streamTitleController.text.trim(),
              );
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF0000)),
            child: const Text('Démarrer'),
          ),
        ],
      ),
    );
  }

  Future<void> _activateYouTubeStream(
      String streamKey, String streamTitle) async {
    setState(() => _isLoading = true);

    try {
      final success = await VideoSDKService.startYouTubeLiveStream(
        widget.meeting.id,
        streamKey,
        streamTitle.isEmpty ? widget.meeting.title : streamTitle,
      );

      if (success) {
        setState(() {
          _isStreaming = true;
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🔴 Stream démarré !'),
              backgroundColor: Color(0xFFFF0000),
            ),
          );
        }
      } else {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erreur: Impossible de démarrer le stream'),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Future<void> _stopYouTubeStream() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Arrêter le stream ?',
            style: TextStyle(color: Colors.white)),
        content: const Text(
          'Voulez-vous vraiment arrêter ?',
          style: TextStyle(color: AppColors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Non',
                style: TextStyle(color: AppColors.primary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger),
            child: const Text('Oui'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      final success =
          await VideoSDKService.stopYouTubeLiveStream(widget.meeting.id);
      setState(() {
        _isStreaming = !success;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    room.leave();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ERROR STATE
    if (_errorMessage != null && !_permissionsGranted) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Erreur'),
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
                  'Erreur de connexion',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _errorMessage ?? 'Erreur inconnue',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _errorMessage = null;
                      _isLoading = true;
                      _permissionsGranted = false;
                    });
                    _initializeMeeting();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Réessayer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // LOADING STATE
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: 20),
              Text(
                'Connexion à la réunion...',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // MEETING VIEW
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
              'Quitter ?',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              _isStreaming
                  ? 'Le stream YouTube est en cours.'
                  : 'Voulez-vous quitter la réunion ?',
              style: const TextStyle(color: Colors.white70),
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
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 2,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (_isStreaming)
                    const Text(
                      '🔴 ',
                      style: TextStyle(fontSize: 16),
                    ),
                  Expanded(
                    child: Text(
                      widget.meeting.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                'Code: ${widget.meeting.id}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            if (widget.isLiveStream)
              IconButton(
                icon: Icon(
                  _isStreaming ? Icons.stop_circle : Icons.play_circle,
                  color: const Color(0xFFFF0000),
                ),
                onPressed: _isStreaming
                    ? _stopYouTubeStream
                    : _startYouTubeLiveStream,
              ),
            IconButton(
              icon: const Icon(
                Icons.call_end,
                color: AppColors.danger,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: Container(
                color: Colors.black,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.videocam,
                        color: AppColors.primary,
                        size: 64,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Réunion : ${widget.meeting.title}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Participants connectés',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.surface,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => print('Micro toggle'),
                    icon: const Icon(Icons.mic),
                    label: const Text('Micro'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => print('Camera toggle'),
                    icon: const Icon(Icons.videocam),
                    label: const Text('Caméra'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
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
