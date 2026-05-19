import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_assignment_e/providers/cart_provider.dart';
import 'package:project_assignment_e/providers/user_provider.dart';
import 'package:project_assignment_e/screens/home_page.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  // Light colours
  static const Color _bgLight = Color(0xfffbf6ef);
  static const Color _darkBrownBase = Color(0xff2b130c);
  static const Color _brownBase = Color(0xffb86f4b);
  static const Color _lightBrownBase = Color(0xffefe2d8);
  static const Color _olive = Color(0xff71805a);

  // Dark colours
  static const Color _bgDark = Color(0xff1a1008);
  static const Color _surfaceDark = Color(0xff2c1a0e);
  static const Color _textDark = Color(0xfffde8d4);
  static const Color _brownDark = Color(0xffcf8a65);

  late AnimationController _enterCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

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
      begin: const Offset(0, 0.05),
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
    super.dispose();
  }

  void _tap() => HapticFeedback.lightImpact();

  void _toggleDarkMode(BuildContext ctx) {
    Provider.of<ThemeProvider>(ctx, listen: false).toggle();
    _tap();
  }

  void _showEditDialog(
    UserProvider prov,
    bool isDark,
    Color surfaceCol,
    Color mainText,
    Color brownCol,
    Color lightBrCol,
    Color borderCol,
  ) {
    _tap();

    final nameCtrl = TextEditingController(text: prov.user.name);
    final emailCtrl = TextEditingController(text: prov.user.email);
    final phoneCtrl = TextEditingController(text: prov.user.phone);
    final locationCtrl = TextEditingController(text: prov.user.location);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: surfaceCol,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        title: Row(
          children: [
            Icon(Icons.edit_outlined, color: brownCol),
            const SizedBox(width: 10),
            Text(
              "Edit Profile",
              style: TextStyle(
                color: mainText,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _editField(
                nameCtrl,
                "Full Name",
                Icons.person_outline,
                isDark,
                mainText,
                brownCol,
                borderCol,
              ),
              const SizedBox(height: 12),
              _editField(
                emailCtrl,
                "Email",
                Icons.email_outlined,
                isDark,
                mainText,
                brownCol,
                borderCol,
              ),
              const SizedBox(height: 12),
              _editField(
                phoneCtrl,
                "Phone",
                Icons.phone_outlined,
                isDark,
                mainText,
                brownCol,
                borderCol,
                inputType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              _editField(
                locationCtrl,
                "Location",
                Icons.location_on_outlined,
                isDark,
                mainText,
                brownCol,
                borderCol,
              ),
            ],
          ),
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
              prov.updateName(nameCtrl.text);
              prov.updateEmail(emailCtrl.text);
              prov.updatePhone(phoneCtrl.text);
              prov.updateLocation(locationCtrl.text);

              HapticFeedback.mediumImpact();
              Navigator.pop(context);

              _showSnack("Profile updated successfully ✓", _olive);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: brownCol,
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
            ),
            child: const Text(
              "Save",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _editField(
    TextEditingController ctrl,
    String label,
    IconData icon,
    bool isDark,
    Color mainText,
    Color brownCol,
    Color borderCol, {
    TextInputType inputType = TextInputType.text,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: inputType,
      style: TextStyle(color: mainText),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDark ? _textDark.withOpacity(0.65) : Colors.brown.shade400,
          fontSize: 14,
        ),
        prefixIcon: Icon(icon, color: brownCol, size: 20),
        filled: true,
        fillColor: isDark ? const Color(0xff24150b) : Colors.white.withOpacity(0.85),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: borderCol),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: borderCol),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: brownCol, width: 1.5),
        ),
      ),
    );
  }

  void _showLanguageDialog(
    UserProvider prov,
    bool isDark,
    Color surfaceCol,
    Color mainText,
    Color brownCol,
    Color borderCol,
  ) {
    _tap();

    const langs = ["English", "العربية", "Français", "Español", "Türkçe"];

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: surfaceCol,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        title: Text(
          "Choose Language",
          style: TextStyle(
            color: mainText,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: langs.map((lang) {
            final sel = prov.user.language == lang;

            return GestureDetector(
              onTap: () {
                prov.updateLanguage(lang);
                _tap();
                Navigator.pop(context);
                _showSnack("Language set to $lang ✓", _olive);
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: sel ? brownCol : surfaceCol.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: sel ? brownCol : borderCol),
                ),
                child: Row(
                  children: [
                    Icon(
                      sel ? Icons.check_circle : Icons.circle_outlined,
                      color: sel
                          ? Colors.white
                          : isDark
                              ? _textDark.withOpacity(0.55)
                              : Colors.brown.shade300,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      lang,
                      style: TextStyle(
                        color: sel ? Colors.white : mainText,
                        fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showLogoutDialog(
    UserProvider prov,
    bool isDark,
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
          borderRadius: BorderRadius.circular(28),
        ),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: lightBrCol,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.logout, color: brownCol, size: 34),
            ),
            const SizedBox(height: 12),
            Text(
              "Log Out?",
              style: TextStyle(
                color: mainText,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
        content: Text(
          "Are you sure you want to log out?",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isDark ? _textDark.withOpacity(0.70) : Colors.brown.shade400,
            fontSize: 15,
          ),
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
              prov.logout();
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
                (_) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: brownCol,
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
            ),
            child: const Text(
              "Log Out",
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
    final borderCol =
        isDark ? Colors.white.withOpacity(0.08) : const Color(0xffeadcd1);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: Consumer<UserProvider>(
              builder: (ctx, prov, _) {
                final user = prov.user;
                final cartCount = Provider.of<CartProvider>(ctx).cartItems.length;

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 40),
                  child: Column(
                    children: [
                      _buildTopBar(
                        ctx,
                        prov,
                        isDark,
                        surfaceCol,
                        mainText,
                        brownCol,
                        lightBrCol,
                        borderCol,
                      ),
                      const SizedBox(height: 28),
                      _buildAvatar(
                        prov,
                        user,
                        brownCol,
                        lightBrCol,
                        mainText,
                        isDark,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.name,
                        style: TextStyle(
                          color: mainText,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          fontFamily: "serif",
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        user.email,
                        style: TextStyle(
                          color: isDark
                              ? _textDark.withOpacity(0.70)
                              : Colors.brown.shade400,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (user.location.isNotEmpty) ...[
                            _chip(
                              Icons.location_on_outlined,
                              user.location,
                              lightBrCol,
                              mainText,
                              brownCol,
                            ),
                            const SizedBox(width: 8),
                          ],
                          _chip(
                            Icons.language,
                            user.language,
                            lightBrCol,
                            mainText,
                            brownCol,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Member since ${user.memberSince}",
                        style: TextStyle(
                          color: isDark
                              ? _textDark.withOpacity(0.50)
                              : Colors.brown.shade300,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildStats(
                        user,
                        cartCount,
                        isDark,
                        surfaceCol,
                        mainText,
                        borderCol,
                      ),
                      const SizedBox(height: 24),
                      if (user.phone.isNotEmpty) ...[
                        _infoRow(
                          Icons.phone_outlined,
                          "Phone",
                          user.phone,
                          isDark,
                          surfaceCol,
                          mainText,
                          brownCol,
                          borderCol,
                        ),
                        const SizedBox(height: 10),
                      ],
                      _infoRow(
                        Icons.email_outlined,
                        "Email",
                        user.email,
                        isDark,
                        surfaceCol,
                        mainText,
                        brownCol,
                        borderCol,
                      ),
                      const SizedBox(height: 24),
                      _menuItem(
                        Icons.shopping_bag_outlined,
                        "My Orders",
                        "${user.orders} orders placed",
                        brownCol,
                        isDark,
                        surfaceCol,
                        mainText,
                        borderCol,
                        () => _tap(),
                      ),
                      _menuItem(
                        Icons.favorite_border,
                        "Favorites",
                        "${user.favorites} saved items",
                        Colors.redAccent,
                        isDark,
                        surfaceCol,
                        mainText,
                        borderCol,
                        () => _tap(),
                      ),
                      _menuItem(
                        Icons.music_note_outlined,
                        "Recently Played",
                        "View your music history",
                        _olive,
                        isDark,
                        surfaceCol,
                        mainText,
                        borderCol,
                        () => _tap(),
                      ),
                      _menuItem(
                        Icons.language,
                        "Language",
                        user.language,
                        Colors.blue.shade600,
                        isDark,
                        surfaceCol,
                        mainText,
                        borderCol,
                        () => _showLanguageDialog(
                          prov,
                          isDark,
                          surfaceCol,
                          mainText,
                          brownCol,
                          borderCol,
                        ),
                      ),
                      _menuItem(
                        Icons.notifications_none,
                        "Notifications",
                        "Manage your alerts",
                        Colors.purple,
                        isDark,
                        surfaceCol,
                        mainText,
                        borderCol,
                        () => _tap(),
                      ),
                      _menuItem(
                        Icons.help_outline,
                        "Help Center",
                        "FAQs and support",
                        Colors.blueGrey,
                        isDark,
                        surfaceCol,
                        mainText,
                        borderCol,
                        () => _tap(),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: () => _showLogoutDialog(
                            prov,
                            isDark,
                            surfaceCol,
                            mainText,
                            brownCol,
                            lightBrCol,
                          ),
                          icon: const Icon(Icons.logout),
                          label: const Text(
                            "Log Out",
                            style: TextStyle(
                              fontSize: 19,
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
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(
    BuildContext ctx,
    UserProvider prov,
    bool isDark,
    Color surfaceCol,
    Color mainText,
    Color brownCol,
    Color lightBrCol,
    Color borderCol,
  ) {
    return Row(
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
        Text(
          "My Profile",
          style: TextStyle(
            color: mainText,
            fontSize: 26,
            fontWeight: FontWeight.bold,
            fontFamily: "serif",
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () => _toggleDarkMode(ctx),
          child: CircleAvatar(
            radius: 24,
            backgroundColor: lightBrCol,
            child: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              color: mainText,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () => _showEditDialog(
            prov,
            isDark,
            surfaceCol,
            mainText,
            brownCol,
            lightBrCol,
            borderCol,
          ),
          child: CircleAvatar(
            radius: 24,
            backgroundColor: surfaceCol.withOpacity(0.90),
            child: Icon(Icons.edit_outlined, color: mainText, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar(
    UserProvider prov,
    UserModel user,
    Color brownCol,
    Color lightBrCol,
    Color mainText,
    bool isDark,
  ) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      builder: (_, val, child) => Transform.scale(scale: val, child: child),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: brownCol, width: 2.5),
            ),
            child: user.avatarUrl.isNotEmpty
                ? CircleAvatar(
                    radius: 58,
                    backgroundImage: NetworkImage(user.avatarUrl),
                  )
                : CircleAvatar(
                    radius: 58,
                    backgroundColor: lightBrCol,
                    child: Text(
                      prov.initials,
                      style: TextStyle(
                        color: brownCol,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        fontFamily: "serif",
                      ),
                    ),
                  ),
          ),
          Positioned(
            bottom: 4,
            right: 4,
            child: GestureDetector(
              onTap: () {
                final isDark = Provider.of<ThemeProvider>(
                  context,
                  listen: false,
                ).isDark;

                final surfaceCol = isDark ? _surfaceDark : Colors.white;
                final mainText = isDark ? _textDark : _darkBrownBase;
                final brownCol = isDark ? _brownDark : _brownBase;
                final lightBrCol =
                    isDark ? const Color(0xff3a2010) : _lightBrownBase;
                final borderCol = isDark
                    ? Colors.white.withOpacity(0.08)
                    : const Color(0xffeadcd1);

                _showEditDialog(
                  prov,
                  isDark,
                  surfaceCol,
                  mainText,
                  brownCol,
                  lightBrCol,
                  borderCol,
                );
              },
              child: const CircleAvatar(
                radius: 18,
                backgroundColor: _olive,
                child: Icon(Icons.edit, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(
    UserModel user,
    int cartCount,
    bool isDark,
    Color surfaceCol,
    Color mainText,
    Color borderCol,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      decoration: BoxDecoration(
        color: surfaceCol.withOpacity(0.85),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: borderCol),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(isDark ? 0.18 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem(
            user.orders.toString(),
            "Orders",
            isDark,
            mainText,
          ),
          _divider(borderCol),
          _statItem(
            user.favorites.toString(),
            "Favorites",
            isDark,
            mainText,
          ),
          _divider(borderCol),
          _statItem(
            user.rating.toStringAsFixed(1),
            "Rating",
            isDark,
            mainText,
          ),
          _divider(borderCol),
          _statItem(
            cartCount.toString(),
            "In Cart",
            isDark,
            mainText,
          ),
        ],
      ),
    );
  }

  Widget _statItem(
    String value,
    String label,
    bool isDark,
    Color mainText,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: mainText,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isDark ? _textDark.withOpacity(0.65) : Colors.brown.shade400,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _divider(Color borderCol) {
    return Container(
      height: 40,
      width: 1,
      color: borderCol,
    );
  }

  Widget _infoRow(
    IconData icon,
    String label,
    String value,
    bool isDark,
    Color surfaceCol,
    Color mainText,
    Color brownCol,
    Color borderCol,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: surfaceCol.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderCol),
      ),
      child: Row(
        children: [
          Icon(icon, color: brownCol, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isDark
                      ? _textDark.withOpacity(0.55)
                      : Colors.brown.shade300,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: mainText,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _menuItem(
    IconData icon,
    String title,
    String subtitle,
    Color color,
    bool isDark,
    Color surfaceCol,
    Color mainText,
    Color borderCol,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: surfaceCol.withOpacity(0.85),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderCol),
      ),
      child: ListTile(
        onTap: () {
          _tap();
          onTap();
        },
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.13),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: mainText,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: isDark ? _textDark.withOpacity(0.65) : Colors.brown.shade400,
            fontSize: 12,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: isDark ? _textDark.withOpacity(0.70) : _brownBase,
        ),
      ),
    );
  }

  Widget _chip(
    IconData icon,
    String label,
    Color lightBrCol,
    Color mainText,
    Color brownCol,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: lightBrCol,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: brownCol),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: mainText,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}