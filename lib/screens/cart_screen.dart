import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_assignment_e/l10n/app_localizations.dart';
import 'package:project_assignment_e/providers/cart_provider.dart';
import 'package:project_assignment_e/utils/app_colors.dart';
import 'package:provider/provider.dart';

// Scaffold wrapper used when navigating via push (e.g. from HomeScreen)
class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(child: CartScreen()),
    );
  }
}

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  // Gradient pairs for item cards
  static const _gradients = [
    [Color(0xFF912F56), Color(0xFF6B1F3E)],
    [Color(0xFF521945), Color(0xFF3B0F33)],
    [Color(0xFF361F27), Color(0xFF24141A)],
    [Color(0xFF3D7A6A), Color(0xFF2A5549)],
    [Color(0xFF7A2C4A), Color(0xFF591E35)],
  ];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Column(
      children: [
        // ── Header ──────────────────────────────────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.wine, AppColors.primaryDark, AppColors.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.shopping_bag_rounded,
                      color: Colors.white, size: 28),
                  const SizedBox(width: 10),
                  Text(
                    l.t('cart'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Consumer<CartProvider>(
                    builder: (_, cart, __) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${cart.itemCount} ${l.t('checkoutItems')}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // ── Body ─────────────────────────────────────────────────────────────
        Expanded(
          child: Consumer<CartProvider>(
            builder: (context, cart, _) {
              if (cart.cartItems.isEmpty) {
                return _EmptyCart(l: l);
              }

              return Column(
                children: [
                  // Items list
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                      physics: const BouncingScrollPhysics(),
                      itemCount: cart.cartItems.length,
                      itemBuilder: (context, i) {
                        final item = cart.cartItems[i];
                        final grad =
                            _gradients[i % _gradients.length];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Dismissible(
                            key: Key('${item.id}_$i'),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20),
                              decoration: BoxDecoration(
                                color: Colors.red.shade700,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.delete_outline_rounded,
                                      color: Colors.white, size: 26),
                                  const SizedBox(height: 4),
                                  Text(
                                    l.t('removeItem'),
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            onDismissed: (_) {
                              HapticFeedback.mediumImpact();
                              cart.itemRemoveFromCart(item);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l.t('removedFromCart')),
                                  duration: const Duration(seconds: 2),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12)),
                                ),
                              );
                            },
                            child: _CartItemCard(
                              item: item,
                              gradient: grad,
                              l: l,
                              onRemove: () {
                                HapticFeedback.mediumImpact();
                                cart.itemRemoveFromCart(item);
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Order summary + checkout
                  _OrderSummary(cart: cart, l: l),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Cart Item Card ────────────────────────────────────────────────────────────
class _CartItemCard extends StatelessWidget {
  final dynamic item;
  final List<Color> gradient;
  final AppLocalizations l;
  final VoidCallback onRemove;

  const _CartItemCard({
    required this.item,
    required this.gradient,
    required this.l,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 105,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(20),
            ),
            child: SizedBox(
              width: 95,
              child: Image.network(
                item.image ?? '',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.music_note_rounded,
                      color: Colors.white38, size: 36),
                ),
              ),
            ),
          ),

          // Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.model ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.brand ?? '',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 12),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      const Icon(Icons.music_note_rounded,
                          color: Colors.white38, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        (item.category ?? '').toString().toUpperCase(),
                        style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 10,
                            letterSpacing: 0.5),
                      ),
                      const Spacer(),
                      Text(
                        '${l.t('currency')} ${item.price?.toStringAsFixed(2) ?? ''}',
                        style: const TextStyle(
                          color: AppColors.goldLight,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Remove button
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.remove_circle_outline_rounded,
                color: Colors.white60, size: 24),
            tooltip: l.t('removeItem'),
          ),
        ],
      ),
    );
  }
}

// ── Order Summary + Checkout ──────────────────────────────────────────────────
class _OrderSummary extends StatelessWidget {
  final CartProvider cart;
  final AppLocalizations l;

  const _OrderSummary({required this.cart, required this.l});

  void _checkout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shopping_bag_rounded,
                  color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Text(l.t('checkoutConfirm'),
                style: const TextStyle(fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SummaryRow(
              label: l.t('subtotal'),
              value:
                  '${l.t('currency')} ${cart.getcartTotal().toStringAsFixed(2)}',
              bold: false,
            ),
            const SizedBox(height: 6),
            _SummaryRow(
              label: l.t('shipping'),
              value: l.t('free'),
              valueColor: AppColors.sage,
              bold: false,
            ),
            const Divider(height: 20),
            _SummaryRow(
              label: l.t('total'),
              value:
                  '${l.t('currency')} ${cart.getcartTotal().toStringAsFixed(2)}',
              bold: true,
              valueColor: AppColors.primary,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.t('close'),
                style: const TextStyle(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              HapticFeedback.mediumImpact();
              cart.clearCart();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(children: [
                    const Icon(Icons.check_circle_rounded,
                        color: Colors.white),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l.t('orderConfirmed'),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold)),
                          Text(l.t('orderMsg'),
                              style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ]),
                  backgroundColor: AppColors.sage,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  duration: const Duration(seconds: 4),
                ),
              );
            },
            icon: const Icon(Icons.check_rounded),
            label: Text(l.t('checkout')),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Summary rows
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Column(
              children: [
                _SummaryRow(
                  label: '${l.t('subtotal')} (${cart.itemCount} ${l.t('checkoutItems')})',
                  value:
                      '${l.t('currency')} ${cart.getcartTotal().toStringAsFixed(2)}',
                  bold: false,
                ),
                const SizedBox(height: 6),
                _SummaryRow(
                  label: l.t('shipping'),
                  value: l.t('free'),
                  valueColor: AppColors.sage,
                  bold: false,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(),
                ),
                _SummaryRow(
                  label: l.t('total'),
                  value:
                      '${l.t('currency')} ${cart.getcartTotal().toStringAsFixed(2)}',
                  bold: true,
                  valueColor: AppColors.primary,
                ),
              ],
            ),
          ),

          // Checkout button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => _checkout(context),
                icon: const Icon(Icons.shopping_bag_rounded),
                label: Text(
                  l.t('checkout'),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: const StadiumBorder(),
                  elevation: 4,
                  shadowColor: AppColors.primary.withValues(alpha: 0.4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.bold,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: bold ? 16 : 14,
            fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
            color: bold
                ? null
                : Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: bold ? 18 : 14,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            color: valueColor ??
                (bold ? null : null),
          ),
        ),
      ],
    );
  }
}

// ── Empty Cart ────────────────────────────────────────────────────────────────
class _EmptyCart extends StatelessWidget {
  final AppLocalizations l;
  const _EmptyCart({required this.l});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shopping_cart_outlined,
                  size: 54, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            Text(
              l.t('emptyCart'),
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              l.t('emptyCartSub'),
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.55),
                  height: 1.5),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.store_rounded),
              label: Text(l.t('browseItems')),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
