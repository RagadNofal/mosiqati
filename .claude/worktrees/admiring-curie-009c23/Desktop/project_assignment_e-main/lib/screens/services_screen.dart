import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_assignment_e/l10n/app_localizations.dart';
import 'package:project_assignment_e/utils/app_colors.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Maintenance form
  final _maintenanceFormKey = GlobalKey<FormState>();
  final _issueController = TextEditingController();
  final _contactController = TextEditingController();
  String _selectedInstrument = 'guitar';
  bool _maintenanceLoading = false;

  // Consultation form
  final _consultationFormKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  String _selectedTime = 'morning';
  bool _consultationLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _issueController.dispose();
    _contactController.dispose();
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _submitMaintenance() async {
    if (!_maintenanceFormKey.currentState!.validate()) return;
    setState(() => _maintenanceLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _maintenanceLoading = false);
    HapticFeedback.mediumImpact();
    _issueController.clear();
    _contactController.clear();
    final l = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 10),
            Text(l.t('requestSent')),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _submitConsultation() async {
    if (!_consultationFormKey.currentState!.validate()) return;
    setState(() => _consultationLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _consultationLoading = false);
    HapticFeedback.mediumImpact();
    _questionController.clear();
    final l = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 10),
            Text(l.t('requestSent')),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final instruments = ['guitar', 'piano', 'drums', 'oud', 'studio'];
    final timeSlots = ['morning', 'afternoon', 'evening'];

    return Column(
      children: [
        // Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
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
              Text(
                l.t('ourServices'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l.t('maintenanceDesc'),
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 12),
              TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white54,
                indicatorColor: AppColors.gold,
                indicatorWeight: 3,
                tabs: [
                  Tab(
                    icon: const Icon(Icons.build_rounded),
                    text: l.t('maintenance'),
                  ),
                  Tab(
                    icon: const Icon(Icons.headset_mic_rounded),
                    text: l.t('consultation'),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // --- Maintenance Tab ---
              SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _maintenanceFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ServiceCard(
                        icon: Icons.build_circle_rounded,
                        title: l.t('maintenance'),
                        subtitle: l.t('maintenanceDesc'),
                        color: AppColors.catGuitar,
                      ),
                      const SizedBox(height: 20),
                      _fieldLabel(l.t('instrumentType'), theme),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedInstrument,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.music_note),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: instruments
                            .map((i) => DropdownMenuItem(
                                  value: i,
                                  child: Text(l.t(i)),
                                ))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _selectedInstrument = v!),
                      ),
                      const SizedBox(height: 16),
                      _fieldLabel(l.t('issueDescription'), theme),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _issueController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: l.t('issueDescription'),
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(bottom: 60),
                            child: Icon(Icons.description_rounded),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? '!' : null,
                      ),
                      const SizedBox(height: 16),
                      _fieldLabel(l.t('contactInfo'), theme),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _contactController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: '+962 7x xxx xxxx',
                          prefixIcon: const Icon(Icons.phone_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? '!' : null,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed:
                              _maintenanceLoading ? null : _submitMaintenance,
                          icon: _maintenanceLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.send_rounded),
                          label: Text(
                            l.t('submit'),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // --- Consultation Tab ---
              SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _consultationFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ServiceCard(
                        icon: Icons.headset_mic_rounded,
                        title: l.t('consultation'),
                        subtitle: l.t('consultationDesc'),
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 20),
                      _fieldLabel(l.t('question'), theme),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _questionController,
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: l.t('question'),
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(bottom: 80),
                            child: Icon(Icons.help_outline_rounded),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? '!' : null,
                      ),
                      const SizedBox(height: 16),
                      _fieldLabel(l.t('preferredTime'), theme),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedTime,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.access_time_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: timeSlots
                            .map((t) => DropdownMenuItem(
                                  value: t,
                                  child: Text(l.t(t)),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedTime = v!),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _consultationLoading
                              ? null
                              : _submitConsultation,
                          icon: _consultationLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.calendar_today_rounded),
                          label: Text(
                            l.t('bookConsultation'),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _fieldLabel(String label, ThemeData theme) => Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
        ),
      );
}

class _ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _ServiceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
