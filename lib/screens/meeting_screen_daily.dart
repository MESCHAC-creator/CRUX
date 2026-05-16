import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../utils/colors.dart';
import '../models/user_model.dart';
import '../models/meeting_model.dart';
import '../services/youtube_live_service.dart';

class MeetingScreenDaily extends StatefulWidget {
  final MeetingModel meeting;
  final UserModel user;
  final bool isLiveStream;

  const MeetingScreenDaily({
    super.key,
    required this.meeting,
    required this.user,
    this.isLiveStream = false,
  });

  @override
  State<MeetingScreenDaily> createState() => _MeetingScreenDailyState();
}

class _MeetingScreenDailyState extends State<MeetingScreenDaily> {
  late WebViewController _webViewController;
  bool _permissionsGranted = false;
  bool _isLoading = true;
  bool _isStreaming = false;
  String? _errorMessage;
  File? _coverImage;

  @override
  void initState() {
    super.initState();
    _grantPermissionsFirst();
  }

  Future<void> _grantPermissionsFirst() async {
    try {
      print('🔐 Requesting permissions...');

      final cameraStatus = await Permission.camera.request();
      final micStatus = await Permission.microphone.request();

      print('📷 Camera: ${cameraStatus.isDenied ? 'DENIED' : 'GRANTED'}');
      print('🎤 Microphone: ${micStatus.isDenied ? 'DENIED' : 'GRANTED'}');

      if (cameraStatus.isGranted && micStatus.isGranted) {
        setState(() => _permissionsGranted = true);
        _loadDailyPage();
      } else {
        setState(() {
          _errorMessage =
              'Les permissions camera et microphone sont requises.';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error: $e');
      _loadDailyPage();
    }
  }

  void _loadDailyPage() {
    final roomCode = widget.meeting.id;

    final htmlContent = '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
            * {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
            }
            body {
                background: #000;
                color: #fff;
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                display: flex;
                flex-direction: column;
                justify-content: center;
                align-items: center;
                height: 100vh;
                text-align: center;
            }
            .container {
                padding: 20px;
            }
            h1 {
                font-size: 24px;
                margin-bottom: 20px;
                color: #2D8CFF;
            }
            .live-badge {
                display: inline-block;
                background: #FF0000;
                color: white;
                padding: 8px 16px;
                border-radius: 20px;
                font-weight: bold;
                margin-bottom: 20px;
                animation: pulse 1s infinite;
            }
            @keyframes pulse {
                0%, 100% { opacity: 1; }
                50% { opacity: 0.7; }
            }
            p {
                font-size: 16px;
                color: #999;
                margin-bottom: 30px;
            }
            .spinner {
                border: 4px solid #333;
                border-top: 4px solid #2D8CFF;
                border-radius: 50%;
                width: 50px;
                height: 50px;
                animation: spin 1s linear infinite;
                margin: 0 auto;
            }
            @keyframes spin {
                0% { transform: rotate(0deg); }
                100% { transform: rotate(360deg); }
            }
        </style>
    </head>
    <body>
        <div class="container">
            ${widget.isLiveStream ? '<div class="live-badge">🔴 EN DIRECT YOUTUBE</div>' : ''}
            <h1>Chargement de la reunion...</h1>
            <p>Connexion à Daily.co</p>
            <div class="spinner"></div>
        </div>
        <script>
            setTimeout(function() {
                window.location.href = 'https://crux.daily.co/$roomCode';
            }, 2000);
        </script>
    </body>
    </html>
    ''';

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(
          'Mozilla/5.0 (Linux; Android 12) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36')
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            print('📱 Loading: $url');
          },
          onPageFinished: (url) {
            print('✅ Page loaded');
            if (mounted) {
              setState(() => _isLoading = false);
            }
          },
          onWebResourceError: (error) {
            print('❌ Error: ${error.description}');
            if (mounted) {
              setState(() {
                _errorMessage = error.description;
                _isLoading = false;
              });
            }
          },
        ),
      )
      ..loadHtmlString(htmlContent);

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickCoverImage() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        setState(() {
          _coverImage = File(image.path);
        });
        print('✅ Image sélectionnée');
      }
    } catch (e) {
      print('❌ Error picking image: $e');
    }
  }

  Future<void> _startYouTubeStream() async {
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
              const SizedBox(height: 16),
              const Divider(color: Colors.white10),
              const SizedBox(height: 8),
              _coverImage == null
                  ? ElevatedButton.icon(
                      onPressed: _pickCoverImage,
                      icon: const Icon(Icons.image),
                      label: const Text('Choisir image'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.surfaceLight,
                      ),
                    )
                  : Column(
                      children: [
                        Container(
                          height: 120,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: FileImage(_coverImage!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: _pickCoverImage,
                          icon: const Icon(Icons.edit),
                          label: const Text('Changer'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.surfaceLight,
                          ),
                        ),
                      ],
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
      final success = await YouTubeLiveService.startYouTubeStream(
        widget.meeting.id,
        streamKey,
        streamTitle.isEmpty ? widget.meeting.title : streamTitle,
        _coverImage?.path,
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
          await YouTubeLiveService.stopYouTubeStream(widget.meeting.id);
      setState(() {
        _isStreaming = !success;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  'Permissions requises',
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
                    _grantPermissionsFirst();
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
                  : 'Voulez-vous quitter ?',
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
                    : _startYouTubeStream,
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
        body: WebViewWidget(
          controller: _webViewController,
        ),
      ),
    );
  }
}
