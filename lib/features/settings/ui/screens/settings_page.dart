import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/modern_theme.dart';
import '../../../../core/constants/company_info.dart';

class ModernSettingsPage extends ConsumerStatefulWidget {
  const ModernSettingsPage({super.key});

  @override
  ConsumerState<ModernSettingsPage> createState() => _ModernSettingsPageState();
}

class _ModernSettingsPageState extends ConsumerState<ModernSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController(text: CompanyInfo.name);
  final _addressCtrl = TextEditingController(text: CompanyInfo.address);
  final _emailCtrl = TextEditingController(text: CompanyInfo.email);
  final _phoneCtrl = TextEditingController(text: CompanyInfo.phone);
  final _taxCtrl = TextEditingController(text: CompanyInfo.gstin);

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _taxCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(ModernTheme.lg),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Settings', style: ModernTheme.headingMedium),
            const SizedBox(height: ModernTheme.xs),
            Text('Configure your business information.', style: ModernTheme.bodyLarge),
            const SizedBox(height: ModernTheme.xl),

            // ── Company Information ──────────────────────────────────────
            _section(
              'Company Information',
              [
                _field('Company Name', 'Enter company name', Icons.business_outlined, _nameCtrl),
                const SizedBox(height: ModernTheme.md),
                _field('Address', 'Enter company address', Icons.location_on_outlined, _addressCtrl, maxLines: 2),
                const SizedBox(height: ModernTheme.md),
                _field('Email', 'Enter company email', Icons.email_outlined, _emailCtrl, inputType: TextInputType.emailAddress),
                const SizedBox(height: ModernTheme.md),
                _field('Phone', 'Enter company phone', Icons.phone_outlined, _phoneCtrl, inputType: TextInputType.phone),
              ],
            ),
            const SizedBox(height: ModernTheme.xl),

            // ── Invoice Settings ─────────────────────────────────────────
            _section(
              'Invoice Settings',
              [
                _field('Default Tax Rate (%)', 'e.g. 18', Icons.percent_rounded, _taxCtrl, inputType: const TextInputType.numberWithOptions(decimal: true)),
              ],
            ),
            const SizedBox(height: ModernTheme.xl),

            // ── Save ─────────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check_rounded, size: 18),
                label: const Text('Save Settings'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ModernTheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ModernTheme.radiusMedium),
                  ),
                  textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(ModernTheme.lg),
      decoration: BoxDecoration(
        color: ModernTheme.surface,
        borderRadius: BorderRadius.circular(ModernTheme.radiusLarge),
        border: Border.all(color: ModernTheme.border),
        boxShadow: ModernTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: ModernTheme.headingSmall),
          const SizedBox(height: ModernTheme.md),
          ...children,
        ],
      ),
    );
  }

  Widget _field(
    String label,
    String hint,
    IconData icon,
    TextEditingController controller, {
    TextInputType? inputType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: ModernTheme.labelMedium),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: inputType,
          maxLines: maxLines,
          style: ModernTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: ModernTheme.bodyMedium.copyWith(color: ModernTheme.textMuted),
            prefixIcon: Icon(icon, size: 18, color: ModernTheme.textSecondary),
            filled: true,
            fillColor: ModernTheme.background,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: ModernTheme.md,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ModernTheme.radiusMedium),
              borderSide: const BorderSide(color: ModernTheme.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ModernTheme.radiusMedium),
              borderSide: const BorderSide(color: ModernTheme.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ModernTheme.radiusMedium),
              borderSide: const BorderSide(color: ModernTheme.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  void _save() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Settings saved'),
        backgroundColor: ModernTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ModernTheme.radiusMedium),
        ),
      ),
    );
  }
}
