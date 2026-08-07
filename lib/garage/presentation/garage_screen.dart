import 'dart:ui';
import 'package:apexflow/core/design/apex_colors.dart';
import 'package:apexflow/shared/design/slate_palette.dart';
import 'package:apexflow/core/design/apex_spacing.dart';
import 'package:apexflow/core/i18n/app_strings.dart';
import 'package:apexflow/core/i18n/app_settings_state.dart';
import 'package:apexflow/garage/application/garage_state.dart';
import 'package:apexflow/notifications/application/notification_state.dart';
import 'package:apexflow/garage/domain/motorcycle_profile.dart';
import 'package:apexflow/garage/domain/service_record.dart';
import 'package:apexflow/garage/presentation/garage_passport_screen.dart';
import 'package:apexflow/garage/presentation/machine_memory_screen.dart';
import 'package:apexflow/shared/widgets/apex_panel.dart';
import 'package:apexflow/shared/widgets/apex_state_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apexflow/settings/application/user_profile_state.dart';
import 'package:apexflow/profile/presentation/premium_paywall_screen.dart';
import 'package:apexflow/garage/application/certified_ledger_pdf.dart';
import 'package:apexflow/fuel/application/fuel_state.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:apexflow/garage/application/park_sticker_pdf.dart';
import 'dart:math' as math;
import 'package:apexflow/features/documents/presentation/document_vault_screen.dart';
import 'package:apexflow/fuel/presentation/fuel_screen.dart';
import 'package:apexflow/core/design/theme_extensions.dart';

class GarageScreen extends ConsumerWidget {
  const GarageScreen({
    super.key,
    required this.strings,
    this.onOpenPartStatus,
    this.onOpenNotifications,
  });

