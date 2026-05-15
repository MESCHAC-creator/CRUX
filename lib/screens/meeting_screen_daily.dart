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
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _requestPermissionsAndLoad();
  }

  Future<void> _requestPermissionsAndLoad() async {
    try {
      print('🔐 Requesting camera and microphone permissions...');

      // Request permissions one by one
      final cameraPermission = await Permission.camera.request();
      final microphonePermission =
          await Permission.microphone.request();

      print('📷 Camera: $cameraPermission');
      print('🎤 Microphone: $microphonePermission');

      // Check if permissions were granted
      if (cameraPermission.isGranted &&
          microphonePermission.isGranted) {
        print('✅ All permissions granted');
        _initializeWebView();
      } else if (cameraPermission.isDenied ||
          microphonePermission.isDenied) {
        print('⚠️ Permissions denied');
        if (mounted) {
          setState(() {
            _errorMessage =
                'Les permissions camera et microphone sont requises.';
            _isLoading = false;
          });
        }
      } else if (cameraPermission.isPermanentlyDenied ||
          microphonePermission.isPermanentlyDenied) {
        print('❌ Permissions permanently denied');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                  'Permissions refusees. Allez aux parametres.'),
              backgroundColor: AppColors.danger,
              action: SnackBarAction(
                label: 'Parametres',
                onPressed: () => openAppSettings(),
              ),
            ),
          );
          _initializeWebView();
        }
      } else {
        _initializeWebView();
      }
    } catch (e) {
      print('❌ Error requesting permissions: $e');
      _initializeWebView();
    }
  }

  void _initializeWebView() {
    final roomCode = widget.meeting.id;
    final roomUrl = 'https://crux.daily.co/$roomCode';

    print('🔗 Loading room: $roomUrl');

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
      ..loadRequest(Uri.parse(roomUrl));

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // LOADING STATE
    if (_isLoading && _errorMessage == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: 20),
              Text(
                'Chargement de la reunion...',
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

    // ERROR STATE
    if (_errorMessage != null) {
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
                      _isLoading = true;
                      _errorMessage = null;
                    });
                    _requestPermissionsAndLoad();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reessayer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // WEBVIEW STATE
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
            content: const Text(
              'Voulez-vous quitter cette reunion ?',
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
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 2,
          title: Column(
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
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
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
