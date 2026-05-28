import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_assignment_e/l10n/app_localizations.dart';
import 'package:project_assignment_e/providers/sound_provider.dart';
import 'package:project_assignment_e/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

// ─── Colours ──────────────────────────────────────────────────────────────────
class _C {
  static const raspberry = Color(0xFF912F56);
  static const rose      = Color(0xFFC4587E);
  static const plum      = Color(0xFF521945);
  static const wine      = Color(0xFF361F27);
  static const gold      = Color(0xFFD4A853);
  static const sage      = Color(0xFF3D7A6A);
  static const bgLight   = Color(0xFFFAF0EE);
  static const bgDark    = Color(0xFF0D090A);
  static const cardD     = Color(0xFF28141E);
}

// ─── Resource model ───────────────────────────────────────────────────────────
class _Resource {
  final IconData icon;
  final String titleKey;
  final String url;
  final List<int> gradColors;
  final InstrumentSound? sound;

  const _Resource({
    required this.icon,
    required this.titleKey,
    required this.url,
    required this.gradColors,
    this.sound,
  });
}

class LearnMusicScreen extends StatefulWidget {
  const LearnMusicScreen({super.key});

  @override
  State<LearnMusicScreen> createState() => _LearnMusicScreenState();
}

class _LearnMusicScreenState extends State<LearnMusicScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  int? _activeSoundIdx;

  // YouTube links — real beginner playlists
  static const _youtubeLinks = [
    _Resource(
      icon: Icons.queue_music_rounded,
      titleKey: 'learnGuitar',
      url: 'https://www.youtube.com/results?search_query=guitar+for+beginners',
      gradColors: [0xFF912F56, 0xFF521945],
      sound: InstrumentSound.guitar,
    ),
    _Resource(
      icon: Icons.piano,
      titleKey: 'learnPiano',
      url: 'https://www.youtube.com/results?search_query=piano+for+beginners',
      gradColors: [0xFF521945, 0xFF2D0E28],
      sound: InstrumentSound.piano,
    ),
    _Resource(
      icon: Icons.graphic_eq_rounded,
      titleKey: 'learnDrums',
      url: 'https://www.youtube.com/results?search_query=drum+lessons+beginners',
      gradColors: [0xFF2E6D5E, 0xFF1A4A3E],
      sound: InstrumentSound.drums,
    ),
    _Resource(
      icon: Icons.music_note_rounded,
      titleKey: 'learnOud',
      url: 'https://www.youtube.com/results?search_query=oud+lessons+beginners',
      gradColors: [0xFFB8602A, 0xFF7A3A10],
      sound: InstrumentSound.oud,
    ),
    _Resource(
      icon: Icons.library_music_rounded,
      titleKey: 'learnTheory',
      url: 'https://www.youtube.com/results?search_query=music+theory+basics',
      gradColors: [0xFF1A3B6B, 0xFF0E2244],
    ),
  ];

  // External learning websites
  static const _learnLinks = [
    _Resource(
      icon: Icons.open_in_new_rounded,
      titleKey: 'learnGuitar',
      url: 'https://www.justinguitar.com',
      gradColors: [0xFF912F56, 0xFF521945],
    ),
    _Resource(
      icon: Icons.open_in_new_rounded,
      titleKey: 'learnPiano',
      url: 'https://www.pianoforall.com',
      gradColors: [0xFF521945, 0xFF2D0E28],
    ),
    _Resource(
      icon: Icons.open_in_new_rounded,
      titleKey: 'learnTheory',
      url: 'https://www.musictheory.net',
      gradColors: [0xFF1A3B6B, 0xFF0E2244],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l      = AppLocalizations.of(context);
    final isDark = context.watch<ThemeProvider>().isDark;
    final bg     = isDark ? _C.bgDark  : _C.bgLight;
    final cardBg = isDark ? _C.cardD   : Colors.white;
    final onCard = isDark ? Colors.white : _C.wine;

    final tips = [
      l.t('learnTip1'),
      l.t('learnTip2'),
      l.t('learnTip3'),
      l.t('learnTip4'),
      l.t('learnTip5'),
    ];

    return Scaffold(
      backgroundColor: bg,
      body: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── App bar ──────────────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 170,
                pinned: true,
                backgroundColor: _C.sage,
                leading: Semantics(
                  label: l.t('back'),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                    },
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1A4A3E), _C.sage, Color(0xFF5AAB99)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              const Icon(Icons.school_rounded,
                                  size: 36, color: Colors.white),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(l.t('learnTitle'),
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.w800)),
                                  Text(l.t('learnSub'),
                                      style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 13)),
                                ],
                              ),
                            ]),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ── Content ──────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tips section
                      _sectionLabel(l.t('learnTipsTitle'), onCard),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                  alpha: isDark ? 0.25 : 0.06),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: List.generate(tips.length, (i) {
                            final isLast = i == tips.length - 1;
                            return Column(children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: _C.sage.withValues(alpha: 0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text('${i + 1}',
                                          style: const TextStyle(
                                              color: _C.sage,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 12)),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(tips[i],
                                          style: TextStyle(
                                              color: onCard.withValues(
                                                  alpha: 0.8),
                                              fontSize: 13,
                                              height: 1.5)),
                                    ),
                                  ],
                                ),
                              ),
                              if (!isLast)
                                const Divider(height: 1, indent: 56),
                            ]);
                          }),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // YouTube section
                      _sectionLabel(l.t('learnYouTube'), onCard),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 110,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.zero,
                          itemCount: _youtubeLinks.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (_, i) {
                            final res = _youtubeLinks[i];
                            final isActive = _activeSoundIdx == i;
                            return _ResourceCard(
                              resource: res,
                              label: l.t(res.titleKey),
                              isActive: isActive,
                              onTap: () {
                                HapticFeedback.lightImpact();
                                if (res.sound != null) {
                                  context
                                      .read<SoundProvider>()
                                      .playInstrument(res.sound!);
                                  setState(() => _activeSoundIdx = i);
                                  Future.delayed(
                                      const Duration(milliseconds: 1500),
                                      () {
                                    if (mounted) {
                                      setState(() => _activeSoundIdx = null);
                                    }
                                  });
                                }
                                _launch(res.url);
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Learning resources section
                      _sectionLabel(l.t('learnLinks'), onCard),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                  alpha: isDark ? 0.25 : 0.06),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children:
                              List.generate(_learnLinks.length, (i) {
                            final res = _learnLinks[i];
                            final isLast = i == _learnLinks.length - 1;
                            final color = Color(res.gradColors[0]);
                            return Column(children: [
                              InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  _launch(res.url);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      16, 14, 16, 14),
                                  child: Row(children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: color.withValues(alpha: 0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(res.icon,
                                          size: 18, color: color),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(l.t(res.titleKey),
                                              style: TextStyle(
                                                color: onCard,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                              )),
                                          Text(res.url,
                                              style: TextStyle(
                                                  color: color,
                                                  fontSize: 11),
                                              overflow: TextOverflow.ellipsis),
                                        ],
                                      ),
                                    ),
                                    Icon(Icons.open_in_new_rounded,
                                        color: color, size: 16),
                                  ]),
                                ),
                              ),
                              if (!isLast) const Divider(height: 1, indent: 54),
                            ]);
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String title, Color color) => Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
          color: color.withValues(alpha: 0.5),
        ),
      );
}

// ─── Resource Card (horizontal scroll) ────────────────────────────────────────
class _ResourceCard extends StatelessWidget {
  final _Resource resource;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ResourceCard({
    required this.resource,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final grad = resource.gradColors.map((c) => Color(c)).toList();
    return Semantics(
      label: label,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: grad,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Color(resource.gradColors[0]).withValues(
                    alpha: isActive ? 0.5 : 0.25),
                blurRadius: isActive ? 16 : 8,
                offset: const Offset(0, 4),
              ),
            ],
            border: isActive
                ? Border.all(color: Colors.white, width: 2)
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: isActive ? 1.2 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Icon(resource.icon,
                    size: 30, color: Colors.white),
              ),
              const SizedBox(height: 6),
              Text(label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              const Icon(Icons.play_circle_outline_rounded,
                  color: Colors.white70, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
