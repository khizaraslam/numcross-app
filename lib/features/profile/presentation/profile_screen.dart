import 'package:flutter/material.dart';
import '../../../app/config/app_config.dart';
import '../../../core/services/storage_service.dart';
import '../../achievements/presentation/achievements_screen.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../statistics/presentation/statistics_screen.dart';

class _C {
  static const bg = Color(0xFFF1F6FF);
  static const navy = Color(0xFF0F1F5C);
  static const blue = Color(0xFF1D6BF3);
  static const muted = Color(0xFF6B7A99);
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late PlayerProfile _p;
  int _completed = 0;
  int _accuracy = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _p = FlutterStorageService.getProfile();
    int completed = 0;
    int starsSum = 0;
    for (final l in FlutterStorageService.getLevels().values) {
      if (l.isCompleted) {
        completed++;
        starsSum += l.stars;
      }
    }
    _completed = completed;
    // Accuracy = stars earned out of the stars possible
    _accuracy =
        completed > 0 ? ((starsSum / (completed * 3)) * 100).round() : 0;
  }

  int get _totalXp {
    int xp = _p.xp;
    for (int l = 1; l < _p.level; l++) {
      xp += l * 100 + 400;
    }
    return xp;
  }

  String get _avatar => _p.avatar == 'girl' ? '👧' : '👦';

  String _fmt(int n) {
    final s = n.toString();
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
      b.write(s[i]);
    }
    return b.toString();
  }

  Future<void> _push(Widget page) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    if (mounted) setState(_load);
  }

  // ---------------- Edit profile dialog ----------------
  Future<void> _editProfile() async {
    final controller = TextEditingController(text: _p.name);
    String avatar = _p.avatar == 'girl' ? 'girl' : 'boy';

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Edit Profile',
              style: TextStyle(fontWeight: FontWeight.w900, color: _C.navy)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final a in const ['boy', 'girl'])
                    GestureDetector(
                      onTap: () => setLocal(() => avatar = a),
                      child: Container(
                        width: 72,
                        height: 72,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFDCEBFF),
                          border: Border.all(
                            color: avatar == a
                                ? _C.blue
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: Center(
                          child: Text(a == 'girl' ? '👧' : '👦',
                              style: const TextStyle(fontSize: 38)),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                maxLength: 20,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _C.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (saved == true) {
      final name = controller.text.trim();
      _p.name = name.isEmpty ? _p.name : name;
      _p.avatar = avatar;
      await FlutterStorageService.saveProfile(_p);
      if (mounted) setState(_load);
    }
    controller.dispose();
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: AppConfig.appName,
      applicationIcon: const Text('🔢', style: TextStyle(fontSize: 36)),
      children: const [Text('A fun math puzzle game.')],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE3F0FF), Color(0xFFF7FAFF)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              children: [
                _topBar(),
                const SizedBox(height: 14),
                _headerCard(),
                const SizedBox(height: 14),
                _statsCard(),
                const SizedBox(height: 14),
                _menuCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- Top bar ----------------
  Widget _topBar() {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (Navigator.of(context).canPop())
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: _shadow,
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: _C.blue, size: 20),
              ),
            ),
          ),
        const Column(
          children: [
            Text('Profile',
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: _C.navy)),
            SizedBox(height: 2),
            Text('Manage your account and settings',
                style: TextStyle(fontSize: 13, color: _C.muted)),
          ],
        ),
      ],
    );
  }

  // ---------------- Header card ----------------
  Widget _headerCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: Container(
        height: 138,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3F2FF), Color(0xFFA9D5FF)],
          ),
        ),
        child: Stack(
          children: [
            const Positioned(
                right: 6,
                bottom: -4,
                child: Text('🏆', style: TextStyle(fontSize: 92))),
            const Positioned(
                right: 100,
                top: 12,
                child: Text('✨', style: TextStyle(fontSize: 22))),
            Row(
              children: [
                GestureDetector(
                  onTap: _editProfile,
                  child: SizedBox(
                    width: 94,
                    height: 94,
                    child: Stack(
                      children: [
                        Container(
                          width: 94,
                          height: 94,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFBFE0FF),
                            border: Border.all(color: _C.blue, width: 4),
                          ),
                          child: Center(
                              child: Text(_avatar,
                                  style: const TextStyle(fontSize: 52))),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle),
                            child: const Icon(Icons.edit_rounded,
                                color: _C.blue, size: 17),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_p.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.w900,
                              color: _C.navy)),
                      Text('${_fmt(_totalXp)} XP earned',
                          style: const TextStyle(
                              fontSize: 13, color: _C.muted)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('👑',
                                style: TextStyle(fontSize: 18)),
                            const SizedBox(width: 6),
                            Text('Level ${_p.level}',
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: _C.navy)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 70),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- Stats card ----------------
  Widget _statsCard() {
    Widget stat(String emoji, String value, String label) {
      return Expanded(
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 30)),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: _C.navy)),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 12, height: 1.1, color: _C.muted)),
          ],
        ),
      );
    }

    Widget divider() => Container(
        width: 1, height: 70, color: const Color(0xFFE2E8F0));

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
      decoration: _card(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          stat('⭐', '${_p.totalStars}', 'Total Stars'),
          divider(),
          stat('📊', '$_completed', 'Levels\nCompleted'),
          divider(),
          stat('🔥', '${_p.currentStreak}', 'Day Streak'),
          divider(),
          stat('🎯', '$_accuracy%', 'Accuracy'),
        ],
      ),
    );
  }

  // ---------------- Menu ----------------
  Widget _menuCard() {
    final items = <_MenuItem>[
      _MenuItem(Icons.person_rounded, const Color(0xFF2B8CFF),
          const Color(0xFFDCEBFF), 'Edit Profile',
          'Update your name and avatar', _editProfile),
      _MenuItem(Icons.bar_chart_rounded, const Color(0xFF22C55E),
          const Color(0xFFDDF6E8), 'Statistics', 'View your detailed progress',
          () => _push(const StatisticsScreen())),
      _MenuItem(Icons.emoji_events_rounded, const Color(0xFF7C3AED),
          const Color(0xFFEADFFF), 'Achievements',
          'See your badges and rewards',
          () => _push(const AchievementsScreen())),
      _MenuItem(Icons.settings_rounded, const Color(0xFFF97316),
          const Color(0xFFFFE9D6), 'Settings',
          'Sound, language and app preferences',
          () => _push(const SettingsScreen())),
      _MenuItem(Icons.info_rounded, const Color(0xFF2B8CFF),
          const Color(0xFFDCEBFF), 'About', 'App version and information',
          _showAbout),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: _card(),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            _menuRow(items[i]),
            if (i != items.length - 1)
              const Divider(height: 1, color: Color(0xFFE9EEF7)),
          ],
        ],
      ),
    );
  }

  Widget _menuRow(_MenuItem m) {
    return GestureDetector(
      onTap: m.onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: m.bg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(m.icon, color: m.color, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(m.title,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: _C.navy)),
                  Text(m.subtitle,
                      style:
                          const TextStyle(fontSize: 12, color: _C.muted)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: _C.muted),
          ],
        ),
      ),
    );
  }

  // ---------------- Helpers ----------------
  List<BoxShadow> get _shadow => [
        BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4)),
      ];

  BoxDecoration _card() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: _shadow,
      );
}

class _MenuItem {
  final IconData icon;
  final Color color;
  final Color bg;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  _MenuItem(this.icon, this.color, this.bg, this.title, this.subtitle,
      this.onTap);
}