import 'package:flutter/material.dart';
import 'package:project_assignment_e/l10n/app_localizations.dart';
import 'package:project_assignment_e/models/coupon.dart';
import 'package:project_assignment_e/models/firestore_product.dart';
import 'package:project_assignment_e/providers/auth_provider.dart';
import 'package:project_assignment_e/providers/notifications_provider.dart';
import 'package:project_assignment_e/screens/admin/coupons/admin_coupons_screen.dart';
import 'package:project_assignment_e/screens/admin/product_form_screen.dart';
import 'package:project_assignment_e/screens/notifications_screen.dart';
import 'package:project_assignment_e/services/coupon_service.dart';
import 'package:project_assignment_e/services/firestore_service.dart';
import 'package:project_assignment_e/utils/app_colors.dart';
import 'package:provider/provider.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final l    = AppLocalizations.of(context);
    final auth = context.watch<AppAuthProvider>();

    // Guard — only admins allowed.
    if (!auth.isAdmin) {
      return Scaffold(
        body: Center(
          child: Text(l.t('adminOnly'),
              style: Theme.of(context).textTheme.titleMedium),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l.t('adminDashboard')),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: l.t('logout'),
            onPressed: () async {
              final confirmed = await _confirm(context, l.t('logout'),
                  'Are you sure you want to sign out?');
              if (confirmed && context.mounted) {
                await context.read<AppAuthProvider>().signOut();
                // AuthGate will rebuild and show WelcomeScreen automatically.
              }
            },
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'fab_coupons',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AdminCouponsScreen()),
            ),
            icon:            const Icon(Icons.local_offer_rounded),
            label:           Text(l.t('manageCoupons')),
            backgroundColor: const Color(0xFF3D7A6A),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'fab_add_product',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProductFormScreen()),
            ),
            icon:  const Icon(Icons.add),
            label: Text(l.t('addProduct')),
          ),
        ],
      ),
      body: StreamBuilder<List<FirestoreProduct>>(
        stream: FirestoreService().streamAllProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final products = snapshot.data ?? [];
          final total      = products.length;
          final lowStock   = products.where((p) => p.isLowStock).length;
          final outOfStock = products.where((p) => p.isOutOfStock).length;

          return CustomScrollView(
            slivers: [
              // ── Quick-nav cards ─────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    children: [
                      _NavCard(
                        label: l.t('manageProducts'),
                        icon:  Icons.inventory_2_outlined,
                        color: AppColors.primary,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const ProductFormScreen()),
                        ),
                      ),
                      const SizedBox(width: 10),
                      _NavCard(
                        label: l.t('manageCoupons'),
                        icon:  Icons.local_offer_rounded,
                        color: const Color(0xFF3D7A6A),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const AdminCouponsScreen()),
                        ),
                      ),
                      const SizedBox(width: 10),
                      _NavCard(
                        label: l.t('manageNotifications'),
                        icon:  Icons.notifications_rounded,
                        color: const Color(0xFFD4A853),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const NotificationsScreen()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Stats row 1: product counts ──────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      _StatCard(
                        label: l.t('totalProducts'),
                        value: '$total',
                        icon: Icons.inventory_2_outlined,
                        color: AppColors.primary,
                        onTap: () => _showProductList(
                          context,
                          l.t('allProductsTitle'),
                          products,
                          l,
                        ),
                      ),
                      const SizedBox(width: 10),
                      _StatCard(
                        label: l.t('lowStockCount'),
                        value: '$lowStock',
                        icon: Icons.warning_amber_rounded,
                        color: Colors.orange,
                        onTap: () => _showProductList(
                          context,
                          l.t('lowStockProducts'),
                          products.where((p) => p.isLowStock).toList(),
                          l,
                          emptyKey: 'noLowStockProducts',
                        ),
                      ),
                      const SizedBox(width: 10),
                      _StatCard(
                        label: l.t('outOfStockCount'),
                        value: '$outOfStock',
                        icon: Icons.remove_shopping_cart_outlined,
                        color: Colors.red.shade700,
                        onTap: () => _showProductList(
                          context,
                          l.t('outOfStockProducts'),
                          products.where((p) => p.isOutOfStock).toList(),
                          l,
                          emptyKey: 'noOutOfStockProducts',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Stats row 2: coupons + notifications ─────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Row(
                    children: [
                      // Active coupons count from Firestore stream
                      Expanded(
                        child: StreamBuilder<List<Coupon>>(
                          stream: CouponService().streamAllCoupons(),
                          builder: (context, snap) {
                            final activeCoupons = (snap.data ?? [])
                                .where((c) => c.isCurrentlyValid)
                                .length;
                            return _StatTile(
                              label: l.t('activeCoupons'),
                              value: '${snap.hasData ? activeCoupons : '-'}',
                              icon: Icons.local_offer_rounded,
                              color: const Color(0xFF3D7A6A),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Notifications count from provider
                      Expanded(
                        child: Consumer<NotificationsProvider>(
                          builder: (context, notifs, _) => _StatTile(
                            label: l.t('notificationsCount'),
                            value: '${notifs.items.length}',
                            icon: Icons.notifications_rounded,
                            color: const Color(0xFFD4A853),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Product list ─────────────────────────────────
              if (products.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inventory_2_outlined,
                            size: 72,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.3)),
                        const SizedBox(height: 12),
                        Text(l.t('noProducts'),
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        FilledButton.icon(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const ProductFormScreen()),
                          ),
                          icon: const Icon(Icons.add),
                          label: Text(l.t('addProduct')),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _ProductTile(product: products[index]),
                    childCount: products.length,
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 88)),
            ],
          );
        },
      ),
    );
  }

  Future<bool> _confirm(BuildContext context, String title, String body) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true),  child: const Text('Yes')),
        ],
      ),
    );
    return result ?? false;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Navigation card widget
