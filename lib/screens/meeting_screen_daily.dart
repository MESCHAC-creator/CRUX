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
  bool _permissionsGranted = false;
  bool _isLoading = true;
  bool _showingPermissions = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Commence par montrer la page de permissions
    _showingPermissions = true;
    _isLoading = false;
  }

  Future<void> _requestPermissions() async {
    setState(() => _isLoading = true);

    try {
      print('🔐 Requesting permissions...');

      final cameraStatus = await Permission.camera.request();
      final micStatus = await Permission.microphone.request();

      print('📷 Camera: $cameraStatus');
      print('🎤 Microphone: $micStatus');

      if (cameraStatus.isGranted && micStatus.isGranted) {
        print('✅ Permissions granted');
        setState(() {
          _permissionsGranted = true;
          _showingPermissions = false;
          _isLoading = false;
        });
        _initializeWebView();
      } else {
        print('⚠️ Permissions denied');
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Camera et microphone requis'),
              backgroundColor: AppColors.danger,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Error: $e');
      setState(() => _isLoading = false);
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
  }

  @override
  Widget build(BuildContext context) {
    // PERMISSIONS PAGE
    if (_showingPermissions) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // BACK BUTTON
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // TITLE
                  const Text(
                    'Permissions requises',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Pour utiliser la videconference, nous avons besoin d\'acceder a votre camera et votre microphone.',
                    style: TextStyle(
                      color: AppColors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // CAMERA PERMISSION CARD
                  _buildPermissionCard(
                    icon: '📷',
                    title: 'Camera',
                    description:
                        'Necessaire pour que les autres vous voient',
                  ),
                  const SizedBox(height: 16),

                  // MICROPHONE PERMISSION CARD
                  _buildPermissionCard(
                    icon: '🎤',
                    title: 'Microphone',
                    description:
                        'Necessaire pour que les autres vous entendent',
                  ),
                  const SizedBox(height: 40),

                  // INSTRUCTIONS
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Comment donner l\'acces ?',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '1. Cliquez sur "Autoriser l\'acces" ci-dessous\n'
                          '2. Des dialogs aparaitront pour chaque permission\n'
                          '3. Acceptez les 2 permissions\n'
                          '4. La reunion se lancera automatiquement',
                          style: TextStyle(
                            color: AppColors.grey,
                            fontSize: 12,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          _isLoading ? null : _requestPermissions,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor:
                            AppColors.primary.withOpacity(0.5),
                        padding: const EdgeInsets.symmetric(
                            vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Autoriser l\'acces',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // LOADING STATE
    if (_isLoading && _errorMessage == null && _permissionsGranted) {
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
                      _showingPermissions = true;
                      _permissionsGranted = false;
                    });
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reessayer'),
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

  Widget _buildPermissionCard({
    required String icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10, width: 2),
      ),
      child: Row(
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppColors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.circle_outlined,
            color: AppColors.grey,
            size: 28,
          ),
        ],
      ),
    );
  }
}
