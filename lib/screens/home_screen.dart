import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../utils/colors.dart';
import '../models/user_model.dart';
import '../models/meeting_model.dart';
import '../services/meeting_service.dart';
import '../services/permission_service.dart';
import '../widgets/custom_button.dart';
import 'meeting_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final UserModel user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final MeetingService _meetingService = MeetingService();
  late TabController _tabController;
  bool _permissionsGranted = false;
  bool _checkingPermissions = true;
  String _selectedMode = 'standard';

  final List<Map<String, dynamic>> _modes = [
    {
      'name': 'Standard',
      'icon': '🎯',
      'value': 'standard',
      'color': const Color(0xFF2D8CFF),
    },
    {
      'name': 'Eglise',
      'icon': '⛪',
      'value': 'church',
      'color': const Color(0xFF6B5B95),
    },
    {
      'name': 'Ecole',
      'icon': '🎓',
      'value': 'education',
      'color': const Color(0xFF88B04B),
    },
    {
      'name': 'Entreprise',
      'icon': '💼',
      'value': 'enterprise',
      'color': const Color(0xFFF7CAC9),
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _requestPermissionsAtStartup();
  }

  Future<void> _requestPermissionsAtStartup() async {
    setState(() => _checkingPermissions = true);
    
    final granted = await PermissionService.requestAllPermissions();
    
    if (mounted) {
      setState(() {
        _permissionsGranted = granted;
        _checkingPermissions = false;
      });
    }

    if (!granted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'Permissions refusees. Allez aux parametres pour les accepter.'),
            backgroundColor: AppColors.danger,
            action: SnackBarAction(
              label: 'Parametres',
              onPressed: () =>
                  PermissionService.openAppSettings(),
            ),
          ),
        );
      }
    }
  }

  Future<void> _createMeeting() async {
    final titleController = TextEditingController();
    
    if (!_permissionsGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Permissions requises. Relancez l\'app et acceptez toutes les permissions.'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Nouvelle Reunion',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Titre de la reunion',
                hintStyle: const TextStyle(color: AppColors.grey),
                filled: true,
                fillColor: AppColors.surfaceLight,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler',
                style: TextStyle(color: AppColors.primary)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Entrez un titre'),
                      backgroundColor: AppColors.danger),
                );
                return;
              }

              Navigator.pop(context);
              _createMeetingProcess(titleController.text.trim());
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary),
            child: const Text('Creer'),
          ),
        ],
      ),
    );
  }

  Future<void> _createMeetingProcess(String title) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
            color: AppColors.primary),
      ),
    );

    try {
      final meeting = await _meetingService.createMeeting(
        title,
        widget.user.uid,
        widget.user.name,
        mode: _selectedMode,
      );

      if (mounted) Navigator.pop(context);

      if (meeting != null) {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MeetingScreen(
                meeting: meeting,
                user: widget.user,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Future<void> _scheduleMeeting() async {
    final titleController = TextEditingController();
    DateTime? selectedDate;
    TimeOfDay? selectedTime;
    
    if (!_permissionsGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permissions requises'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          title: const Text('Programmer Une Reunion',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Titre de la reunion',
                    hintStyle: const TextStyle(color: AppColors.grey),
                    filled: true,
                    fillColor: AppColors.surfaceLight,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now()
                          .add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() => selectedDate = date);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            color: AppColors.primary),
                        const SizedBox(width: 12),
                        Text(
                          selectedDate != null
                              ? DateFormat('dd/MM/yyyy')
                                  .format(selectedDate!)
                              : 'Selectionnez la date',
                          style: TextStyle(
                            color: selectedDate != null
                                ? Colors.white
                                : AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null) {
                      setState(() => selectedTime = time);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time,
                            color: AppColors.primary),
                        const SizedBox(width: 12),
                        Text(
                          selectedTime != null
                              ? selectedTime!.format(context)
                              : 'Selectionnez l\'heure',
                          style: TextStyle(
                            color: selectedTime != null
                                ? Colors.white
                                : AppColors.grey,
                          ),
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
                  style: TextStyle(color: AppColors.primary)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Entrez un titre'),
                        backgroundColor: AppColors.danger),
                  );
                  return;
                }
                if (selectedDate == null || selectedTime == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Selectionnez date et heure'),
                        backgroundColor: AppColors.danger),
                  );
                  return;
                }

                final scheduledAt = DateTime(
                  selectedDate!.year,
                  selectedDate!.month,
                  selectedDate!.day,
                  selectedTime!.hour,
                  selectedTime!.minute,
                );

                Navigator.pop(context);
                _scheduleMeetingProcess(
                  titleController.text.trim(),
                  scheduledAt,
                );
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary),
              child: const Text('Programmer'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _scheduleMeetingProcess(
      String title, DateTime scheduledAt) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
            color: AppColors.primary),
      ),
    );

    try {
      final meeting = await _meetingService.scheduleMeeting(
        title,
        widget.user.uid,
        widget.user.name,
        scheduledAt,
        mode: _selectedMode,
      );

      if (mounted) Navigator.pop(context);

      if (meeting != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reunion programmee avec succes !'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Future<void> _joinMeeting() async {
    final codeController = TextEditingController();

    if (!_permissionsGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Permissions requises. Relancez l\'app et acceptez toutes les permissions.'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Rejoindre Reunion',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: codeController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Code de reunion',
                hintStyle: const TextStyle(color: AppColors.grey),
                filled: true,
                fillColor: AppColors.surfaceLight,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler',
                style: TextStyle(color: AppColors.primary)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (codeController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Entrez un code'),
                      backgroundColor: AppColors.danger),
                );
                return;
              }

              Navigator.pop(context);
              _joinMeetingProcess(codeController.text.trim());
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary),
            child: const Text('Rejoindre'),
          ),
        ],
      ),
    );
  }

  Future<void> _joinMeetingProcess(String code) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
            color: AppColors.primary),
      ),
    );

    try {
      final meeting =
          await _meetingService.joinMeeting(code);

      if (mounted) Navigator.pop(context);

      if (meeting != null) {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MeetingScreen(
                meeting: meeting,
                user: widget.user,
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reunion non trouvee'),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingPermissions) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                  color: AppColors.primary),
              const SizedBox(height: 16),
              const Text(
                'Verification des permissions...',
                style: TextStyle(
                    color: Colors.white54, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('CRUX',
                style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    letterSpacing: 4)),
            Text(
              'Bienvenue, ${widget.user.name}',
              style: const TextStyle(
                  color: Colors.white60, fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings,
                color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const SettingsScreen(),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (!_permissionsGranted)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: AppColors.danger.withOpacity(0.2),
              child: Row(
                children: [
                  const Icon(Icons.warning,
                      color: AppColors.danger, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: const Text(
                      'Permissions refusees. Allez aux parametres pour les accepter.',
                      style: TextStyle(
                          color: AppColors.danger,
                          fontSize: 12),
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        PermissionService.openAppSettings(),
                    child: const Text('Parametres',
                        style: TextStyle(
                            color: AppColors.primary)),
                  ),
                ],
              ),
            ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // TAB 1: ACCUEIL
                ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    const Text('MODE DE REUNION',
                        style: TextStyle(
                            color: AppColors.grey,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5)),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1,
                      ),
                      itemCount: _modes.length,
                      itemBuilder: (context, index) {
                        final mode = _modes[index];
                        final isSelected =
                            _selectedMode == mode['value'];
                        return GestureDetector(
                          onTap: () => setState(() =>
                              _selectedMode = mode['value']),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? mode['color']
                                  : AppColors.surface,
                              borderRadius:
                                  BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? mode['color']
                                    : Colors.white10,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Text(mode['icon'],
                                    style: const TextStyle(
                                        fontSize: 32)),
                                const SizedBox(height: 8),
                                Text(
                                  mode['name'],
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.white54,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    CustomButton(
                      text: 'NOUVELLE REUNION',
                      onPressed: _createMeeting,
                      color: AppColors.primary,
                      icon: Icons.add,
                    ),
                    const SizedBox(height: 12),
                    CustomButton(
                      text: 'PROGRAMMER REUNION',
                      onPressed: _scheduleMeeting,
                      color: AppColors.primary,
                      icon: Icons.schedule,
                    ),
                    const SizedBox(height: 12),
                    CustomButton(
                      text: 'REJOINDRE REUNION',
                      onPressed: _joinMeeting,
                      color: AppColors.surfaceLight,
                      textColor: Colors.white,
                      icon: Icons.login,
                    ),
                  ],
                ),
                // TAB 2: PROGRAMMEES
                FutureBuilder<List<MeetingModel>>(
                  future: _meetingService
                      .getScheduledMeetings(widget.user.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primary),
                      );
                    }

                    final meetings = snapshot.data ?? [];
                    if (meetings.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            const Icon(
                                Icons.schedule_outlined,
                                color: AppColors.grey,
                                size: 48),
                            const SizedBox(height: 12),
                            const Text(
                              'Aucune reunion programmee',
                              style: TextStyle(
                                  color: AppColors.grey),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: meetings.length,
                      itemBuilder: (context, index) {
                        final meeting = meetings[index];
                        final date = DateFormat('dd/MM')
                            .format(meeting.scheduledAt ??
                                DateTime.now());
                        final time = DateFormat('HH:mm')
                            .format(meeting.scheduledAt ??
                                DateTime.now());
                        return Container(
                          margin:
                              const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius:
                                BorderRadius.circular(16),
                            border: Border.all(
                                color: Colors.white10),
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                      children: [
                                        Text(
                                          meeting.title,
                                          style: const TextStyle(
                                              color: Colors
                                                  .white,
                                              fontWeight:
                                                  FontWeight
                                                      .bold),
                                        ),
                                        const SizedBox(
                                            height: 4),
                                        Text(
                                          'Code: ${meeting.id}',
                                          style: const TextStyle(
                                              color: AppColors
                                                  .primary,
                                              fontSize: 12,
                                              letterSpacing:
                                                  1),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .end,
                                    children: [
                                      Text(date,
                                          style: const TextStyle(
                                              color: AppColors
                                                  .primary,
                                              fontWeight:
                                                  FontWeight
                                                      .bold)),
                                      Text(time,
                                          style: const TextStyle(
                                              color: AppColors
                                                  .primary,
                                              fontSize: 12)),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              CustomButton(
                                text:
                                    'REJOINDRE MAINTENANT',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          MeetingScreen(
                                        meeting: meeting,
                                        user: widget.user,
                                      ),
                                    ),
                                  );
                                },
                                color:
                                    AppColors.primary,
                                height: 40,
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          Container(
            color: AppColors.surface,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.grey,
              tabs: const [
                Tab(text: 'ACCUEIL'),
                Tab(text: 'PROGRAMMEES'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
