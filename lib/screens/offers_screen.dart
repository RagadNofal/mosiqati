import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:project_assignment_e/l10n/app_localizations.dart';
import 'package:project_assignment_e/models/coupon.dart';
import 'package:project_assignment_e/providers/cart_provider.dart';
import 'package:project_assignment_e/providers/sound_provider.dart';
import 'package:project_assignment_e/providers/theme_provider.dart';
import 'package:project_assignment_e/screens/cart_screen.dart';
import 'package:project_assignment_e/services/coupon_service.dart';
import 'package:provider/provider.dart';

// ─── Colour palette ────────────────────────────────────────────────────────────
class _C {
  static const raspberry = Color(0xFF912F56);
  static const plum      = Color(0xFF521945);
  static const wine      = Color(0xFF361F27);
  static const bgLight   = Color(0xFFFAF0EE);
  static const bgDark    = Color(0xFF0D090A);
  static const cardD     = Color(0xFF28141E);
}

class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key});

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l      = AppLocalizations.of(context);
    final isDark = context.watch<ThemeProvider>().isDark;
    final lang   = Localizations.localeOf(context).languageCode;
    final bg     = isDark ? _C.bgDark : _C.bgLight;
    final cardBg = isDark ? _C.cardD  : Colors.white;
    final onCard = isDark ? Colors.white : _C.wine;

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── App bar ────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight:  160,
            pinned:          true,
            backgroundColor: _C.raspberry,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white),
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
              },
            ),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(children: [
                          const Icon(Icons.local_offer_rounded,
                              size: 36, color: Colors.white),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l.t('offersTitle'),
                                style: const TextStyle(
                                  color:      Colors.white,
                                  fontSize:   24,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                l.t('offersSub'),
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 13),
                              ),
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

          // ── Coupon list ────────────────────────────────────────────────
          StreamBuilder<List<Coupon>>(
            stream: CouponService().streamAllCoupons(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              // Filter: only active and currently valid coupons.
              final all = snapshot.data ?? [];
              final active = all
                  .where((c) => c.status == CouponStatus.active)
                  .toList();

              if (active.isEmpty) {
                return SliverFillRemaining(
                  child: _EmptyOffers(
                      l: l, isDark: isDark, onCard: onCard),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: Duration(milliseconds: 350 + i * 80),
                      curve: Curves.easeOutBack,
                      builder: (_, val, child) => Opacity(
                        opacity: val.clamp(0, 1),
                        child: Transform.translate(
                          offset: Offset(0, 24 * (1 - val)),
                          child: child,
                        ),
                      ),
                      child: _CouponCard(
                        coupon:  active[i],
                        lang:    lang,
                        l:       l,
                        cardBg:  cardBg,
                        onCard:  onCard,
                        isDark:  isDark,
                      ),
                    ),
                    childCount: active.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Coupon Card ───────────────────────────────────────────────────────────────
class _CouponCard extends StatelessWidget {
  final Coupon           coupon;
  final String           lang;
  final AppLocalizations l;
  final Color            cardBg;
  final Color            onCard;
  final bool             isDark;

  const _CouponCard({
    required this.coupon,
    required this.lang,
    required this.l,
    required this.cardBg,
    required this.onCard,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final fmt  = DateFormat('dd MMM yyyy');
    final isPercent = coupon.discountType == 'percentage';
    final discLabel = isPercent
        ? '${coupon.discountValue.toStringAsFixed(0)}% ${l.t('couponPercentage')}'
        : '${l.t('currency')} ${coupon.discountValue.toStringAsFixed(2)} ${l.t('couponFixed')}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        decoration: BoxDecoration(
          color:        cardBg,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color:     Colors.black.withValues(alpha: isDark ? 0.3 : 0.07),
              blurRadius: 16,
              offset:    const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top row: code + discount badge ──────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Code chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color:        const Color(0xFF912F56)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: const Color(0xFF912F56)
                              .withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.local_offer_rounded,
                            size: 14, color: Color(0xFF912F56)),
                        const SizedBox(width: 6),
                        Text(
                          coupon.code,
                          style: const TextStyle(
                            fontSize:      14,
                            fontWeight:    FontWeight.w900,
                            color:         Color(0xFF912F56),
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Discount badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF912F56), Color(0xFF521945)],
                        begin: Alignment.topLeft,
                        end:   Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isPercent
                          ? '-${coupon.discountValue.toStringAsFixed(0)}%'
                          : '-${l.t('currency')} ${coupon.discountValue.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color:      Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize:   15,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ── Title ────────────────────────────────────────────────────
              Text(
                coupon.displayTitle(lang),
                style: TextStyle(
                  color:      onCard,
                  fontSize:   17,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              if (lang == 'ar'
                  ? coupon.descriptionAr.isNotEmpty
                  : coupon.descriptionEn.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  lang == 'ar'
                      ? coupon.descriptionAr
                      : coupon.descriptionEn,
                  style: TextStyle(
                    color:   onCard.withValues(alpha: 0.6),
                    fontSize: 13,
                    height:  1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 10),

              // ── Info row ────────────────────────────────────────────────
              Wrap(
                spacing: 12,
                runSpacing: 4,
                children: [
                  _InfoChip(
                    icon:  Icons.discount_outlined,
                    label: discLabel,
                    color: const Color(0xFF912F56),
                  ),
                  if (coupon.minOrderAmount > 0)
                    _InfoChip(
                      icon:  Icons.shopping_bag_outlined,
                      label:
                          '${l.t('couponMinOrder')}: ${l.t('currency')} ${coupon.minOrderAmount.toStringAsFixed(2)}',
                      color: const Color(0xFF521945),
                    ),
                  _InfoChip(
                    icon:  Icons.calendar_month_outlined,
                    label:
                        '${l.t('offValidUntil')} ${fmt.format(coupon.validUntil)}',
                    color: const Color(0xFF3D7A6A),
                  ),
                  if (coupon.usageLimit != null)
                    _InfoChip(
                      icon:  Icons.people_outline_rounded,
                      label:
                          '${coupon.usedCount} / ${coupon.usageLimit} ${l.t('couponUsed')}',
                      color: Colors.orange.shade700,
                    ),
                ],
              ),

              const SizedBox(height: 14),

              // ── Action buttons ──────────────────────────────────────────
              Row(
                children: [
                  // Copy Code
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Clipboard.setData(
                            ClipboardData(text: coupon.code));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(children: [
                              const Icon(Icons.copy_rounded,
                                  color: Colors.white, size: 16),
                              const SizedBox(width: 8),
                              Text(l.t('couponCopied')),
                            ]),
                            backgroundColor: const Color(0xFF521945),
                            behavior:        SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      icon:  const Icon(Icons.copy_outlined, size: 16),
                      label: Text(l.t('copyCode')),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: Color(0xFF912F56)),
                        foregroundColor: const Color(0xFF912F56),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Apply in Cart
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        HapticFeedback.mediumImpact();
                        context.read<SoundProvider>().play(
                            SoundType.couponSuccess);
                        final cart = context.read<CartProvider>();
                        final errorKey = await cart.applyCoupon(coupon.code);
                        if (!context.mounted) return;
                        if (errorKey == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(children: [
                                const Icon(Icons.check_circle_rounded,
                                    color: Colors.white, size: 16),
                                const SizedBox(width: 8),
                                Text(l.t('couponApplied')),
                              ]),
                              backgroundColor: const Color(0xFF3D7A6A),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(12)),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                          // Navigate to cart
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const CartPage()),
                          );
                        } else {
                          context.read<SoundProvider>().play(
                              SoundType.couponError);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(children: [
                                const Icon(Icons.error_outline_rounded,
                                    color: Colors.white, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                    child: Text(AppLocalizations.of(
                                            context)
                                        .t(errorKey))),
                              ]),
                              backgroundColor: Colors.red.shade700,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(12)),
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        }
                      },
                      icon:  const Icon(Icons.shopping_cart_rounded,
                          size: 16),
                      label: Text(l.t('applyInCart')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF912F56),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Info chip ─────────────────────────────────────────────────────────────────
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String   label;
  final Color    color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color.withValues(alpha: 0.8)),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize:   11,
              color:      color.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
}

// ── Empty Offers ──────────────────────────────────────────────────────────────
class _EmptyOffers extends StatelessWidget {
  final AppLocalizations l;
  final bool  isDark;
  final Color onCard;

  const _EmptyOffers({
    required this.l,
    required this.isDark,
    required this.onCard,
  });

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width:  100,
                height: 100,
                decoration: BoxDecoration(
                  color:  const Color(0xFF912F56).withValues(alpha: 0.08),
                  shape:  BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_offer_outlined,
                  size:  52,
                  color: Color(0xFF912F56),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l.t('noActiveOffers'),
                style: TextStyle(
                  color:      onCard,
                  fontSize:   22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l.t('noActiveOffersSub'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color:  onCard.withValues(alpha: 0.6),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      );
}
