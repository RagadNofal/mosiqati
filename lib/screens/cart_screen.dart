import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_assignment_e/providers/cart_provider.dart';
import 'package:project_assignment_e/screens/home_page.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen>
    with SingleTickerProviderStateMixin {
  // ── Light colours ──────────────────────────
  static const Color _bgLight = Color(0xfffbf6ef);
  static const Color _darkBrownBase = Color(0xff2b130c);
  static const Color _brownBase = Color(0xffb86f4b);
  static const Color _lightBrownBase = Color(0xffefe2d8);
  static const Color _olive = Color(0xff71805a);

  // ── Dark colours ──────────────────────────
  static const Color _bgDark = Color(0xff1a1008);
  static const Color _surfaceDark = Color(0xff2c1a0e);
  static const Color _textDark = Color(0xfffde8d4);
  static const Color _brownDark = Color(0xffcf8a65);

  final TextEditingController _promoCtrl = TextEditingController();

  bool _promoApplied = false;
  bool _promoError = false;
  double _discount = 0.0;

  late AnimationController _enterCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  static const String _validPromo = "MOSIQATI10";

  @override
  void initState() {
    super.initState();

    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    _fadeAnim = CurvedAnimation(
      parent: _enterCtrl,
      curve: Curves.easeIn,
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _enterCtrl,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    _promoCtrl.dispose();
    super.dispose();
  }

  void _tap() => HapticFeedback.lightImpact();
  void _success() => HapticFeedback.mediumImpact();
  void _err() => HapticFeedback.heavyImpact();

  void _toggleDarkMode(BuildContext ctx) {
    Provider.of<ThemeProvider>(ctx, listen: false).toggle();
    _tap();
  }

  void _applyPromo() {
    _tap();

    if (_promoCtrl.text.trim().toUpperCase() == _validPromo) {
      setState(() {
        _promoApplied = true;
        _promoError = false;
        _discount = 0.10;
      });

      _success();
      _showSnack("🎉 Promo code applied! 10% discount.", _olive);
    } else {
      setState(() {
        _promoApplied = false;
        _promoError = true;
        _discount = 0.0;
      });

      _err();
    }
  }

  void _removePromo() {
    _tap();

    setState(() {
      _promoApplied = false;
      _promoError = false;
      _discount = 0.0;
      _promoCtrl.clear();
    });
  }

  void _showCheckoutDialog(
    double total,
    bool isDark,
    Color bgColor,
    Color surfaceCol,
    Color mainText,
    Color brownCol,
    Color lightBrCol,
  ) {
    _tap();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: surfaceCol,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: lightBrCol,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline,
                color: _olive,
                size: 42,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Confirm Order",
              style: TextStyle(
                color: mainText,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Text(
          "Your order total is \$${total.toStringAsFixed(2)}.\nProceed to checkout?",
          style: TextStyle(
            color: isDark ? _textDark.withOpacity(0.75) : Colors.brown.shade400,
            fontSize: 15,
          ),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(
                color:
                    isDark ? _textDark.withOpacity(0.75) : Colors.brown.shade400,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<CartProvider>(context, listen: false).clearCart();
              _success();
              _showSnack("✅ Order placed successfully! Thank you.", _olive);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: brownCol,
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
            ),
            child: const Text(
              "Place Order",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        content: Text(
          msg,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;

    final bgColor = isDark ? _bgDark : _bgLight;
    final surfaceCol = isDark ? _surfaceDark : Colors.white;
    final mainText = isDark ? _textDark : _darkBrownBase;
    final brownCol = isDark ? _brownDark : _brownBase;
    final lightBrCol = isDark ? const Color(0xff3a2010) : _lightBrownBase;
    final borderCol = isDark ? Colors.white.withOpacity(0.08) : const Color(0xffeadcd1);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: Consumer<CartProvider>(
              builder: (ctx, cart, _) => cart.cartItems.isNotEmpty
                  ? _buildCartFull(
                      ctx,
                      cart,
                      isDark,
                      bgColor,
                      surfaceCol,
                      mainText,
                      brownCol,
                      lightBrCol,
                      borderCol,
                    )
                  : _buildEmptyCart(
                      ctx,
                      isDark,
                      bgColor,
                      surfaceCol,
                      mainText,
                      brownCol,
                      lightBrCol,
                      borderCol,
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCartFull(
    BuildContext ctx,
    CartProvider cart,
    bool isDark,
    Color bgColor,
    Color surfaceCol,
    Color mainText,
    Color brownCol,
    Color lightBrCol,
    Color borderCol,
  ) {
    final subtotal = double.tryParse(cart.getcartTotal().toString()) ?? 0.0;
    final discountAmt = subtotal * _discount;
    final total = subtotal - discountAmt;

    return Column(
      children: [
        _buildHeader(
          ctx,
          cart.cartItems.length,
          isDark,
          surfaceCol,
          mainText,
          brownCol,
          lightBrCol,
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            itemCount: cart.cartItems.length,
            itemBuilder: (ctx, i) => _buildCartItemCard(
              ctx,
              cart.cartItems[i],
              i,
              isDark,
              bgColor,
              surfaceCol,
              mainText,
              brownCol,
              lightBrCol,
              borderCol,
            ),
          ),
        ),
        _buildPromoField(
          isDark,
          surfaceCol,
          mainText,
          brownCol,
          lightBrCol,
          borderCol,
        ),
        _buildOrderSummary(
          ctx,
          subtotal,
          discountAmt,
          total,
          isDark,
          bgColor,
          surfaceCol,
          mainText,
          brownCol,
          lightBrCol,
          borderCol,
        ),
      ],
    );
  }

  Widget _buildHeader(
    BuildContext ctx,
    int count,
    bool isDark,
    Color surfaceCol,
    Color mainText,
    Color brownCol,
    Color lightBrCol,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              _tap();
              Navigator.pop(ctx);
            },
            child: CircleAvatar(
              radius: 24,
              backgroundColor: surfaceCol.withOpacity(0.90),
              child: Icon(Icons.arrow_back, color: mainText),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            "My Cart",
            style: TextStyle(
              color: mainText,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              fontFamily: "serif",
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => _toggleDarkMode(ctx),
            child: CircleAvatar(
              radius: 22,
              backgroundColor: lightBrCol,
              child: Icon(
                isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                color: mainText,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: lightBrCol,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "$count item${count != 1 ? 's' : ''}",
              style: TextStyle(
                color: mainText,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemCard(
    BuildContext ctx,
    dynamic item,
    int index,
    bool isDark,
    Color bgColor,
    Color surfaceCol,
    Color mainText,
    Color brownCol,
    Color lightBrCol,
    Color borderCol,
  ) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.92, end: 1.0),
      duration: Duration(milliseconds: 350 + index * 60),
      curve: Curves.easeOutBack,
      builder: (_, val, child) => Transform.scale(scale: val, child: child),
      child: Dismissible(
        key: Key("${item.id}_$index"),
        direction: DismissDirection.endToStart,
        confirmDismiss: (_) async {
          bool confirmed = false;

          await showDialog(
            context: ctx,
            builder: (_) => AlertDialog(
              backgroundColor: surfaceCol,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: Text(
                "Remove Item?",
                style: TextStyle(
                  color: mainText,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Text(
                "Remove \"${item.model}\" from cart?",
                style: TextStyle(
                  color: isDark
                      ? _textDark.withOpacity(0.75)
                      : Colors.brown.shade400,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    confirmed = false;
                    Navigator.pop(ctx);
                  },
                  child: Text(
                    "Keep",
                    style: TextStyle(
                      color: isDark
                          ? _textDark.withOpacity(0.75)
                          : Colors.brown.shade400,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    confirmed = true;
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                  ),
                  child: const Text("Remove"),
                ),
              ],
            ),
          );

          return confirmed;
        },
        onDismissed: (_) {
          Provider.of<CartProvider>(ctx, listen: false)
              .itemRemoveFromCart(item);
          _tap();
          _showSnack("${item.model} removed from cart.", brownCol);
        },
        background: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.redAccent.withOpacity(0.85),
            borderRadius: BorderRadius.circular(28),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.delete_outline, color: Colors.white, size: 30),
              SizedBox(height: 4),
              Text(
                "Remove",
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: surfaceCol.withOpacity(0.90),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: borderCol),
            boxShadow: [
              BoxShadow(
                color: Colors.brown.withOpacity(isDark ? 0.18 : 0.08),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 110,
                height: 120,
                decoration: BoxDecoration(
                  color: lightBrCol,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Image.network(
                    item.image.toString(),
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.image_not_supported_outlined,
                      color: isDark
                          ? _textDark.withOpacity(0.45)
                          : Colors.brown.shade300,
                      size: 38,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.model.toString(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: mainText,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: lightBrCol,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        item.category?.toString() ?? "Instrument",
                        style: TextStyle(
                          color: brownCol,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "\$${item.price}",
                      style: TextStyle(
                        color: brownCol,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  _tap();

                  showDialog(
                    context: ctx,
                    builder: (_) => AlertDialog(
                      backgroundColor: surfaceCol,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      title: Text(
                        "Remove Item?",
                        style: TextStyle(
                          color: mainText,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      content: Text(
                        "Remove \"${item.model}\" from cart?",
                        style: TextStyle(
                          color: isDark
                              ? _textDark.withOpacity(0.75)
                              : Colors.brown.shade400,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: Text(
                            "Keep",
                            style: TextStyle(
                              color: isDark
                                  ? _textDark.withOpacity(0.75)
                                  : Colors.brown.shade400,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Provider.of<CartProvider>(ctx, listen: false)
                                .itemRemoveFromCart(item);
                            _tap();
                            Navigator.pop(ctx);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            shape: const StadiumBorder(),
                          ),
                          child: const Text("Remove"),
                        ),
                      ],
                    ),
                  );
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPromoField(
    bool isDark,
    Color surfaceCol,
    Color mainText,
    Color brownCol,
    Color lightBrCol,
    Color borderCol,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: surfaceCol.withOpacity(0.90),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: _promoApplied
                ? _olive
                : _promoError
                    ? Colors.redAccent
                    : borderCol,
            width: _promoApplied || _promoError ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              _promoApplied
                  ? Icons.check_circle_outline
                  : Icons.local_offer_outlined,
              color: _promoApplied ? _olive : brownCol,
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _promoApplied
                  ? const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "\"MOSIQATI10\" applied!",
                          style: TextStyle(
                            color: _olive,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          "10% discount added",
                          style: TextStyle(
                            color: _olive,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    )
                  : TextField(
                      controller: _promoCtrl,
                      style: TextStyle(color: mainText),
                      decoration: InputDecoration(
                        hintText: "Enter promo code (try MOSIQATI10)",
                        hintStyle: TextStyle(
                          color: isDark
                              ? _textDark.withOpacity(0.50)
                              : Colors.brown.shade300,
                          fontSize: 13,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        errorText: _promoError ? "Invalid promo code" : null,
                      ),
                      onSubmitted: (_) => _applyPromo(),
                    ),
            ),
            const SizedBox(width: 8),
            _promoApplied
                ? GestureDetector(
                    onTap: _removePromo,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: lightBrCol,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        "Remove",
                        style: TextStyle(
                          color: brownCol,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                : GestureDetector(
                    onTap: _applyPromo,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: brownCol,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Text(
                        "Apply",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(
    BuildContext ctx,
    double subtotal,
    double discountAmt,
    double total,
    bool isDark,
    Color bgColor,
    Color surfaceCol,
    Color mainText,
    Color brownCol,
    Color lightBrCol,
    Color borderCol,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceCol.withOpacity(0.96),
        borderRadius: BorderRadius.circular(34),
        border: Border.all(color: borderCol),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(isDark ? 0.18 : 0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _summaryRow(
            "Subtotal",
            "\$${subtotal.toStringAsFixed(2)}",
            isDark ? _textDark.withOpacity(0.65) : Colors.brown.shade400,
            mainText,
          ),
          if (_promoApplied) ...[
            const SizedBox(height: 8),
            _summaryRow(
              "Discount (10%)",
              "-\$${discountAmt.toStringAsFixed(2)}",
              _olive,
              _olive,
            ),
          ],
          const SizedBox(height: 8),
          Container(
            height: 1,
            color: borderCol,
            margin: const EdgeInsets.symmetric(vertical: 4),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total",
                style: TextStyle(
                  color: isDark
                      ? _textDark.withOpacity(0.65)
                      : Colors.brown.shade400,
                  fontSize: 18,
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  "\$${total.toStringAsFixed(2)}",
                  key: ValueKey(total),
                  style: TextStyle(
                    color: mainText,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _tap();

                      showDialog(
                        context: ctx,
                        builder: (_) => AlertDialog(
                          backgroundColor: surfaceCol,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          title: Text(
                            "Clear Cart?",
                            style: TextStyle(
                              color: mainText,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: Text(
                            "Remove all items?",
                            style: TextStyle(
                              color: isDark
                                  ? _textDark.withOpacity(0.75)
                                  : Colors.brown.shade400,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: Text(
                                "Cancel",
                                style: TextStyle(
                                  color: isDark
                                      ? _textDark.withOpacity(0.75)
                                      : Colors.brown.shade400,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Provider.of<CartProvider>(ctx, listen: false)
                                    .clearCart();
                                _tap();
                                Navigator.pop(ctx);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                foregroundColor: Colors.white,
                                shape: const StadiumBorder(),
                              ),
                              child: const Text("Clear All"),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.delete_sweep_outlined, size: 20),
                    label: const Text(
                      "Clear",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                      shape: const StadiumBorder(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () => _showCheckoutDialog(
                      total,
                      isDark,
                      bgColor,
                      surfaceCol,
                      mainText,
                      brownCol,
                      lightBrCol,
                    ),
                    icon: const Icon(Icons.shopping_cart_checkout_outlined),
                    label: const Text(
                      "Check out",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brownCol,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: const StadiumBorder(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, Color lc, Color vc) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: lc, fontSize: 15)),
        Text(
          value,
          style: TextStyle(
            color: vc,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyCart(
    BuildContext ctx,
    bool isDark,
    Color bgColor,
    Color surfaceCol,
    Color mainText,
    Color brownCol,
    Color lightBrCol,
    Color borderCol,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 18),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    _tap();
                    Navigator.pop(ctx);
                  },
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: surfaceCol.withOpacity(0.90),
                    child: Icon(Icons.arrow_back, color: mainText),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => _toggleDarkMode(ctx),
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: lightBrCol,
                    child: Icon(
                      isDark
                          ? Icons.light_mode_outlined
                          : Icons.dark_mode_outlined,
                      color: mainText,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.7, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutBack,
            builder: (_, val, child) => Transform.scale(
              scale: val,
              child: child,
            ),
            child: CircleAvatar(
              radius: 60,
              backgroundColor: lightBrCol,
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 58,
                color: mainText,
              ),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            "Your Cart is Empty",
            style: TextStyle(
              color: mainText,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              fontFamily: "serif",
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Browse instruments and add your favorite items to the cart.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark
                  ? _textDark.withOpacity(0.70)
                  : Colors.brown.shade400,
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _chip("🪕 Oud", surfaceCol, mainText, borderCol),
              const SizedBox(width: 8),
              _chip("🎸 Guitar", surfaceCol, mainText, borderCol),
              const SizedBox(width: 8),
              _chip("🎹 Piano", surfaceCol, mainText, borderCol),
            ],
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () {
                _tap();
                Navigator.pushReplacement(
                  ctx,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                );
              },
              icon: const Icon(Icons.storefront_outlined),
              label: const Text(
                "Browse Items",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: brownCol,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: const StadiumBorder(),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _chip(
    String label,
    Color surfaceCol,
    Color mainText,
    Color borderCol,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: surfaceCol.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderCol),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: mainText,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}