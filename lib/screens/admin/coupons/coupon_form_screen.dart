import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_assignment_e/l10n/app_localizations.dart';
import 'package:project_assignment_e/models/coupon.dart';
import 'package:project_assignment_e/providers/notifications_provider.dart';
import 'package:project_assignment_e/services/coupon_service.dart';
import 'package:project_assignment_e/utils/app_colors.dart';
import 'package:provider/provider.dart';

class CouponFormScreen extends StatefulWidget {
  final Coupon? coupon; // null = create mode
  const CouponFormScreen({super.key, this.coupon});

  @override
  State<CouponFormScreen> createState() => _CouponFormScreenState();
}

class _CouponFormScreenState extends State<CouponFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool  _saving  = false;

  // Controllers
  late final TextEditingController _codeCtrl;
  late final TextEditingController _titleEnCtrl;
  late final TextEditingController _titleArCtrl;
  late final TextEditingController _descEnCtrl;
  late final TextEditingController _descArCtrl;
  late final TextEditingController _valueCtrl;
  late final TextEditingController _minOrderCtrl;
  late final TextEditingController _maxDiscountCtrl;
  late final TextEditingController _usageLimitCtrl;

  String   _discountType = 'percentage'; // 'percentage' | 'fixed'
  bool     _isActive     = true;
  DateTime _validFrom    = DateTime.now();
  DateTime _validUntil   = DateTime.now().add(const Duration(days: 30));

  bool get _isEdit => widget.coupon != null;

  @override
  void initState() {
    super.initState();
    final c = widget.coupon;
    _codeCtrl        = TextEditingController(text: c?.code ?? '');
    _titleEnCtrl     = TextEditingController(text: c?.titleEn ?? '');
    _titleArCtrl     = TextEditingController(text: c?.titleAr ?? '');
    _descEnCtrl      = TextEditingController(text: c?.descriptionEn ?? '');
    _descArCtrl      = TextEditingController(text: c?.descriptionAr ?? '');
    _valueCtrl       = TextEditingController(
        text: c != null ? c.discountValue.toString() : '');
    _minOrderCtrl    = TextEditingController(
        text: c != null ? c.minOrderAmount.toString() : '0');
    _maxDiscountCtrl = TextEditingController(
        text: c?.maxDiscountAmount?.toString() ?? '');
    _usageLimitCtrl  = TextEditingController(
        text: c?.usageLimit?.toString() ?? '');

    if (c != null) {
      _discountType = c.discountType;
      _isActive     = c.isActive;
      _validFrom    = c.validFrom;
      _validUntil   = c.validUntil;
    }
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _titleEnCtrl.dispose();
    _titleArCtrl.dispose();
    _descEnCtrl.dispose();
    _descArCtrl.dispose();
    _valueCtrl.dispose();
    _minOrderCtrl.dispose();
    _maxDiscountCtrl.dispose();
    _usageLimitCtrl.dispose();
    super.dispose();
  }

  // ── Date pickers ───────────────────────────────────────────────────────────

  Future<void> _pickDate({required bool isFrom}) async {
    final initial = isFrom ? _validFrom : _validUntil;
    final first   = isFrom ? DateTime(2020) : _validFrom;
    final last    = DateTime(2100);

    final picked = await showDatePicker(
      context:     context,
      initialDate: initial,
      firstDate:   first,
      lastDate:    last,
    );
    if (picked == null) return;
    setState(() {
      if (isFrom) {
        _validFrom = picked;
        if (_validUntil.isBefore(_validFrom)) {
          _validUntil = _validFrom.add(const Duration(days: 1));
        }
      } else {
        _validUntil = picked;
      }
    });
  }

  // ── Save ───────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_validUntil.isBefore(_validFrom) ||
        _validUntil.isAtSameMomentAs(_validFrom)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context).t('couponEndBeforeStart')),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      return;
    }

    setState(() => _saving = true);
    final l = AppLocalizations.of(context);
    try {
      final service = CouponService();
      final now     = DateTime.now();
      final coupon  = Coupon(
        id:                widget.coupon?.id ?? '',
        code:              _codeCtrl.text.trim().toUpperCase(),
        titleEn:           _titleEnCtrl.text.trim(),
        titleAr:           _titleArCtrl.text.trim(),
        descriptionEn:     _descEnCtrl.text.trim(),
        descriptionAr:     _descArCtrl.text.trim(),
        discountType:      _discountType,
        discountValue:     double.tryParse(_valueCtrl.text) ?? 0,
        minOrderAmount:    double.tryParse(_minOrderCtrl.text) ?? 0,
        maxDiscountAmount: _maxDiscountCtrl.text.trim().isEmpty
            ? null
            : double.tryParse(_maxDiscountCtrl.text),
        validFrom:         _validFrom,
        validUntil:        _validUntil,
        isActive:          _isActive,
        usageLimit:        _usageLimitCtrl.text.trim().isEmpty
            ? null
            : int.tryParse(_usageLimitCtrl.text),
        usedCount:         widget.coupon?.usedCount ?? 0,
        createdAt:         widget.coupon?.createdAt ?? now,
        updatedAt:         now,
      );

      if (_isEdit) {
        await service.updateCoupon(coupon);
      } else {
        await service.addCoupon(coupon);
      }

      if (!mounted) return;
      HapticFeedback.mediumImpact();

      // Create notification only when adding a new coupon (not editing).
      if (!_isEdit) {
        context.read<NotificationsProvider>().addNotification(
          NotificationModel(
            id:      'coupon_${DateTime.now().millisecondsSinceEpoch}',
            titleEn: '${l.t('notifNewCoupon')}: ${_codeCtrl.text.trim()}',
            titleAr: '${l.t('notifNewCouponAr')}: ${_codeCtrl.text.trim()}',
            bodyEn:  '${_titleEnCtrl.text.trim()} — ${l.t('notifNewCouponBody')}',
            bodyAr:  '${_titleArCtrl.text.trim()} — ${l.t('notifNewCouponBodyAr')}',
            icon:    Icons.local_offer_rounded,
            color:   const Color(0xFF3D7A6A),
            time:    DateTime.now(),
          ),
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: [
          const Icon(Icons.check_circle_rounded,
              color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(l.t('couponSaved')),
        ]),
        backgroundColor: const Color(0xFF3D7A6A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l.t('couponSaveFailed')),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? l.t('editCoupon') : l.t('addCoupon')),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [
            // ── Coupon Code ──────────────────────────────────────────────────
            _buildSection(
              icon:  Icons.local_offer_rounded,
              title: l.t('couponCode'),
              children: [
                _field(
                  ctrl:       _codeCtrl,
                  label:      l.t('couponCode'),
                  hint:       'SUMMER20',
                  icon:       Icons.local_offer_outlined,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_-]')),
                    UpperCaseFormatter(),
                  ],
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return l.t('couponCodeRequired');
                    }
                    return null;
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Title & Description ──────────────────────────────────────────
            _buildSection(
              icon:  Icons.title_rounded,
              title: l.t('couponDetails'),
              children: [
                _field(
                  ctrl:  _titleEnCtrl,
                  label: l.t('couponTitleEn'),
                  hint:  'Summer Sale',
                  icon:  Icons.title_rounded,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? l.t('fieldRequired')
                      : null,
                ),
                const SizedBox(height: 12),
                _field(
                  ctrl:  _titleArCtrl,
                  label: l.t('couponTitleAr'),
                  hint:  'تخفيضات الصيف',
                  icon:  Icons.title_rounded,
                  textDirection: TextDirection.rtl,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? l.t('fieldRequired')
                      : null,
                ),
                const SizedBox(height: 12),
                _field(
                  ctrl:      _descEnCtrl,
                  label:     l.t('couponDescEn'),
                  hint:      'Get 20% off on all guitars',
                  icon:      Icons.description_outlined,
                  maxLines:  2,
                ),
                const SizedBox(height: 12),
                _field(
                  ctrl:          _descArCtrl,
                  label:         l.t('couponDescAr'),
                  hint:          'احصل على خصم 20٪ على جميع الجيتارات',
                  icon:          Icons.description_outlined,
                  maxLines:      2,
                  textDirection: TextDirection.rtl,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Discount ─────────────────────────────────────────────────────
            _buildSection(
              icon:  Icons.discount_outlined,
              title: l.t('couponDiscount'),
              children: [
                // Type selector
                Row(
                  children: [
                    Expanded(
                      child: _TypeButton(
                        label:    l.t('couponPercentage'),
                        icon:     Icons.percent_rounded,
                        selected: _discountType == 'percentage',
                        onTap:    () => setState(
                            () => _discountType = 'percentage'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _TypeButton(
                        label:    l.t('couponFixed'),
                        icon:     Icons.attach_money_rounded,
                        selected: _discountType == 'fixed',
                        onTap:    () =>
                            setState(() => _discountType = 'fixed'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _field(
                  ctrl:          _valueCtrl,
                  label:         _discountType == 'percentage'
                      ? l.t('couponPercentageValue')
                      : l.t('couponFixedValue'),
                  hint:          _discountType == 'percentage' ? '20' : '5.00',
                  icon:          _discountType == 'percentage'
                      ? Icons.percent_rounded
                      : Icons.attach_money_rounded,
                  keyboardType:  TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d*'))
                  ],
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return l.t('fieldRequired');
                    }
                    final n = double.tryParse(v);
                    if (n == null || n <= 0) return l.t('couponValuePositive');
                    if (_discountType == 'percentage' &&
                        (n < 1 || n > 100)) {
                      return l.t('couponPercentageRange');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _field(
                  ctrl:         _minOrderCtrl,
                  label:        l.t('couponMinOrder'),
                  hint:         '0.00',
                  icon:         Icons.shopping_bag_outlined,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d*'))
                  ],
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return null;
                    final n = double.tryParse(v);
                    if (n == null || n < 0) return l.t('couponAmountNonNeg');
                    return null;
                  },
                ),
                if (_discountType == 'percentage') ...[
                  const SizedBox(height: 12),
                  _field(
                    ctrl:         _maxDiscountCtrl,
                    label:        l.t('couponMaxDiscount'),
                    hint:         l.t('couponOptional'),
                    icon:         Icons.money_off_rounded,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d*'))
                    ],
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return null;
                      final n = double.tryParse(v);
                      if (n == null || n < 0) return l.t('couponAmountNonNeg');
                      return null;
                    },
                  ),
                ],
              ],
            ),

            const SizedBox(height: 16),

            // ── Validity ─────────────────────────────────────────────────────
            _buildSection(
              icon:  Icons.calendar_month_outlined,
              title: l.t('couponValidity'),
              children: [
                _DateRow(
                  label:   l.t('couponValidFrom'),
                  date:    _validFrom,
                  onTap:   () => _pickDate(isFrom: true),
                ),
                const SizedBox(height: 12),
                _DateRow(
                  label:   l.t('couponValidUntil'),
                  date:    _validUntil,
                  onTap:   () => _pickDate(isFrom: false),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Usage & Status ────────────────────────────────────────────────
            _buildSection(
              icon:  Icons.settings_outlined,
              title: l.t('couponSettings'),
              children: [
                _field(
                  ctrl:         _usageLimitCtrl,
                  label:        l.t('couponUsageLimit'),
                  hint:         l.t('couponUnlimited'),
                  icon:         Icons.people_outline_rounded,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly
                  ],
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: Icon(
                    _isActive
                        ? Icons.toggle_on_rounded
                        : Icons.toggle_off_outlined,
                    color: _isActive ? AppColors.primary : Colors.grey,
                  ),
                  title:    Text(l.t('couponActive')),
                  subtitle: Text(_isActive
                      ? l.t('couponActiveHint')
                      : l.t('couponInactiveHint')),
                  value:    _isActive,
                  onChanged: (v) => setState(() => _isActive = v),
                  activeThumbColor: AppColors.primary,
                ),
              ],
            ),

            const SizedBox(height: 28),

            // ── Save button ───────────────────────────────────────────────────
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.check_rounded),
                label: Text(
                  l.t('saveCoupon'),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helper builders ────────────────────────────────────────────────────────

  Widget _buildSection({
    required IconData icon,
    required String   title,
    required List<Widget> children,
  }) {
    return Card(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ]),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController ctrl,
    required String label,
    String?  hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    String? Function(String?)? validator,
    TextDirection? textDirection,
  }) =>
      TextFormField(
        controller:          ctrl,
        keyboardType:        keyboardType,
        inputFormatters:     inputFormatters,
        maxLines:            maxLines,
        validator:           validator,
        textDirection:       textDirection,
        decoration: InputDecoration(
          labelText:    label,
          hintText:     hint,
          prefixIcon:   Icon(icon, size: 20),
          border:       OutlineInputBorder(
              borderRadius: BorderRadius.circular(12)),
          filled:       true,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 12),
        ),
      );
}

// ── Type selector button ──────────────────────────────────────────────────────
class _TypeButton extends StatelessWidget {
  final String   label;
  final IconData icon;
  final bool     selected;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color:        selected
                ? AppColors.primary.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : Colors.grey.withValues(alpha: 0.35),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 16,
                  color: selected ? AppColors.primary : Colors.grey),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize:   13,
                  fontWeight: FontWeight.w600,
                  color:      selected ? AppColors.primary : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
}

// ── Date row ──────────────────────────────────────────────────────────────────
class _DateRow extends StatelessWidget {
  final String   label;
  final DateTime date;
  final VoidCallback onTap;

  const _DateRow({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = '${date.day.toString().padLeft(2, '0')} / '
        '${date.month.toString().padLeft(2, '0')} / ${date.year}';
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
              color: Colors.grey.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_month_outlined,
                size: 20, color: AppColors.primary),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color:    Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.55),
                  ),
                ),
                Text(
                  fmt,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ],
            ),
            const Spacer(),
            Icon(Icons.edit_calendar_outlined,
                size: 18,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.45)),
          ],
        ),
      ),
    );
  }
}

// ── Input formatter: uppercase ────────────────────────────────────────────────
class UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
