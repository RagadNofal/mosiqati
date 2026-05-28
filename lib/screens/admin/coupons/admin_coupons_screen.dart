import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:project_assignment_e/l10n/app_localizations.dart';
import 'package:project_assignment_e/models/coupon.dart';
import 'package:project_assignment_e/screens/admin/coupons/coupon_form_screen.dart';
import 'package:project_assignment_e/services/coupon_service.dart';
import 'package:project_assignment_e/utils/app_colors.dart';

class AdminCouponsScreen extends StatelessWidget {
  const AdminCouponsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.t('manageCoupons')),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CouponFormScreen()),
        ),
        icon:  const Icon(Icons.add),
        label: Text(l.t('addCoupon')),
      ),
      body: StreamBuilder<List<Coupon>>(
        stream: CouponService().streamAllCoupons(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final coupons = snapshot.data ?? [];
          if (coupons.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.local_offer_outlined,
                      size: 72,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.3)),
                  const SizedBox(height: 12),
                  Text(l.t('noCoupons'),
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const CouponFormScreen()),
                    ),
                    icon:  const Icon(Icons.add),
                    label: Text(l.t('addCoupon')),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            itemCount: coupons.length,
            itemBuilder: (context, i) =>
                _CouponTile(coupon: coupons[i]),
          );
        },
      ),
    );
  }
}

// ── Coupon Tile ───────────────────────────────────────────────────────────────
class _CouponTile extends StatelessWidget {
  final Coupon coupon;
  const _CouponTile({required this.coupon});

  @override
  Widget build(BuildContext context) {
    final l      = AppLocalizations.of(context);
    final theme  = Theme.of(context);
    final fmt    = DateFormat('dd MMM yyyy');

    // Status badge config
    Color statusColor;
    String statusLabel;
    IconData statusIcon;
    switch (coupon.status) {
      case CouponStatus.active:
        statusColor = Colors.green.shade700;
        statusLabel = l.t('couponStatusActive');
        statusIcon  = Icons.check_circle_outline_rounded;
      case CouponStatus.expired:
        statusColor = Colors.grey;
        statusLabel = l.t('couponStatusExpired');
        statusIcon  = Icons.schedule_rounded;
      case CouponStatus.notStarted:
        statusColor = Colors.blue.shade700;
        statusLabel = l.t('couponStatusNotStarted');
        statusIcon  = Icons.hourglass_top_rounded;
      case CouponStatus.usageLimitReached:
        statusColor = Colors.orange.shade700;
        statusLabel = l.t('couponStatusLimitReached');
        statusIcon  = Icons.block_rounded;
      case CouponStatus.inactive:
        statusColor = Colors.red.shade700;
        statusLabel = l.t('couponStatusInactive');
        statusIcon  = Icons.visibility_off_outlined;
    }

    final discountLabel = coupon.discountType == 'percentage'
        ? '${coupon.discountValue.toStringAsFixed(0)}%'
        : '${l.t('currency')} ${coupon.discountValue.toStringAsFixed(2)}';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top row: code + discount + menu ─────────────────────────────
            Row(
              children: [
                // Code chip
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.35)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.local_offer_rounded,
                          size: 14, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        coupon.code,
                        style: const TextStyle(
                          fontSize:   13,
                          fontWeight: FontWeight.w800,
                          color:      AppColors.primary,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Discount badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color:        Colors.amber.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: Colors.amber.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    '- $discountLabel',
                    style: const TextStyle(
                      fontSize:   12,
                      fontWeight: FontWeight.w700,
                      color:      Colors.amber,
                    ),
                  ),
                ),

                const Spacer(),
                _ActionMenu(coupon: coupon),
              ],
            ),

            const SizedBox(height: 8),

            // ── Title ────────────────────────────────────────────────────────
            Text(
              coupon.titleEn,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 6),

            // ── Validity ─────────────────────────────────────────────────────
            Row(
              children: [
                const Icon(Icons.calendar_month_outlined,
                    size: 13, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${fmt.format(coupon.validFrom)} – ${fmt.format(coupon.validUntil)}',
                  style: theme.textTheme.labelSmall,
                ),
              ],
            ),

            const SizedBox(height: 6),

            // ── Bottom row: status + usage ────────────────────────────────────
            Row(
              children: [
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color:        statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: statusColor.withValues(alpha: 0.35)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 11, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize:   10,
                          fontWeight: FontWeight.w600,
                          color:      statusColor,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Usage
                Icon(Icons.people_outline_rounded,
                    size: 13,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5)),
                const SizedBox(width: 3),
                Text(
                  coupon.usageLimit != null
                      ? '${coupon.usedCount} / ${coupon.usageLimit}'
                      : '${coupon.usedCount} ${l.t('couponUsed')}',
                  style: theme.textTheme.labelSmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Action menu ───────────────────────────────────────────────────────────────
class _ActionMenu extends StatelessWidget {
  final Coupon coupon;
  const _ActionMenu({required this.coupon});

  @override
  Widget build(BuildContext context) {
    final l       = AppLocalizations.of(context);
    final service = CouponService();

    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) async {
        HapticFeedback.lightImpact();
        switch (value) {
          case 'edit':
            Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => CouponFormScreen(coupon: coupon)),
            );
          case 'toggle':
            await service.toggleActive(coupon.id, coupon.isActive);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(coupon.isActive
                    ? l.t('couponDeactivated')
                    : l.t('couponActivated')),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ));
            }
          case 'delete':
            final ok = await _confirm(
                context, l.t('deleteCoupon'), l.t('deleteCouponConfirm'));
            if (ok) {
              await service.deleteCoupon(coupon.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(l.t('couponDeleted')),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ));
              }
            }
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'edit',
          child: ListTile(
            leading: const Icon(Icons.edit_outlined),
            title:   Text(l.t('editCoupon')),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        PopupMenuItem(
          value: 'toggle',
          child: ListTile(
            leading: Icon(coupon.isActive
                ? Icons.pause_circle_outline_rounded
                : Icons.play_circle_outline_rounded),
            title: Text(coupon.isActive
                ? l.t('deactivateCoupon')
                : l.t('activateCoupon')),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: ListTile(
            leading: Icon(Icons.delete_outline,
                color: Colors.red.shade700),
            title: Text(l.t('deleteCoupon'),
                style: TextStyle(color: Colors.red.shade700)),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }

  Future<bool> _confirm(
      BuildContext context, String title, String body) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title:   Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style:
                FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
