import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../models/user_model.dart';
import '../models/meeting_model.dart';
import '../services/meeting_service.dart';
import '../services/auth_service.dart';
import '../widgets/custom_button.dart';
import '../screens/meeting_screen.dart';
import '../screens/login_screen.dart';
import '../screens/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final UserModel user;
  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MeetingService _meetingService = MeetingService();
  final AuthService _authService = AuthService();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _scheduleCodeController = TextEditingController();
  final TextEditingController _scheduleTitleController = TextEditingController();
  bool _isCreating = false;
  bool _isJoining = false;
  bool _isScheduling = false;
  List<MeetingModel> _scheduledMeetings = [];
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _loadScheduledMeetings();
  }

  Future<void> _loadScheduledMeetings() async {
    final meetings =
    await _meetingService.getScheduledMeetings(widget.user.uid);
    if (mounted) setState(() => _scheduledMeetings = meetings);
  }

  void _createMeeting() async {
    setState(() => _isCreating = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Creation de la reunion en cours...'),
        duration: Duration(seconds: 30),
      ),
    );
    final meeting = await _meetingService.createMeeting(
      'Reunion CRUX',
      widget.user.uid,
      widget.user.name,
    );
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    if (meeting != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              MeetingScreen(meeting: meeting, user: widget.user),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible de creer la reunion.'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
    if (mounted) setState(() => _isCreating = false);
  }

  void _joinMeeting() async {
    if (_codeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entrez un code de reunion')),
      );
      return;
    }
    setState(() => _isJoining = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Recherche de la reunion...'),
        duration: Duration(seconds: 30),
      ),
    );
    final meeting = await _meetingService.joinMeeting(
      _codeController.text.trim().toUpperCase(),
    );
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    if (meeting != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              MeetingScreen(meeting: meeting, user: widget.user),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reunion introuvable. Verifiez le code.'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
    if (mounted) setState(() => _isJoining = false);
  }

  void _showScheduleDialog() {
    DateTime selectedDate =
    DateTime.now().add(const Duration(hours: 1));
    _scheduleTitleController.clear();
    _scheduleCodeController.text =
        _meetingService.generateMeetingCode();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          title: const Text('Programmer une reunion',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Titre',
                    style: TextStyle(
                        color: AppColors.grey, fontSize: 12)),
                const SizedBox(height: 6),
                TextField(
                  controller: _scheduleTitleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Ex: Reunion equipe',
                    hintStyle:
                    const TextStyle(color: AppColors.grey),
                    filled: true,
                    fillColor: AppColors.surfaceLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Code personnalise',
                    style: TextStyle(
                        color: AppColors.grey, fontSize: 12)),
                const SizedBox(height: 6),
                TextField(
                  controller: _scheduleCodeController,
                  style: const TextStyle(
                      color: Colors.white,
                      letterSpacing: 3,
                      fontWeight: FontWeight.bold),
                  textCapitalization: TextCapitalization.characters,
                  maxLength: 6,
                  decoration: InputDecoration(
                    hintText: 'ABC123',
                    hintStyle:
                    const TextStyle(color: AppColors.grey),
                    filled: true,
                    fillColor: AppColors.surfaceLight,
                    counterStyle:
                    const TextStyle(color: AppColors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.refresh,
                          color: AppColors.primary),
                      onPressed: () {
                        _scheduleCodeController.text =
                            _meetingService.generateMeetingCode();
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Date et heure',
                    style: TextStyle(
                        color: AppColors.grey, fontSize: 12)),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now()
                          .add(const Duration(days: 365)),
                      builder: (context, child) => Theme(
                        data: ThemeData.dark().copyWith(
                          colorScheme: const ColorScheme.dark(
                              primary: AppColors.primary),
                        ),
                        child: child!,
                      ),
                    );
                    if (date != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime:
                        TimeOfDay.fromDateTime(selectedDate),
                        builder: (context, child) => Theme(
                          data: ThemeData.dark().copyWith(
                            colorScheme: const ColorScheme.dark(
                                primary: AppColors.primary),
                          ),
                          child: child!,
                        ),
                      );
                      if (time != null) {
                        setDialogState(() {
                          selectedDate = DateTime(
                              date.year,
                              date.month,
                              date.day,
                              time.hour,
                              time.minute);
                        });
                      }
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            color: AppColors.primary, size: 18),
                        const SizedBox(width: 12),
                        Text(
                          '${selectedDate.day}/${selectedDate.month}/${selectedDate.year} a ${selectedDate.hour.toString().padLeft(2, '0')}:${selectedDate.minute.toString().padLeft(2, '0')}',
                          style:
                          const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler',
                  style: TextStyle(color: AppColors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_scheduleTitleController.text.trim().isEmpty)
                  return;
                setState(() => _isScheduling = true);
                Navigator.pop(context);
                final meeting =
                await _meetingService.scheduleMeeting(
                  _scheduleTitleController.text.trim(),
                  widget.user.uid,
                  widget.user.name,
                  selectedDate,
                  customCode: _scheduleCodeController.text
                      .trim()
                      .toUpperCase(),
                );
                setState(() => _isScheduling = false);
                if (meeting != null && mounted) {
                  await _loadScheduledMeetings();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Reunion programmee ! Code: ${meeting.id}'),
                      backgroundColor: AppColors.success,
                      duration: const Duration(seconds: 4),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary),
              child: const Text('Programmer',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          'CRUX',
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: AppColors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const SettingsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.white),
            onPressed: _logout,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Row(
            children: [
              _tabButton('Accueil', 0),
              _tabButton('Programmees', 1),
            ],
          ),
        ),
      ),
      body: _selectedTab == 0 ? _buildHome() : _buildScheduled(),
    );
  }

  Widget _tabButton(String label, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected
                    ? AppColors.primary
                    : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color:
              isSelected ? AppColors.primary : AppColors.grey,
              fontWeight: isSelected
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHome() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withOpacity(0.7)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white24,
                  child: Text(
                    widget.user.name.isNotEmpty
                        ? widget.user.name[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bonjour, ${widget.user.name} !',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Que voulez-vous faire ?',
                        style: TextStyle(
                            color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: _quickActionCard(
                  icon: Icons.video_call,
                  label: 'Nouvelle\nreunion',
                  color: AppColors.primary,
                  onTap: _createMeeting,
                  isLoading: _isCreating,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _quickActionCard(
                  icon: Icons.calendar_month,
                  label: 'Programmer\nune reunion',
                  color: AppColors.success,
                  onTap: _showScheduleDialog,
                  isLoading: _isScheduling,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.group_add,
                        color: AppColors.primary, size: 24),
                    SizedBox(width: 10),
                    Text(
                      'Rejoindre une reunion',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _codeController,
                  style: const TextStyle(
                    color: AppColors.white,
                    letterSpacing: 4,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  textCapitalization: TextCapitalization.characters,
                  maxLength: 6,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'[A-Za-z0-9]')),
                  ],
                  decoration: InputDecoration(
                    hintText: 'Ex: ABC123',
                    hintStyle: const TextStyle(
                        color: AppColors.grey, letterSpacing: 2),
                    filled: true,
                    fillColor: AppColors.background,
                    counterStyle:
                    const TextStyle(color: AppColors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: AppColors.primary, width: 2),
                    ),
                    prefixIcon:
                    const Icon(Icons.tag, color: AppColors.grey),
                  ),
                ),
                const SizedBox(height: 12),
                CustomButton(
                  text: AppConstants.joinMeeting,
                  onPressed: _joinMeeting,
                  isLoading: _isJoining,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: isLoading
                  ? const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              )
                  : Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduled() {
    if (_scheduledMeetings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calendar_today,
                color: AppColors.grey, size: 64),
            const SizedBox(height: 16),
            const Text('Aucune reunion programmee',
                style: TextStyle(
                    color: AppColors.grey, fontSize: 16)),
            const SizedBox(height: 8),
            const Text('Programmez votre prochaine reunion',
                style: TextStyle(
                    color: AppColors.grey, fontSize: 13)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showScheduleDialog,
              icon: const Icon(Icons.add),
              label: const Text('Programmer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadScheduledMeetings,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _scheduledMeetings.length,
        itemBuilder: (context, index) {
          final meeting = _scheduledMeetings[index];
          final isUpcoming = meeting.scheduledAt != null &&
              meeting.scheduledAt!.isAfter(DateTime.now());
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isUpcoming
                    ? AppColors.primary.withOpacity(0.3)
                    : Colors.white10,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isUpcoming
                        ? AppColors.primary.withOpacity(0.2)
                        : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.video_call,
                    color: isUpcoming
                        ? AppColors.primary
                        : AppColors.grey,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meeting.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (meeting.scheduledAt != null)
                        Text(
                          '${meeting.scheduledAt!.day}/${meeting.scheduledAt!.month}/${meeting.scheduledAt!.year} a ${meeting.scheduledAt!.hour.toString().padLeft(2, '0')}:${meeting.scheduledAt!.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                              color: AppColors.grey, fontSize: 12),
                        ),
                      Row(
                        children: [
                          const Icon(Icons.tag,
                              color: AppColors.primary, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            meeting.id,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(
                                  ClipboardData(text: meeting.id));
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                const SnackBar(
                                    content: Text('Code copie !'),
                                    duration: Duration(seconds: 1)),
                              );
                            },
                            child: const Icon(Icons.copy,
                                color: AppColors.primary, size: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final m = await _meetingService
                        .joinMeeting(meeting.id);
                    if (m != null && mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MeetingScreen(
                              meeting: m, user: widget.user),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Rejoindre',
                      style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}