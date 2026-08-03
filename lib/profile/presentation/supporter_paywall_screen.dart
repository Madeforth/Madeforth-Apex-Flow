import 'package:apexflow/core/design/apex_spacing.dart';
import 'package:apexflow/core/i18n/app_strings.dart';
import 'package:apexflow/settings/application/user_profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apexflow/profile/presentation/profile_hub_screen.dart';
import 'package:apexflow/core/design/theme_extensions.dart';

class SupporterPaywallScreen extends ConsumerStatefulWidget {
  const SupporterPaywallScreen({super.key, required this.strings});

  final AppStrings strings;

  @override
  ConsumerState<SupporterPaywallScreen> createState() =>
      _SupporterPaywallScreenState();
}

class _SupporterPaywallScreenState
    extends ConsumerState<SupporterPaywallScreen> {
  bool _isLoading = false;

  void _executePurchase(int tierId, String tierName, String price) {
    final tr = widget.strings.locale.languageCode == 'tr';
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: context.colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ApexSpacing.radius),
            side: BorderSide(color: context.colors.border),
          ),
          title: Row(
            children: [
              Icon(Icons.favorite_outline, color: context.colors.cyan),
              const SizedBox(width: 10),
              Text(
                tInline(
                  widget.strings.languageCode,
                  'Google Play İşlemi',
                  'Google Play Billing',
                  'Google Play-Abrechnung',
                ),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Apex Flow - $tierName',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                tInline(
                  widget.strings.languageCode,
                  'Fiyat: $price',
                  'Price: $price',
                  'Preis: $price',
                ),
                style: TextStyle(
                  color: context.colors.caution,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                tInline(
                  widget.strings.languageCode,
                  'Bu ekran Google Play / App Store mağaza satın alma entegrasyonu için hazırlanmıştır. Gerçek sürümde mağaza ödeme penceresini açacaktır.',
                  'This screen is prepared for Google Play / App Store checkout integration. In production, it will open the native store billing sheet.',
                  'Dieser Bildschirm ist für die Checkout-Integration von Google Play/App Store vorbereitet. In der Produktion wird das Abrechnungsblatt des nativen Geschäfts geöffnet.',
                ),
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                tInline(
                  widget.strings.languageCode,
                  'İPTAL',
                  'CANCEL',
                  'STORNIEREN',
                ),
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.cyan,
                foregroundColor: context.colors.onAccent,
              ),
              onPressed: () {
                Navigator.pop(context);
                _simulateStoreCheckout(tierId);
              },
              child: Text(
                tInline(
                  widget.strings.languageCode,
                  'TEST ÖDEMESİ YAP',
                  'SIMULATE PAYMENT',
                  'ZAHLUNG SIMULIEREN',
                ),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _simulateStoreCheckout(int tierId) {
    final tr = widget.strings.locale.languageCode == 'tr';
    setState(() {
      _isLoading = true;
    });
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ref.read(userProfileProvider.notifier).updateSupporterTier(tierId);
      final supporterThemeIndex = riderCardThemes.indexWhere(
        (t) => t.requiredSupporterTier > 0,
      );
      if (supporterThemeIndex != -1) {
        ref.read(userProfileProvider.notifier).selectTheme(supporterThemeIndex);
      }

      // Show SnackBar BEFORE pop to avoid invalid context
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tInline(
              widget.strings.languageCode,
              'Desteğiniz için teşekkürler! Apex Flow Supporter paketiniz başarıyla aktifleştirildi! 🏍️',
              'Thank you for your support! Your Apex Flow Supporter pack has been activated! 🏍️',
              'Vielen Dank für Ihre Unterstützung! Ihr Apex Flow Supporter-Paket wurde aktiviert! 🏍️',
            ),
          ),
          backgroundColor: context.colors.cyan,
        ),
      );
      if (Navigator.canPop(context)) Navigator.pop(context);
    });
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
                padding: const EdgeInsets.symmetric(
                  horizontal: ApexSpacing.x2,
                  vertical: ApexSpacing.x1,
                ),
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: context.colors.surface,
                        borderRadius: BorderRadius.circular(ApexSpacing.radius),
                        border: Border.all(
                          color: context.colors.cyan,
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.favorite,
                            color: context.colors.cyan,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            tInline(
                              widget.strings.languageCode,
                              'GELİŞTİRİCİYİ DESTEKLE',
                              'SUPPORT THE DEVELOPER',
                              'UNTERSTÜTZEN SIE DEN ENTWICKLER',
                            ),
                            style: TextStyle(
                              color: context.colors.cyan,
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
                        'APEX FLOW SUPPORTER',
                        'APEX FLOW SUPPORTER',
                        'APEX FLOW SUPPORTER',
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
                        'Apex Flow bağımsız bir geliştirici tarafından yapılıyor. Uygulamayı geliştirmemize yardımcı olun ve özel sürüş gösteriş (Flex) özelliklerini açın.',
                        'Apex Flow is built by an indie developer. Help us develop the app and unlock exclusive rider flex features.',
                        'Apex Flow wurde von einem Indie-Entwickler entwickelt. Helfen Sie uns, die App zu entwickeln und exklusive Rider-Flex-Funktionen freizuschalten.',
                      ),
                      style: TextStyle(
                        color: context.colors.textSecondary,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: ApexSpacing.x3),

                  if (profile.supporterTier >= 1) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: context.colors.cyan.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(ApexSpacing.radius),
                        border: Border.all(
                          color: context.colors.cyan.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          tInline(
                            widget.strings.languageCode,
                            'Destekçimiz olduğunuz için teşekkürler! 👑',
                            'Thank you for being a supporter! 👑',
                            'Vielen Dank, dass Sie ein Unterstützer sind! 👑',
                          ),
                          style: TextStyle(
                            color: context.colors.cyan,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: ApexSpacing.x3),
                  ],

                  // TIER 1: PIT CREW
                  _buildPricingTier(
                    tierId: 1,
                    title: 'PIT CREW',
                    priceTr: '₺49.99',
                    priceEn: '\$2.99',
                    descriptionTr:
                        'Sadece çorbada tuzum olsun demek isteyenler için.',
                    descriptionEn:
                        'For those who just want to support the project.',
                    featuresTr: [
                      'Destekçi Rozeti (Bronz Somun Anahtarı)',
                      'Geliştiricinin Sonsuz Teşekkürü',
                    ],
                    featuresEn: [
                      'Supporter Badge (Bronze Wrench)',
                      'Developer\'s Endless Gratitude',
                    ],
                    isRecommended: false,
                    borderColor: context.colors.border,
                    iconColor: context.colors.textSecondary,
                    icon: Icons.build_circle_outlined,
                    tr: tr,
                    isUnlocked:
                        profile.unlockedSupporterTiers.contains(1) ||
                        profile.supporterTier == 1,
                    isActive: profile.supporterTier == 1,
                  ),
                  const SizedBox(height: 16),

                  // TIER 2: TRACK RIDER (Recommended)
                  _buildPricingTier(
                    tierId: 2,
                    title: 'TRACK RIDER',
                    priceTr: '₺149.99',
                    priceEn: '\$9.99',
                    descriptionTr:
                        'Lobi ve profillerde fark edilin. Karbon fiber doku ve onay tikini kapın!',
                    descriptionEn:
                        'Stand out in lobbies and profiles. Grab the carbon fiber texture and verified tick!',
                    featuresTr: [
                      'Tüm Pit Crew Özellikleri',
                      'Lobi & Profil Karbon Doku Efekti',
                      'Gümüş İsim & Profilde Onay Tiki (Verified)',
                    ],
                    featuresEn: [
                      'All Pit Crew Features',
                      'Lobby & Profile Carbon Texture',
                      'Silver Name & Verified Profile Tick',
                    ],
                    isRecommended: true,
                    borderColor: context.colors.cyan,
                    iconColor: context.colors.cyan,
                    icon: Icons.verified,
                    tr: tr,
                    gradient: [
                      const Color(0xFF1E1E1E),
                      const Color(0xFF2D2D2D),
                    ],
                    isUnlocked:
                        profile.unlockedSupporterTiers.contains(2) ||
                        profile.supporterTier == 2,
                    isActive: profile.supporterTier == 2,
                  ),
                  const SizedBox(height: 16),

                  // TIER 3: APEX FOUNDER (Decoy / Ultimate Flex)
                  _buildPricingTier(
                    tierId: 3,
                    title: 'APEX FOUNDER',
                    priceTr: '₺499.99',
                    priceEn: '\$49.99',
                    descriptionTr:
                        'Geliştiricinin gerçek dostu. Ultimate Flex paketi ile herkes sizi konuşsun.',
                    descriptionEn:
                        'True friend of the developer. Let everyone talk about you with the Ultimate Flex pack.',
                    featuresTr: [
                      'Tüm Track Rider Özellikleri',
                      'Özel Altın İsim & Elmas İkonu',
                      'Lobi Girişinde Sistem Anonsu',
                      'Sonsuz Kurucu Üye Statüsü',
                    ],
                    featuresEn: [
                      'All Track Rider Features',
                      'Exclusive Gold Name & Diamond Icon',
                      'System Announcement on Lobby Join',
                      'Eternal Founder Status',
                    ],
                    isRecommended: false,
                    borderColor: Colors.amber.withValues(alpha: 0.5),
                    iconColor: Colors.amber,
                    icon: Icons.diamond,
                    tr: tr,
                    isUnlocked:
                        profile.unlockedSupporterTiers.contains(3) ||
                        profile.supporterTier == 3,
                    isActive: profile.supporterTier == 3,
                  ),

                  const SizedBox(height: ApexSpacing.x3),

                  // Return to App Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: context.colors.white,
                        side: BorderSide(
                          color: context.colors.border,
                          width: 1.2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            ApexSpacing.radius,
                          ),
                        ),
                      ),
                      onPressed: () {
                        if (Navigator.canPop(context)) Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.arrow_back,
                        size: 18,
                        color: context.colors.white,
                      ),
                      label: Text(
                        tInline(
                          widget.strings.languageCode,
                          'Uygulamaya Dön',
                          'Return to App',
                          'Zurück zur App',
                        ),
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
      ),
    );
  }

  Widget _buildPricingTier({
    required int tierId,
    required String title,
    required String priceTr,
    required String priceEn,
    required String descriptionTr,
    required String descriptionEn,
    required List<String> featuresTr,
    required List<String> featuresEn,
    required bool isRecommended,
    required Color borderColor,
    required Color iconColor,
    required IconData icon,
    required bool tr,
    required bool isUnlocked,
    required bool isActive,
    List<Color>? gradient,
  }) {
    final price = tr ? priceTr : priceEn;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: gradient == null ? context.colors.surface : null,
            gradient: gradient != null
                ? LinearGradient(
                    colors: gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            borderRadius: BorderRadius.circular(ApexSpacing.radius),
            border: Border.all(
              color: borderColor,
              width: isRecommended ? 2.0 : 1.0,
            ),
            boxShadow: isRecommended
                ? [
                    BoxShadow(
                      color: context.colors.cyan.withValues(alpha: 0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _AnimatedFlexIcon(
                          icon: icon,
                          color: iconColor,
                          tierId: tierId,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          title,
                          style: TextStyle(
                            color: iconColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      price,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: isRecommended
                            ? Colors.white
                            : context.colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  tr ? descriptionTr : descriptionEn,
                  style: TextStyle(
                    color: isRecommended
                        ? Colors.white70
                        : context.colors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),
                Divider(color: context.colors.border, height: 1),
                const SizedBox(height: 16),
                ...List.generate(featuresTr.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: isRecommended
                              ? context.colors.cyan
                              : context.colors.healthy,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            tr ? featuresTr[index] : featuresEn[index],
                            style: TextStyle(
                              color: isRecommended
                                  ? Colors.white
                                  : context.colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isActive
                          ? context.colors.healthy.withValues(alpha: 0.2)
                          : (isUnlocked
                                ? context.colors.elevated
                                : (isRecommended
                                      ? context.colors.cyan
                                      : context.colors.elevated)),
                      foregroundColor: isActive
                          ? context.colors.healthy
                          : (isUnlocked
                                ? context.colors.white
                                : (isRecommended
                                      ? context.colors.onAccent
                                      : context.colors.white)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(ApexSpacing.radius),
                        side: isRecommended && !isUnlocked && !isActive
                            ? BorderSide.none
                            : BorderSide(color: context.colors.border),
                      ),
                      elevation: 0,
                    ),
                    onPressed: _isLoading || isActive
                        ? null
                        : () {
                            if (isUnlocked) {
                              ref
                                  .read(userProfileProvider.notifier)
                                  .updateSupporterTier(tierId);
                            } else {
                              _executePurchase(tierId, title, price);
                            }
                          },
                    child: Text(
                      isActive
                          ? tInline(
                              widget.strings.languageCode,
                              'Seçili',
                              'Selected',
                              'Ausgewählt',
                            )
                          : (isUnlocked
                                ? tInline(
                                    widget.strings.languageCode,
                                    'Kullan',
                                    'Use',
                                    'Verwenden',
                                  )
                                : tInline(
                                    widget.strings.languageCode,
                                    'Destek Ol ($price)',
                                    'Support ($price)',
                                    'Support ($price)',
                                  )),
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isRecommended)
          Positioned(
            top: -12,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: context.colors.cyan,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: context.colors.cyan.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                tInline(
                  widget.strings.languageCode,
                  'EN POPÜLER',
                  'MOST POPULAR',
                  'AM BELIEBTESTEN',
                ),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _AnimatedFlexIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  final int tierId;

  const _AnimatedFlexIcon({
    required this.icon,
    required this.color,
    required this.tierId,
  });

  @override
  State<_AnimatedFlexIcon> createState() => _AnimatedFlexIconState();
}

class _AnimatedFlexIconState extends State<_AnimatedFlexIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        if (widget.tierId == 1) {
          // Wrench: slight rotation
          return Transform.rotate(
            angle: (_controller.value - 0.5) * 0.4,
            child: Icon(widget.icon, color: widget.color, size: 24),
          );
        } else if (widget.tierId == 2) {
          // Verified Tick: Scale pulse
          return Transform.scale(
            scale: 0.95 + (_controller.value * 0.15),
            child: Icon(widget.icon, color: widget.color, size: 24),
          );
        } else {
          // Diamond: Glow + Scale + Rotate
          return Transform.scale(
            scale: 0.9 + (_controller.value * 0.2),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withValues(
                      alpha: 0.3 * _controller.value,
                    ),
                    blurRadius: 10 * _controller.value,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Transform.rotate(
                angle: (_controller.value) * 0.2,
                child: Icon(widget.icon, color: widget.color, size: 24),
              ),
            ),
          );
        }
      },
    );
  }
}
