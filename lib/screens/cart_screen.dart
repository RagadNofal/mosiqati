import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_assignment_e/l10n/app_localizations.dart';
import 'package:project_assignment_e/providers/auth_provider.dart';
import 'package:project_assignment_e/providers/cart_provider.dart';
import 'package:project_assignment_e/providers/sound_provider.dart';
import 'package:project_assignment_e/screens/auth/login_screen.dart';
import 'package:project_assignment_e/services/firestore_service.dart';
import 'package:project_assignment_e/utils/app_colors.dart';
import 'package:project_assignment_e/widgets/product_image.dart';
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
                        final entry = cart.cartItems[i];
                        final grad  = _gradients[i % _gradients.length];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Dismissible(
                            key: Key('${entry.product.id}_$i'),
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
                              cart.itemRemoveFromCart(entry);
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
                              entry:    entry,
                              gradient: grad,
                              l:        l,
                              onRemove: () {
                                HapticFeedback.mediumImpact();
                                cart.itemRemoveFromCart(entry);
                              },
                              onIncrement: () {
                                HapticFeedback.selectionClick();
                                cart.addQuantity(
                                    entry.product.id ?? '');
                              },
                              onDecrement: () {
                                HapticFeedback.selectionClick();
                                cart.removeQuantity(
                                    entry.product.id ?? '');
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Coupon input
                  _CouponInput(cart: cart, l: l),

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
  final CartEntry   entry;
  final List<Color> gradient;
  final AppLocalizations l;
  final VoidCallback onRemove;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _CartItemCard({
    required this.entry,
    required this.gradient,
    required this.l,
    required this.onRemove,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    final lang        = Localizations.localeOf(context).languageCode;
    final isRTL       = Directionality.of(context) == TextDirection.rtl;
    final l           = AppLocalizations.of(context);
    final product     = entry.product;
    final stock   = product.quantity ?? 0;
    final atLimit = entry.quantity >= stock;

    return Container(
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
            borderRadius: BorderRadius.only(
              topLeft:     Radius.circular(isRTL ? 0 : 20),
              bottomLeft:  Radius.circular(isRTL ? 0 : 20),
              topRight:    Radius.circular(isRTL ? 20 : 0),
              bottomRight: Radius.circular(isRTL ? 20 : 0),
            ),
            child: Container(
              width: 95,
              height: 110,
              color: Colors.white.withValues(alpha: 0.92),
              padding: const EdgeInsets.all(8),
              child: ProductImageWidget(
                imageUrl: product.image,
                fit:      BoxFit.contain,
                iconSize: 36,
                iconColor: const Color(0xFF912F56),
              ),
            ),
          ),

          // Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    product.displayModel(lang),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.displayBrand(lang),
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 8),

                  // ── Quantity stepper + price row ─────────────────────────
                  Row(
                    children: [
                      // Decrement
                      Semantics(
                        label: l.t('semDecQty'),
                        button: true,
                        child: GestureDetector(
                          onTap: onDecrement,
                          child: Container(
                            width: 34,
                            height: 34,
                            alignment: Alignment.center,
                            child: Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.remove_rounded,
                                  color: Colors.white, size: 14),
                            ),
                          ),
                        ),
                      ),

                      // Quantity
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          '${entry.quantity}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                      // Increment (greyed when at stock limit)
                      Semantics(
                        label: l.t('semIncQty'),
                        button: true,
                        enabled: !atLimit,
                        child: GestureDetector(
                          onTap: atLimit ? null : onIncrement,
                          child: Container(
                            width: 34,
                            height: 34,
                            alignment: Alignment.center,
                            child: Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: atLimit
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.add_rounded,
                                  color: atLimit
                                      ? Colors.white30
                                      : Colors.white,
                                  size: 14),
                            ),
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Price
                      Text(
                        '${l.t('currency')} '
                        '${((product.price ?? 0) * entry.quantity).toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppColors.goldLight,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.music_note_rounded,
                        color: Colors.white38, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      product.displayCategory(lang),
                      style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                          letterSpacing: 0.5),
                    ),
                    if (atLimit) ...[
                      const Spacer(),
                      Text(
                        l.t('atStockLimit'),
                        style: TextStyle(
                            color: Colors.amber.shade300,
                            fontSize: 9,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ]),
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

// ── Coupon Input ──────────────────────────────────────────────────────────────
class _CouponInput extends StatefulWidget {
  final CartProvider   cart;
  final AppLocalizations l;
  const _CouponInput({required this.cart, required this.l});

  @override
  State<_CouponInput> createState() => _CouponInputState();
}

class _CouponInputState extends State<_CouponInput> {
  final _ctrl      = TextEditingController();
  bool  _applying  = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _apply() async {
    final code = _ctrl.text.trim();
    if (code.isEmpty) return;
    setState(() => _applying = true);
    final errorKey = await widget.cart.applyCoupon(code);
    if (!mounted) return;
    setState(() => _applying = false);
    if (errorKey == null) {
      _ctrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: [
          const Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(widget.l.t('couponApplied')),
        ]),
        backgroundColor: AppColors.sage,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: [
          const Icon(Icons.error_outline_rounded,
              color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(widget.l.t(errorKey))),
        ]),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = widget.cart;
    final l    = widget.l;
    final lang = Localizations.localeOf(context).languageCode;

    // ── Coupon already applied ──────────────────────────────────────────────
    if (cart.appliedCoupon != null) {
      final c = cart.appliedCoupon!;
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.sage.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.sage.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              const Icon(Icons.local_offer_rounded,
                  color: AppColors.sage, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.code,
                      style: const TextStyle(
                        color:      AppColors.sage,
                        fontWeight: FontWeight.w800,
                        fontSize:   13,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      c.displayTitle(lang),
                      style: TextStyle(
                        color:   AppColors.sage.withValues(alpha: 0.8),
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  cart.removeCoupon();
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red.shade600,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(60, 32),
                ),
                child: Text(l.t('removeCoupon'),
                    style: const TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ),
      );
    }

    // ── Coupon code input ───────────────────────────────────────────────────
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _ctrl,
              textCapitalization: TextCapitalization.characters,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 1),
              decoration: InputDecoration(
                hintText:      l.t('enterCouponCode'),
                hintStyle:     const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.normal,
                    letterSpacing: 0),
                prefixIcon:    const Icon(Icons.local_offer_outlined,
                    size: 18, color: AppColors.primary),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14)),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                isDense: true,
              ),
              onSubmitted: (_) => _apply(),
            ),
          ),
          const SizedBox(width: 8),
          Semantics(
            label: widget.l.t('semApplyCoupon'),
            button: true,
            child: SizedBox(
              height: 46,
              child: ElevatedButton(
                onPressed: _applying ? null : _apply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: _applying
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Text(l.t('applyCoupon'),
                        style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Order Summary + Checkout ──────────────────────────────────────────────────
class _OrderSummary extends StatelessWidget {
  final CartProvider   cart;
  final AppLocalizations l;

  const _OrderSummary({required this.cart, required this.l});

  void _checkout(BuildContext context) {
    // ── Guest guard ──────────────────────────────────────────────────────────
    final auth = context.read<AppAuthProvider>();
    if (!auth.isLoggedIn) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_outline_rounded,
                    color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(l.t('loginRequired'))),
            ],
          ),
          content: Text(l.t('loginToCheckout')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l.t('cancel')),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              child: Text(l.t('signIn')),
            ),
          ],
        ),
      );
      return;
    }

    // ── Snapshot values before async gap ────────────────────────────────────
    final userId        = auth.user?.uid ?? '';
    final items         = cart.checkoutItems;
    final subtotal      = cart.subtotal;
    final discountAmt   = cart.discountAmount;
    final finalTotal    = cart.getcartTotal();
    final coupon        = cart.appliedCoupon;

    // ── Checkout confirmation dialog ─────────────────────────────────────────
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24)),
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
                    '${l.t('currency')} ${subtotal.toStringAsFixed(2)}',
                bold: false,
              ),
              if (discountAmt > 0) ...[
                const SizedBox(height: 6),
                _SummaryRow(
                  label: l.t('couponDiscount'),
                  value:
                      '- ${l.t('currency')} ${discountAmt.toStringAsFixed(2)}',
                  valueColor: AppColors.sage,
                  bold: false,
                ),
              ],
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
                    '${l.t('currency')} ${finalTotal.toStringAsFixed(2)}',
                bold: true,
                valueColor: AppColors.primary,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(ctx),
              child: Text(l.t('close'),
                  style: const TextStyle(color: Colors.grey)),
            ),
            ElevatedButton.icon(
              onPressed: isLoading
                  ? null
                  : () async {
                      setDialogState(() => isLoading = true);
                      HapticFeedback.mediumImpact();

                      try {
                        // Only run the Firestore transaction when there are
                        // Firestore-backed products.  Static JSON products
                        // (no real Firestore documents) are skipped.
                        if (items.isNotEmpty) {
                          await FirestoreService().checkout(
                            items,
                            userId:         userId,
                            subtotal:       subtotal,
                            discountAmount: discountAmt,
                            finalTotal:     finalTotal,
                            coupon:         coupon,
                          );
                        }

                        cart.clearCart();
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(children: [
                                const Icon(Icons.check_circle_rounded,
                                    color: Colors.white),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(l.t('orderConfirmed'),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      Text(l.t('orderMsg'),
                                          style: const TextStyle(
                                              fontSize: 12)),
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
                        }
                      } on CheckoutException catch (e) {
                        if (ctx.mounted) {
                          setDialogState(() => isLoading = false);
                          Navigator.pop(ctx);
                        }
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.message),
                              backgroundColor: Colors.red.shade700,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              duration: const Duration(seconds: 4),
                            ),
                          );
                        }
                      } catch (_) {
                        if (ctx.mounted) {
                          setDialogState(() => isLoading = false);
                          Navigator.pop(ctx);
                        }
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l.t('checkoutError')),
                              backgroundColor: Colors.red.shade700,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              duration: const Duration(seconds: 4),
                            ),
                          );
                        }
                      }
                    },
              icon: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.check_rounded),
              label: Text(l.t('checkout')),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
              ),
            ),
          ],
        ),
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
                  label:
                      '${l.t('subtotal')} (${cart.itemCount} ${l.t('checkoutItems')})',
                  value:
                      '${l.t('currency')} ${cart.subtotal.toStringAsFixed(2)}',
                  bold: false,
                ),
                if (cart.discountAmount > 0) ...[
                  const SizedBox(height: 6),
                  _SummaryRow(
                    label: l.t('couponDiscount'),
                    value:
                        '- ${l.t('currency')} ${cart.discountAmount.toStringAsFixed(2)}',
                    valueColor: AppColors.sage,
                    bold: false,
                  ),
                ],
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
            child: Semantics(
              label: l.t('semCheckout'),
              button: true,
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
            ),   // closes Semantics
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
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

// ── Empty Cart ────────────────────────────────────────────────────────────────
class _EmptyCart extends StatefulWidget {
  final AppLocalizations l;
  const _EmptyCart({required this.l});

  @override
  State<_EmptyCart> createState() => _EmptyCartState();
}

class _EmptyCartState extends State<_EmptyCart> {
  @override
  void initState() {
    super.initState();
    // Play the empty-cart sound once, after the first frame, so it fires
    // only when the empty state first appears — not on every rebuild.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<SoundProvider>().play(SoundType.emptyCart);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.l;
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
