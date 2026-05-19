import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({Key? key}) : super(key: key);

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen>
    with SingleTickerProviderStateMixin {
  // ── Colours ───────────────────────────────
  static const Color _bg         = Color(0xfffbf6ef);
  static const Color _darkBrown  = Color(0xff2b130c);
  static const Color _brown      = Color(0xffb86f4b);
  static const Color _lightBrown = Color(0xffefe2d8);
  static const Color _olive      = Color(0xff71805a);

  late AnimationController _enterCtrl;
  late Animation<double>   _fadeAnim;
  late Animation<Offset>   _slideAnim;

  // ── Selected service state ────────────────
  String? _selectedService;

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 700),
    )..forward();
    _fadeAnim  = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeIn);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() { _enterCtrl.dispose(); super.dispose(); }

  void _tap()     => HapticFeedback.lightImpact();
  void _success() => HapticFeedback.mediumImpact();

  // ── Booking Dialog ────────────────────────
  void _showBookingDialog(String serviceTitle) {
    _tap();
    final nameCtrl  = TextEditingController();
    final phoneCtrl = TextEditingController();
    final noteCtrl  = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        title: Column(children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(color: _lightBrown, shape: BoxShape.circle),
            child: const Icon(Icons.calendar_month_outlined, color: _brown, size: 34),
          ),
          const SizedBox(height: 12),
          Text("Book: $serviceTitle",
              style: const TextStyle(color: _darkBrown, fontWeight: FontWeight.bold, fontSize: 18),
              textAlign: TextAlign.center),
        ]),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            _field(nameCtrl,  "Full Name",    Icons.person_outline),
            const SizedBox(height: 12),
            _field(phoneCtrl, "Phone Number", Icons.phone_outlined, inputType: TextInputType.phone),
            const SizedBox(height: 12),
            _field(noteCtrl,  "Notes (optional)", Icons.notes_outlined, maxLines: 3),
          ]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: Colors.brown.shade400)),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty || phoneCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(_snackBar(
                  "Please fill in your name and phone.", Colors.redAccent));
                return;
              }
              Navigator.pop(context);
              _success(); // ✅ صوت نجاح عند إرسال طلب الصيانة
              _showSuccessDialog(serviceTitle);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _brown, foregroundColor: Colors.white,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
            ),
            child: const Text("Send Request", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ── Success Dialog ────────────────────────
  void _showSuccessDialog(String serviceTitle) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        title: Column(children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.5, end: 1.0),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutBack,
            builder: (_, val, child) => Transform.scale(scale: val, child: child),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(color: _olive, shape: BoxShape.circle),
              child: const Icon(Icons.check, color: Colors.white, size: 40),
            ),
          ),
          const SizedBox(height: 14),
          const Text("Request Sent!",
              style: TextStyle(color: _darkBrown, fontWeight: FontWeight.bold, fontSize: 22),
              textAlign: TextAlign.center),
        ]),
        content: Text(
          "Your \"$serviceTitle\" request has been sent successfully.\nWe'll contact you shortly.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.brown.shade400, fontSize: 15, height: 1.5),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: _olive, foregroundColor: Colors.white,
                shape: const StadiumBorder(),
              ),
              child: const Text("Done", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Text Field helper ─────────────────────
  Widget _field(TextEditingController ctrl, String label, IconData icon,
      {TextInputType inputType = TextInputType.text, int maxLines = 1}) {
    return TextField(
      controller: ctrl, keyboardType: inputType, maxLines: maxLines,
      style: const TextStyle(color: _darkBrown),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.brown.shade400, fontSize: 14),
        prefixIcon: maxLines == 1 ? Icon(icon, color: _brown, size: 20) : null,
        filled: true, fillColor: Colors.white.withOpacity(0.85),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border:        OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: Color(0xffeadcd1))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: Color(0xffeadcd1))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: _brown, width: 1.5)),
      ),
    );
  }

  SnackBar _snackBar(String msg, Color color) => SnackBar(
    backgroundColor: color, behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
    content: Text(msg, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
  );

  // ── Build ─────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopBar(),
                  const SizedBox(height: 26),
                  const Text("Services",
                      style: TextStyle(color: _darkBrown, fontSize: 36,
                          fontWeight: FontWeight.bold, fontFamily: "serif")),
                  const SizedBox(height: 8),
                  Text("Professional care for your musical instruments.",
                      style: TextStyle(color: Colors.brown.shade400, fontSize: 16)),
                  const SizedBox(height: 26),
                  _buildMainCard(),
                  const SizedBox(height: 26),
                  const Text("Choose a Service",
                      style: TextStyle(color: _darkBrown, fontSize: 24,
                          fontWeight: FontWeight.bold, fontFamily: "serif")),
                  const SizedBox(height: 16),
                  _buildServiceItem(
                    icon: Icons.build_outlined,
                    title: "Instrument Repair",
                    subtitle: "Fix strings, keys, body damage and sound issues.",
                    price: "From \$25",
                    index: 0,
                  ),
                  _buildServiceItem(
                    icon: Icons.tune,
                    title: "Tuning Service",
                    subtitle: "Professional tuning for guitar, oud and piano.",
                    price: "From \$15",
                    index: 1,
                  ),
                  _buildServiceItem(
                    icon: Icons.cleaning_services_outlined,
                    title: "Cleaning & Polish",
                    subtitle: "Deep cleaning to keep your instrument fresh.",
                    price: "From \$10",
                    index: 2,
                  ),
                  _buildServiceItem(
                    icon: Icons.school_outlined,
                    title: "Music Lessons",
                    subtitle: "Learn guitar, piano, oud or drums with experts.",
                    price: "From \$30",
                    index: 3,
                  ),
                  const SizedBox(height: 20),
                  _buildBookingCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Top Bar ───────────────────────────────
  Widget _buildTopBar() {
    return Row(children: [
      GestureDetector(
        onTap: () { _tap(); Navigator.pop(context); },
        child: CircleAvatar(
          radius: 24,
          backgroundColor: Colors.white.withOpacity(0.85),
          child: const Icon(Icons.arrow_back, color: _darkBrown),
        ),
      ),
      const Spacer(),
      CircleAvatar(
        radius: 24,
        backgroundColor: _lightBrown,
        child: const Icon(Icons.notifications_none, color: _darkBrown),
      ),
    ]);
  }

  // ── Main Promo Card ───────────────────────
  Widget _buildMainCard() {
    return Container(
      height: 180,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(colors: [Color(0xfffffbf5), Color(0xfff0d7c4)]),
        border: Border.all(color: const Color(0xffeadcd1)),
      ),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(color: _lightBrown, borderRadius: BorderRadius.circular(20)),
              child: const Text("SPECIAL SERVICE",
                  style: TextStyle(color: _brown, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 18),
            const Text("Tune your sound\nwith experts",
                style: TextStyle(color: _darkBrown, fontSize: 25, fontWeight: FontWeight.bold, height: 1.1)),
            const SizedBox(height: 8),
            Text("Fast booking and premium care.",
                style: TextStyle(color: Colors.brown.shade400, fontSize: 14)),
          ]),
        ),
        CircleAvatar(
          radius: 48,
          backgroundColor: Colors.white.withOpacity(0.65),
          child: const Icon(Icons.handyman_outlined, color: _brown, size: 50),
        ),
      ]),
    );
  }

  // ── Service Item ──────────────────────────
  Widget _buildServiceItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String price,
    required int index,
  }) {
    final isSelected = _selectedService == title;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.92, end: 1.0),
      duration: Duration(milliseconds: 400 + index * 80),
      curve: Curves.easeOutBack,
      builder: (_, val, child) => Transform.scale(scale: val, child: child),
      child: GestureDetector(
        onTap: () {
          _tap();
          setState(() => _selectedService = isSelected ? null : title);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? _brown.withOpacity(0.08) : Colors.white.withOpacity(0.88),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: isSelected ? _brown : const Color(0xffeadcd1),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(children: [
            Container(
              width: 58, height: 58,
              decoration: BoxDecoration(
                color: isSelected ? _brown : _lightBrown,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, color: isSelected ? Colors.white : _brown, size: 30),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: _darkBrown, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.brown.shade400, fontSize: 13, height: 1.3)),
            ])),
            const SizedBox(width: 8),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(price, style: const TextStyle(color: _olive, fontSize: 14, fontWeight: FontWeight.bold)),
              if (isSelected) ...[
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () => _showBookingDialog(title),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: _brown, borderRadius: BorderRadius.circular(12)),
                    child: const Text("Book", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ]),
          ]),
        ),
      ),
    );
  }

  // ── Booking CTA Card ──────────────────────
  Widget _buildBookingCard() {
    return GestureDetector(
      onTap: () => _showBookingDialog("General Service"),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: _darkBrown, borderRadius: BorderRadius.circular(28)),
        child: Row(children: [
          const Icon(Icons.calendar_month_outlined, color: Colors.white, size: 38),
          const SizedBox(width: 14),
          const Expanded(
            child: Text("Book a service appointment now",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          CircleAvatar(
            backgroundColor: _brown,
            child: const Icon(Icons.arrow_forward, color: Colors.white),
          ),
        ]),
      ),
    );
  }
}