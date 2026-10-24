// DISTINCT ROLLOUT V3 — zapzipzone: "Bottom panel"
// Layout template from distinct-samples/pingpongpop.
import 'package:flutter/material.dart';
import '../theme/arcade_config.dart';
import '../engine/arcade_engine.dart';
import '../services/settings_service.dart';
import '../services/sound_service.dart';
import 'game_screen.dart';
import 'settings_screen.dart';
import 'support_screen.dart';

const List<String> _emojiFb = ['Noto Color Emoji'];

class MenuScreen extends StatefulWidget {
  final ArcadeConfig config;
  const MenuScreen({super.key, required this.config});
  @override State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  int highScore = 0;
  String playerName = 'Player 1';

  @override void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final svc = SettingsService('${widget.config.slug}_');
    final h = await svc.getHighScore();
    final n = await svc.getPlayerName();
    if (mounted) setState(() { highScore = h; playerName = n; });
  }

  void _play() async {
    final svc = SettingsService('${widget.config.slug}_');
    final diff = await svc.getDifficulty();
    final shape = await svc.getShape();
    final mul = [0.8, 1.0, 1.3][diff.clamp(0, 2)];
    final sound = SoundService('${widget.config.slug}_');
    await sound.load();
    await sound.click();
    if (!mounted) return;
    Navigator.push(context, MaterialPageRoute(builder: (_) => GameScreen(
      config: widget.config,
      engine: ArcadeEngine(cfg: widget.config, diffMul: mul),
      sound: sound,
      shape: shape,
    ))).then((_) => _load());
  }

  @override Widget build(BuildContext context) {
    final c = widget.config;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [c.primaryColor.withOpacity(0.55), c.darkColor])),
        child: SafeArea(child: Column(children: [
          Expanded(child: Center(child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(c.playerEmoji,
                  style: const TextStyle(fontSize: 72, fontFamilyFallback: _emojiFb)),
              const SizedBox(height: 12),
              Text(c.displayName.toUpperCase(), textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w700, letterSpacing: 3.0, fontFamilyFallback: _emojiFb)),
              const SizedBox(height: 6),
              Text(c.tagline, textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 14, fontFamilyFallback: _emojiFb)),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(20)),
                child: Text('🏆 $playerName — Best: $highScore',
                    style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontFamilyFallback: _emojiFb)),
              ),
            ])))),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            decoration: BoxDecoration(
              color: c.darkColor.withOpacity(0.85),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(children: [
              SizedBox(width: double.infinity, child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: c.accentColor, foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: const StadiumBorder()),
                onPressed: _play,
                child: const Text('▶  PLAY', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, fontFamilyFallback: _emojiFb)))),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _miniBtn('❓  HOW TO PLAY', () => _howTo(context, c))),
                const SizedBox(width: 8),
                Expanded(child: _miniBtn('⚙️  SETTINGS', () {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (_) => SettingsScreen(config: c))).then((_) => _load());
                })),
                const SizedBox(width: 8),
                Expanded(child: _miniBtn('💛  SUPPORT', () {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (_) => SupportScreen(config: c)));
                })),
              ]),
              const SizedBox(height: 16),
              const Text('Credits: WAJIHA', style: TextStyle(color: Colors.white38, fontSize: 12, fontFamilyFallback: _emojiFb)),
            ]),
          ),
        ])),
      ),
    );
  }

  void _howTo(BuildContext ctx, ArcadeConfig c) {
    showDialog(context: ctx, builder: (_) => AlertDialog(
      backgroundColor: c.darkColor,
      title: Text(c.displayName, style: const TextStyle(color: Colors.white, fontFamilyFallback: _emojiFb)),
      content: Text(c.howTo, style: const TextStyle(color: Colors.white70, fontFamilyFallback: _emojiFb)),
      actions: [TextButton(
        onPressed: () => Navigator.pop(ctx),
        child: Text('GOT IT', style: TextStyle(color: c.accentColor, fontFamilyFallback: _emojiFb)))],
    ));
  }

  Widget _miniBtn(String label, VoidCallback onTap) => ElevatedButton(
    style: ElevatedButton.styleFrom(backgroundColor: Colors.white24, foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
      shape: const StadiumBorder()),
    onPressed: onTap,
    child: FittedBox(fit: BoxFit.scaleDown,
      child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, fontFamilyFallback: _emojiFb))));
}