  final AppStrings strings;
  final VoidCallback? onOpenPartStatus;
  final VoidCallback? onOpenNotifications;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(garageStateProvider);
    final tr = strings.locale.languageCode == 'tr';

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: context.colors.background,
        body: SafeArea(
          child: Stack(
            children: [
              TabBarView(
                children: [
                  ListView(
                    padding: const EdgeInsets.only(
                      top: 72, // 16 top + 38 height + 18 spacing
                      left: ApexSpacing.x2,
                      right: ApexSpacing.x2,
                      bottom: ApexSpacing.x2,
                    ),
                    children: [
                      _GarageHeader(
                        strings: strings,
                        onOpenNotifications: onOpenNotifications,
                      ),
                      const SizedBox(height: ApexSpacing.x2),
                      if (state.isHydrating) ...[
                        ApexStatePanel(
                          icon: Icons.storage_outlined,
                          title: tInline(
                            AppStrings.currentLanguageCode,
                            'Garaj okunuyor',
                            'Reading garage',
                            'Lesegarage',
                          ),
                          message: tInline(
                            AppStrings.currentLanguageCode,
                            'Yerel motosiklet ve servis kayıtları hazırlanıyor.',
                            'Local motorcycle and service records are being prepared.',
                            'Lokale Motorrad- und Wartungsunterlagen werden erstellt.',
                          ),
                          loading: true,
                        ),
                        const SizedBox(height: 80),
                      ] else if (state.motorcycles.isEmpty) ...[
                        ApexStatePanel(
                          icon: Icons.two_wheeler_outlined,
                          title: tInline(
                            AppStrings.currentLanguageCode,
                            'Garaj boş',
                            'Garage is empty',
                            'Garage ist leer',
                          ),
                          message: tInline(
                            AppStrings.currentLanguageCode,
                            'İlk makineyi ekleyerek servis aralığı, parça durumu ve hafızayı başlat.',
                            'Add the first machine to start service windows, part status, and memory.',
                            'Fügen Sie die erste Maschine hinzu, um Servicefenster, Teilestatus und Speicher zu starten.',
                          ),
                          action: SizedBox(
                            width: double.infinity,
                            child: TextButton.icon(
                              style: TextButton.styleFrom(
                                foregroundColor: context.colors.onAccent,
                                backgroundColor: context.colors.cyan,
                              ),
                              onPressed: () => _showAddBikeSheet(context, ref),
                              icon: const Icon(
                                Icons.add_road_outlined,
                                size: 18,
                              ),
                              label: Text(
                                tInline(
                                  AppStrings.currentLanguageCode,
                                  'Motosiklet Ekle',
                                  'Add Motorcycle',
                                  'Motorrad hinzufügen',
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 80),
                      ] else ...[
                        _GarageSummaryCard(
                          bike: state.activeBike,
                          strings: strings,
                        ),
                        const SizedBox(height: 12),
                        _QuickActionsRow(
                          strings: strings,
                          onServiceEntry: () => showServiceEntrySheet(
                            context,
                            ref,
                            state,
                            strings,
                          ),
                          onPartStatus: () => onOpenPartStatus?.call(),
                          onAddBike: () {
                            final isPremium = ref
                                .read(userProfileProvider)
                                .isPremium;
                            if (state.motorcycles.length >= 1 && !isPremium) {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) =>
                                      PremiumPaywallScreen(strings: strings),
                                ),
                              );
                            } else {
                              _showAddBikeSheet(context, ref);
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        _MachineHealthGrid(
                          statuses: state.componentStatuses,
                          bike: state.activeBike,
                          strings: strings,
                          onOpenPartStatus: onOpenPartStatus,
                        ),
                        const SizedBox(height: 16),
                        _SystemMenuGrid(
                          strings: strings,
                          onOpenMemory: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    MachineMemoryScreen(strings: strings),
                              ),
                            );
                          },
                          onOpenPassport: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    GaragePassportScreen(strings: strings),
                              ),
                            );
                          },
                          onCertifiedLedger: () async {
                            final userProfile = ref.read(userProfileProvider);
                            if (!userProfile.isPremium) {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) =>
                                      PremiumPaywallScreen(strings: strings),
                                ),
                              );
                            } else {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => Center(
                                  child: CircularProgressIndicator(
                                    color: context.colors.cyan,
                                  ),
                                ),
                              );
                              try {
                                await CertifiedLedgerPdf.generateAndShare(
                                  bike: state.activeBike,
                                  records: state.serviceRecords,
                                  riderTag: userProfile.riderTag,
                                  isTurkish: tr,
                                );
                              } finally {
                                if (context.mounted) {
                                  Navigator.pop(context);
                                }
                              }
                            }
                          },
                          onParkAlert: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => _ParkedBikeAlertScreen(
                                  strings: strings,
                                  bike: state.activeBike,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        _CostAnalyticsPanel(strings: strings),
                        const SizedBox(height: 16),
                        _ServiceTimeline(
                          records: state.serviceRecords,
                          strings: strings,
                        ),
                        const SizedBox(height: 16),
                        _MotorcycleListPanel(state: state, strings: strings),
                        const SizedBox(height: 80),
                      ],
                    ],
                  ),
                  DocumentVaultScreen(strings: strings, topPadding: 64),
                  FuelScreen(strings: strings, topPadding: 64),
                ],
              ),
              Positioned(
                top: 16,
                left: 0,
                right: 0,
                child: Center(
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
                          borderRadius: BorderRadius.circular(19),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08),
                            width: 1,
                          ),
                        ),
                        child: TabBar(
                          dividerColor: Colors.transparent,
                          indicatorSize: TabBarIndicatorSize.tab,
                          indicator: BoxDecoration(
                            color: context.colors.cyan.withValues(
                              alpha: 0.14,
                            ), // Liquid highlight
                            borderRadius: BorderRadius.circular(17),
                          ),
                          tabs: [
                            Tab(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.garage_outlined, size: 14),
                                    const SizedBox(width: 6),
                                    Text(
                                      tInline(
                                        AppStrings.currentLanguageCode,
                                        'Garaj',
                                        'Garage',
                                        'Garage',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Tab(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.folder_open_outlined,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      tInline(
                                        AppStrings.currentLanguageCode,
                                        'Belgeler',
                                        'Documents',
                                        'Dokumente',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Tab(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.local_gas_station_outlined,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      tInline(
                                        AppStrings.currentLanguageCode,
                                        'Yakıt',
                                        'Fuel',
                                        'Kraftstoff',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          labelColor:
                              context.colors.cyan, // Selected text/icon color
                          unselectedLabelColor: context.colors.textSecondary,
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                          unselectedLabelStyle: const TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddBikeSheet(BuildContext context, WidgetRef ref) {
    HapticFeedback.selectionClick();
    final isPremium = ref.read(userProfileProvider).isPremium;
    final state = ref.read(garageStateProvider);
    if (state.motorcycles.length >= 1 && !isPremium) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => PremiumPaywallScreen(strings: strings),
        ),
      );
      return;
    }
    final tr = strings.locale.languageCode == 'tr';
    final nameController = TextEditingController();
    final modelController = TextEditingController();
    final odometerController = TextEditingController(text: '0');
    final lastServiceController = TextEditingController(text: '0');
    final serviceIntervalController = TextEditingController(text: '6000');
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.colors.surface,
      barrierColor: context.colors.background.withValues(alpha: 0.72),
      isScrollControlled: true,
      builder: (context) {
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
                  'Motosiklet Ekle',
                  'Add Motorcycle',
                  'Motorrad hinzufügen',
                ),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              _ApexTextField(
                label: tInline(
                  AppStrings.currentLanguageCode,
                  'Motosiklet adı',
                  'Motorcycle name',
                  'Motorradname',
                ),
                controller: nameController,
              ),
              const SizedBox(height: 8),
              _ApexTextField(
                label: tInline(
                  AppStrings.currentLanguageCode,
                  'Model',
                  'Model',
                  'Modell',
                ),
                controller: modelController,
              ),
              const SizedBox(height: 8),
              _ApexTextField(
                label: tInline(
                  AppStrings.currentLanguageCode,
                  'Güncel Kilometre',
                  'Odometer km',
                  'Kilometerzähler km',
                ),
                controller: odometerController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              _ApexTextField(
                label: tInline(
                  AppStrings.currentLanguageCode,
                  'Son Servis Kilometresi',
                  'Last Service Odometer km',
                  'Letzte Wartung Kilometerzähler km',
                ),
                controller: lastServiceController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              _ApexTextField(
                label: tInline(
                  AppStrings.currentLanguageCode,
                  'Bakım Aralığı (km)',
                  'Service Interval (km)',
                  'Wartungsintervall (km)',
                ),
                controller: serviceIntervalController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: context.colors.onAccent,
                    backgroundColor: context.colors.cyan,
                  ),
                  onPressed: () {
                    final name = nameController.text.trim();
                    final model = modelController.text.trim();
                    final odometer = int.tryParse(
                      odometerController.text.trim(),
                    );
                    final lastService = int.tryParse(
                      lastServiceController.text.trim(),
                    );
                    final serviceInterval = int.tryParse(
                      serviceIntervalController.text.trim(),
                    );

                    if (name.isEmpty ||
                        model.isEmpty ||
                        odometer == null ||
                        lastService == null ||
                        serviceInterval == null) {
                      ScaffoldMessenger.of(context)
                        ..clearSnackBars()
                        ..showSnackBar(
                          SnackBar(
                            content: Text(
                              tInline(
                                AppStrings.currentLanguageCode,
                                'Lütfen tüm alanları doğru şekilde doldur.',
                                'Please fill in all fields correctly.',
                                'Bitte füllen Sie alle Felder korrekt aus.',
                              ),
                            ),
                          ),
                        );
                      return;
                    }
                    if (odometer < 0 ||
                        lastService < 0 ||
                        serviceInterval <= 0) {
                      ScaffoldMessenger.of(context)
                        ..clearSnackBars()
                        ..showSnackBar(
                          SnackBar(
                            content: Text(
                              tInline(
                                AppStrings.currentLanguageCode,
                                'Kilometre değerleri sıfırdan büyük, bakım aralığı pozitif olmalı.',
                                'Odometer must be non-negative and service interval positive.',
                                'Der Kilometerzähler darf nicht negativ und das Wartungsintervall positiv sein.',
                              ),
                            ),
                          ),
                        );
                      return;
                    }
                    if (lastService > odometer) {
                      ScaffoldMessenger.of(context)
                        ..clearSnackBars()
                        ..showSnackBar(
                          SnackBar(
                            content: Text(
                              tInline(
                                AppStrings.currentLanguageCode,
                                'Son servis kilometresi güncel kilometreden büyük olamaz.',
                                'Last service odometer cannot exceed current odometer.',
                                'Der Kilometerzähler der letzten Wartung darf den aktuellen Kilometerstand nicht überschreiten.',
                              ),
                            ),
                          ),
                        );
                      return;
                    }
                    ref
                        .read(garageStateProvider.notifier)
                        .addMotorcycle(
                          name: name,
                          model: model,
                          odometerKm: odometer,
                          lastServiceKm: lastService,
                          serviceIntervalKm: serviceInterval,
                        );
                    Navigator.of(context).pop();
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
    ).then((_) {
      nameController.dispose();
      modelController.dispose();
      odometerController.dispose();
      lastServiceController.dispose();
      serviceIntervalController.dispose();
    });
  }
}

class _GarageHeader extends ConsumerWidget {
  const _GarageHeader({required this.strings, this.onOpenNotifications});

  final AppStrings strings;
  final VoidCallback? onOpenNotifications;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = strings.locale.languageCode == 'tr';
    final unreadCount = ref.watch(unreadNotificationCountProvider);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr ? 'Garaj' : 'Garage',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                tInline(
                  AppStrings.currentLanguageCode,
                  'Makineler, servis geçmişi ve parça durumu.',
                  'Machines, service history, and component condition.',
                  'Maschinen, Servicehistorie und Zustand der Komponenten.',
                ),
                style: const TextStyle(color: SlatePalette.oledMutedText, fontSize: 13),
              ),
            ],
          ),
        ),
        if (onOpenNotifications != null)
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onOpenNotifications?.call();
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(
                  Icons.notifications_none,
                  color: Colors.white70,
                  size: 24,
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: 0,
                    top: 2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: context.colors.cyan,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

void _showEditIntervalDialog(
  BuildContext context,
  WidgetRef ref,
  MotorcycleProfile bike,
  AppStrings strings,
) {
  final controller = TextEditingController(
    text: bike.serviceIntervalKm.toString(),
  );
  final tr = strings.locale.languageCode == 'tr';

  showDialog<void>(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: SlatePalette.surfaceDeep,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ApexSpacing.radius),
        ),
        child: StatefulBuilder(
          builder: (context, setState) {
            final currentVal =
                int.tryParse(controller.text) ?? bike.serviceIntervalKm;
            final presets = [3000, 5000, 6000, 10000];

            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr ? 'Bakım Aralığı Belirle' : 'Set Service Interval',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tr
                        ? 'Motosikletin kaç kilometrede bir bakıma girmesi gerektiğini belirtin.'
                        : 'Enter how many kilometers between maintenance cycles.',
                    style: const TextStyle(
                      color: SlatePalette.oledMutedText,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Presets
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: presets.map((preset) {
                      final isSelected = currentVal == preset;
                      return InkWell(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            controller.text = preset.toString();
                          });
                        },
                        borderRadius: BorderRadius.circular(ApexSpacing.radius),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(
                                    0xFF06B6D4,
                                  ).withValues(alpha: 0.15)
                                : SlatePalette.surface,
                            borderRadius: BorderRadius.circular(
                              ApexSpacing.radius,
                            ),
                            border: Border.all(
                              color: isSelected
                                  ? context.colors.cyan
                                  : Colors.white.withValues(alpha: 0.05),
                            ),
                          ),
                          child: Text(
                            '$preset km',
                            style: TextStyle(
                              color: isSelected
                                  ? context.colors.cyan
                                  : Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),

                  // Custom input field
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: SlatePalette.surface,
                      labelText: tr ? 'Özel Değer (km)' : 'Custom Value (km)',
                      labelStyle: const TextStyle(
                        color: SlatePalette.oledMutedText,
                        fontSize: 12,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(ApexSpacing.radius),
                        borderSide: BorderSide(
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(ApexSpacing.radius),
                        borderSide: BorderSide(color: context.colors.cyan),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Actions Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: SlatePalette.oledMutedText,
                        ),
                        child: Text(tr ? 'İptal' : 'Cancel'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          final val =
                              int.tryParse(controller.text) ??
                              bike.serviceIntervalKm;
                          ref
                              .read(garageStateProvider.notifier)
                              .updateServiceInterval(bike, val);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.colors.cyan,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              ApexSpacing.radius,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          tr ? 'Kaydet' : 'Save',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}

class _GarageSummaryCard extends ConsumerWidget {
  const _GarageSummaryCard({required this.bike, required this.strings});

  final MotorcycleProfile bike;
  final AppStrings strings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = strings.locale.languageCode == 'tr';
    final settings = ref.watch(appSettingsProvider);

    final distanceUnitLabel = settings.distanceUnit;
    final displayInterval = settings
        .toDisplayDistance(bike.serviceIntervalKm.toDouble())
        .toStringAsFixed(0);
    final remaining = settings.toDisplayDistance(
      bike.kmUntilService.toDouble(),
    );
    final odometerVal = settings.toDisplayDistance(bike.odometerKm.toDouble());

    final state = bike.serviceWindowState;
    final color = switch (state) {
      ServiceWindowState.stable => context.colors.healthy,
      ServiceWindowState.dueSoon => context.colors.caution,
      ServiceWindowState.overdue => context.colors.red,
    };

    final now = DateTime.now();
    final updateTimeStr =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SlatePalette.surfaceDeep.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(ApexSpacing.radius),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tInline(
              AppStrings.currentLanguageCode,
              'GARAJ ÖZETİ',
              'GARAGE SUMMARY',
              'GARAGENÜBERSICHT',
            ),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: context.colors.cyan,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            tInline(
              AppStrings.currentLanguageCode,
              'Aktif motosiklet',
              'Active motorcycle',
              'Aktives Motorrad',
            ),
            style: TextStyle(color: context.colors.textSecondary, fontSize: 11),
          ),
          const SizedBox(height: 2),
          Text(
            bike.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  tInline(
                    AppStrings.currentLanguageCode,
                    'Bakım takibi',
                    'Maintenance tracking',
                    'Wartungsverfolgung',
                  ),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: SlatePalette.emerald.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: SlatePalette.emerald.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: SlatePalette.emerald,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      tInline(
                        AppStrings.currentLanguageCode,
                        'Kayıtlar güncel',
                        'Logs up-to-date',
                        'Protokolle aktuell',
                      ),
                      style: const TextStyle(
                        color: SlatePalette.emerald,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            tInline(
              AppStrings.currentLanguageCode,
              'Makinenin güncel durumunu tek noktadan yönet.',
              'Manage your machine\'s current status in one place.',
              'Verwalten Sie den aktuellen Status Ihrer Maschine an einem Ort.',
            ),
            style: const TextStyle(color: SlatePalette.oledMutedText, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${odometerVal.toStringAsFixed(0)}",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tr ? 'Toplam kilometre' : 'Total odometer',
                      style: const TextStyle(
                        color: SlatePalette.oledMutedText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${remaining.abs().toStringAsFixed(0)}",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      remaining < 0
                          ? (tr ? 'Bakım gecikti' : 'Service overdue')
                          : (tr ? 'Sonraki bakıma' : 'Next service'),
                      style: const TextStyle(
                        color: SlatePalette.oledMutedText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: bike.serviceProgress,
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 4,
            children: [
              Text(
                '$displayInterval $distanceUnitLabel ',
                style: const TextStyle(color: SlatePalette.oledMutedText, fontSize: 12),
              ),
              Text(
                tInline(
                  AppStrings.currentLanguageCode,
                  'bakım aralığı',
                  'Service interval',
                  'Wartungsintervall',
                ),
                style: const TextStyle(color: SlatePalette.oledMutedText, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.white.withValues(alpha: 0.05)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  tInline(
                    AppStrings.currentLanguageCode,
                    'Son güncelleme • Bugün $updateTimeStr',
                    'Last update • Today $updateTimeStr',
                    'Letztes Update • Heute $updateTimeStr',
                  ),
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  _showEditIntervalDialog(context, ref, bike, strings);
                },
                style: TextButton.styleFrom(
                  foregroundColor: context.colors.cyan,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  tInline(
                    AppStrings.currentLanguageCode,
                    'Aralığı Düzenle',
                    'Edit Interval',
                    'Intervall bearbeiten',
                  ),
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
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow({
    required this.strings,
    required this.onServiceEntry,
    required this.onPartStatus,
    required this.onAddBike,
  });

  final AppStrings strings;
  final VoidCallback onServiceEntry;
  final VoidCallback onPartStatus;
  final VoidCallback onAddBike;

  @override
  Widget build(BuildContext context) {
    final tr = strings.locale.languageCode == 'tr';
    final de = strings.locale.languageCode == 'de';
    return Row(
      children: [
        Expanded(
          child: _QuickActionButton(
            label: tr
                ? 'Servis Ekle'
                : (de ? 'Service-Eintrag' : 'Service Entry'),
            icon: Icons.build_outlined,
            onTap: onServiceEntry,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _QuickActionButton(
            label: tr ? 'Parça Durumu' : (de ? 'Teile-Zustand' : 'Part Status'),
            icon: Icons.precision_manufacturing_outlined,
            onTap: onPartStatus,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _QuickActionButton(
            label: tr
                ? 'Motor Ekle'
                : (de ? 'Motorrad hinzufügen' : 'Add Bike'),
            icon: Icons.two_wheeler_outlined,
            onTap: onAddBike,
          ),
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(ApexSpacing.radius),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: SlatePalette.surfaceDeep.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(ApexSpacing.radius),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          children: [
            Icon(icon, color: context.colors.cyan, size: 20),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MachineMetric extends StatelessWidget {
  const _MachineMetric({
    required this.label,
    required this.value,
    required this.unit,
  });

  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: context.colors.border, width: 3),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: ApexSpacing.x1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: ApexSpacing.x1),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 21,
                      height: 0.95,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    unit,
                    style: TextStyle(
                      color: context.colors.muted,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MotorcycleListPanel extends ConsumerWidget {
  const _MotorcycleListPanel({required this.state, required this.strings});

  final GarageState state;
  final AppStrings strings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = strings.locale.languageCode == 'tr';
    final active = state.activeBike;
    final activeList = state.motorcycles.where((b) => !b.archived).toList();
    final archived = state.motorcycles.where((b) => b.archived).toList();

    return ApexPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PanelTitle(
            label: tInline(
              AppStrings.currentLanguageCode,
              'Motosikletler',
              'Motorcycles',
              'Motorräder',
            ),
            value: tInline(
              AppStrings.currentLanguageCode,
              '${activeList.length} aktif',
              '${activeList.length} active',
              '${activeList.length} aktiv',
            ),
          ),
          const SizedBox(height: ApexSpacing.x1),
          if (state.motorcycles.isEmpty)
            Text(
              tInline(
                AppStrings.currentLanguageCode,
                'Henüz motosiklet yok. İlk makineyi ekleyerek başla.',
                'No motorcycles yet. Add your first machine to begin.',
                'Noch keine Motorräder. Fügen Sie zunächst Ihre erste Maschine hinzu.',
              ),
              style: TextStyle(
                color: context.colors.textSecondary,
                height: 1.35,
              ),
            ),
          for (final bike in activeList) ...[
            _MotorcycleRow(
              bike: bike,
              isActive: bike == active,
              tr: tr,
              onSelect: () => ref
                  .read(garageStateProvider.notifier)
                  .setActiveMotorcycle(bike),
              onEdit: () => _showEditBikeSheet(context, ref, bike, tr),
              onArchive: () {
                HapticFeedback.selectionClick();
                ref.read(garageStateProvider.notifier).toggleArchive(bike);
              },
              onDelete: () => _confirmDeleteBike(context, ref, bike),
            ),
            if (bike != activeList.last) const SizedBox(height: 8),
          ],
          if (archived.isNotEmpty) ...[
            const SizedBox(height: ApexSpacing.x2),
            Text(
              tInline(
                AppStrings.currentLanguageCode,
                'Arşiv',
                'Archive',
                'Archiv',
              ),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            for (final bike in archived) ...[
              _MotorcycleRow(
                bike: bike,
                isActive: bike == active,
                tr: tr,
                onSelect: () {
                  ref.read(garageStateProvider.notifier).toggleArchive(bike);
                  ref
                      .read(garageStateProvider.notifier)
                      .setActiveMotorcycle(bike.copyWith(archived: false));
                },
                onEdit: () => _showEditBikeSheet(context, ref, bike, tr),
                onArchive: () {
                  HapticFeedback.selectionClick();
                  ref.read(garageStateProvider.notifier).toggleArchive(bike);
                },
                onDelete: () => _confirmDeleteBike(context, ref, bike),
              ),
              if (bike != archived.last) const SizedBox(height: 8),
            ],
          ],
        ],
      ),
    );
  }

  Future<void> _showEditBikeSheet(
    BuildContext context,
    WidgetRef ref,
    MotorcycleProfile bike,
    bool tr,
  ) async {
    HapticFeedback.selectionClick();
    final name = TextEditingController(text: bike.name);
    final model = TextEditingController(text: bike.model);
    final odometer = TextEditingController(text: bike.odometerKm.toString());

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.surface,
      barrierColor: context.colors.background.withValues(alpha: 0.72),
      builder: (context) {
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
                  'Profili Düzenle',
                  'Edit profile',
                  'Profil bearbeiten',
                ),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              _ApexTextField(
                label: tInline(
                  AppStrings.currentLanguageCode,
                  'İsim',
                  'Name',
                  'Name',
                ),
                controller: name,
              ),
              const SizedBox(height: 8),
              _ApexTextField(
                label: tInline(
                  AppStrings.currentLanguageCode,
                  'Model',
                  'Model',
                  'Modell',
                ),
                controller: model,
              ),
              const SizedBox(height: 8),
              _ApexTextField(
                label: tInline(
                  AppStrings.currentLanguageCode,
                  'Kilometre',
                  'Odometer km',
                  'Kilometerzähler km',
                ),
                controller: odometer,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: context.colors.onAccent,
                    backgroundColor: context.colors.cyan,
                  ),
                  onPressed: () {
                    final nextName = name.text.trim();
                    final nextModel = model.text.trim();
                    final nextOdo = int.tryParse(odometer.text.trim());
                    if (nextName.isEmpty ||
                        nextModel.isEmpty ||
                        nextOdo == null) {
                      ScaffoldMessenger.of(context)
                        ..clearSnackBars()
                        ..showSnackBar(
                          SnackBar(
                            content: Text(
                              tInline(
                                AppStrings.currentLanguageCode,
                                'Lütfen ad, model ve kilometre alanlarını kontrol et.',
                                'Please check name, model, and odometer fields.',
                                'Bitte überprüfen Sie die Felder Name, Modell und Kilometerzähler.',
                              ),
                            ),
                          ),
                        );
                      return;
                    }
                    ref
                        .read(garageStateProvider.notifier)
                        .updateMotorcycle(
                          bike: bike,
                          name: nextName,
                          model: nextModel,
                          odometerKm: nextOdo,
                        );
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.save_outlined, size: 18),
                  label: Text(
                    tInline(
                      AppStrings.currentLanguageCode,
                      'Kaydet',
                      'Save',
                      'Speichern',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _confirmDeleteBike(context, ref, bike);
                  },
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: Text(
                    tInline(
                      AppStrings.currentLanguageCode,
                      'Motosikleti Sil',
                      'Delete Motorcycle',
                      'Motorrad löschen',
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
    name.dispose();
    model.dispose();
    odometer.dispose();
  }

  Future<void> _confirmDeleteBike(
    BuildContext context,
    WidgetRef ref,
    MotorcycleProfile bike,
  ) async {
    final lang = AppStrings.currentLanguageCode;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: SlatePalette.surfaceDeep,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ApexSpacing.radius),
            side: BorderSide(color: Colors.red.withValues(alpha: 0.3)),
          ),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  tInline(
                    lang,
                    'Motosikleti Sil?',
                    'Delete Motorcycle?',
                    'Motorrad löschen?',
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            tInline(
              lang,
              '"${bike.name}" motosikletini ve buna ait tüm servis kayıtlarını silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
              'Are you sure you want to delete "${bike.name}" and all associated service records? This action cannot be undone.',
              'Sind Sie sicher, dass Sie "${bike.name}" und alle zugehörigen Serviceeinträge löschen möchten? Dies kann nicht rückgängig gemacht werden.',
            ),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(
                tInline(lang, 'İptal', 'Cancel', 'Abbrechen'),
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(
                tInline(lang, 'Sil', 'Delete', 'Löschen'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      HapticFeedback.mediumImpact();
      ref.read(garageStateProvider.notifier).deleteMotorcycle(bike.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              tInline(
                lang,
                'Motosiklet ve tüm verileri silindi.',
                'Motorcycle and all associated data deleted.',
                'Motorrad und alle Daten wurden gelöscht.',
              ),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }
}

class _MotorcycleRow extends StatelessWidget {
  const _MotorcycleRow({
    required this.bike,
    required this.isActive,
    required this.tr,
    required this.onSelect,
    required this.onEdit,
    required this.onArchive,
    required this.onDelete,
  });

  final MotorcycleProfile bike;
  final bool isActive;
  final bool tr;
  final VoidCallback onSelect;
  final VoidCallback onEdit;
  final VoidCallback onArchive;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onSelect,
      borderRadius: BorderRadius.circular(ApexSpacing.radius),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? context.colors.elevated : context.colors.surface,
          border: Border.all(
            color: isActive
                ? context.colors.cyan.withValues(alpha: 0.35)
                : context.colors.border,
          ),
          borderRadius: BorderRadius.circular(ApexSpacing.radius),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bike.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    bike.model,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.colors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: tInline(
                AppStrings.currentLanguageCode,
                'Düzenle',
                'Edit',
                'Bearbeiten',
              ),
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined, size: 18),
            ),
            IconButton(
              tooltip: bike.archived
                  ? (tInline(
                      AppStrings.currentLanguageCode,
                      'Arşivden çıkar',
                      'Unarchive',
                      'Dearchivieren',
                    ))
                  : (tInline(
                      AppStrings.currentLanguageCode,
                      'Arşivle',
                      'Archive',
                      'Archiv',
                    )),
              onPressed: onArchive,
              icon: Icon(
                bike.archived
                    ? Icons.unarchive_outlined
                    : Icons.archive_outlined,
                size: 18,
              ),
            ),
            IconButton(
              tooltip: tInline(
                AppStrings.currentLanguageCode,
                'Sil',
                'Delete',
                'Löschen',
              ),
              onPressed: onDelete,
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.redAccent,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GarageActionStrip extends StatelessWidget {
  const _GarageActionStrip({
    required this.strings,
    required this.bikeCount,
    required this.onAddBike,
    required this.onServiceEntry,
    required this.onPartStatus,
    required this.onOpenMemory,
    required this.onOpenPassport,
    required this.onCertifiedLedger,
    required this.onParkAlert,
  });

  final AppStrings strings;
  final int bikeCount;
  final VoidCallback onAddBike;
  final VoidCallback onServiceEntry;
  final VoidCallback onPartStatus;
  final VoidCallback onOpenMemory;
  final VoidCallback onOpenPassport;
  final VoidCallback onCertifiedLedger;
  final VoidCallback onParkAlert;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _GarageMainAction(
                label: tInline(
                  AppStrings.currentLanguageCode,
                  'Servis Girişi',
                  'Service Entry',
                  'Diensteintrag',
                ),
                icon: Icons.build_outlined,
                onTap: onServiceEntry,
              ),
            ),
            const SizedBox(width: ApexSpacing.x1),
            Expanded(
              child: _GarageMainAction(
                label: tInline(
                  AppStrings.currentLanguageCode,
                  'Parça Durumu',
                  'Part Status',
                  'Teilestatus',
                ),
                icon: Icons.precision_manufacturing_outlined,
                onTap: onPartStatus,
              ),
            ),
            const SizedBox(width: ApexSpacing.x1),
            Expanded(
              child: _GarageMainAction(
                label: tInline(
                  AppStrings.currentLanguageCode,
                  'Motor Ekle',
                  'Add Bike',
                  'Motorrad hinz.',
                ),
                icon: Icons.tune_outlined,
                onTap: onAddBike,
              ),
            ),
          ],
        ),
        const SizedBox(height: ApexSpacing.x2),
        Text(
          tInline(
            AppStrings.currentLanguageCode,
            'Diğer garaj araçları',
            'More garage tools',
            'Weitere Garagenwerkzeuge',
          ),
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: ApexSpacing.x1),
        ApexPanel(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _GarageToolListTile(
                      label: tInline(
                        AppStrings.currentLanguageCode,
                        'Makine Hafızası',
                        'Machine Memory',
                        'Maschinenspeicher',
                      ),
                      icon: Icons.timeline_outlined,
                      onTap: onOpenMemory,
                    ),
                  ),
                  Container(width: 1, height: 48, color: context.colors.border),
                  Expanded(
                    child: _GarageToolListTile(
                      label: tInline(
                        AppStrings.currentLanguageCode,
                        'Garaj Pasaportu',
                        'Garage Passport',
                        'Garagenpass',
                      ),
                      icon: Icons.badge_outlined,
                      onTap: onOpenPassport,
                    ),
                  ),
                ],
              ),
              Divider(height: 1, color: context.colors.border),
              Row(
                children: [
                  Expanded(
                    child: _GarageToolListTile(
                      label: tInline(
                        AppStrings.currentLanguageCode,
                        'Onaylı Sicil',
                        'Certified Ledger',
                        'Zertifiziertes Hauptbuch',
                      ),
                      icon: Icons.verified_outlined,
                      onTap: onCertifiedLedger,
                    ),
                  ),
                  Container(width: 1, height: 48, color: context.colors.border),
                  Expanded(
                    child: _GarageToolListTile(
                      label: tInline(
                        AppStrings.currentLanguageCode,
                        'Park Uyarısı',
                        'Park Alert',
                        'Parkalarm',
                      ),
                      icon: Icons.notifications_active_outlined,
                      onTap: onParkAlert,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GarageMainAction extends StatelessWidget {
  const _GarageMainAction({
    required this.label,
    required this.icon,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ApexSpacing.radius),
      child: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: context.colors.surface,
          border: Border.all(color: context.colors.border),
          borderRadius: BorderRadius.circular(ApexSpacing.radius),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: context.colors.cyan, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _GarageToolListTile extends StatelessWidget {
  const _GarageToolListTile({
    required this.label,
    required this.icon,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Icon(icon, color: context.colors.cyan, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: context.colors.muted, size: 16),
          ],
        ),
      ),
    );
  }
}

class _ServiceEntry {
  const _ServiceEntry({
    required this.type,
    required this.label,
    required this.odometerKm,
    required this.note,
  });

  final String type;
  final String label;
  final int odometerKm;
  final String note;
}

class _ServiceEntrySheet extends StatefulWidget {
  const _ServiceEntrySheet({
    required this.strings,
    required this.initialOdometerKm,
    required this.lastServiceLabel,
    required this.onSubmit,
    this.initialRecord,
  });

  final AppStrings strings;
  final int initialOdometerKm;
  final String? lastServiceLabel;
  final ValueChanged<_ServiceEntry> onSubmit;
  final ServiceRecord? initialRecord;

  @override
  State<_ServiceEntrySheet> createState() => _ServiceEntrySheetState();
}

class _ServiceEntrySheetState extends State<_ServiceEntrySheet> {
  late final TextEditingController _labelController;
  late final TextEditingController _odometerController;
  late final TextEditingController _noteController;
  String? _error;

  @override
  late String _selectedType;

  @override
  void initState() {
    super.initState();
    final rec = widget.initialRecord;
    _labelController = TextEditingController(text: rec?.label ?? '');
    _odometerController = TextEditingController(
      text: (rec?.odometerKm ?? widget.initialOdometerKm).toString(),
    );
    _noteController = TextEditingController(text: rec?.note ?? '');
    _selectedType = rec?.type ?? 'mechanic';
  }

  @override
  void dispose() {
    _labelController.dispose();
    _odometerController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = widget.strings;
    final tr = strings.locale.languageCode == 'tr';
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final quickLabels = _quickLabels(strings);

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottomInset + 16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: ApexSpacing.x1),
            Text(
              strings.garageServiceEntryHelper,
              style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: 12,
                height: 1.35,
              ),
            ),
            if (quickLabels.isNotEmpty) ...[
              const SizedBox(height: ApexSpacing.x1),
              Wrap(
                spacing: ApexSpacing.x1,
                runSpacing: ApexSpacing.x1,
                children: [
                  for (final label in quickLabels)
                    _QuickFillChip(
                      label: label,
                      onTap: () => _applyQuickLabel(label),
                    ),
                ],
              ),
            ],
            _PanelTitle(
              label: tInline(
                AppStrings.currentLanguageCode,
                'Servis girişi',
                'Service entry',
                'Serviceeintrag',
              ),
              value: tInline(
                AppStrings.currentLanguageCode,
                'Yerel oturum',
                'Local session',
                'Lokale Sitzung',
              ),
            ),
            const SizedBox(height: ApexSpacing.x2),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedType = 'mechanic'),
                    borderRadius: BorderRadius.circular(ApexSpacing.radius),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedType == 'mechanic'
                            ? context.colors.cyan.withValues(alpha: 0.15)
                            : context.colors.rail,
                        border: Border.all(
                          color: _selectedType == 'mechanic'
                              ? context.colors.cyan
                              : Colors.transparent,
                        ),
                        borderRadius: BorderRadius.circular(ApexSpacing.radius),
                      ),
                      child: Center(
                        child: Text(
                          tInline(
                            AppStrings.currentLanguageCode,
                            'Yetkili Servis',
                            'Mechanic',
                            'Mechaniker',
                          ),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _selectedType == 'mechanic'
                                ? context.colors.cyan
                                : context.colors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: ApexSpacing.x1),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedType = 'diy'),
                    borderRadius: BorderRadius.circular(ApexSpacing.radius),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedType == 'diy'
                            ? context.colors.healthy.withValues(alpha: 0.15)
                            : context.colors.rail,
                        border: Border.all(
                          color: _selectedType == 'diy'
                              ? context.colors.healthy
                              : Colors.transparent,
                        ),
                        borderRadius: BorderRadius.circular(ApexSpacing.radius),
                      ),
                      child: Center(
                        child: Text(
                          tInline(
                            AppStrings.currentLanguageCode,
                            'Kendin Yap',
                            'DIY',
                            'DIY',
                          ),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _selectedType == 'diy'
                                ? context.colors.healthy
                                : context.colors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: ApexSpacing.x2),
            _ApexTextField(
              label: tInline(
                AppStrings.currentLanguageCode,
                'Servis etiketi',
                'Service label',
                'Service-Etikett',
              ),
              controller: _labelController,
            ),
            const SizedBox(height: ApexSpacing.x1),
            _ApexTextField(
              label: tInline(
                AppStrings.currentLanguageCode,
                'Kilometre',
                'Odometer km',
                'Kilometerzähler km',
              ),
              controller: _odometerController,
              keyboardType: TextInputType.number,
              helperText: tInline(
                AppStrings.currentLanguageCode,
                'Garaj kilometresi hazir',
                'Garage odometer is ready',
                'Der Garagen-Kilometerzähler ist fertig',
              ),
            ),
            const SizedBox(height: ApexSpacing.x1),
            _ApexTextField(
              label: tInline(
                AppStrings.currentLanguageCode,
                'Mekanik not',
                'Mechanical note',
                'Mechanische Notiz',
              ),
              controller: _noteController,
              maxLines: 3,
              helperText: tInline(
                AppStrings.currentLanguageCode,
                'Istege bagli',
                'Optional',
                'Optional',
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: ApexSpacing.x1),
              Text(
                _error!,
                style: TextStyle(color: context.colors.red, fontSize: 12),
              ),
            ],
            const SizedBox(height: ApexSpacing.x2),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: TextButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.save_outlined, size: 17),
                label: Text(
                  tInline(
                    AppStrings.currentLanguageCode,
                    'Servis Kaydını Kaydet',
                    'Save Service Memory',
                    'Servicespeicher speichern',
                  ),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: context.colors.onAccent,
                  backgroundColor: context.colors.cyan,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ApexSpacing.radius),
                    side: BorderSide(color: context.colors.cyan),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _quickLabels(AppStrings strings) {
    final values = <String>[
      if (widget.lastServiceLabel != null &&
          widget.lastServiceLabel!.trim().isNotEmpty)
        widget.lastServiceLabel!.trim(),
      strings.garageServicePresetLabel('inspection'),
      strings.garageServicePresetLabel('oil'),
      strings.garageServicePresetLabel('chain'),
      strings.garageServicePresetLabel('brake'),
      strings.garageServicePresetLabel('tire'),
    ];
    return values.toSet().toList();
  }

  void _applyQuickLabel(String label) {
    HapticFeedback.selectionClick();
    setState(() {
      _labelController.text = label;
      _labelController.selection = TextSelection.collapsed(
        offset: _labelController.text.length,
      );
    });
  }

  void _submit() {
    final odometerKm = int.tryParse(_odometerController.text.trim());
    final tr = Localizations.localeOf(context).languageCode == 'tr';
    if (odometerKm == null || odometerKm < 0) {
      setState(
        () => _error = tInline(
          AppStrings.currentLanguageCode,
          'Geçerli bir kilometre değeri gir.',
          'Enter a valid odometer value.',
          'Geben Sie einen gültigen Kilometerstand ein.',
        ),
      );
      return;
    }

    HapticFeedback.selectionClick();
    widget.onSubmit(
      _ServiceEntry(
        type: _selectedType,
        label: _labelController.text,
        odometerKm: odometerKm,
        note: _noteController.text,
      ),
    );
    Navigator.of(context).pop();
  }
}

class _PartStatusEntry {
  const _PartStatusEntry({
    required this.chainWearPercent,
    required this.tireWearPercent,
    required this.brakeWearPercent,
    required this.oilHealthPercent,
    required this.batteryHealthPercent,
  });

  final int chainWearPercent;
  final int tireWearPercent;
  final int brakeWearPercent;
  final int oilHealthPercent;
  final int batteryHealthPercent;
}

class _ApexTextField extends StatelessWidget {
  const _ApexTextField({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.maxLines = 1,
    this.helperText,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? helperText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      cursorColor: context.colors.cyan,
      style: TextStyle(color: context.colors.white, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        labelStyle: TextStyle(
          color: context.colors.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
        filled: true,
        fillColor: context.colors.elevated,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ApexSpacing.radius),
          borderSide: BorderSide(color: context.colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ApexSpacing.radius),
          borderSide: BorderSide(color: context.colors.cyan),
        ),
      ),
    );
  }
}

class _QuickFillChip extends StatelessWidget {
  const _QuickFillChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: onTap,
      avatar: Icon(Icons.bolt_outlined, size: 14, color: context.colors.cyan),
      label: Text(label),
      labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
      side: BorderSide(color: context.colors.border),
      backgroundColor: context.colors.elevated,
    );
  }
}

class _StatusSlider extends StatelessWidget {
  const _StatusSlider({
    required this.title,
    required this.hint,
    required this.value,
    required this.onChanged,
    required this.isHealth,
  });

  final String title;
  final String hint;
  final double value;
  final ValueChanged<double> onChanged;
  final bool isHealth; // If true, 100% is green. If false (wear), 100% is red.

  @override
  Widget build(BuildContext context) {
    Color getTrackColor() {
      if (isHealth) {
        if (value >= 70) return context.colors.healthy;
        if (value >= 35) return context.colors.orange;
        return context.colors.red;
      } else {
        if (value <= 30) return context.colors.healthy;
        if (value <= 65) return context.colors.orange;
        return context.colors.red;
      }
    }

    final color = getTrackColor();

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: ApexSpacing.x1),
      decoration: BoxDecoration(
        color: context.colors.elevated,
        borderRadius: BorderRadius.circular(ApexSpacing.radius),
        border: Border.all(color: context.colors.border.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hint,
                      style: TextStyle(
                        color: context.colors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withValues(alpha: 0.5)),
                ),
                child: Text(
                  '${value.toInt()}%',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: color,
              inactiveTrackColor: context.colors.rail,
              thumbColor: color,
              overlayColor: color.withValues(alpha: 0.2),
              trackHeight: 12,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
              tickMarkShape: SliderTickMarkShape.noTickMark,
            ),
            child: Slider(
              value: value,
              min: 0,
              max: 100,
              divisions: 100,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _MachineHealthGrid extends StatelessWidget {
  const _MachineHealthGrid({
    required this.statuses,
    required this.bike,
    required this.strings,
    this.onOpenPartStatus,
  });

  final List<GarageComponentStatus> statuses;
  final MotorcycleProfile bike;
  final AppStrings strings;
  final VoidCallback? onOpenPartStatus;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              tInline(
                AppStrings.currentLanguageCode,
                'Makine Sağlığı',
                'Machine Health',
                'Maschinengesundheit',
              ),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onOpenPartStatus?.call();
              },
              child: Text(
                tInline(
                  AppStrings.currentLanguageCode,
                  'Tümünü Gör >',
                  'See All >',
                  'Alle sehen >',
                ),
                style: TextStyle(
                  color: context.colors.cyan,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.1,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: statuses.length,
          itemBuilder: (context, index) {
            final status = statuses[index];
            return _ComponentGridCell(
              status: status,
              bike: bike,
              strings: strings,
            );
          },
        ),
      ],
    );
  }
}

class _ComponentGridCell extends StatelessWidget {
  const _ComponentGridCell({
    required this.status,
    required this.bike,
    required this.strings,
  });

  final GarageComponentStatus status;
  final MotorcycleProfile bike;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final copy = _resolveCopy();
    final healthColor = _statusColor(context, copy.progress, status.value);

    return InkWell(
      onTap: () => _showComponentDetails(context, copy, healthColor),
      borderRadius: BorderRadius.circular(ApexSpacing.radius),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: SlatePalette.surfaceDeep.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(ApexSpacing.radius),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: healthColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(4),
              ),
              child: CustomPaint(
                painter: ComponentVectorPainter(
                  component: status.label.toLowerCase(),
                  color: healthColor,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    strings.garageComponentLabel(status.label),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: healthColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          copy.headline,
                          style: TextStyle(
                            color: context.colors.textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            _ComponentMiniRail(value: copy.progress, color: healthColor),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, color: context.colors.muted, size: 14),
          ],
        ),
      ),
    );
  }

  Color _statusColor(BuildContext context, double progress, String value) {
    if (value == '—') {
      return context.colors.border.withValues(alpha: 0.5);
    }
    if (progress >= 0.75) {
      return context.colors.healthy;
    }
    if (progress >= 0.45) {
      return context.colors.caution;
    }
    return context.colors.red;
  }

  _ComponentCopy _resolveCopy() {
    return switch (status.label) {
      'Chain' => _wearCopy(
        wearPercent: bike.chainWearPercent,
        component: 'chain',
        freshKey: 'fresh',
        stableKey: 'stable',
        watchKey: 'watch',
        actionKey: 'service_soon',
      ),
      'Tires' => _wearCopy(
        wearPercent: bike.tireWearPercent,
        component: 'tire',
        freshKey: 'fresh_tread',
        stableKey: 'balanced',
        watchKey: 'watch_tread',
        actionKey: 'replace_soon',
      ),
      'Brakes' => _wearCopy(
        wearPercent: bike.brakeWearPercent,
        component: 'brake',
        freshKey: 'fresh',
        stableKey: 'stable',
        watchKey: 'watch',
        actionKey: 'service_soon',
      ),
      'Oil' => _healthCopy(
        healthPercent: bike.oilHealthPercent,
        component: 'oil',
        strongKey: 'fresh_service',
        stableKey: 'mid_interval',
        watchKey: 'due_soon',
        actionKey: 'change_now',
      ),
      'Battery' => _healthCopy(
        healthPercent: bike.batteryHealthPercent,
        component: 'battery',
        strongKey: 'instant_start',
        stableKey: 'routine_use',
        watchKey: 'monitor',
        actionKey: 'charge_check',
      ),
      'Service' => _serviceCopy(),
      _ => _ComponentCopy(
        headline: status.value,
        signal: status.signal,
        progress: 0.5,
      ),
    };
  }

  _ComponentCopy _wearCopy({
    required int wearPercent,
    required String component,
    required String freshKey,
    required String stableKey,
    required String watchKey,
    required String actionKey,
  }) {
    if (wearPercent == -1) {
      return _ComponentCopy(
        headline: tInline(
          AppStrings.currentLanguageCode,
          'Seçilmedi',
          'Not selected',
          'Nicht ausgewählt',
        ),
        signal: tInline(
          AppStrings.currentLanguageCode,
          'Lütfen seçiniz',
          'Please select',
          'Bitte auswählen',
        ),
        progress: 0.0,
      );
    }
    final stateKey = wearPercent >= 70
        ? actionKey
        : wearPercent >= 45
        ? watchKey
        : wearPercent >= 20
        ? stableKey
        : freshKey;

    return _ComponentCopy(
      headline: strings.garageConditionLabel(stateKey),
      signal: strings.garageConditionSignal(component, stateKey),
      progress: (100 - wearPercent) / 100.0,
    );
  }

  _ComponentCopy _healthCopy({
    required int healthPercent,
    required String component,
    required String strongKey,
    required String stableKey,
    required String watchKey,
    required String actionKey,
  }) {
    if (healthPercent == -1) {
      return _ComponentCopy(
        headline: tInline(
          AppStrings.currentLanguageCode,
          'Seçilmedi',
          'Not selected',
          'Nicht ausgewählt',
        ),
        signal: tInline(
          AppStrings.currentLanguageCode,
          'Lütfen seçiniz',
          'Please select',
          'Bitte auswählen',
        ),
        progress: 0.0,
      );
    }
    final stateKey = healthPercent >= 80
        ? strongKey
        : healthPercent >= 50
        ? stableKey
        : healthPercent >= 20
        ? watchKey
        : actionKey;

    return _ComponentCopy(
      headline: strings.garageConditionLabel(stateKey),
      signal: strings.garageConditionSignal(component, stateKey),
      progress: healthPercent / 100.0,
    );
  }

  _ComponentCopy _serviceCopy() {
    final state = bike.serviceWindowState;
    final tr = strings.locale.languageCode == 'tr';
    final de = strings.locale.languageCode == 'de';
    final progress = bike.serviceProgress.clamp(0.0, 1.0);

    return switch (state) {
      ServiceWindowState.stable => _ComponentCopy(
        headline: tr ? 'Ritminde' : (de ? 'Im Rhythmus' : 'Stable'),
        signal: tr
            ? 'Servis zamanına daha var.'
            : (de
                  ? 'Wartung noch nicht erforderlich.'
                  : 'Service not required yet.'),
        progress: 1.0 - progress,
      ),
      ServiceWindowState.dueSoon => _ComponentCopy(
        headline: tr ? 'Bakım Yakın' : (de ? 'Wartung bald' : 'Due Soon'),
        signal: tr
            ? 'Yakında rutin bakım gerekli.'
            : (de
                  ? 'Routinewartung bald erforderlich.'
                  : 'Routine service required soon.'),
        progress: 1.0 - progress,
      ),
      ServiceWindowState.overdue => _ComponentCopy(
        headline: tr ? 'Gecikti' : (de ? 'Überfällig' : 'Overdue'),
        signal: tr
            ? 'Acil bakım gerekiyor.'
            : (de
                  ? 'Sofortige Wartung erforderlich.'
                  : 'Immediate service required.'),
        progress: 0.0,
      ),
    };
  }

  void _showComponentDetails(
    BuildContext context,
    _ComponentCopy copy,
    Color healthColor,
  ) {
    HapticFeedback.selectionClick();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.colors.surface,
      barrierColor: context.colors.background.withValues(alpha: 0.72),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            MediaQuery.viewInsetsOf(context).bottom + 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: healthColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: healthColor.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Center(
                      child: CustomPaint(
                        size: const Size(24, 24),
                        painter: ComponentVectorPainter(
                          component: status.label.toLowerCase(),
                          color: healthColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          strings.garageComponentLabel(status.label),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          copy.headline,
                          style: TextStyle(
                            fontSize: 13,
                            color: healthColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                strings.locale.languageCode == 'tr'
                    ? 'Bileşen Durumu'
                    : (strings.locale.languageCode == 'de'
                          ? 'Komponenten-Zustand'
                          : 'Component Status'),
                style: TextStyle(
                  fontSize: 12,
                  color: context.colors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.colors.elevated,
                  borderRadius: BorderRadius.circular(ApexSpacing.radius),
                  border: Border.all(color: context.colors.border),
                ),
                child: Text(
                  copy.signal,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: context.colors.border,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ApexSpacing.radius),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    strings.locale.languageCode == 'tr'
                        ? 'Tamam'
                        : (strings.locale.languageCode == 'de'
                              ? 'Schließen'
                              : 'Close'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ComponentMiniRail extends StatelessWidget {
  const _ComponentMiniRail({required this.value, required this.color});
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 18,
      height: 4,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: LinearProgressIndicator(
          value: value,
          backgroundColor: Colors.white.withValues(alpha: 0.1),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ),
    );
  }
}

class _SystemMenuGrid extends StatelessWidget {
  const _SystemMenuGrid({
    required this.strings,
    required this.onOpenMemory,
    required this.onOpenPassport,
    required this.onCertifiedLedger,
    required this.onParkAlert,
  });

  final AppStrings strings;
  final VoidCallback onOpenMemory;
  final VoidCallback onOpenPassport;
  final VoidCallback onCertifiedLedger;
  final VoidCallback onParkAlert;

  @override
  Widget build(BuildContext context) {
    final tr = strings.locale.languageCode == 'tr';
    final de = strings.locale.languageCode == 'de';
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 2.4,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      children: [
        _SystemMenuItem(
          label: tr
              ? 'Makine Hafızası'
              : (de ? 'Maschinenspeicher' : 'Machine Memory'),
          icon: Icons.timeline_outlined,
          onTap: onOpenMemory,
        ),
        _SystemMenuItem(
          label: tr
              ? 'Garaj Pasaportu'
              : (de ? 'Garagen-Pass' : 'Garage Passport'),
          icon: Icons.badge_outlined,
          onTap: onOpenPassport,
        ),
        _SystemMenuItem(
          label: tr
              ? 'Onaylı Sicil'
              : (de ? 'Zertifiziertes Register' : 'Certified Ledger'),
          icon: Icons.verified_outlined,
          onTap: onCertifiedLedger,
        ),
        _SystemMenuItem(
          label: tr ? 'Park Uyarısı' : (de ? 'Park-Alarm' : 'Park Alert'),
          icon: Icons.notifications_active_outlined,
          onTap: onParkAlert,
        ),
      ],
    );
  }
}

class _SystemMenuItem extends StatelessWidget {
  const _SystemMenuItem({
    required this.label,
    required this.icon,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(ApexSpacing.radius),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: SlatePalette.surfaceDeep.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(ApexSpacing.radius),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 2),
            const Icon(Icons.chevron_right, color: Colors.white30, size: 14),
          ],
        ),
      ),
    );
  }
}

class ComponentVectorPainter extends CustomPainter {
  final String component;
  final Color color;

  ComponentVectorPainter({required this.component, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;

    switch (component) {
      case 'chain':
        canvas.drawCircle(Offset(cx - 10, cy), 3, paint);
        canvas.drawCircle(Offset(cx + 10, cy), 3, paint);
        final path = Path()
          ..moveTo(cx - 10, cy - 5)
          ..lineTo(cx + 10, cy - 5)
          ..arcToPoint(
            Offset(cx + 10, cy + 5),
            radius: const Radius.circular(5),
          )
          ..lineTo(cx - 10, cy + 5)
          ..arcToPoint(
            Offset(cx - 10, cy - 5),
            radius: const Radius.circular(5),
          )
          ..close();
        canvas.drawPath(path, paint);
        canvas.drawPath(path, fillPaint);
        break;
      case 'tires':
        final tirePath = Path()
          ..moveTo(cx - 12, cy + 10)
          ..quadraticBezierTo(cx - 12, cy - 10, cx, cy - 10)
          ..quadraticBezierTo(cx + 12, cy - 10, cx + 12, cy + 10);
        canvas.drawPath(tirePath, paint);
        canvas.drawPath(tirePath, fillPaint);

        canvas.drawLine(Offset(cx - 7, cy - 3), Offset(cx - 3, cy + 1), paint);
        canvas.drawLine(Offset(cx + 7, cy - 3), Offset(cx + 3, cy + 1), paint);
        canvas.drawLine(Offset(cx - 5, cy + 3), Offset(cx - 1, cy + 7), paint);
        canvas.drawLine(Offset(cx + 5, cy + 3), Offset(cx + 1, cy + 7), paint);
        break;
      case 'brakes':
        canvas.drawCircle(Offset(cx, cy), 13, paint);
        canvas.drawCircle(Offset(cx, cy), 5, paint);
        final caliperPath = Path()
          ..moveTo(cx + 3, cy - 13)
          ..lineTo(cx + 13, cy - 3)
          ..lineTo(cx + 10, cy)
          ..lineTo(cx, cy - 10)
          ..close();
        canvas.drawPath(caliperPath, paint);
        canvas.drawPath(caliperPath, fillPaint);
        final dotPaint = Paint()
          ..color = color
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(cx - 7, cy), 1.0, dotPaint);
        canvas.drawCircle(Offset(cx + 7, cy), 1.0, dotPaint);
        canvas.drawCircle(Offset(cx, cy - 7), 1.0, dotPaint);
        canvas.drawCircle(Offset(cx, cy + 7), 1.0, dotPaint);
        break;
      case 'oil':
        final dropPath = Path()
          ..moveTo(cx, cy - 13)
          ..cubicTo(cx - 11, cy - 2, cx - 11, cy + 11, cx, cy + 11)
          ..cubicTo(cx + 11, cy + 11, cx + 11, cy - 2, cx, cy - 13)
          ..close();
        canvas.drawPath(dropPath, paint);
        canvas.drawPath(dropPath, fillPaint);
        final wavePath = Path()
          ..moveTo(cx - 7, cy + 3)
          ..quadraticBezierTo(cx - 3, cy + 1, cx, cy + 3)
          ..quadraticBezierTo(cx + 3, cy + 5, cx + 7, cy + 3)
          ..lineTo(cx + 7, cy + 9)
          ..quadraticBezierTo(cx, cy + 10, cx - 7, cy + 9)
          ..close();
        canvas.drawPath(wavePath, paint);
        break;
      case 'battery':
        final bodyRect = Rect.fromCenter(
          center: Offset(cx, cy + 1),
          width: 22,
          height: 16,
        );
        canvas.drawRect(bodyRect, paint);
        canvas.drawRect(bodyRect, fillPaint);
        final term1 = Rect.fromLTWH(cx - 9, cy - 9, 3, 2);
        final term2 = Rect.fromLTWH(cx + 6, cy - 9, 3, 2);
        canvas.drawRect(term1, paint);
        canvas.drawRect(term2, paint);
        canvas.drawLine(Offset(cx - 7, cy + 1), Offset(cx - 3, cy + 1), paint);
        canvas.drawLine(Offset(cx + 3, cy + 1), Offset(cx + 7, cy + 1), paint);
        canvas.drawLine(Offset(cx + 5, cy - 1), Offset(cx + 5, cy + 3), paint);
        break;
      default:
        canvas.drawCircle(Offset(cx, cy), 7, paint);
        for (int i = 0; i < 8; i++) {
          final double angle = i * math.pi / 4;
          final double sx = cx + 7 * math.cos(angle);
          final double sy = cy + 7 * math.sin(angle);
          final double ex = cx + 10 * math.cos(angle);
          final double ey = cy + 10 * math.sin(angle);
          canvas.drawLine(Offset(sx, sy), Offset(ex, ey), paint);
        }
        canvas.drawCircle(Offset(cx, cy), 2.5, paint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant ComponentVectorPainter oldDelegate) {
    return oldDelegate.component != component || oldDelegate.color != color;
  }
}

class _ComponentCopy {
  const _ComponentCopy({
    required this.headline,
    required this.signal,
    required this.progress,
  });

  final String headline;
  final String signal;
  final double progress;
}

class _ComponentRail extends StatelessWidget {
  const _ComponentRail({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(99),
      child: LinearProgressIndicator(
        value: value,
        minHeight: 5,
        backgroundColor: context.colors.rail,
        valueColor: AlwaysStoppedAnimation<Color>(_railColor(context, value)),
      ),
    );
  }

  Color _railColor(BuildContext context, double progress) {
    if (progress >= 0.75) {
      return context.colors.healthy;
    }
    if (progress >= 0.45) {
      return context.colors.caution;
    }
    return context.colors.red;
  }
}

class _ServiceTimeline extends ConsumerWidget {
  const _ServiceTimeline({required this.records, required this.strings});

  final List<ServiceRecord> records;
  final AppStrings strings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = strings.locale.languageCode == 'tr';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              tr ? 'Servis Hafızası' : 'Service memory',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: SlatePalette.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${records.length}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (records.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: SlatePalette.surfaceDeep.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(ApexSpacing.radius),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Text(
              tInline(
                AppStrings.currentLanguageCode,
                'Henüz servis kaydı yok. İlk kaydı Garaj komutlarından ekleyebilirsin.',
                'No service history yet. Add your first entry from quick actions.',
                'Noch kein Servicespeicher. Fügen Sie Ihren ersten Eintrag über Schnellaktionen hinzu.',
              ),
              style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: 13,
                height: 1.35,
              ),
            ),
          )
        else ...[
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: math.min(2, records.length),
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final record = records[index];
              return Dismissible(
                key: ValueKey(record.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: context.colors.red,
                    borderRadius: BorderRadius.circular(ApexSpacing.radius),
                  ),
                  child: const Icon(Icons.delete_outline, color: Colors.white),
                ),
                onDismissed: (_) {
                  ref
                      .read(garageStateProvider.notifier)
                      .deleteServiceRecord(record.id);
                },
                child: _ServiceCard(record: record, strings: strings),
              );
            },
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: () {
                HapticFeedback.selectionClick();
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => MachineMemoryScreen(strings: strings),
                  ),
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    tr ? 'Tüm kayıtları görüntüle' : 'View all records',
                    style: TextStyle(
                      color: context.colors.cyan,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right,
                    color: context.colors.cyan,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ServiceCard extends ConsumerWidget {
  const _ServiceCard({required this.record, required this.strings});
  final ServiceRecord record;
  final AppStrings strings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = strings.locale.languageCode == 'tr';
    final de = strings.locale.languageCode == 'de';
    String formattedStatus = record.status;
    if (tr) {
      formattedStatus = switch (record.status.toLowerCase()) {
        'active interval' => 'Aktif Aralık',
        'stable' => 'Stabil',
        'watch' => 'Takipte',
        'new log' => 'Yeni kayıt',
        _ => record.status,
      };
    } else if (de) {
      formattedStatus = switch (record.status.toLowerCase()) {
        'active interval' => 'Aktiver Intervall',
        'stable' => 'Im Rhythmus',
        'watch' => 'Beobachtung',
        'new log' => 'Neuer Eintrag',
        _ => record.status,
      };
    } else {
      if (record.status.toLowerCase() == 'new log') {
        formattedStatus = 'New Log';
      }
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SlatePalette.surfaceDeep.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(ApexSpacing.radius),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: context.colors.healthy,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${record.odometerKm} km • ${record.note.isEmpty ? (tr ? 'Ek mekanik not bulunmuyor.' : 'No additional mechanical notes.') : record.note}',
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              final state = ref.read(garageStateProvider);
              showModalBottomSheet<void>(
                context: context,
                backgroundColor: context.colors.surface,
                barrierColor: context.colors.background.withValues(alpha: 0.72),
                isScrollControlled: true,
                builder: (_) {
                  return _ServiceEntrySheet(
                    strings: strings,
                    initialOdometerKm: state.activeBike.odometerKm,
                    lastServiceLabel: null,
                    initialRecord: record,
                    onSubmit: (entry) {
                      ref
                          .read(garageStateProvider.notifier)
                          .updateServiceRecord(
                            ServiceRecord(
                              id: record.id,
                              type: entry.type,
                              label: entry.label,
                              odometerKm: entry.odometerKm,
                              status: record.status,
                              note: entry.note,
                              loggedAtIso: record.loggedAtIso,
                            ),
                          );
                    },
                  );
                },
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  formattedStatus,
                  style: TextStyle(
                    color: context.colors.cyan,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 2),
                Icon(Icons.chevron_right, color: context.colors.cyan, size: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PanelTitle extends StatelessWidget {
  const _PanelTitle({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: context.colors.cyan,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _StatusTag extends StatelessWidget {
  const _StatusTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: context.colors.cyan.withValues(alpha: 0.62)),
        borderRadius: BorderRadius.circular(ApexSpacing.radius),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: context.colors.cyan,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _CostAnalyticsPanel extends StatefulWidget {
  const _CostAnalyticsPanel({required this.strings});

  final AppStrings strings;

  @override
  State<_CostAnalyticsPanel> createState() => _CostAnalyticsPanelState();
}

class _CostAnalyticsPanelState extends State<_CostAnalyticsPanel> {
  String _filterKey = '6m';

  @override
  Widget build(BuildContext context) {
    return _CostAnalyticsPanelInner(
      strings: widget.strings,
      filterKey: _filterKey,
      onFilterChanged: (val) {
        setState(() {
          _filterKey = val;
        });
      },
    );
  }
}

class _CostAnalyticsPanelInner extends ConsumerWidget {
  const _CostAnalyticsPanelInner({
    required this.strings,
    required this.filterKey,
    required this.onFilterChanged,
  });

  final AppStrings strings;
  final String filterKey;
  final ValueChanged<String> onFilterChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = strings.locale.languageCode == 'tr';
    final fuelState = ref.watch(fuelStateProvider);
    final garageState = ref.watch(garageStateProvider);

    final now = DateTime.now();
    final DateTime limitDate;
    final int graphMonths;

    switch (filterKey) {
      case '1m':
        limitDate = now.subtract(const Duration(days: 30));
        graphMonths = 1;
        break;
      case '3m':
        limitDate = now.subtract(const Duration(days: 90));
        graphMonths = 3;
        break;
      case '6m':
        limitDate = now.subtract(const Duration(days: 180));
        graphMonths = 6;
        break;
      case '12m':
        limitDate = now.subtract(const Duration(days: 365));
        graphMonths = 12;
        break;
      default:
        limitDate = now.subtract(const Duration(days: 180));
        graphMonths = 6;
    }

    final totalFuel = fuelState.entries
        .where((e) {
          final d = DateTime.parse(e.dateIso);
          return d.isAfter(limitDate) || d.isAtSameMomentAs(limitDate);
        })
        .fold<double>(0.0, (sum, e) => sum + e.totalTry);

    final totalService = garageState.serviceRecords
        .where((r) {
          final d = DateTime.parse(r.loggedAtIso);
          return d.isAfter(limitDate) || d.isAtSameMomentAs(limitDate);
        })
        .fold<double>(0.0, (sum, r) => sum + r.cost);

    final months = <String>[];
    final fuelCosts = <double>[];
    final serviceCosts = <double>[];

    for (int i = graphMonths - 1; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      final monthLabel = _getMonthLabel(date.month, tr);
      months.add(monthLabel);

      final monthFuel = fuelState.entries
          .where((e) {
            final d = DateTime.parse(e.dateIso);
            return d.year == date.year && d.month == date.month;
          })
          .fold<double>(0.0, (sum, e) => sum + e.totalTry);

      final monthService = garageState.serviceRecords
          .where((r) {
            final d = DateTime.parse(r.loggedAtIso);
            return d.year == date.year && d.month == date.month;
          })
          .fold<double>(0.0, (sum, r) => sum + r.cost);

      fuelCosts.add(monthFuel);
      serviceCosts.add(monthService);
    }

    final hasData =
        fuelCosts.any((c) => c > 0) || serviceCosts.any((c) => c > 0);

    final de = strings.locale.languageCode == 'de';
    String filterText = tr
        ? 'Son 6 Ay'
        : (de ? 'Letzte 6 Monate' : 'Last 6 Months');
    switch (filterKey) {
      case '1m':
        filterText = tr
            ? 'Son 1 Ay'
            : (de ? 'Letzter 1 Monat' : 'Last 1 Month');
        break;
      case '3m':
        filterText = tr
            ? 'Son 3 Ay'
            : (de ? 'Letzte 3 Monate' : 'Last 3 Months');
        break;
      case '6m':
        filterText = tr
            ? 'Son 6 Ay'
            : (de ? 'Letzte 6 Monate' : 'Last 6 Months');
        break;
      case '12m':
        filterText = tr
            ? 'Son 12 Ay'
            : (de ? 'Letzte 12 Monate' : 'Last 12 Months');
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              tr ? 'Giderler' : (de ? 'Ausgaben' : 'Expenses'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            PopupMenuButton<String>(
              initialValue: filterKey,
              onSelected: (String value) {
                HapticFeedback.selectionClick();
                onFilterChanged(value);
              },
              color: SlatePalette.surface,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: SlatePalette.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: context.colors.cyan.withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      filterText,
                      style: TextStyle(
                        color: context.colors.cyan,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: context.colors.cyan,
                      size: 16,
                    ),
                  ],
                ),
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: '1m',
                  child: Text(
                    tr ? 'Son 1 Ay' : (de ? 'Letzter 1 Monat' : 'Last 1 Month'),
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
                PopupMenuItem(
                  value: '3m',
                  child: Text(
                    tr
                        ? 'Son 3 Ay'
                        : (de ? 'Letzte 3 Monate' : 'Last 3 Months'),
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
                PopupMenuItem(
                  value: '6m',
                  child: Text(
                    tr
                        ? 'Son 6 Ay'
                        : (de ? 'Letzte 6 Monate' : 'Last 6 Months'),
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
                PopupMenuItem(
                  value: '12m',
                  child: Text(
                    tr
                        ? 'Son 12 Ay'
                        : (de ? 'Letzte 12 Monate' : 'Last 12 Months'),
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: SlatePalette.surfaceDeep.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(ApexSpacing.radius),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${totalFuel.toStringAsFixed(0)} TL',
                        style: const TextStyle(
                          color: Color(0xFFEA580C),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tr ? 'Yakıt' : 'Fuel',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${totalService.toStringAsFixed(0)} TL',
                        style: TextStyle(
                          color: context.colors.cyan,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tr ? 'Bakım' : 'Service',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: hasData
                        ? SizedBox(
                            height: 120,
                            child: CustomPaint(
                              painter: CostAnalyticsPainter(
                                cyanColor: context.colors.cyan,
                                months: months,
                                fuelCosts: fuelCosts,
                                serviceCosts: serviceCosts,
                              ),
                            ),
                          )
                        : Container(
                            height: 120,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: SlatePalette.surfaceDeep.withValues(
                                alpha: 0.3,
                              ),
                              borderRadius: BorderRadius.circular(
                                ApexSpacing.radius,
                              ),
                            ),
                            child: Text(
                              tr
                                  ? 'Grafik veri bekliyor'
                                  : (AppStrings.currentLanguageCode == 'de'
                                        ? 'Warten auf Daten'
                                        : 'Chart waiting for data'),
                              style: const TextStyle(
                                color: Colors.white30,
                                fontSize: 11,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _LegendItem(
                    color: const Color(0xFFEA580C),
                    label: tr
                        ? 'Yakıt'
                        : (AppStrings.currentLanguageCode == 'de'
                              ? 'Kraftstoff'
                              : 'Fuel'),
                  ),
                  const SizedBox(width: 16),
                  _LegendItem(
                    color: context.colors.cyan,
                    label: tr
                        ? 'Bakım'
                        : (AppStrings.currentLanguageCode == 'de'
                              ? 'Wartung'
                              : 'Service'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getMonthLabel(int m, bool tr) {
    if (tr) {
      final list = [
        'Oca',
        'Şub',
        'Mar',
        'Nis',
        'May',
        'Haz',
        'Tem',
        'Ağu',
        'Eyl',
        'Eki',
        'Kas',
        'Ara',
      ];
      return list[(m - 1) % 12];
    } else if (AppStrings.currentLanguageCode == 'de') {
      final list = [
        'Jan',
        'Feb',
        'Mär',
        'Apr',
        'Mai',
        'Jun',
        'Juli',
        'Aug',
        'Sep',
        'Okt',
        'Nov',
        'Dez',
      ];
      return list[(m - 1) % 12];
    } else {
      final list = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return list[(m - 1) % 12];
    }
  }
}

class _StatMiniPanel extends StatelessWidget {
  const _StatMiniPanel({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final bool isZero =
        value == '0 ₺' || value == '0' || value.startsWith('0 ');
    final displayValueColor = isZero ? const Color(0xFF64748B) : color;

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(
            0xFFE2E8F0,
          ), // Slate 200 (slightly darker than off-white)
          borderRadius: BorderRadius.circular(ApexSpacing.radius),
          border: Border.all(
            color: SlatePalette.surfaceDeep,
            width: 1.5,
          ), // Solid slate border
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 4,
              offset: const Offset(1, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 8.5,
                color: SlatePalette.surface, // Deep slate gray close to black
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color:
                    displayValueColor, // Muted gray for 0 TL, otherwise color
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.white70,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class CostAnalyticsPainter extends CustomPainter {
  final Color cyanColor;
  CostAnalyticsPainter({
    required this.cyanColor,
    required this.months,
    required this.fuelCosts,
    required this.serviceCosts,
  });

  final List<String> months;
  final List<double> fuelCosts;
  final List<double> serviceCosts;

  @override
  void paint(Canvas canvas, Size size) {
    final tr =
        months.isNotEmpty && months[0].toLowerCase().contains('o') ||
        months[0].toLowerCase().contains('ş') ||
        months[0].toLowerCase().contains('m'); // rough locale check
    final paintGrid = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..strokeWidth = 1.0;

    final double paddingLeft = 45.0;
    final double paddingRight = 10.0;
    final double paddingTop = 10.0;
    final double paddingBottom = 20.0;

    final double chartWidth = size.width - paddingLeft - paddingRight;
    final double chartHeight = size.height - paddingTop - paddingBottom;

    // Draw grid lines
    for (int i = 0; i <= 3; i++) {
      final double y = paddingTop + (chartHeight / 3) * i;
      canvas.drawLine(
        Offset(paddingLeft, y),
        Offset(size.width - paddingRight, y),
        paintGrid,
      );
    }

    final int monthsCount = months.length;
    double maxCost = 1000.0;
    for (int i = 0; i < monthsCount; i++) {
      final total = fuelCosts[i] + serviceCosts[i];
      if (total > maxCost) {
        maxCost = total;
      }
    }
    maxCost = (maxCost / 500).ceil() * 500.0;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Draw Y-axis labels
    for (int i = 0; i <= 3; i++) {
      final val = maxCost - (maxCost / 3) * i;
      final double y = paddingTop + (chartHeight / 3) * i;

      textPainter.text = TextSpan(
        text: '${val.toStringAsFixed(0)} ₺',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.5),
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(paddingLeft - textPainter.width - 6, y - textPainter.height / 2),
      );
    }

    final bool hasData =
        fuelCosts.any((c) => c > 0) || serviceCosts.any((c) => c > 0);

    if (!hasData) {
      // Empty state placeholder
      final placeholderPainter = TextPainter(
        text: TextSpan(
          text: tInline(
            AppStrings.currentLanguageCode,
            'Henüz Harcama Kaydı Bulunmuyor',
            'No Expense Records Yet',
            'Noch keine Spesenabrechnungen',
          ),
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 10.5,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      placeholderPainter.layout();

      final descPainter = TextPainter(
        text: TextSpan(
          text: tInline(
            AppStrings.currentLanguageCode,
            'Yakıt veya bakım eklediğinizde grafik güncellenir.',
            'Add fuel or service records to populate the chart.',
            'Fügen Sie Kraftstoff- oder Servicedatensätze hinzu, um das Diagramm zu füllen.',
          ),
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.35),
            fontSize: 8,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      descPainter.layout();

      placeholderPainter.paint(
        canvas,
        Offset(
          paddingLeft + (chartWidth - placeholderPainter.width) / 2,
          paddingTop + (chartHeight - placeholderPainter.height) / 2 - 6,
        ),
      );

      descPainter.paint(
        canvas,
        Offset(
          paddingLeft + (chartWidth - descPainter.width) / 2,
          paddingTop + (chartHeight - descPainter.height) / 2 + 10,
        ),
      );
    } else {
      final double colWidth = chartWidth / monthsCount;
      final double barWidth = colWidth * 0.45;

      for (int i = 0; i < monthsCount; i++) {
        final double centerX = paddingLeft + colWidth * i + colWidth / 2;

        final fuelVal = fuelCosts[i];
        final serviceVal = serviceCosts[i];

        final double fuelHeight = (fuelVal / maxCost) * chartHeight;
        final double serviceHeight = (serviceVal / maxCost) * chartHeight;

        if (serviceVal > 0) {
          final rectService = Rect.fromLTWH(
            centerX - barWidth / 2,
            paddingTop + chartHeight - serviceHeight,
            barWidth,
            serviceHeight,
          );
          final paintService = Paint()
            ..color = cyanColor.withValues(alpha: 0.9)
            ..style = PaintingStyle.fill;
          canvas.drawRect(rectService, paintService);
        }

        if (fuelVal > 0) {
          final rectFuel = Rect.fromLTWH(
            centerX - barWidth / 2,
            paddingTop + chartHeight - serviceHeight - fuelHeight,
            barWidth,
            fuelHeight,
          );
          final paintFuel = Paint()
            ..color = Colors.orange.withValues(alpha: 0.9)
            ..style = PaintingStyle.fill;
          canvas.drawRect(rectFuel, paintFuel);
        }
      }
    }

    // Always draw month labels on X-axis
    final double colWidth = chartWidth / monthsCount;
    for (int i = 0; i < monthsCount; i++) {
      final double centerX = paddingLeft + colWidth * i + colWidth / 2;
      textPainter.text = TextSpan(
        text: months[i],
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.85),
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          centerX - textPainter.width / 2,
          size.height - paddingBottom + 6,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CostAnalyticsPainter oldDelegate) {
    return oldDelegate.months != months ||
        oldDelegate.fuelCosts != fuelCosts ||
        oldDelegate.serviceCosts != serviceCosts;
  }
}

class _ParkedBikeAlertScreen extends ConsumerStatefulWidget {
  const _ParkedBikeAlertScreen({required this.strings, required this.bike});
  final AppStrings strings;
  final MotorcycleProfile bike;

  @override
  ConsumerState<_ParkedBikeAlertScreen> createState() =>
      _ParkedBikeAlertScreenState();
}

class _ParkedBikeAlertScreenState
    extends ConsumerState<_ParkedBikeAlertScreen> {
  @override
  Widget build(BuildContext context) {
    final tr = widget.strings.locale.languageCode == 'tr';
    final userProfile = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          tInline(
            AppStrings.currentLanguageCode,
            'Akıllı Park Uyarısı',
            'Smart Park Alert',
            'Smart-Park-Alarm',
          ),
        ),
      ),
      body: SafeArea(
        child: userProfile.isPremium
            ? ListView(
                padding: const EdgeInsets.all(ApexSpacing.x2),
                children: [
                  ApexPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.qr_code_2_outlined,
                              color: context.colors.cyan,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              tInline(
                                AppStrings.currentLanguageCode,
                                'AKILLI PARK STICKER',
                                'SMART PARK STICKER',
                                'SMART PARK-AUFKLEBER',
                              ),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: context.colors.cyan,
                              ),
                            ),
                          ],
                        ),
                        Divider(color: context.colors.border, height: 20),
                        Text(
                          tInline(
                            AppStrings.currentLanguageCode,
                            'Aşağıdaki QR kodu motorunuzun üzerine (örneğin kaskınıza veya çamurluğunuza) yapıştırın. Diğer sürücüler bunu tarattığında size anonim olarak acil durum uyarısı gönderebilir.',
                            'Stick the QR code below on your bike (e.g. helmet or mudguard). Other riders can scan it to send you anonymous emergency alerts.',
                            'Kleben Sie den untenstehenden QR-Code auf Ihr Fahrrad (z. B. Helm oder Schutzblech). Andere Fahrer können es scannen, um Ihnen anonyme Notfallwarnungen zu senden.',
                          ),
                          style: TextStyle(
                            color: context.colors.textSecondary,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: Container(
                            width: 200,
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFE2E8F0,
                              ), // Slate 200 (slightly darker than off-white)
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: SlatePalette.surfaceDeep,
                                width: 2,
                              ), // Slate 900
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(2, 4),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 20,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Mini Header
                                const Text(
                                  'A P E X   F L O W',
                                  style: TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.bold,
                                    color: SlatePalette.surfaceDeep,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  tInline(
                                    AppStrings.currentLanguageCode,
                                    'PARK İRTİBAT',
                                    'PARK CONTACT',
                                    'PARKKONTAKT',
                                  ),
                                  style: TextStyle(
                                    fontSize: 6,
                                    fontWeight: FontWeight.bold,
                                    color: context.colors.cyan,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 10),

                                // White QR code block
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(
                                      ApexSpacing.radius,
                                    ),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                      width: 1,
                                    ),
                                  ),
                                  child: QrImageView(
                                    data:
                                        'https://apex-flow-7baea.web.app/?id=${Uri.encodeComponent(userProfile.riderTag)}',
                                    size: 140,
                                    gapless: false,
                                    eyeStyle: const QrEyeStyle(
                                      eyeShape: QrEyeShape.square,
                                      color: Colors.black,
                                    ),
                                    dataModuleStyle: const QrDataModuleStyle(
                                      dataModuleShape: QrDataModuleShape.square,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),

                                // Rider Tag Pill Tag
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: SlatePalette.surfaceDeep,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    userProfile.riderTag,
                                    style: const TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFE2E8F0),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton.icon(
                            style: TextButton.styleFrom(
                              foregroundColor: context.colors.onAccent,
                              backgroundColor: context.colors.cyan,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () async {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => Center(
                                  child: CircularProgressIndicator(
                                    color: context.colors.cyan,
                                  ),
                                ),
                              );
                              try {
                                await ParkStickerPdf.generateAndShare(
                                  riderTag: userProfile.riderTag,
                                  bikeModel:
                                      '${widget.bike.name} ${widget.bike.model}',
                                  isTurkish: tr,
                                );
                              } finally {
                                if (context.mounted) {
                                  Navigator.pop(context);
                                }
                              }
                            },
                            icon: const Icon(
                              Icons.picture_as_pdf_outlined,
                              size: 18,
                            ),
                            label: Text(
                              tInline(
                                AppStrings.currentLanguageCode,
                                'Sticker PDF\'i İndir / Paylaş',
                                'Download / Share Sticker PDF',
                                'Aufkleber-PDF herunterladen/teilen',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lock_outline,
                        size: 64,
                        color: context.colors.cyan,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        tInline(
                          AppStrings.currentLanguageCode,
                          'Premium Özellik',
                          'Premium Feature',
                          'Premium-Funktion',
                        ),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        tInline(
                          AppStrings.currentLanguageCode,
                          'Akıllı Park QR Stickerı & Anonim Acil Bildirim özelliğini kullanmak için Premium pakete geçin.',
                          'Upgrade to Premium to use the Smart Park QR Sticker & Anonymous Alert feature.',
                          'Führen Sie ein Upgrade auf Premium durch, um die Funktion „Smart Park QR Sticker & Anonymous Alert“ zu nutzen.',
                        ),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: context.colors.textSecondary),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: context.colors.onAccent,
                            backgroundColor: context.colors.cyan,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (context) => PremiumPaywallScreen(
                                  strings: widget.strings,
                                ),
                              ),
                            );
                          },
                          child: Text(
                            tInline(
                              AppStrings.currentLanguageCode,
                              'Premium Satın Al',
                              'Buy Premium',
                              'Premium kaufen',
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

  Widget _buildSimulatorButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ApexSpacing.radius),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.colors.elevated,
          borderRadius: BorderRadius.circular(ApexSpacing.radius),
          border: Border.all(color: context.colors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 12),
          ],
        ),
      ),
    );
  }

  void _triggerMockAlert(String message) {
    HapticFeedback.heavyImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.notifications_active, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

void showServiceEntrySheet(
  BuildContext context,
  WidgetRef ref,
  GarageState state,
  AppStrings strings, {
  ServiceRecord? initialRecord,
}) {
  HapticFeedback.selectionClick();
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: context.colors.surface,
    barrierColor: context.colors.background.withValues(alpha: 0.72),
    isScrollControlled: true,
    builder: (context) {
      return _ServiceEntrySheet(
        strings: strings,
        initialOdometerKm: state.activeBike.odometerKm,
        lastServiceLabel: state.serviceRecords.isEmpty
            ? null
            : state.serviceRecords.first.label,
        initialRecord: initialRecord,
        onSubmit: (entry) {
          if (initialRecord != null) {
            ref
                .read(garageStateProvider.notifier)
                .updateServiceRecord(
                  ServiceRecord(
                    id: initialRecord.id,
                    type: entry.type,
                    label: entry.label,
                    odometerKm: entry.odometerKm,
                    status: initialRecord.status,
                    note: entry.note,
                    loggedAtIso: initialRecord.loggedAtIso,
                  ),
                );
          } else {
            ref
                .read(garageStateProvider.notifier)
                .addServiceRecord(
                  type: entry.type,
                  label: entry.label,
                  odometerKm: entry.odometerKm,
                  note: entry.note,
                );
          }
        },
      );
    },
  );
}
