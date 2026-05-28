import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_assignment_e/l10n/app_localizations.dart';
import 'package:project_assignment_e/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
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

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

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

  void _shareApp(AppLocalizations l) {
    Share.share(
      'MOSIQATI — ${l.t("tagline")}\n'
      "Jordan's premier musical instruments store.\n"
      'Shop guitars, oud, piano, drums & more!\n\n'
      '${l.t("aboutWebsite")}',
    );
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

    return Scaffold(
      backgroundColor: bg,
      body: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── App bar ─────────────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: _C.plum,
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
                actions: [
                  Semantics(
                    label: l.t('shareApp'),
                    child: IconButton(
                      icon: const Icon(Icons.share_rounded, color: Colors.white),
                      tooltip: l.t('shareApp'),
                      onPressed: () => _shareApp(l),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_C.wine, _C.plum, _C.raspberry],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // App logo
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.music_note_rounded,
                                  color: Colors.white, size: 42),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              l.t('appName'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 2,
                              ),
                            ),
                            Text(
                              l.t('tagline'),
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 13),
                            ),
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

                      // Version badge
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: _C.raspberry.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: _C.raspberry.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            l.t('appVersion'),
                            style: const TextStyle(
                              color: _C.raspberry,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Mission
                      _SectionCard(
                        title: l.t('aboutMission'),
                        icon: Icons.flag_rounded,
                        iconColor: _C.raspberry,
                        cardBg: cardBg,
                        isDark: isDark,
                        child: Text(
                          l.t('aboutMissionText'),
                          style: TextStyle(
                            color: onCard.withValues(alpha: 0.75),
                            fontSize: 14,
                            height: 1.65,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Features
                      _SectionCard(
                        title: l.t('aboutFeatures'),
                        icon: Icons.star_rounded,
                        iconColor: _C.gold,
                        cardBg: cardBg,
                        isDark: isDark,
                        child: Column(
                          children: [
                            _FeatureRow(Icons.library_music_rounded,
                                l.t('aboutFeat1'), _C.raspberry, onCard),
                            _FeatureRow(Icons.build_rounded,
                                l.t('aboutFeat2'), _C.sage, onCard),
                            _FeatureRow(Icons.local_shipping_rounded,
                                l.t('aboutFeat3'), _C.gold, onCard),
                            _FeatureRow(Icons.translate_rounded,
                                l.t('aboutFeat4'), _C.plum, onCard),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Contact
                      _SectionCard(
                        title: l.t('aboutContact'),
                        icon: Icons.contact_mail_rounded,
                        iconColor: _C.sage,
                        cardBg: cardBg,
                        isDark: isDark,
                        child: Column(children: [
                          _ContactRow(
                            Icons.email_rounded,
                            l.t('aboutEmail'),
                            _C.raspberry,
                            onCard,
                            onTap: () => _launch('mailto:${l.t("aboutEmail")}'),
                          ),
                          _ContactRow(
                            Icons.phone_rounded,
                            l.t('aboutPhone'),
                            _C.sage,
                            onCard,
                            onTap: () => _launch('tel:${l.t("aboutPhone")}'),
                          ),
                          _ContactRow(
                            Icons.language_rounded,
                            l.t('aboutWebsite'),
                            _C.plum,
                            onCard,
                            onTap: () =>
                                _launch('https://${l.t("aboutWebsite")}'),
                          ),
                          _ContactRow(
                            Icons.location_on_rounded,
                            l.t('aboutAddress'),
                            _C.gold,
                            onCard,
                          ),
                        ]),
                      ),
                      const SizedBox(height: 24),

                      // Share app button
                      Semantics(
                        label: l.t('shareApp'),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _shareApp(l),
                            icon: const Icon(Icons.share_rounded),
                            label: Text(l.t('shareApp'),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 15)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _C.raspberry,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              elevation: 4,
                              shadowColor:
                                  _C.raspberry.withValues(alpha: 0.35),
                            ),
                          ),
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
}

// ─── Section Card ─────────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Color cardBg;
  final bool isDark;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.cardBg,
    required this.isDark,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                color: isDark ? Colors.white : _C.wine,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ]),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color textColor;

  const _FeatureRow(this.icon, this.label, this.color, this.textColor);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label,
              style: TextStyle(
                  color: textColor.withValues(alpha: 0.8), fontSize: 13)),
        ),
      ]),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback? onTap;

  const _ContactRow(this.icon, this.label, this.color, this.textColor,
      {this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap != null
          ? () {
              HapticFeedback.lightImpact();
              onTap!();
            }
          : null,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: TextStyle(
                  color: onTap != null ? color : textColor.withValues(alpha: 0.8),
                  fontSize: 13,
                  decoration: onTap != null ? TextDecoration.underline : null,
                  decorationColor: color,
                )),
          ),
          if (onTap != null)
            Icon(Icons.open_in_new_rounded, color: color, size: 14),
        ]),
      ),
    );
  }
}
