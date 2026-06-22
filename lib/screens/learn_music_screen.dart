import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_assignment_e/l10n/app_localizations.dart';
import 'package:project_assignment_e/providers/sound_provider.dart';
import 'package:project_assignment_e/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

// ─── Colours ──────────────────────────────────────────────────────────────────
class _C {
  static const wine    = Color(0xFF361F27);
  static const sage    = Color(0xFF3D7A6A);
  static const bgLight = Color(0xFFFAF0EE);
  static const bgDark  = Color(0xFF0D090A);
  static const cardD   = Color(0xFF28141E);
}

// ─── Interactive guide topic ───────────────────────────────────────────────────
class _Guide {
  final IconData icon;
  final int colorHex;
  final String titleEn;
  final String titleAr;
  final String bodyEn;
  final String bodyAr;
  final String ytUrl;

  const _Guide({
    required this.icon,
    required this.colorHex,
    required this.titleEn,
    required this.titleAr,
    required this.bodyEn,
    required this.bodyAr,
    required this.ytUrl,
  });
}

// ─── YouTube / website resource ────────────────────────────────────────────────
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

// ─── Screen ───────────────────────────────────────────────────────────────────
class LearnMusicScreen extends StatefulWidget {
  const LearnMusicScreen({super.key});

  @override
  State<LearnMusicScreen> createState() => _LearnMusicScreenState();
}

