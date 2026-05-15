import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/colors.dart';
import '../models/user_model.dart';
import '../models/meeting_model.dart';

class MeetingScreenDaily extends StatefulWidget {
  final MeetingModel meeting;
  final UserModel user;

  const MeetingScreenDaily({
    super.key,
    required this.meeting,
    required this.user,
  });

  @override
  State<MeetingScreenDaily> createState() => _MeetingScreenDailyState();
}

class _MeetingScreenDailyState extends State<MeetingScreenDaily> {
  late WebViewController _webViewController;
  bool _isLoading = true;
  bool _permissionsGranted = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkAndRequestPermissions();
  }

  Future<void> _checkAndRequestPermissions() async {
    try {
      print('🔐 Checking permissions...');

      // Vérifier l'état actuel
      final cameraStatus = await Permission.camera.status;
      final micStatus = await Permission.microphone.status;

      print('📷 Camera status: $cameraStatus');
      print('🎤 Microphone status: $micStatus');

      // Si déjà accordées, continuer
      if (cameraStatus.isGranted && micStatus.isGranted) {
        print('✅ Permissions already granted');
        _permissionsGranted = true;
        _initializeWebView();
        return;
      }

      // Demander les permissions
      print('📋 Requesting permissions...');

      final cameraResult = await Permission.camera.request();
      final micResult = await Permission.microphone.request();

      print('📷 Camera result: $cameraResult');
      print('🎤 Microphone result: $micResult');

      if (cameraResult.isGranted && micResult.isGranted) {
        print('✅ Permissions granted');
        _permissionsGranted = true;
        _initializeWebView();
        return;
      }

      if (cameraResult.isDenied || micResult.isDenied) {
        print('⚠️ Permissions denied by user');
        if (mounted) {
          setState(() {
            _errorMessage =
                'Les permissions camera et microphone sont requises pour la videconference.';
            _isLoading = false;
          });
        }
        return;
      }

      if (cameraResult.isPermanentlyDenied ||
          micResult.isPermanentlyDenied) {
        print('❌ Permissions permanently denied');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                  'Les permissions sont refusees. Allez aux parametres.'),
              backgroundColor: AppColors.danger,
              action: SnackBarAction(
                label: 'Parametres',
                onPressed: () => openAppSettings(),
              ),
            ),
          );
        }
        return;
      }

      _initializeWebView();
    } catch (e) {
      print('❌ Error checking permissions: $e');
      _initializeWebView();
    }
  }

  void _initializeWebView() {
    final roomCode = widget.meeting.id;
    final roomUrl = 'https://crux.daily.co/$roomCode';

    print('🔗 Loading Daily.co room: $roomUrl');

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(
          'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.4896.75 Mobile Safari/537.36')
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            print('📱 Page loading: $url');
          },
          onPageFinished: (String url) {
            print('✅ Page loaded: $url');
            if (mounted) {
              setState(() => _isLoading = false);
            }
          },
          onWebResourceError: (WebResourceError error) {
            print('❌ Web error: ${error.description}');
            if (mounted) {
              setState(() {
                _errorMessage = error.description;
                _isLoading = false;
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(roomUrl));

    _webViewController = controller;

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _errorMessage == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: 16),
              Text(
                'Chargement de la reunion...',
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          title: const Text('Erreur'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,
                    color: AppColors.danger, size: 60),
                const SizedBox(height: 16),
                const Text(
                  'Erreur de connexion',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  style: const TextStyle(
                      color: Colors.white54, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                      _errorMessage = null;
                      _permissionsGranted = false;
                    });
                    _checkAndRequestPermissions();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reessayer'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            title: const Text('Quitter la reunion ?',
                style: TextStyle(color: Colors.white)),
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
          Navigator.pop(context);
        }
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          title: Column(
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
              Text(
                'Code: ${widget.meeting.id}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.call_end,
                  color: AppColors.danger),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        body: WebViewWidget(controller: _webViewController),
      ),
    );
  }
}
