import 'package:flutter/material.dart';
import 'package:project_assignment_e/l10n/app_localizations.dart';
import 'package:project_assignment_e/models/firestore_product.dart';
import 'package:project_assignment_e/providers/notifications_provider.dart';
import 'package:project_assignment_e/services/firestore_service.dart';
import 'package:provider/provider.dart';

/// Add or edit a Firestore product.
/// Pass [product] to edit; leave null to add a new one.
class ProductFormScreen extends StatefulWidget {
  final FirestoreProduct? product;
  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Core fields
  final _nameEnCtrl     = TextEditingController();
  final _nameArCtrl     = TextEditingController();
  final _descEnCtrl     = TextEditingController();
  final _descArCtrl     = TextEditingController();
  final _priceCtrl      = TextEditingController();
  final _qtyCtrl        = TextEditingController();
  final _imageUrlCtrl   = TextEditingController();
  final _imageAssetCtrl = TextEditingController();
  final _imagesCtrl     = TextEditingController(); // multi-line: one URL per line

  // Extended fields
  final _brandEnCtrl    = TextEditingController();
  final _brandArCtrl    = TextEditingController();
  final _colorEnCtrl    = TextEditingController();
  final _colorArCtrl    = TextEditingController();
  final _weightCtrl     = TextEditingController();
  final _dimsCtrl       = TextEditingController();
  final _matEnCtrl      = TextEditingController();
  final _matArCtrl      = TextEditingController();
  final _warrantyEnCtrl = TextEditingController();
  final _warrantyArCtrl = TextEditingController();
  final _modelNoCtrl    = TextEditingController();
  final _originEnCtrl   = TextEditingController();
  final _originArCtrl   = TextEditingController();
  final _condEnCtrl     = TextEditingController();
  final _condArCtrl     = TextEditingController();
  final _specsEnCtrl    = TextEditingController();
  final _specsArCtrl    = TextEditingController();
  final _featEnCtrl     = TextEditingController();
  final _featArCtrl     = TextEditingController();

  String _selectedCategory = 'guitar';
  bool   _isAvailable      = true;
  bool   _isSaving         = false;