class _LearnMusicScreenState extends State<LearnMusicScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _fade;
  late final Animation<Offset>   _slide;
  int? _activeSoundIdx;

  // ── 7 interactive guide topics (bilingual inline text) ────────────────────
  static const _guides = [
    _Guide(
      icon: Icons.queue_music_rounded,
      colorHex: 0xFF912F56,
      titleEn: 'Guitar Basics',
      titleAr: 'أساسيات الغيتار',
      bodyEn: 'Start with the basics: learn to hold the guitar properly and '
          'understand string names (E A D G B E from low to high). Practice '
          'open chords — G, C, D, Em, Am — and focus on clean transitions '
          'before increasing speed. Even 15–20 minutes of focused daily '
          'practice will produce noticeable progress within weeks.',
      bodyAr: 'ابدأ بالأساسيات: تعلّم كيفية إمساك الغيتار بشكل صحيح وتعرّف على '
          'أسماء الأوتار (E A D G B E من الأدنى إلى الأعلى). تدرّب على الأوتار '
          'المفتوحة الأساسية — G, C, D, Em, Am — وركّز على الانتقال السلس '
          'بينها قبل تسريع العزف. حتى 15–20 دقيقة من التدريب اليومي المركّز '
          'ستُنتج تقدماً ملحوظاً في غضون أسابيع.',
      ytUrl: 'https://www.youtube.com/results?search_query=guitar+basics+for+beginners',
    ),
    _Guide(
      icon: Icons.piano,
      colorHex: 0xFF521945,
      titleEn: 'Piano Basics',
      titleAr: 'أساسيات البيانو',
      bodyEn: 'Begin by learning correct hand position and key names '
          '(C D E F G A B repeating across the keyboard). Practice the C '
          'major scale with each hand separately, then together. Learn simple '
          'pieces hands-separately before combining them. Use a metronome '
          'from day one — steady rhythm is the foundation of great piano playing.',
      bodyAr: 'ابدأ بتعلّم وضعية اليد الصحيحة وأسماء المفاتيح (C D E F G A B '
          'تتكرر عبر لوحة المفاتيح). تدرّب على سلّم C الكبير بكل يد على حدة، '
          'ثم كلتيهما معاً. تعلّم المقاطع الموسيقية البسيطة بيدٍ واحدة قبل '
          'دمجهما. استخدم المترونوم منذ اليوم الأول — الإيقاع الثابت هو أساس '
          'العزف الرائع على البيانو.',
      ytUrl: 'https://www.youtube.com/results?search_query=piano+basics+for+beginners',
    ),
    _Guide(
      icon: Icons.music_note_rounded,
      colorHex: 0xFFB8602A,
      titleEn: 'Oud Basics',
      titleAr: 'أساسيات العود',
      bodyEn: 'The oud has no frets, so ear training is essential from the '
          'very start. Learn standard tuning (C G D A E from low to high) and '
          'basic risha (pick) technique — hold it loosely and let it glide. '
          'Start with maqam Rast to develop your feel for Arabic and Middle '
          'Eastern scales before moving to Bayati or Hijaz.',
      bodyAr: 'العود لا يحتوي على حدود (فريتس)، لذا فإن تدريب الأذن أمر أساسي منذ '
          'البداية. تعلّم ضبط الأوتار القياسي (C G D A E من الأدنى إلى الأعلى) '
          'وتقنية الريشة الأساسية — أمسكها بخفة ودعها تنزلق. ابدأ بمقام الراست '
          'لتطوير إحساسك بالسلالم العربية والشرقية قبل الانتقال إلى البياتي '
          'أو الحجاز.',
      ytUrl: 'https://www.youtube.com/results?search_query=oud+beginners+lesson',
    ),
    _Guide(
      icon: Icons.graphic_eq_rounded,
      colorHex: 0xFF2E6D5E,
      titleEn: 'Drums & Rhythm',
      titleAr: 'الطبول والإيقاع',
      bodyEn: 'Start with a basic 4/4 rock beat: hi-hat on every quarter note, '
          'snare on beats 2 and 4, bass drum on beats 1 and 3. Practice '
          'each limb independently before combining them. Keep a metronome '
          'running at a slow tempo — accuracy always comes before speed. '
          'Once the beat feels natural, gradually increase the tempo.',
      bodyAr: 'ابدأ بإيقاع روك 4/4 الأساسي: هاي-هات على كل نبضة، سنير على '
          'النبضتين 2 و4، باس درم على النبضتين 1 و3. تدرّب على كل طرف من '
          'أطرافك بشكل مستقل قبل دمجها. حافظ على تشغيل المترونوم بإيقاع بطيء '
          '— الدقة دائماً تأتي قبل السرعة. بمجرد أن يبدو الإيقاع طبيعياً، '
          'زد السرعة تدريجياً.',
      ytUrl: 'https://www.youtube.com/results?search_query=drum+lessons+beginners+basic+beat',
    ),
    _Guide(
      icon: Icons.library_music_rounded,
      colorHex: 0xFF1A3B6B,
      titleEn: 'Music Theory',
      titleAr: 'نظرية الموسيقى',
      bodyEn: 'Music theory explains why music sounds the way it does. Start '
          'with reading notes on a staff (treble and bass clef), understanding '
          'intervals, and learning the major scale formula (W-W-H-W-W-W-H). '
          'Basic theory makes learning any instrument faster, sight-reading '
          'easier, and improvisation more intuitive.',
      bodyAr: 'نظرية الموسيقى تشرح لماذا تبدو الموسيقى بالطريقة التي نسمعها. '
          'ابدأ بقراءة النوتات على المدرج الموسيقي (مفتاح الكمان والباص)، وفهم '
          'الفترات الموسيقية، وتعلّم صيغة السلّم الكبير (W-W-H-W-W-W-H). '
          'معرفة النظرية الأساسية تجعل تعلّم أي آلة أسرع وقراءة النوتات أسهل '
          'والارتجال أكثر سهولة.',
      ytUrl: 'https://www.youtube.com/results?search_query=music+theory+basics+beginners',
    ),
    _Guide(
      icon: Icons.tune_rounded,
      colorHex: 0xFF3D7A6A,
      titleEn: 'Tuning Tips',
      titleAr: 'نصائح الضبط',
      bodyEn: 'Always tune before you play — even a slightly out-of-tune '
          'instrument trains your ear incorrectly. For guitar and oud, use a '
          'clip-on chromatic tuner or a free tuner app. Acoustic pianos need '
          'professional tuning every 1–2 years. Drum heads require regular '
          'tension checks to stay resonant and clear.',
      bodyAr: 'دائماً اضبط آلتك قبل العزف — حتى الآلة الخارجة عن الضبط قليلاً '
          'تدرّب أذنك بشكل خاطئ. للغيتار والعود، استخدم ضابط تردد كروماتي أو '
          'تطبيقاً مجانياً للضبط. يحتاج البيانو الأكوستيكي إلى ضبط احترافي '
          'كل 1–2 سنوات. تحتاج جلود الطبول إلى فحص منتظم للتوتر للحفاظ على '
          'صوت رنين واضح.',
      ytUrl: 'https://www.youtube.com/results?search_query=how+to+tune+guitar+beginners',
    ),
    _Guide(
      icon: Icons.schedule_rounded,
      colorHex: 0xFF6B3A7D,
      titleEn: 'Practice Routine',
      titleAr: 'روتين التدريب',
      bodyEn: 'A structured routine beats random noodling every time: '
          '5 min warm-up, 10 min scales or exercises, 15 min on a specific '
          'difficult passage, 10 min free play. Consistent daily sessions of '
          '30–45 minutes outperform irregular marathon sessions. Keep a '
          'practice journal to track goals and progress.',
      bodyAr: 'الروتين المنظّم يتفوق دائماً على العزف العشوائي: 5 دقائق إحماء، '
          '10 دقائق سلالم أو تمارين، 15 دقيقة على مقطع صعب بعينه، 10 دقائق '
          'عزف حر. الجلسات اليومية المنتظمة لمدة 30–45 دقيقة تتفوق على '
          'الجلسات الطويلة المتقطعة. احتفظ بمفكرة تدريب لتتبع الأهداف '
          'والتقدم.',
      ytUrl: 'https://www.youtube.com/results?search_query=music+practice+routine+tips+beginners',
    ),
  ];

  // ── YouTube tutorial cards ──────────────────────────────────────────────────
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

  // ── External learning websites ──────────────────────────────────────────────
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

  // ── URL launcher ─────────────────────────────────────────────────────────────
  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // ── Guide detail bottom sheet ─────────────────────────────────────────────────
  void _showGuide(_Guide guide, bool isAr, bool isDark) {
    final cardBg    = isDark ? _C.cardD   : Colors.white;
    final textColor = isDark ? Colors.white : _C.wine;
    final accent    = Color(guide.colorHex);
    final title     = isAr ? guide.titleAr : guide.titleEn;
    final body      = isAr ? guide.bodyAr  : guide.bodyEn;

    HapticFeedback.lightImpact();

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        minChildSize: 0.4,
        maxChildSize: 0.85,
        builder: (sheetCtx, scrollCtrl) => Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(children: [
            // ── Drag handle
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // ── Scrollable content
            Expanded(
              child: ListView(
                controller: scrollCtrl,
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                children: [
                  // Header row: icon + title
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(guide.icon, color: accent, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Divider(color: accent.withValues(alpha: 0.2)),
                  const SizedBox(height: 14),
                  // Body explanation
                  Text(
                    body,
                    textDirection:
                        isAr ? TextDirection.rtl : TextDirection.ltr,
                    style: TextStyle(
                      color: textColor.withValues(alpha: 0.85),
                      fontSize: 14.5,
                      height: 1.75,
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Watch on YouTube button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(sheetCtx);
                        _launch(guide.ytUrl);
                      },
                      icon: const Icon(
                          Icons.play_circle_filled_rounded,
                          color: Colors.white),
                      label: Text(
                        isAr ? 'شاهد على يوتيوب' : 'Watch on YouTube',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFCC0000),
                        shape: const StadiumBorder(),
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final l      = AppLocalizations.of(context);
    final isDark = context.watch<ThemeProvider>().isDark;
    final isAr   = Localizations.localeOf(context).languageCode == 'ar';
    final bg     = isDark ? _C.bgDark  : _C.bgLight;
    final cardBg = isDark ? _C.cardD   : Colors.white;
    final onCard = isDark ? Colors.white : _C.wine;

    return Scaffold(
      backgroundColor: bg,
      body: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [

              // ── App bar ────────────────────────────────────────────────
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
                        colors: [
                          Color(0xFF1A4A3E),
                          _C.sage,
                          Color(0xFF5AAB99),
                        ],
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
                              Expanded(
                                child: Column(
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
                              ),
                            ]),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ── Main content ───────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // ── Guides & Tips section ──────────────────────────
                      _sectionLabel(l.t('learnGuidesTitle'), onCard),
                      const SizedBox(height: 12),
                      _GuidesCard(
                        guides: _guides,
                        isAr: isAr,
                        isDark: isDark,
                        cardBg: cardBg,
                        onCard: onCard,
                        onTap: (g) => _showGuide(g, isAr, isDark),
                      ),
                      const SizedBox(height: 28),

                      // ── YouTube tutorials ──────────────────────────────
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
                            final res      = _youtubeLinks[i];
                            final isActive = _activeSoundIdx == i;
                            return _ResourceCard(
                              resource: res,
                              label: l.t(res.titleKey),
                              isActive: isActive,
                              onTap: () async {
                                HapticFeedback.lightImpact();
                                if (res.sound != null) {
                                  context
                                      .read<SoundProvider>()
                                      .playInstrument(res.sound!);
                                  setState(() => _activeSoundIdx = i);
                                  // Brief delay so the sound starts before
                                  // the browser opens and the app backgrounds.
                                  await Future.delayed(
                                      const Duration(milliseconds: 600));
                                  if (mounted) {
                                    setState(() => _activeSoundIdx = null);
                                  }
                                }
                                _launch(res.url);
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── Learning websites ──────────────────────────────
                      _sectionLabel(l.t('learnLinks'), onCard),
                      const SizedBox(height: 12),
                      _WebsitesCard(
                        links: _learnLinks,
                        l: l,
                        isDark: isDark,
                        cardBg: cardBg,
                        onCard: onCard,
                        onTap: (url) {
                          HapticFeedback.lightImpact();
                          _launch(url);
                        },
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

  // ── Section label helper ─────────────────────────────────────────────────────
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

// ─── Guides card list ──────────────────────────────────────────────────────────
class _GuidesCard extends StatelessWidget {
  final List<_Guide> guides;
  final bool isAr;
  final bool isDark;
  final Color cardBg;
  final Color onCard;
  final void Function(_Guide) onTap;

  const _GuidesCard({
    required this.guides,
    required this.isAr,
    required this.isDark,
    required this.cardBg,
    required this.onCard,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: List.generate(guides.length, (i) {
          final guide  = guides[i];
          final isLast = i == guides.length - 1;
          final accent = Color(guide.colorHex);
          final title  = isAr ? guide.titleAr : guide.titleEn;

          return Column(children: [
            InkWell(
              onTap: () => onTap(guide),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
                child: Row(children: [
                  // Coloured icon circle
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(guide.icon, size: 20, color: accent),
                  ),
                  const SizedBox(width: 12),
                  // Title
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: onCard,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  // Chevron
                  Icon(
                    Icons.chevron_right_rounded,
                    color: accent.withValues(alpha: 0.55),
                    size: 22,
                  ),
                ]),
              ),
            ),
            if (!isLast) Divider(height: 1, indent: 66, color: Colors.grey.withValues(alpha: 0.15)),
          ]);
        }),
      ),
    );
  }
}

// ─── Website links card ────────────────────────────────────────────────────────
class _WebsitesCard extends StatelessWidget {
  final List<_Resource> links;
  final AppLocalizations l;
  final bool isDark;
  final Color cardBg;
  final Color onCard;
  final void Function(String url) onTap;

  const _WebsitesCard({
    required this.links,
    required this.l,
    required this.isDark,
    required this.cardBg,
    required this.onCard,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: List.generate(links.length, (i) {
          final res    = links[i];
          final isLast = i == links.length - 1;
          final color  = Color(res.gradColors[0]);

          return Column(children: [
            InkWell(
              onTap: () => onTap(res.url),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Row(children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(res.icon, size: 18, color: color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l.t(res.titleKey),
                            style: TextStyle(
                              color: onCard,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            )),
                        Text(res.url,
                            style:
                                TextStyle(color: color, fontSize: 11),
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  Icon(Icons.open_in_new_rounded,
                      color: color, size: 16),
                ]),
              ),
            ),
            if (!isLast)
              Divider(
                  height: 1,
                  indent: 54,
                  color: Colors.grey.withValues(alpha: 0.15)),
          ]);
        }),
      ),
    );
  }
}

// ─── YouTube resource card (horizontal scroll) ─────────────────────────────────
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
                color: Color(resource.gradColors[0])
                    .withValues(alpha: isActive ? 0.5 : 0.25),
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
                child: Icon(resource.icon, size: 30, color: Colors.white),
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
