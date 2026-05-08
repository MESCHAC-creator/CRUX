import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import '../../core/theme.dart';
import '../../core/l10n.dart';

class AppController extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  String _lang = 'fr';

  ThemeMode get themeMode => _themeMode;
  String get lang => _lang;

  void toggleTheme() {
    _themeMode =
    _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  void toggleLang() {
    _lang = _lang == 'fr' ? 'en' : 'fr';
    notifyListeners();
  }

  bool get isDark => _themeMode == ThemeMode.dark;
}

class _FeatureItem {
  final IconData icon;
  final Color iconBg;
  final String titleKey;
  final String descKey;
  const _FeatureItem({
    required this.icon,
    required this.iconBg,
    required this.titleKey,
    required this.descKey,
  });
}

const _features = [
  _FeatureItem(
    icon: Icons.videocam_rounded,
    iconBg: Color(0xFFEDE9FF),
    titleKey: 'featHdTitle',
    descKey: 'featHdDesc',
  ),
  _FeatureItem(
    icon: Icons.calendar_month_rounded,
    iconBg: Color(0xFFE0F9F4),
    titleKey: 'featScheduleTitle',
    descKey: 'featScheduleDesc',
  ),
  _FeatureItem(
    icon: Icons.chat_bubble_outline_rounded,
    iconBg: Color(0xFFE8F0FE),
    titleKey: 'featChatTitle',
    descKey: 'featChatDesc',
  ),
  _FeatureItem(
    icon: Icons.lock_outline_rounded,
    iconBg: Color(0xFFE6FAF3),
    titleKey: 'featSecureTitle',
    descKey: 'featSecureDesc',
  ),
];

class _Stat {
  final String value;
  final String labelKey;
  final Color color;
  const _Stat(this.value, this.labelKey, this.color);
}

const _stats = [
  _Stat('12 K+', 'statUsers', Color(0xFF6C63FF)),
  _Stat('3 K+', 'statCalls', Color(0xFF00D4AA)),
  _Stat('99.9%', 'statUptime', Color(0xFF4F46E5)),
];

class HomeScreen extends StatefulWidget {
  final AppController controller;
  const HomeScreen({super.key, required this.controller});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final _codeController = TextEditingController();
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  String get _lang => widget.controller.lang;
  String _t(String key) => CruxL10n.t(key, lang: _lang);

  String _generateMeetingCode() {
    const chars = 'abcdefghijklmnopqrstuvwxyz';
    final rnd = Random();
    String seg(int n) =>
        List.generate(n, (_) => chars[rnd.nextInt(chars.length)]).join();
    return 'crux-${seg(3)}-${seg(4)}';
  }

