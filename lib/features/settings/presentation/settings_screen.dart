import 'package:flutter/material.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/services/storage_service.dart';

class _C {
  static const bg = Color(0xFFF1F6FF);
  static const navy = Color(0xFF0F1F5C);
  static const blue = Color(0xFF1D6BF3);
  static const muted = Color(0xFF6B7A99);
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppSettings>(
      valueListenable: SettingsService.notifier,
      builder: (context, s, _) {
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _topBar(context),
                    const SizedBox(height: 18),

                    // ---------------- Gameplay ----------------
                    _header('Gameplay'),
                    _switchTile(
                      icon: Icons.volume_up_rounded,
                      color: const Color(0xFF2B8CFF),
                      title: 'Sound Effects',
                      subtitle: 'Click sounds while you play',
                      value: s.sound,
                      onChanged: (v) async {
                        await SettingsService.update((x) => x.sound = v);
                        SettingsService.click(); // preview
                      },
                    ),
                    _switchTile(
                      icon: Icons.vibration_rounded,
                      color: const Color(0xFF7C3AED),
                      title: 'Vibration (Haptics)',
                      subtitle: 'Feel taps, mistakes and wins',
                      value: s.vibration,
                      onChanged: (v) async {
                        await SettingsService.update((x) => x.vibration = v);
                        SettingsService.haptic(); // preview
                      },
                    ),
                    _switchTile(
                      icon: Icons.timer_outlined,
                      color: const Color(0xFFF97316),
                      title: 'Timer',
                      subtitle: 'Show a timer during each puzzle',
                      value: s.timer,
                      onChanged: (v) =>
                          SettingsService.update((x) => x.timer = v),
                    ),
                    _switchTile(
                      icon: Icons.rule_rounded,
                      color: const Color(0xFF22C55E),
                      title: 'Auto-Check Equations',
                      subtitle: s.autoCheckEquations
                          ? 'Puzzle finishes as soon as every answer is right'
                          : 'Press Check to finish the puzzle',
                      value: s.autoCheckEquations,
                      onChanged: (v) => SettingsService.update(
                          (x) => x.autoCheckEquations = v),
                    ),
                    const SizedBox(height: 10),

                    // ---------------- Mistakes ----------------
                    _choiceCard(
                      icon: Icons.error_outline_rounded,
                      color: const Color(0xFFEF4444),
                      title: 'Mistake Checking',
                      subtitle: _mistakeHelp(s.mistakeChecking),
                      options: const {
                        'immediate': 'Immediate',
                        'on_check': 'On Check',
                        'off': 'Off',
                      },
                      selected: s.mistakeChecking,
                      onSelect: (v) =>
                          SettingsService.update((x) => x.mistakeChecking = v),
                    ),
                    const SizedBox(height: 18),

                    // ---------------- Appearance ----------------
                    _header('Appearance'),
                    _choiceCard(
                      icon: Icons.text_fields_rounded,
                      color: const Color(0xFFF59E0B),
                      title: 'Text Size',
                      subtitle: s.textSize == 'large'
                          ? 'Larger text everywhere'
                          : 'Default text size',
                      options: const {
                        'normal': 'Normal',
                        'large': 'Large',
                      },
                      selected: s.textSize,
                      onSelect: (v) =>
                          SettingsService.update((x) => x.textSize = v),
                    ),
                    const SizedBox(height: 26),

                    const Center(
                      child: Column(
                        children: [
                          Text('NumCross v1.0.0 (Build 2026.1)',
                              style: TextStyle(
                                  color: _C.muted,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text('Offline-First Cross-Math Engine',
                              style:
                                  TextStyle(color: _C.muted, fontSize: 10)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _mistakeHelp(String mode) {
    switch (mode) {
      case 'on_check':
        return 'Wrong answers show only when you press Check';
      case 'off':
        return 'Wrong answers are never highlighted';
      default:
        return 'Wrong answers turn red right away';
    }
  }

  // ---------------- Pieces ----------------
  Widget _topBar(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (Navigator.of(context).canPop())
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 44,
                height: 44,
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 56),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text('Settings',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: _C.navy)),
              ),
              Text('Make the game work your way',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: _C.muted)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _header(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(title.toUpperCase(),
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: _C.muted,
              letterSpacing: 1.2)),
    );
  }

  Widget _iconBox(IconData icon, Color color) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  Widget _switchTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      decoration: _card(),
      child: Row(
        children: [
          _iconBox(icon, color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: _C.navy)),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12, height: 1.25, color: _C.muted)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: _C.blue,
          ),
        ],
      ),
    );
  }

  Widget _choiceCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required Map<String, String> options,
    required String selected,
    required ValueChanged<String> onSelect,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _card(),
      child: Column(
        children: [
          Row(
            children: [
              _iconBox(icon, color),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: _C.navy)),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 12, height: 1.25, color: _C.muted)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFE9F0FC),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: options.entries.map((e) {
                final isSel = e.key == selected;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      SettingsService.tap();
                      onSelect(e.key);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      height: 38,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSel ? _C.blue : Colors.transparent,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Text(e.value,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: isSel ? Colors.white : _C.muted)),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  List<BoxShadow> get _shadow => [
        BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4)),
      ];

  BoxDecoration _card() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: _shadow,
      );
}