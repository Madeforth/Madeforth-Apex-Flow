import 'package:apexflow/core/design/apex_spacing.dart';
import 'package:apexflow/core/i18n/app_strings.dart';
import 'package:apexflow/core/services/purchases_service.dart';
import 'package:apexflow/settings/application/user_profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apexflow/core/design/theme_extensions.dart';

class PremiumPaywallScreen extends ConsumerStatefulWidget {
  const PremiumPaywallScreen({super.key, required this.strings});

  final AppStrings strings;

  @override
  ConsumerState<PremiumPaywallScreen> createState() =>
      _PremiumPaywallScreenState();
}

class _PremiumPaywallScreenState extends ConsumerState<PremiumPaywallScreen> {
  static const double _cardRadius = 18;

  bool _isLoading = false;
  String _selectedPlan = 'yearly'; // 'monthly', 'yearly', 'lifetime'

  Future<void> _executePurchase() async {
    setState(() {
      _isLoading = true;
    });

    final offering = await PurchasesService.instance.getCurrentOffering();
    final package = _selectedPlan == 'monthly'
        ? offering?.monthly
        : offering?.annual;

    if (package == null) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tInline(
              widget.strings.languageCode,
              'Mağaza fiyatları şu anda yüklenemedi. Lütfen tekrar deneyin.',
              'Store pricing could not be loaded right now. Please try again.',
              'Store-Preise konnten gerade nicht geladen werden. Bitte versuchen Sie es erneut.',
            ),
          ),
          backgroundColor: context.colors.caution,
        ),
      );
      return;
    }

    final customerInfo = await PurchasesService.instance.purchasePackage(
      package,
    );
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });

    final unlocked =
        customerInfo?.entitlements.active.containsKey(
          PurchasesEntitlements.premium,
        ) ??
        false;

    if (!unlocked) {
      // Purchase failed or was cancelled by the user — no local state change.
      return;
    }

    await ref.read(userProfileProvider.notifier).updatePremiumStatus(true);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          tInline(
            widget.strings.languageCode,
            'Premium üyeliğiniz başlatıldı. 👑',
            'Premium membership started. 👑',
            'Premium-Mitgliedschaft gestartet. 👑',
          ),
        ),
        backgroundColor: context.colors.cyan,
      ),
    );
    if (Navigator.canPop(context)) Navigator.pop(context);
  }

  Future<void> _restorePurchases() async {
    setState(() {
      _isLoading = true;
    });

    final customerInfo = await PurchasesService.instance.restorePurchases();
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });

    final unlocked =
        customerInfo?.entitlements.active.containsKey(
          PurchasesEntitlements.premium,
        ) ??
        false;

    if (!unlocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tInline(
              widget.strings.languageCode,
              'Bu hesaba bağlı, geri yüklenecek bir satın alma bulunamadı.',
              'No purchases were found to restore for this account.',
              'Für dieses Konto wurden keine wiederherstellbaren Käufe gefunden.',
            ),
          ),
          backgroundColor: context.colors.caution,
        ),
      );
      return;
    }

    await ref.read(userProfileProvider.notifier).updatePremiumStatus(true);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          tInline(
            widget.strings.languageCode,
            'Premium üyeliğiniz geri yüklendi. 👑',
            'Your Premium membership has been restored. 👑',
            'Ihre Premium-Mitgliedschaft wurde wiederhergestellt. 👑',
          ),
        ),
        backgroundColor: context.colors.cyan,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tr = widget.strings.locale.languageCode == 'tr';
    final profile = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: context.colors.white),
          onPressed: () {
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(color: context.colors.cyan),
              )
            : ListView(
                padding: EdgeInsets.fromLTRB(
                  ApexSpacing.x2,
                  ApexSpacing.x1,
                  ApexSpacing.x2,
                  ApexSpacing.x1 + MediaQuery.of(context).padding.bottom,
                ),
                children: [
                  // Minimalist premium logo badge
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: context.colors.surface,
                        borderRadius: BorderRadius.circular(_cardRadius),
                        border: Border.all(
                          color: context.colors.caution,
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.workspace_premium_outlined,
                            color: context.colors.caution,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            tInline(
                              widget.strings.languageCode,
                              'APEXFLOW MOTOR SPORLARI',
                              'APEXFLOW MOTORSPORTS',
                              'APEXFLOW MOTORSPORT',
                            ),
                            style: TextStyle(
                              color: context.colors.caution,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: ApexSpacing.x2),

                  Center(
                    child: Text(
                      tInline(
                        widget.strings.languageCode,
                        'PREMIUM SÜRÜŞ SİSTEMİ',
                        'PREMIUM RIDING SYSTEM',
                        'PREMIUM-FAHRSYSTEM',
                      ),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: context.colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      tInline(
                        widget.strings.languageCode,
                        'Yolların kontrolünü eline alın, sosyal sürüş ağını keşfedin.',
                        'Take control of the roads, discover the social ride network.',
                        'Übernehmen Sie die Kontrolle über die Straßen und entdecken Sie das soziale Fahrnetzwerk.',
                      ),
                      style: TextStyle(
                        color: context.colors.textSecondary,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: ApexSpacing.x3),

                  // Premium Features List
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.colors.surface,
                      borderRadius: BorderRadius.circular(_cardRadius),
                      border: Border.all(
                        color: context.colors.border,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildFeatureRow(
                          icon: Icons.person_add_alt_1_outlined,
                          title: tInline(
                            widget.strings.languageCode,
                            'Sınırsız Arkadaş Ekleme',
                            'Add Unlimited Friends',
                            'Fügen Sie unbegrenzt viele Freunde hinzu',
                          ),
                          subtitle: tInline(
                            widget.strings.languageCode,
                            'Diğer motorcuları ekleyin, sürüş geçmişlerini ve aktif durumlarını görün.',
                            'Connect with other riders, check their ride history & active status.',
                            'Vernetzen Sie sich mit anderen Fahrern, überprüfen Sie deren Fahrverlauf und aktiven Status.',
                          ),
                          tr: tr,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(
                            color: context.colors.border,
                            height: 1,
                          ),
                        ),
                        _buildFeatureRow(
                          icon: Icons.alternate_email_outlined,
                          title: tInline(
                            widget.strings.languageCode,
                            'Özel Rider Tag Seçimi',
                            'Custom Rider Tag',
                            'Benutzerdefiniertes Fahrer-Tag',
                          ),
                          subtitle: tInline(
                            widget.strings.languageCode,
                            'Benzersiz bir @kullanici_adi belirleyerek arkadaşlarınızın sizi kolayca bulmasını sağlayın.',
                            'Define a unique @username tag so friends can easily locate your profile.',
                            'Definieren Sie ein eindeutiges @username-Tag, damit Freunde Ihr Profil leicht finden können.',
                          ),
                          tr: tr,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(
                            color: context.colors.border,
                            height: 1,
                          ),
                        ),
                        _buildFeatureRow(
                          icon: Icons.badge_outlined,
                          title: tInline(
                            widget.strings.languageCode,
                            'Acil Durum Kartı & Kan Grubu',
                            'Emergency Contact ID Card',
                            'Notfallkontakt-ID-Karte',
                          ),
                          subtitle: tInline(
                            widget.strings.languageCode,
                            'Kan grubunuzu ve acil durum yakını detaylarınızı ID kartınızda güvenle paylaşın.',
                            'Share your blood type & emergency contact details on your digital ID card.',
                            'Teilen Sie Ihre Blutgruppe und Notfallkontaktdaten auf Ihrem digitalen Personalausweis mit.',
                          ),
                          tr: tr,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(
                            color: context.colors.border,
                            height: 1,
                          ),
                        ),
                        _buildFeatureRow(
                          icon: Icons.description_outlined,
                          title: tInline(
                            widget.strings.languageCode,
                            'Dijital Kaza Tutanağı',
                            'Digital Accident Report',
                            'Digitaler Unfallbericht',
                          ),
                          subtitle: tInline(
                            widget.strings.languageCode,
                            'Resmi kaza tutanağını kolayca hazırlayın ve anında hazır PDF çıktısı alın.',
                            'Easily prepare official accident reports and immediately export ready-to-use PDF documents.',
                            'Erstellen Sie ganz einfach offizielle Unfallberichte und exportieren Sie sofort gebrauchsfertige PDF-Dokumente.',
                          ),
                          tr: tr,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: ApexSpacing.x3),

                  if (profile.isPremium) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: context.colors.cyan.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(_cardRadius),
                        border: Border.all(
                          color: context.colors.cyan.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          tInline(
                            widget.strings.languageCode,
                            'Zaten Apex Flow Premium Üyesisiniz! 👑',
                            'You are already an Apex Flow Premium Member! 👑',
                            'Sie sind bereits Apex Flow Premium-Mitglied! 👑',
                          ),
                          style: TextStyle(
                            color: context.colors.cyan,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    // Side-by-side equal height plan cards: Monthly vs Yearly
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Monthly Plan Card
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedPlan = 'monthly';
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _selectedPlan == 'monthly'
                                      ? context.colors.cyan.withValues(
                                          alpha: 0.12,
                                        )
                                      : context.colors.surface,
                                  borderRadius: BorderRadius.circular(
                                    _cardRadius,
                                  ),
                                  border: Border.all(
                                    color: _selectedPlan == 'monthly'
                                        ? context.colors.cyan
                                        : context.colors.border,
                                    width: _selectedPlan == 'monthly' ? 2 : 1,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      tInline(
                                        widget.strings.languageCode,
                                        'AYLIK',
                                        'MONTHLY',
                                        'MONATLICH',
                                      ),
                                      style: TextStyle(
                                        color: context.colors.textSecondary,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      tInline(
                                        widget.strings.languageCode,
                                        '₺14,99',
                                        '\$4.99',
                                        '4,99 €',
                                      ),
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                        color: context.colors.white,
                                      ),
                                    ),
                                    Text(
                                      tInline(
                                        widget.strings.languageCode,
                                        '/ ay',
                                        '/ month',
                                        '/ Monat',
                                      ),
                                      style: TextStyle(
                                        color: context.colors.textSecondary,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),

                          // Yearly Plan Card (POPULAR / BEST VALUE)
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedPlan = 'yearly';
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _selectedPlan == 'yearly'
                                      ? context.colors.cyan.withValues(
                                          alpha: 0.12,
                                        )
                                      : context.colors.surface,
                                  borderRadius: BorderRadius.circular(
                                    _cardRadius,
                                  ),
                                  border: Border.all(
                                    color: _selectedPlan == 'yearly'
                                        ? context.colors.cyan
                                        : context.colors.border,
                                    width: _selectedPlan == 'yearly' ? 2 : 1,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: context.colors.caution,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        tInline(
                                          widget.strings.languageCode,
                                          'ÖNERİLEN',
                                          'RECOMMENDED',
                                          'EMPFOHLEN',
                                        ),
                                        style: TextStyle(
                                          color: context.colors.onAccent,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      tInline(
                                        widget.strings.languageCode,
                                        'YILLIK',
                                        'YEARLY',
                                        'JÄHRLICH',
                                      ),
                                      style: TextStyle(
                                        color: context.colors.cyan,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      tInline(
                                        widget.strings.languageCode,
                                        '₺99,99',
                                        '\$29.99',
                                        '29,99 €',
                                      ),
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                        color: context.colors.white,
                                      ),
                                    ),
                                    Text(
                                      tInline(
                                        widget.strings.languageCode,
                                        '/ yıl',
                                        '/ year',
                                        '/ Jahr',
                                      ),
                                      style: TextStyle(
                                        color: context.colors.textSecondary,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Google Play Action Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.colors.cyan,
                          foregroundColor: context.colors.onAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(_cardRadius),
                          ),
                          elevation: 0,
                        ),
                        onPressed: _isLoading ? null : _executePurchase,
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.shop_2_outlined, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    tInline(
                                      widget.strings.languageCode,
                                      'Google Play ile Güvenli Satın Al',
                                      'Purchase via Google Play',
                                      'Kauf über Google Play',
                                    ),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                  const SizedBox(height: ApexSpacing.x2),

                  if (!profile.isPremium) ...[
                    Center(
                      child: TextButton(
                        onPressed: _isLoading ? null : _restorePurchases,
                        child: Text(
                          tInline(
                            widget.strings.languageCode,
                            'Satın Alımları Geri Yükle',
                            'Restore Purchases',
                            'Käufe wiederherstellen',
                          ),
                          style: TextStyle(
                            color: context.colors.textSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
      ),
    );
  }

  Widget _buildFeatureRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool tr,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: context.colors.cyan, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: context.colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontSize: 11,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
