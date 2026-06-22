import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project_assignment_e/l10n/app_localizations.dart';
import 'package:project_assignment_e/providers/auth_provider.dart';
import 'package:project_assignment_e/providers/theme_provider.dart';
import 'package:provider/provider.dart';

// ── Palette ───────────────────────────────────────────────────────────────────
class _C {
  static const raspberry = Color(0xFF912F56);
  static const plum      = Color(0xFF521945);
  static const wine      = Color(0xFF361F27);
  static const bgDark    = Color(0xFF0D090A);
  static const bgLight   = Color(0xFFFAF0EE);
  static const cardD     = Color(0xFF28141E);
  static const gold      = Color(0xFFD4A853);
}

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l      = AppLocalizations.of(context);
    final auth   = context.watch<AppAuthProvider>();
    final isDark = context.watch<ThemeProvider>().isDark;
    final bg     = isDark ? _C.bgDark : _C.bgLight;

    // ── Guest: show login-required state ─────────────────────────────────────
    if (!auth.isLoggedIn) {
      return Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          title: Text(l.t('myOrders')),
          backgroundColor: _C.plum,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline_rounded,
                    size: 72, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  l.t('loginRequired'),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  l.t('loginOrRegisterSub'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ── Logged-in: stream orders ──────────────────────────────────────────────
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text(l.t('myOrders')),
        backgroundColor: _C.plum,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('userId', isEqualTo: auth.user!.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Show empty state on any error (collection may not exist yet)
          if (snapshot.hasError || !(snapshot.hasData)) {
            return _EmptyOrders(l: l, isDark: isDark);
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return _EmptyOrders(l: l, isDark: isDark);
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: docs.length,
            itemBuilder: (_, i) => _OrderCard(
              orderId: docs[i].id,
              data: docs[i].data(),
              l: l,
              isDark: isDark,
            ),
          );
        },
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────
class _EmptyOrders extends StatelessWidget {
  final AppLocalizations l;
  final bool isDark;
  const _EmptyOrders({required this.l, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: Colors.grey.withValues(alpha: 0.45),
          ),
          const SizedBox(height: 16),
          Text(
            l.t('noOrdersYet'),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : _C.wine,
                ),
          ),
        ],
      ),
    );
  }
}

// ─── Order card ───────────────────────────────────────────────────────────────
class _OrderCard extends StatelessWidget {
  final String orderId;
  final Map<String, dynamic> data;
  final AppLocalizations l;
  final bool isDark;

  const _OrderCard({
    required this.orderId,
    required this.data,
    required this.l,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg    = isDark ? _C.cardD : Colors.white;
    final textColor = isDark ? Colors.white : _C.wine;

    // Parse fields
    final createdAt  = (data['createdAt'] as Timestamp?)?.toDate();
    final dateStr    = createdAt != null
        ? '${createdAt.day.toString().padLeft(2, '0')}/'
          '${createdAt.month.toString().padLeft(2, '0')}/'
          '${createdAt.year}'
        : '—';
    final items      = (data['items'] as Map<String, dynamic>?) ?? {};
    final itemCount  = items.values
        .fold<int>(0, (s, v) => s + ((v as num?)?.toInt() ?? 0));
    final subtotal   = (data['subtotal']       as num?)?.toDouble() ?? 0;
    final discount   = (data['discountAmount'] as num?)?.toDouble() ?? 0;
    final total      = (data['total']          as num?)?.toDouble() ?? 0;
    final status     = (data['status']         as String?) ?? 'pending';
    final couponCode = data['couponCode']       as String?;

    // Status colour / icon
    Color    statusColor;
    IconData statusIcon;
    switch (status) {
      case 'completed':
        statusColor = Colors.green.shade600;
        statusIcon  = Icons.check_circle_rounded;
        break;
      case 'cancelled':
        statusColor = Colors.red.shade600;
        statusIcon  = Icons.cancel_rounded;
        break;
      default:
        statusColor = Colors.orange;
        statusIcon  = Icons.pending_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: short ID + status badge ──────────────────────────
          Row(
            children: [
              const Icon(Icons.receipt_rounded, size: 18, color: _C.gold),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '#${orderId.length >= 8 ? orderId.substring(0, 8).toUpperCase() : orderId.toUpperCase()}',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              // Status badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: statusColor.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 12, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Date
          Text(dateStr,
              style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // ── Order details ─────────────────────────────────────────────
          _InfoRow(
            icon: Icons.shopping_bag_outlined,
            label: l.t('checkoutItems'),
            value: '$itemCount',
            textColor: textColor,
          ),
          const SizedBox(height: 6),
          _InfoRow(
            icon: Icons.sell_outlined,
            label: l.t('subtotal'),
            value: '${subtotal.toStringAsFixed(2)} ${l.t('currency')}',
            textColor: textColor,
          ),
          if (discount > 0) ...[
            const SizedBox(height: 6),
            _InfoRow(
              icon: Icons.local_offer_outlined,
              label: couponCode != null
                  ? '${l.t('couponCode')}: $couponCode'
                  : l.t('couponDiscount'),
              value: '-${discount.toStringAsFixed(2)} ${l.t('currency')}',
              textColor: Colors.green.shade600,
            ),
          ],
          const SizedBox(height: 6),
          _InfoRow(
            icon: Icons.payments_outlined,
            label: l.t('total'),
            value: '${total.toStringAsFixed(2)} ${l.t('currency')}',
            textColor: _C.raspberry,
            bold: true,
          ),
        ],
      ),
    );
  }
}

// ─── Info row helper ──────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String   label;
  final String   value;
  final Color    textColor;
  final bool     bold;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.textColor,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: textColor,
            fontSize: 13,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