  void _handleNewMeeting() {
    final code = _generateMeetingCode();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Réunion créée : $code'),
        behavior: SnackBarBehavior.floating,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'Copier',
          onPressed: () => Clipboard.setData(ClipboardData(text: code)),
        ),
      ),
    );
  }

  void _handleJoinMeeting() {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Connexion à : $code…'),
        behavior: SnackBarBehavior.floating,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final isDark = widget.controller.isDark ||
            (widget.controller.themeMode == ThemeMode.system &&
                MediaQuery.platformBrightnessOf(context) == Brightness.dark);
        final textPrimary = isDark
            ? CruxColors.textPrimaryDark
            : CruxColors.textPrimaryLight;
        final textSecondary = isDark
            ? CruxColors.textSecondaryDark
            : CruxColors.textSecondaryLight;
        final cardBg =
        isDark ? CruxColors.cardDark : CruxColors.cardLight;
        final borderColor =
        isDark ? CruxColors.borderDark : CruxColors.borderLight;

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                floating: true,
                backgroundColor:
                (isDark ? CruxColors.cardDark : CruxColors.cardLight)
                    .withOpacity(0.9),
                surfaceTintColor: Colors.transparent,
                flexibleSpace: ClipRect(
                  child: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        color: (isDark
                            ? CruxColors.cardDark
                            : CruxColors.cardLight)
                            .withOpacity(0.9),
                        border: Border(
                          bottom:
                          BorderSide(color: borderColor, width: 0.5),
                        ),
                      ),
                    ),
                  ),
                ),
                title: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            CruxColors.gradientStart,
                            CruxColors.gradientEnd
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          'C',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _t('appName'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const Spacer(),
                    _IconBtn(
                      tooltip: 'Langue',
                      color: textPrimary,
                      onTap: widget.controller.toggleLang,
                      child: Text(
                        _lang.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    _IconBtn(
                      tooltip: isDark ? 'Mode clair' : 'Mode sombre',
                      color: textPrimary,
                      onTap: widget.controller.toggleTheme,
                      child: Icon(
                        isDark
                            ? Icons.wb_sunny_outlined
                            : Icons.nightlight_round_outlined,
                        size: 18,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        _t('login'),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    _GradientButton(
                      label: _t('signup'),
                      onTap: () {},
                    ),
                  ],
                ),
                automaticallyImplyLeading: false,
              ),
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: _HeroSection(
                      lang: _lang,
                      t: _t,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                      onNewMeeting: _handleNewMeeting,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 8),
                  child: _QuickJoinBar(
                    controller: _codeController,
                    hint: _t('quickJoinHint'),
                    btnLabel: _t('quickJoinBtn'),
                    isDark: isDark,
                    borderColor: borderColor,
                    onJoin: _handleJoinMeeting,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 16),
                  child: Row(
                    children: _stats.map((s) {
                      return Expanded(
                        child: _StatCard(
                          value: s.value,
                          label: _t(s.labelKey),
                          color: s.color,
                          isDark: isDark,
                          borderColor: borderColor,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 8),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                        (context, i) {
                      final f = _features[i];
                      return _AnimatedFeatureCard(
                        icon: f.icon,
                        iconBg: isDark
                            ? f.iconBg.withOpacity(0.15)
                            : f.iconBg,
                        iconColor: CruxColors.primary,
                        title: _t(f.titleKey),
                        description: _t(f.descKey),
                        isDark: isDark,
                        borderColor: borderColor,
                        cardBg: cardBg,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        delay: Duration(milliseconds: 100 * i),
                      );
                    },
                    childCount: _features.length,
                  ),
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.15,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                    children: [
                      Divider(color: borderColor, height: 1),
                      const SizedBox(height: 20),
                      Text(
                        '© ${DateTime.now().year} CRUX · ${_t("footerCopyright")}',
                        style:
                        TextStyle(fontSize: 13, color: textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HeroSection extends StatelessWidget {
  final String lang;
  final String Function(String) t;
  final Color textPrimary;
  final Color textSecondary;
  final bool isDark;
  final VoidCallback onNewMeeting;

  const _HeroSection({
    required this.lang,
    required this.t,
    required this.textPrimary,
    required this.textSecondary,
    required this.isDark,
    required this.onNewMeeting,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [const Color(0xFF1A1040), CruxColors.backgroundDark]
              : [const Color(0xFFEDE9FF), CruxColors.backgroundLight],
        ),
      ),
      child: Column(
        children: [
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: CruxColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: CruxColors.primary.withOpacity(0.25),
                  width: 0.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: CruxColors.accent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  lang == 'fr'
                      ? 'Maintenant disponible · v1.0'
                      : 'Now available · v1.0',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: CruxColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${t("heroTitle1")}\n',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                    letterSpacing: -1.2,
                    color: textPrimary,
                  ),
                ),
                WidgetSpan(
                  child: ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [
                        CruxColors.gradientStart,
                        CruxColors.gradientEnd,
                      ],
                    ).createShader(bounds),
                    child: Text(
                      t('heroTitle2'),
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            t('tagline'),
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 16, height: 1.6, color: textSecondary),
          ),
          const SizedBox(height: 28),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              _GradientButton(
                label: t('getStarted'),
                icon: Icons.arrow_forward_rounded,
                height: 50,
                fontSize: 15,
                onTap: () {},
              ),
              OutlinedButton.icon(
                onPressed: onNewMeeting,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(t('newMeetingBtn')),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 50),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 22, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  side: BorderSide(
                    color: isDark
                        ? CruxColors.borderDark
                        : CruxColors.borderLight,
                  ),
                  foregroundColor: textPrimary,
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickJoinBar extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final String btnLabel;
  final bool isDark;
  final Color borderColor;
  final VoidCallback onJoin;

  const _QuickJoinBar({
    required this.controller,
    required this.hint,
    required this.btnLabel,
    required this.isDark,
    required this.borderColor,
    required this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: isDark ? CruxColors.cardDark : CruxColors.cardLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          const Icon(Icons.link_rounded,
              size: 18, color: CruxColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onSubmitted: (_) => onJoin(),
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? CruxColors.textPrimaryDark
                    : CruxColors.textPrimaryLight,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? CruxColors.textSecondaryDark
                      : CruxColors.textSecondaryLight,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          GestureDetector(
            onTap: onJoin,
            child: Container(
              margin: const EdgeInsets.all(4),
              padding: const EdgeInsets.symmetric(
                  horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    CruxColors.gradientStart,
                    CruxColors.gradientEnd
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                btnLabel,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final bool isDark;
  final Color borderColor;

  const _StatCard({
    required this.value,
    required this.label,
    required this.color,
    required this.isDark,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.12 : 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2), width: 0.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? CruxColors.textSecondaryDark
                  : CruxColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedFeatureCard extends StatefulWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String description;
  final bool isDark;
  final Color borderColor;
  final Color cardBg;
  final Color textPrimary;
  final Color textSecondary;
  final Duration delay;

  const _AnimatedFeatureCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.isDark,
    required this.borderColor,
    required this.cardBg,
    required this.textPrimary,
    required this.textSecondary,
    required this.delay,
  });

  @override
  State<_AnimatedFeatureCard> createState() => _AnimatedFeatureCardState();
}

class _AnimatedFeatureCardState extends State<_AnimatedFeatureCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.cardBg,
            borderRadius: BorderRadius.circular(16),
            border:
            Border.all(color: widget.borderColor, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: widget.iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(widget.icon,
                    size: 20, color: widget.iconColor),
              ),
              const SizedBox(height: 12),
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: widget.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.description,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  color: widget.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;
  final double height;
  final double fontSize;

  const _GradientButton({
    required this.label,
    required this.onTap,
    this.icon,
    this.height = 40,
    this.fontSize = 13,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [CruxColors.gradientStart, CruxColors.gradientEnd],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: CruxColors.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 6),
              Icon(icon, size: 16, color: Colors.white),
            ],
          ],
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final Widget child;
  final String tooltip;
  final Color color;
  final VoidCallback onTap;

  const _IconBtn({
    required this.child,
    required this.tooltip,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Center(child: child),
        ),
      ),
    );
  }
}