// ─────────────────────────────────────────────────────────────────────────────

class _NavCard extends StatelessWidget {
  final String   label;
  final IconData icon;
  final Color    color;
  final VoidCallback onTap;

  const _NavCard({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Expanded(
        child: InkWell(
          onTap:        onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            decoration: BoxDecoration(
              color:        color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(16),
              border:       Border.all(color: color.withValues(alpha: 0.30)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width:  44,
                  height: 44,
                  decoration: BoxDecoration(
                    color:  color.withValues(alpha: 0.15),
                    shape:  BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines:  2,
                  style: TextStyle(
                    fontSize:   11,
                    fontWeight: FontWeight.w700,
                    color:      color,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Stat card widget
// ─────────────────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color  color;
  final VoidCallback? onTap;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => Expanded(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            decoration: BoxDecoration(
              color:        color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(14),
              border:       Border.all(color: color.withOpacity(0.25)),
            ),
            child: Column(
              children: [
                Icon(icon, color: color, size: 26),
                const SizedBox(height: 6),
                Text(value,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: color)),
                const SizedBox(height: 2),
                Text(label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: Theme.of(context).textTheme.labelSmall),
                if (onTap != null) ...[
                  const SizedBox(height: 2),
                  Icon(Icons.chevron_right_rounded, color: color, size: 14),
                ],
              ],
            ),
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Stat tile — like _StatCard but WITHOUT the Expanded wrapper, so it can be
// placed inside an explicit Expanded in the second stats row.
// ─────────────────────────────────────────────────────────────────────────────

class _StatTile extends StatelessWidget {
  final String   label;
  final String   value;
  final IconData icon;
  final Color    color;

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color:        color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(14),
          border:       Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color)),
            const SizedBox(height: 2),
            Text(label,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper — show a modal bottom sheet with a filtered product list
// ─────────────────────────────────────────────────────────────────────────────

void _showProductList(
  BuildContext context,
  String title,
  List<FirestoreProduct> products,
  AppLocalizations l, {
  String? emptyKey,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.65,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (ctx, scrollController) => Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Title
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const Divider(height: 1),
          // Product list or empty state
          Expanded(
            child: products.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_outline_rounded,
                              size: 56,
                              color: Colors.green.shade400),
                          const SizedBox(height: 12),
                          Text(
                            emptyKey != null ? l.t(emptyKey) : l.t('noProducts'),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: scrollController,
                    itemCount: products.length,
                    itemBuilder: (_, i) => _ProductTile(product: products[i]),
                  ),
          ),
        ],
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Product tile
// ─────────────────────────────────────────────────────────────────────────────

class _ProductTile extends StatelessWidget {
  final FirestoreProduct product;
  const _ProductTile({required this.product});

  @override
  Widget build(BuildContext context) {
    final l     = AppLocalizations.of(context);
    final theme = Theme.of(context);

    Color statusColor;
    String statusLabel;
    if (product.isOutOfStock) {
      statusColor = Colors.red.shade700;
      statusLabel = l.t('outOfStock');
    } else if (product.isLowStock) {
      statusColor = Colors.orange;
      statusLabel = l.t('lowStock');
    } else if (!product.isAvailable) {
      statusColor = Colors.grey;
      statusLabel = l.t('unavailable');
    } else {
      statusColor = Colors.green.shade700;
      statusLabel = l.t('available');
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
        leading: _ProductImage(product: product),
        title: Text(
          product.nameEn,
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${product.price.toStringAsFixed(2)} ${l.t('currency')}  •  Qty: ${product.quantity}',
                style: theme.textTheme.bodySmall),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color:        statusColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border:       Border.all(color: statusColor.withOpacity(0.4)),
              ),
              child: Text(statusLabel,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor)),
            ),
          ],
        ),
        trailing: _ActionMenu(product: product),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
              builder: (_) => ProductFormScreen(product: product)),
        ),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  final FirestoreProduct product;
  const _ProductImage({required this.product});

  @override
  Widget build(BuildContext context) {
    final img = product.displayImage;
    if (img.isEmpty) {
      return Container(
        width: 56, height: 56,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.music_note_rounded, color: AppColors.primary),
      );
    }
    final isNetwork = img.startsWith('http');
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: isNetwork
          ? Image.network(img, width: 56, height: 56, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.broken_image_outlined))
          : Image.asset(img, width: 56, height: 56, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.broken_image_outlined)),
    );
  }
}

