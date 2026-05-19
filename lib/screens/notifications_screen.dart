import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_assignment_e/l10n/app_localizations.dart';
import 'package:project_assignment_e/providers/notifications_provider.dart';
import 'package:project_assignment_e/providers/theme_provider.dart';
import 'package:provider/provider.dart';

// ── Palette ───────────────────────────────────────────────────────────────────
class _C {
  static const raspberry = Color(0xFF912F56);
  static const plum      = Color(0xFF521945);
  static const wine      = Color(0xFF361F27);
  static const bgDark    = Color(0xFF0D090A);
  static const cardD     = Color(0xFF28141E);
  static const bgLight   = Color(0xFFFAF0EE);
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String _timeLabel(AppLocalizations l, DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return l.t('justNow');
    if (diff.inMinutes < 60) return '${diff.inMinutes} ${l.t('minutesAgo')}';
    if (diff.inHours < 24) return '${diff.inHours} ${l.t('hoursAgo')}';
    return l.t('yesterday');
  }

  @override
  Widget build(BuildContext context) {
    final l       = AppLocalizations.of(context);
    final isDark  = context.watch<ThemeProvider>().isDark;
    final notifProv = context.watch<NotificationsProvider>();
    final items   = notifProv.items;

    final bg      = isDark ? _C.bgDark   : _C.bgLight;
    final cardBg  = isDark ? _C.cardD    : Colors.white;
    final textCol = isDark ? Colors.white : _C.wine;
    final subCol  = isDark ? Colors.white54 : Colors.grey.shade600;

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── App bar ─────────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            expandedHeight: 120,
            backgroundColor: _C.plum,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              if (notifProv.unreadCount > 0)
                TextButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    notifProv.markAllAsRead();
                  },
                  icon: const Icon(Icons.done_all_rounded,
                      color: Colors.white70, size: 18),
                  label: Text(
                    l.t('markAllRead'),
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
              const SizedBox(width: 4),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding:
                  const EdgeInsets.fromLTRB(56, 0, 16, 16),
              title: Row(
                children: [
                  Text(
                    l.t('notifications'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (notifProv.unreadCount > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _C.raspberry,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${notifProv.unreadCount}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ],
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_C.wine, _C.plum, _C.raspberry],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),

          // ── Content ──────────────────────────────────────────────────────
          if (items.isEmpty)
            SliverFillRemaining(
              child: _EmptyState(l: l, isDark: isDark, textCol: textCol, subCol: subCol),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final item = items[i];
                    return FadeTransition(
                      opacity: CurvedAnimation(
                        parent: _ctrl,
                        curve: Interval(
                          (i / items.length) * 0.5,
                          0.5 + (i / items.length) * 0.5,
                          curve: Curves.easeOut,
                        ),
                      ),
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.2),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: _ctrl,
                          curve: Interval(
                            (i / items.length) * 0.5,
                            0.5 + (i / items.length) * 0.5,
                            curve: Curves.easeOutCubic,
                          ),
                        )),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _NotificationCard(
                            item: item,
                            timeLabel: _timeLabel(l, item.time),
                            l: l,
                            cardBg: cardBg,
                            textCol: textCol,
                            subCol: subCol,
                            isDark: isDark,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              context
                                  .read<NotificationsProvider>()
                                  .markAsRead(item.id);
                            },
                            onDismiss: () {
                              HapticFeedback.mediumImpact();
                              context
                                  .read<NotificationsProvider>()
                                  .remove(item.id);
                            },
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: items.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Notification Card ─────────────────────────────────────────────────────────
class _NotificationCard extends StatelessWidget {
  final NotificationModel item;
  final String timeLabel;
  final AppLocalizations l;
  final Color cardBg, textCol, subCol;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotificationCard({
    required this.item,
    required this.timeLabel,
    required this.l,
    required this.cardBg,
    required this.textCol,
    required this.subCol,
    required this.isDark,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.red.shade700,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_outline_rounded,
            color: Colors.white, size: 26),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: item.isRead
                ? cardBg
                : (isDark
                    ? item.color.withValues(alpha: 0.12)
                    : item.color.withValues(alpha: 0.06)),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: item.isRead
                  ? Colors.transparent
                  : item.color.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon circle
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(item.icon, color: item.color, size: 22),
              ),
              const SizedBox(width: 14),

              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l.t(item.titleKey),
                            style: TextStyle(
                              color: textCol,
                              fontWeight: item.isRead
                                  ? FontWeight.w500
                                  : FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (!item.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: item.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l.t(item.bodyKey),
                      style: TextStyle(color: subCol, fontSize: 13, height: 1.4),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      timeLabel,
                      style: TextStyle(
                        color: item.color.withValues(alpha: 0.8),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final AppLocalizations l;
  final bool isDark;
  final Color textCol, subCol;

  const _EmptyState({
    required this.l,
    required this.isDark,
    required this.textCol,
    required this.subCol,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: _C.raspberry.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                size: 52,
                color: _C.raspberry,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l.t('noNotifications'),
              style: TextStyle(
                color: textCol,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l.t('noNotificationsSub'),
              textAlign: TextAlign.center,
              style: TextStyle(color: subCol, fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