  static const _categories = ['guitar', 'piano', 'drums', 'oud', 'studio'];

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    if (p != null) {
      _nameEnCtrl.text     = p.nameEn;
      _nameArCtrl.text     = p.nameAr;
      _descEnCtrl.text     = p.descriptionEn;
      _descArCtrl.text     = p.descriptionAr;
      _priceCtrl.text      = p.price.toString();
      _qtyCtrl.text        = p.quantity.toString();
      _imageUrlCtrl.text   = p.imageUrl;
      _imageAssetCtrl.text = p.imageAsset;
      _imagesCtrl.text     = p.images.join('\n');
      _selectedCategory    = p.category;
      _isAvailable         = p.isAvailable;
      _brandEnCtrl.text    = p.brandEn;
      _brandArCtrl.text    = p.brandAr;
      _colorEnCtrl.text    = p.colorEn;
      _colorArCtrl.text    = p.colorAr;
      _weightCtrl.text     = p.weight;
      _dimsCtrl.text       = p.dimensions;
      _matEnCtrl.text      = p.materialEn;
      _matArCtrl.text      = p.materialAr;
      _warrantyEnCtrl.text = p.warrantyEn;
      _warrantyArCtrl.text = p.warrantyAr;
      _modelNoCtrl.text    = p.modelNumber;
      _originEnCtrl.text   = p.originCountryEn;
      _originArCtrl.text   = p.originCountryAr;
      _condEnCtrl.text     = p.conditionEn;
      _condArCtrl.text     = p.conditionAr;
      _specsEnCtrl.text    = p.specificationsEn;
      _specsArCtrl.text    = p.specificationsAr;
      _featEnCtrl.text     = p.featuresEn;
      _featArCtrl.text     = p.featuresAr;
    }
  }

  @override
  void dispose() {
    for (final c in [
      _nameEnCtrl, _nameArCtrl, _descEnCtrl, _descArCtrl,
      _priceCtrl, _qtyCtrl, _imageUrlCtrl, _imageAssetCtrl, _imagesCtrl,
      _brandEnCtrl, _brandArCtrl, _colorEnCtrl, _colorArCtrl,
      _weightCtrl, _dimsCtrl, _matEnCtrl, _matArCtrl,
      _warrantyEnCtrl, _warrantyArCtrl, _modelNoCtrl,
      _originEnCtrl, _originArCtrl, _condEnCtrl, _condArCtrl,
      _specsEnCtrl, _specsArCtrl, _featEnCtrl, _featArCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  List<String> _parseImages() => _imagesCtrl.text
      .split('\n')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final l       = AppLocalizations.of(context);
    final service = FirestoreService();
    final now     = DateTime.now();

    final product = FirestoreProduct(
      id:              widget.product?.id ?? '',
      nameEn:          _nameEnCtrl.text.trim(),
      nameAr:          _nameArCtrl.text.trim(),
      descriptionEn:   _descEnCtrl.text.trim(),
      descriptionAr:   _descArCtrl.text.trim(),
      price:           double.tryParse(_priceCtrl.text.trim()) ?? 0.0,
      quantity:        int.tryParse(_qtyCtrl.text.trim()) ?? 0,
      imageUrl:        _imageUrlCtrl.text.trim(),
      imageAsset:      _imageAssetCtrl.text.trim(),
      images:          _parseImages(),
      category:        _selectedCategory,
      isAvailable:     _isAvailable,
      brandEn:         _brandEnCtrl.text.trim(),
      brandAr:         _brandArCtrl.text.trim(),
      colorEn:         _colorEnCtrl.text.trim(),
      colorAr:         _colorArCtrl.text.trim(),
      weight:          _weightCtrl.text.trim(),
      dimensions:      _dimsCtrl.text.trim(),
      materialEn:      _matEnCtrl.text.trim(),
      materialAr:      _matArCtrl.text.trim(),
      warrantyEn:      _warrantyEnCtrl.text.trim(),
      warrantyAr:      _warrantyArCtrl.text.trim(),
      modelNumber:     _modelNoCtrl.text.trim(),
      originCountryEn: _originEnCtrl.text.trim(),
      originCountryAr: _originArCtrl.text.trim(),
      conditionEn:     _condEnCtrl.text.trim(),
      conditionAr:     _condArCtrl.text.trim(),
      specificationsEn: _specsEnCtrl.text.trim(),
      specificationsAr: _specsArCtrl.text.trim(),
      featuresEn:      _featEnCtrl.text.trim(),
      featuresAr:      _featArCtrl.text.trim(),
      createdAt:       widget.product?.createdAt ?? now,
      updatedAt:       now,
    );

    try {
      if (widget.product == null) {
        await service.addProduct(product);
      } else {
        await service.updateProduct(product);
      }
      if (mounted) {
        // Create notification only when adding a new product (not editing).
        if (widget.product == null) {
          context.read<NotificationsProvider>().addNotification(
            NotificationModel(
              id:      'product_${DateTime.now().millisecondsSinceEpoch}',
              titleEn: '${l.t('notifNewProduct')}: ${_nameEnCtrl.text.trim()}',
              titleAr: '${l.t('notifNewProductAr')}: ${_nameArCtrl.text.trim()}',
              bodyEn:  l.t('notifNewProductBody'),
              bodyAr:  l.t('notifNewProductBodyAr'),
              icon:    Icons.music_note_rounded,
              color:   const Color(0xFF912F56),
              time:    DateTime.now(),
            ),
          );
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.t('productSaved')),
              backgroundColor: Colors.green.shade700),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()),
              backgroundColor: Colors.red.shade700),
        );
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l      = AppLocalizations.of(context);
    final isEdit = widget.product != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? l.t('editProduct') : l.t('addProduct')),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                // ── Names ──────────────────────────────────────────────────
                _section('Product Names'),
                _field(_nameEnCtrl, l.t('productName'),
                    validator: (v) => (v?.trim().isEmpty ?? true)
                        ? l.t('fieldRequired')
                        : null),
                const SizedBox(height: 12),
                _field(_nameArCtrl, l.t('productNameAr'),
                    validator: (v) => (v?.trim().isEmpty ?? true)
                        ? l.t('fieldRequired')
                        : null),

                // ── Descriptions ───────────────────────────────────────────
                const SizedBox(height: 20),
                _section('Descriptions'),
                _field(_descEnCtrl, l.t('productDescEn'), maxLines: 3),
                const SizedBox(height: 12),
                _field(_descArCtrl, l.t('productDescAr'), maxLines: 3),

                // ── Pricing & Stock ────────────────────────────────────────
                const SizedBox(height: 20),
                _section('Pricing & Stock'),
                Row(
                  children: [
                    Expanded(
                      child: _field(_priceCtrl, l.t('productPrice'),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return l.t('fieldRequired');
                            }
                            if (double.tryParse(v.trim()) == null) {
                              return 'Invalid number';
                            }
                            return null;
                          }),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _field(_qtyCtrl, l.t('productQty'),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return l.t('fieldRequired');
                            }
                            if (int.tryParse(v.trim()) == null) {
                              return 'Invalid number';
                            }
                            return null;
                          }),
                    ),
                  ],
                ),

                // ── Category ───────────────────────────────────────────────
                const SizedBox(height: 20),
                _section('Category'),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.category_outlined),
                  ),
                  items: _categories
                      .map((c) =>
                          DropdownMenuItem(value: c, child: Text(l.t(c))))
                      .toList(),
                  onChanged: (v) => _selectedCategory = v ?? _selectedCategory,
                ),

                // ── Brand & Identifiers ────────────────────────────────────
                const SizedBox(height: 20),
                _section('Brand & Identifiers'),
                Row(
                  children: [
                    Expanded(child: _field(_brandEnCtrl, l.t('productBrandEn'))),
                    const SizedBox(width: 12),
                    Expanded(child: _field(_brandArCtrl, l.t('productBrandAr'))),
                  ],
                ),
                const SizedBox(height: 12),
                _field(_modelNoCtrl, l.t('productModelNumber')),

                // ── Color & Physical ───────────────────────────────────────
                const SizedBox(height: 20),
                _section('Color & Physical Properties'),
                Row(
                  children: [
                    Expanded(child: _field(_colorEnCtrl, l.t('productColorEn'))),
                    const SizedBox(width: 12),
                    Expanded(child: _field(_colorArCtrl, l.t('productColorAr'))),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _field(_weightCtrl, l.t('productWeight'))),
                    const SizedBox(width: 12),
                    Expanded(child: _field(_dimsCtrl, l.t('productDimensions'))),
                  ],
                ),

                // ── Material ───────────────────────────────────────────────
                const SizedBox(height: 20),
                _section('Material'),
                Row(
                  children: [
                    Expanded(child: _field(_matEnCtrl, l.t('productMaterialEn'))),
                    const SizedBox(width: 12),
                    Expanded(child: _field(_matArCtrl, l.t('productMaterialAr'))),
                  ],
                ),

                // ── Origin & Condition ─────────────────────────────────────
                const SizedBox(height: 20),
                _section('Origin & Condition'),
                Row(
                  children: [
                    Expanded(child: _field(_originEnCtrl, l.t('productOriginEn'))),
                    const SizedBox(width: 12),
                    Expanded(child: _field(_originArCtrl, l.t('productOriginAr'))),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _field(_condEnCtrl, l.t('productConditionEn'))),
                    const SizedBox(width: 12),
                    Expanded(child: _field(_condArCtrl, l.t('productConditionAr'))),
                  ],
                ),

                // ── Warranty ───────────────────────────────────────────────
                const SizedBox(height: 20),
                _section('Warranty'),
                Row(
                  children: [
                    Expanded(
                        child: _field(_warrantyEnCtrl, l.t('productWarrantyEn'))),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _field(_warrantyArCtrl, l.t('productWarrantyAr'))),
                  ],
                ),

                // ── Specifications ─────────────────────────────────────────
                const SizedBox(height: 20),
                _section('Specifications'),
                _field(_specsEnCtrl, l.t('productSpecsEn'), maxLines: 4),
                const SizedBox(height: 12),
                _field(_specsArCtrl, l.t('productSpecsAr'), maxLines: 4),

                // ── Features ──────────────────────────────────────────────
                const SizedBox(height: 20),
                _section('Features'),
                _field(_featEnCtrl, l.t('productFeaturesEn'), maxLines: 4),
                const SizedBox(height: 12),
                _field(_featArCtrl, l.t('productFeaturesAr'), maxLines: 4),

                // ── Images ────────────────────────────────────────────────
                const SizedBox(height: 20),
                _section('Images'),
                _field(_imagesCtrl, l.t('productImages'), maxLines: 5),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    'Enter each image URL on a separate line. The first URL is used as the thumbnail.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.55),
                        ),
                  ),
                ),
                const SizedBox(height: 12),
                Text('— or use a single URL / asset path —',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 8),
                _field(_imageUrlCtrl, l.t('productImageUrl')),
                const SizedBox(height: 12),
                _field(_imageAssetCtrl, l.t('productImageAsset')),

                // ── Visibility ────────────────────────────────────────────
                const SizedBox(height: 20),
                _section('Visibility'),
                SwitchListTile.adaptive(
                  value: _isAvailable,
                  onChanged: (v) => setState(() => _isAvailable = v),
                  title: Text(
                      _isAvailable ? l.t('available') : l.t('unavailable')),
                  subtitle: Text(_isAvailable
                      ? 'Customers can see this product'
                      : 'Product is hidden from customers'),
                  contentPadding: EdgeInsets.zero,
                ),

                // ── Save button ───────────────────────────────────────────
                const SizedBox(height: 28),
                FilledButton.icon(
                  onPressed: _isSaving ? null : _save,
                  icon: _isSaving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(l.t('saveProduct')),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _section(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          text,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
      );

  Widget _field(
    TextEditingController ctrl,
    String label, {
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) =>
      TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          alignLabelWithHint: maxLines > 1,
        ),
      );
}
