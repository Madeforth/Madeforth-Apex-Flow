import 'dart:io';
import 'dart:ui';
import 'dart:async';
import 'package:apexflow/core/design/apex_colors.dart';
import 'package:apexflow/core/design/apex_spacing.dart';
import 'package:apexflow/core/i18n/app_strings.dart';
import 'package:apexflow/core/i18n/app_settings_state.dart';
import 'package:apexflow/documents/application/document_vault_state.dart';
import 'package:apexflow/documents/domain/motorcycle_document.dart';
import 'package:apexflow/documents/domain/tax_record.dart';
import 'package:apexflow/garage/application/garage_state.dart';
import 'package:apexflow/shared/widgets/apex_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:apexflow/settings/application/user_profile_state.dart';
import 'package:apexflow/profile/presentation/premium_paywall_screen.dart';
import 'package:apexflow/garage/presentation/accident_region_selector.dart';

import 'package:apexflow/notifications/notification_scheduler.dart';
import 'package:apexflow/core/design/theme_extensions.dart';
import 'package:apexflow/core/storage/document_file_crypto.dart';
import 'package:url_launcher/url_launcher.dart';

class DocumentVaultScreen extends ConsumerStatefulWidget {
  const DocumentVaultScreen({
    super.key,
    required this.strings,
    this.topPadding = 0.0,
    this.onClose,
  });

  final AppStrings strings;
  final double topPadding;

  /// Forwarded to the paywall shown when the user isn't premium — lets it
  /// switch to a different tab since this screen isn't reached via
  /// Navigator.push (there's nothing to pop back to).
  final VoidCallback? onClose;

  @override
  ConsumerState<DocumentVaultScreen> createState() =>
      _DocumentVaultScreenState();
}

class _DocumentVaultScreenState extends ConsumerState<DocumentVaultScreen> {
  String _activeTab = 'docs'; // 'docs' or 'tax'