class _ActionMenu extends StatelessWidget {
  final FirestoreProduct product;
  const _ActionMenu({required this.product});

  @override
  Widget build(BuildContext context) {
    final l       = AppLocalizations.of(context);
    final service = FirestoreService();

    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) async {
        switch (value) {
          case 'edit':
            Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => ProductFormScreen(product: product)),
            );
          case 'toggle':
            if (product.isAvailable) {
              final ok = await _confirm(context, l.t('disableProduct'),
                  l.t('disableConfirm'));
              if (ok) {
                await service.disableProduct(product.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l.t('productDisabled'))));
                }
              }
            } else {
              await service.enableProduct(product.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l.t('productEnabled'))));
              }
            }
          case 'delete':
            final ok = await _confirm(context, l.t('deleteProduct'),
                l.t('deleteConfirm'));
            if (ok) {
              await service.deleteProduct(product.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l.t('productDeleted'))));
              }
            }
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'edit',
          child: ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: Text(l.t('editProduct')),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        PopupMenuItem(
          value: 'toggle',
          child: ListTile(
            leading: Icon(product.isAvailable
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined),
            title: Text(product.isAvailable
                ? l.t('disableProduct')
                : l.t('enableProduct')),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: ListTile(
            leading: Icon(Icons.delete_outline, color: Colors.red.shade700),
            title: Text(l.t('deleteProduct'),
                style: TextStyle(color: Colors.red.shade700)),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }

  Future<bool> _confirm(BuildContext context, String title, String body) async {
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
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