  @override
  Widget build(BuildContext context) {
    final isPremium = ref.watch(userProfileProvider).isPremium;
    if (!isPremium) {
      return PremiumPaywallScreen(
        strings: widget.strings,
        onClose: widget.onClose,
      );
    }

    final state = ref.watch(documentVaultProvider);
    final garage = ref.watch(garageStateProvider);
    final tr = widget.strings.locale.languageCode == 'tr';

    if (garage.motorcycles.isEmpty) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Text(
              tInline(
                AppStrings.currentLanguageCode,
                'Lütfen önce Garaj sekmesinden bir motosiklet ekle.',
                'Please add a motorcycle in the Garage tab first.',
                'Bitte fügen Sie zuerst ein Motorrad im Reiter „Garage“ hinzu.',
              ),
              style: TextStyle(color: context.colors.textSecondary),
            ),
          ),
        ),
      );
    }

    final activeBike = garage.activeBike;
    final bikeDocs = state.documents
        .where((d) => d.bikeStableId == activeBike.id)
        .toList();
    final bikeTaxes = state.taxRecords
        .where((t) => t.bikeStableId == activeBike.id)
        .toList();

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: EdgeInsets.only(
                top: widget.topPadding + 64, // 16 top + 38 height + 10 spacing
                left: ApexSpacing.x2,
                right: ApexSpacing.x2,
                bottom: 80,
              ),
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.strings.vaultTitle,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AccidentRegionSelectorScreen(
                              strings: widget.strings,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.description_outlined),
                      label: Text(
                        tInline(
                          AppStrings.currentLanguageCode,
                          'Kaza Tutanağı',
                          'Accident Report',
                          'Unfallbericht',
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colors.red.withValues(
                          alpha: 0.1,
                        ),
                        foregroundColor: context.colors.red,
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  widget.strings.vaultSubtitle,
                  style: TextStyle(color: context.colors.textSecondary),
                ),
                const SizedBox(height: 24),

                // Content
                if (_activeTab == 'docs')
                  _DocsTabContent(
                    documents: bikeDocs,
                    strings: widget.strings,
                    bikeStableId: activeBike.id,
                    onAdd: () {
                      final isPremium = ref.read(userProfileProvider).isPremium;
                      if (bikeDocs.length >= 2 && !isPremium) {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                PremiumPaywallScreen(strings: widget.strings),
                          ),
                        );
                      } else {
                        _showAddDocSheet(context, activeBike.id);
                      }
                    },
                  )
                else
                  _TaxTabContent(
                    records: bikeTaxes,
                    strings: widget.strings,
                    bikeStableId: activeBike.id,
                    onAdd: () {
                      final isPremium = ref.read(userProfileProvider).isPremium;
                      if (bikeTaxes.length >= 2 && !isPremium) {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                PremiumPaywallScreen(strings: widget.strings),
                          ),
                        );
                      } else {
                        _showAddTaxSheet(context, activeBike.id);
                      }
                    },
                    onLoadTemplate: () =>
                        _showTemplateDialog(context, activeBike.id),
                  ),
              ],
            ),
            Positioned(
              top: widget.topPadding + 12, // Pushed down below topPadding
              left: 0,
              right: 0,
              child: _VaultTabSelector(
                strings: widget.strings,
                activeTab: _activeTab,
                onChanged: (tab) => setState(() => _activeTab = tab),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDocSheet(BuildContext context, String bikeId) {
    HapticFeedback.selectionClick();
    final tr = widget.strings.locale.languageCode == 'tr';
    final titleController = TextEditingController();
    final descController = TextEditingController();
    String? pickedImagePath;
    DateTime? selectedExpirationDate;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.colors.surface,
      barrierColor: context.colors.background.withValues(alpha: 0.72),
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                MediaQuery.viewInsetsOf(context).bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tInline(
                      AppStrings.currentLanguageCode,
                      'Yeni Belge Ekle',
                      'Add New Document',
                      'Neues Dokument hinzufügen',
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: tInline(
                        AppStrings.currentLanguageCode,
                        'Belge Başlığı',
                        'Document Title',
                        'Dokumenttitel',
                      ),
                      hintText: tInline(
                        AppStrings.currentLanguageCode,
                        'Örn: Ruhsat, Ehliyet',
                        'E.g., Registration',
                        'Z. B. Registrierung',
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: descController,
                    decoration: InputDecoration(
                      labelText: tInline(
                        AppStrings.currentLanguageCode,
                        'Açıklama',
                        'Description',
                        'Beschreibung',
                      ),
                      hintText: tInline(
                        AppStrings.currentLanguageCode,
                        'İsteğe bağlı notlar',
                        'Optional notes',
                        'Optionale Notizen',
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Date Picker for Expiration Date
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      tInline(
                        AppStrings.currentLanguageCode,
                        'Geçerlilik Tarihi (İsteğe Bağlı)',
                        'Expiration Date (Optional)',
                        'Ablaufdatum (optional)',
                      ),
                    ),
                    subtitle: Text(
                      selectedExpirationDate == null
                          ? (tInline(
                              AppStrings.currentLanguageCode,
                              'Seçilmedi',
                              'None',
                              'Keiner',
                            ))
                          : DateFormat(
                              'yyyy-MM-dd',
                            ).format(selectedExpirationDate!),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (selectedExpirationDate != null)
                          IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              setSheetState(
                                () => selectedExpirationDate = null,
                              );
                            },
                          ),
                        Icon(
                          Icons.calendar_today_outlined,
                          color: context.colors.cyan,
                        ),
                      ],
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedExpirationDate ?? DateTime.now(),
                        firstDate: DateTime.now().subtract(
                          const Duration(days: 365),
                        ),
                        lastDate: DateTime.now().add(
                          const Duration(days: 3650),
                        ),
                      );
                      if (picked != null) {
                        setSheetState(() => selectedExpirationDate = picked);
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  // Image Preview & Capture
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: context.colors.cyan,
                            side: BorderSide(color: context.colors.border),
                          ),
                          onPressed: () async {
                            final picker = ImagePicker();
                            final image = await picker.pickImage(
                              source: ImageSource.camera,
                            );
                            if (image != null) {
                              setSheetState(() => pickedImagePath = image.path);
                            }
                          },
                          icon: const Icon(Icons.camera_alt_outlined, size: 18),
                          label: Text(
                            tInline(
                              AppStrings.currentLanguageCode,
                              'Fotoğraf Çek',
                              'Take Photo',
                              'Machen Sie ein Foto',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: context.colors.cyan,
                            side: BorderSide(color: context.colors.border),
                          ),
                          onPressed: () async {
                            final picker = ImagePicker();
                            final image = await picker.pickImage(
                              source: ImageSource.gallery,
                            );
                            if (image != null) {
                              setSheetState(() => pickedImagePath = image.path);
                            }
                          },
                          icon: const Icon(
                            Icons.photo_library_outlined,
                            size: 18,
                          ),
                          label: Text(
                            tInline(
                              AppStrings.currentLanguageCode,
                              'Galeriden Seç',
                              'Choose Gallery',
                              'Wählen Sie Galerie',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (pickedImagePath != null) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.file(
                        File(pickedImagePath!),
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: context.colors.onAccent,
                        backgroundColor: context.colors.cyan,
                      ),
                      onPressed: () async {
                        final title = titleController.text.trim();
                        if (title.isEmpty) return;
                        var vaultImagePath = pickedImagePath;
                        if (vaultImagePath != null) {
                          vaultImagePath =
                              await DocumentFileCrypto.encryptIntoVault(
                                File(vaultImagePath),
                              );
                        }
                        final docId = await ref
                            .read(documentVaultProvider.notifier)
                            .addDocument(
                              bikeStableId: bikeId,
                              title: title,
                              description: descController.text.trim(),
                              imagePath: vaultImagePath,
                              expirationDateIso: selectedExpirationDate
                                  ?.toIso8601String(),
                            );
                        if (selectedExpirationDate != null) {
                          unawaited(
                            NotificationScheduler.scheduleDocumentExpiryReminder(
                              docId: docId,
                              title: title,
                              expirationDate: selectedExpirationDate!,
                              strings: AppStrings(
                                ref.read(appSettingsProvider).locale,
                              ),
                            ),
                          );
                        }
                        if (context.mounted) Navigator.of(context).pop();
                      },
                      child: Text(
                        tInline(
                          AppStrings.currentLanguageCode,
                          'Kaydet',
                          'Save',
                          'Speichern',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAddTaxSheet(BuildContext context, String bikeId) {
    HapticFeedback.selectionClick();
    final tr = widget.strings.locale.languageCode == 'tr';
    final amountController = TextEditingController();
    String selectedType = 'other';
    DateTime selectedDate = DateTime.now();

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.colors.surface,
      barrierColor: context.colors.background.withValues(alpha: 0.72),
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                MediaQuery.viewInsetsOf(context).bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tInline(
                      AppStrings.currentLanguageCode,
                      'Ödeme / Tarih Ekle',
                      'Add New Due Date',
                      'Neues Fälligkeitsdatum hinzufügen',
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedType,
                    dropdownColor: context.colors.surface,
                    decoration: InputDecoration(
                      labelText: tInline(
                        AppStrings.currentLanguageCode,
                        'Ödeme Türü',
                        'Payment Type',
                        'Zahlungsart',
                      ),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'mtv_1',
                        child: Text(widget.strings.taxLabel('mtv_1')),
                      ),
                      DropdownMenuItem(
                        value: 'mtv_2',
                        child: Text(widget.strings.taxLabel('mtv_2')),
                      ),
                      DropdownMenuItem(
                        value: 'insurance',
                        child: Text(widget.strings.taxLabel('insurance')),
                      ),
                      DropdownMenuItem(
                        value: 'inspection',
                        child: Text(widget.strings.taxLabel('inspection')),
                      ),
                      DropdownMenuItem(
                        value: 'global_insurance',
                        child: Text(
                          widget.strings.taxLabel('global_insurance'),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'global_inspection',
                        child: Text(
                          widget.strings.taxLabel('global_inspection'),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'road_tax',
                        child: Text(widget.strings.taxLabel('road_tax')),
                      ),
                      DropdownMenuItem(
                        value: 'other',
                        child: Text(widget.strings.taxLabel('other')),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) setSheetState(() => selectedType = val);
                    },
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: widget.strings.taxAmount,
                      hintText: '0.00',
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Date Picker
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      tInline(
                        AppStrings.currentLanguageCode,
                        'Son Ödeme Tarihi',
                        'Due Date',
                        'Fälligkeitsdatum',
                      ),
                    ),
                    subtitle: Text(
                      DateFormat('yyyy-MM-dd').format(selectedDate),
                    ),
                    trailing: Icon(
                      Icons.calendar_today_outlined,
                      color: context.colors.cyan,
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2035),
                      );
                      if (picked != null) {
                        setSheetState(() => selectedDate = picked);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: context.colors.onAccent,
                        backgroundColor: context.colors.cyan,
                      ),
                      onPressed: () async {
                        final amt =
                            double.tryParse(amountController.text.trim()) ??
                            0.0;
                        await ref
                            .read(documentVaultProvider.notifier)
                            .addTaxRecord(
                              bikeStableId: bikeId,
                              type: selectedType,
                              dueDateIso: selectedDate.toIso8601String(),
                              amount: amt,
                              currency: tInline(
                                AppStrings.currentLanguageCode,
                                'TRY',
                                'USD',
                                'USD',
                              ),
                            );
                        unawaited(
                          NotificationScheduler.scheduleTaxDueReminder(
                            recordId: DateTime.now().millisecondsSinceEpoch
                                .toString(),
                            typeLabel: widget.strings.taxLabel(selectedType),
                            dueDate: selectedDate,
                            strings: widget.strings,
                          ),
                        );
                        if (context.mounted) Navigator.of(context).pop();
                      },
                      child: Text(
                        tInline(
                          AppStrings.currentLanguageCode,
                          'Ekle',
                          'Add',
                          'Hinzufügen',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showTemplateDialog(BuildContext context, String bikeId) {
    HapticFeedback.selectionClick();
    final tr = widget.strings.locale.languageCode == 'tr';

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: context.colors.surface,
          title: Text(
            tInline(
              AppStrings.currentLanguageCode,
              'Şablon Seçimi',
              'Choose Template',
              'Wählen Sie Vorlage',
            ),
          ),
          content: Text(
            tInline(
              AppStrings.currentLanguageCode,
              'Motosikletiniz için vergi ve muayene tarihlerini otomatik oluşturmak ister misiniz?',
              'Would you like to auto-generate tax and inspection dates for this motorcycle?',
              'Möchten Sie Steuer- und Inspektionstermine für dieses Motorrad automatisch generieren?',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                tInline(
                  AppStrings.currentLanguageCode,
                  'Vazgeç',
                  'Cancel',
                  'Stornieren',
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                await ref
                    .read(documentVaultProvider.notifier)
                    .generateDefaultTemplates(
                      bikeStableId: bikeId,
                      isTurkey: true,
                      currency: 'TRY',
                    );
                if (ctx.mounted) Navigator.of(ctx).pop();
              },
              child: Text(
                tInline(
                  AppStrings.currentLanguageCode,
                  'Türkiye Şablonu',
                  'Turkey Template',
                  'Türkei-Vorlage',
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                await ref
                    .read(documentVaultProvider.notifier)
                    .generateDefaultTemplates(
                      bikeStableId: bikeId,
                      isTurkey: false,
                      currency: 'USD',
                    );
                if (ctx.mounted) Navigator.of(ctx).pop();
              },
              child: Text(
                tInline(
                  AppStrings.currentLanguageCode,
                  'Global Şablon',
                  'Global Template',
                  'Globale Vorlage',
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Tab Selector Widget
class _VaultTabSelector extends StatelessWidget {
  const _VaultTabSelector({
    required this.strings,
    required this.activeTab,
    required this.onChanged,
  });

  final AppStrings strings;
  final String activeTab;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 38,
            constraints: const BoxConstraints(maxWidth: 270),
            decoration: BoxDecoration(
              color: context.colors.navChip.withValues(
                alpha: 0.8,
              ), // Semi-transparent navbar background
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(19),
            ),
            padding: const EdgeInsets.all(2),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => onChanged('docs'),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: activeTab == 'docs'
                            ? context.colors.cyan.withValues(
                                alpha: 0.14,
                              ) // Liquid-like highlight
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(17),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.description_outlined,
                              size: 14, // Slimmer icon
                              color: activeTab == 'docs'
                                  ? context
                                        .colors
                                        .cyan // Selected tab icon color
                                  : context.colors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              strings.vaultDocTab,
                              style: TextStyle(
                                fontSize: 11, // Slimmer text
                                fontWeight: activeTab == 'docs'
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: activeTab == 'docs'
                                    ? context
                                          .colors
                                          .cyan // Selected tab text color
                                    : context.colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => onChanged('tax'),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: activeTab == 'tax'
                            ? context.colors.cyan.withValues(
                                alpha: 0.14,
                              ) // Liquid-like highlight
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(17),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 14, // Slimmer icon
                              color: activeTab == 'tax'
                                  ? context
                                        .colors
                                        .cyan // Selected tab icon color
                                  : context.colors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              strings.vaultTaxTab,
                              style: TextStyle(
                                fontSize: 11, // Slimmer text
                                fontWeight: activeTab == 'tax'
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: activeTab == 'tax'
                                    ? context
                                          .colors
                                          .cyan // Selected tab text color
                                    : context.colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Documents list view
class _DocsTabContent extends ConsumerWidget {
  const _DocsTabContent({
    required this.documents,
    required this.strings,
    required this.bikeStableId,
    required this.onAdd,
  });

  final List<MotorcycleDocument> documents;
  final AppStrings strings;
  final String bikeStableId;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              strings.vaultDocTab,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
            ),
            SizedBox(
              height: 32,
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: context.colors.onAccent,
                  backgroundColor: context.colors.cyan,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                onPressed: onAdd,
                icon: const Icon(Icons.add, size: 14),
                label: Text(
                  strings.vaultAddDoc,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: ApexSpacing.x1),
        if (documents.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Text(
                strings.vaultNoDocs,
                style: TextStyle(color: context.colors.textSecondary),
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.9,
            ),
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final doc = documents[index];
              return _DocCard(doc: doc, strings: strings);
            },
          ),
      ],
    );
  }
}

// Document card widget
class _DocCard extends ConsumerWidget {
  const _DocCard({required this.doc, required this.strings});

  final MotorcycleDocument doc;
  final AppStrings strings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasImage = doc.imagePath != null && doc.imagePath!.isNotEmpty;

    return ApexPanel(
      child: InkWell(
        onTap: () {
          if (hasImage) {
            _showFullImageDialog(context, doc.imagePath!, doc.title);
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  width: double.infinity,
                  color: context.colors.elevated,
                  child: hasImage
                      ? _VaultImage(path: doc.imagePath!, fit: BoxFit.cover)
                      : Icon(
                          Icons.description_outlined,
                          color: context.colors.textSecondary,
                          size: 32,
                        ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doc.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (doc.description.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          doc.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            color: context.colors.textSecondary,
                          ),
                        ),
                      ],
                      if (doc.expirationDateIso != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.event,
                              size: 10,
                              color: _isNearExpiry(doc.expirationDate)
                                  ? context.colors.red
                                  : context.colors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                _formatExpiryDate(
                                  doc.expirationDate,
                                  strings.locale.languageCode,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: _isNearExpiry(doc.expirationDate)
                                      ? context.colors.red
                                      : context.colors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    Icons.delete_outline,
                    size: 16,
                    color: context.colors.red,
                  ),
                  onPressed: () async {
                    HapticFeedback.mediumImpact();
                    await ref
                        .read(documentVaultProvider.notifier)
                        .deleteDocument(doc.id);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showFullImageDialog(BuildContext context, String path, String title) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          backgroundColor: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                title: Text(title, style: const TextStyle(color: Colors.white)),
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ),
              Expanded(
                child: InteractiveViewer(
                  child: _VaultImage(path: path, fit: BoxFit.contain),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _isNearExpiry(DateTime? date) {
    if (date == null) return false;
    final diff = date.difference(DateTime.now()).inDays;
    return diff <= 30;
  }

  String _formatExpiryDate(DateTime? date, String languageCode) {
    if (date == null) return '';
    final dd = date.day.toString().padLeft(2, '0');
    final mm = date.month.toString().padLeft(2, '0');
    if (languageCode == 'tr') {
      return 'Geçerlilik: $dd.$mm.${date.year}';
    }
    if (languageCode == 'de') {
      return 'Läuft ab: $dd.$mm.${date.year}';
    }
    return 'Expires: $mm/$dd/${date.year}';
  }
}

// Tax / Due Dates Tab Content
class _TaxTabContent extends ConsumerWidget {
  const _TaxTabContent({
    required this.records,
    required this.strings,
    required this.bikeStableId,
    required this.onAdd,
    required this.onLoadTemplate,
  });

  final List<TaxRecord> records;
  final AppStrings strings;
  final String bikeStableId;
  final VoidCallback onAdd;
  final VoidCallback onLoadTemplate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = strings.locale.languageCode == 'tr';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              strings.vaultTaxTab,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
            ),
            if (records.isNotEmpty)
              Wrap(
                spacing: 8,
                children: [
                  SizedBox(
                    height: 32,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: context.colors.cyan,
                        side: BorderSide(color: context.colors.border),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      onPressed: onLoadTemplate,
                      icon: const Icon(Icons.auto_awesome, size: 14),
                      label: Text(
                        tInline(
                          AppStrings.currentLanguageCode,
                          'Şablon',
                          'Template',
                          'Vorlage',
                        ),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 32,
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: context.colors.onAccent,
                        backgroundColor: context.colors.cyan,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      onPressed: onAdd,
                      icon: const Icon(Icons.add, size: 14),
                      label: Text(
                        strings.taxAddButton,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: ApexSpacing.x1),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _OfficialShortcutChip(
                icon: Icons.fact_check_outlined,
                label: tInline(
                  strings.languageCode,
                  'Muayene Randevusu',
                  'Inspection Appointment',
                  'Inspektionstermin',
                ),
                url: 'https://www.tuvturk.com.tr',
              ),
              const SizedBox(width: 8),
              _OfficialShortcutChip(
                icon: Icons.account_balance_outlined,
                label: tInline(
                  strings.languageCode,
                  'MTV Öde (e-Devlet)',
                  'Pay Vehicle Tax (e-Devlet)',
                  'Kfz-Steuer bezahlen (e-Devlet)',
                ),
                url: 'https://www.turkiye.gov.tr',
              ),
            ],
          ),
        ),
        const SizedBox(height: ApexSpacing.x1),
        if (records.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 48,
                    color: context.colors.muted,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    tInline(
                      AppStrings.currentLanguageCode,
                      'Kayıtlı vergi veya ödeme tarihi bulunmuyor.',
                      'No due dates saved yet.',
                      'Noch keine Fälligkeitstermine gespeichert.',
                    ),
                    style: TextStyle(color: context.colors.textSecondary),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: context.colors.cyan,
                          side: BorderSide(color: context.colors.border),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        onPressed: onLoadTemplate,
                        icon: const Icon(Icons.auto_awesome, size: 16),
                        label: Text(
                          strings.taxTemplateButton,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: context.colors.onAccent,
                          backgroundColor: context.colors.cyan,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        onPressed: onAdd,
                        icon: const Icon(Icons.add, size: 16),
                        label: Text(
                          strings.taxAddButton,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final r = records[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: _TaxCard(record: r, strings: strings),
              );
            },
          ),
      ],
    );
  }
}

/// Displays a document photo/PDF page stored via [DocumentFileCrypto]. Falls
/// back to rendering [path] as a plain file if decryption fails, which
/// covers pre-encryption files saved before this feature existed.
class _VaultImage extends StatelessWidget {
  const _VaultImage({required this.path, required this.fit});

  final String path;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: DocumentFileCrypto.decrypt(path),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }
        final bytes = snapshot.data;
        if (bytes != null) {
          return Image.memory(bytes, fit: fit);
        }
        return Image.file(File(path), fit: fit);
      },
    );
  }
}

class _OfficialShortcutChip extends StatelessWidget {
  const _OfficialShortcutChip({
    required this.icon,
    required this.label,
    required this.url,
  });

  final IconData icon;
  final String label;
  final String url;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: context.colors.textSecondary,
        side: BorderSide(color: context.colors.border),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      onPressed: () async {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      },
      icon: Icon(icon, size: 14),
      label: Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// Individual Tax Card
class _TaxCard extends ConsumerWidget {
  const _TaxCard({required this.record, required this.strings});

  final TaxRecord record;
  final AppStrings strings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = strings.locale.languageCode == 'tr';
    final remainingDays = record.dueDate.difference(DateTime.now()).inDays;

    Color alertColor = context.colors.healthy;
    if (!record.isPaid) {
      if (remainingDays < 30) {
        alertColor = context.colors.red;
      } else if (remainingDays < 90) {
        alertColor = context.colors.caution;
      } else {
        alertColor = context.colors.cyan;
      }
    }

    final formattedDate = DateFormat('yyyy-MM-dd').format(record.dueDate);
    final daysText = record.isPaid
        ? (tInline(AppStrings.currentLanguageCode, 'Ödendi', 'Paid', 'Bezahlt'))
        : (remainingDays < 0
              ? (tInline(
                  AppStrings.currentLanguageCode,
                  '${remainingDays.abs()} gün gecikti',
                  '${remainingDays.abs()} days overdue',
                  '${remainingDays.abs()} Tage überfällig',
                ))
              : (tInline(
                  AppStrings.currentLanguageCode,
                  '$remainingDays gün kaldı',
                  '$remainingDays days left',
                  '$remainingDays verbleibende Tage',
                )));

    return ApexPanel(
      child: Row(
        children: [
          Container(
            width: 4,
            height: 48,
            decoration: BoxDecoration(
              color: alertColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.taxLabel(record.type),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$formattedDate • $daysText',
                  style: TextStyle(
                    fontSize: 11,
                    color: record.isPaid
                        ? context.colors.textSecondary
                        : alertColor,
                    fontWeight: record.isPaid
                        ? FontWeight.normal
                        : FontWeight.w700,
                  ),
                ),
                if (record.amount > 0) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${record.amount.toStringAsFixed(0)} ${record.currency}',
                    style: TextStyle(
                      fontSize: 11,
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Paid Check Button
          Checkbox(
            activeColor: context.colors.cyan,
            checkColor: context.colors.onAccent,
            value: record.isPaid,
            onChanged: (val) async {
              HapticFeedback.selectionClick();
              await ref
                  .read(documentVaultProvider.notifier)
                  .toggleTaxPaid(record.id);
            },
          ),
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              size: 18,
              color: context.colors.muted,
            ),
            onPressed: () async {
              HapticFeedback.mediumImpact();
              await ref
                  .read(documentVaultProvider.notifier)
                  .deleteTaxRecord(record.id);
            },
          ),
        ],
      ),
    );
  }
}
