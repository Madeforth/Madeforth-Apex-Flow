import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Wraps the RevenueCat SDK. Configure with real per-platform API keys before
/// any purchase/entitlement call is made — see [init]. Until an iOS key is
/// added here, iOS builds simply skip configuration and every entitlement
/// check safely reports "not entitled" rather than crashing.
///
/// Entitlement identifiers configured in the RevenueCat dashboard
/// (project "Apex Flow", app "Apex Flow (Play Store)"):
///   - "premium"          -> apexflow_premium_monthly, apexflow_premium_yearly
///   - "supporter_tier_1" -> apexflow_supporter_tier1
///   - "supporter_tier_2" -> apexflow_supporter_tier2
///   - "supporter_tier_3" -> apexflow_supporter_tier3
abstract final class PurchasesEntitlements {
  static const premium = 'premium';
  static String supporterTier(int tier) => 'supporter_tier_$tier';
}

abstract final class PurchasesProductIds {
  static String supporterTier(int tier) => 'apexflow_supporter_tier$tier';
}

class PurchasesService {
  PurchasesService._privateConstructor();
  static final PurchasesService instance =
      PurchasesService._privateConstructor();

  bool _configured = false;

  // RevenueCat public SDK key (safe to embed client-side — not a secret
  // key). Sandbox/"test_" key from RevenueCat onboarding, 2026-08-05 —
  // swap for the production key before a real release build.
  static const String _androidApiKey = 'test_fvELpOGwmQYczPBZoMCjnadMUaD';
  static const String? _iosApiKey = null; // Not yet configured in RevenueCat.

  Future<void> init() async {
    if (_configured) return;
    if (kIsWeb) return; // RevenueCat has no web SDK path here.

    final apiKey = Platform.isAndroid
        ? _androidApiKey
        : (Platform.isIOS ? _iosApiKey : null);
    if (apiKey == null) {
      debugPrint(
        '[PurchasesService] No RevenueCat API key for this platform — purchases disabled.',
      );
      return;
    }

    try {
      await Purchases.setLogLevel(
        kReleaseMode ? LogLevel.warn : LogLevel.debug,
      );
      await Purchases.configure(PurchasesConfiguration(apiKey));
      _configured = true;
    } catch (e) {
      debugPrint('[PurchasesService] configure() failed: $e');
    }
  }

  /// Fetches the current offering (the "default" offering configured in the
  /// RevenueCat dashboard, containing the Monthly/Yearly premium packages).
  Future<Offering?> getCurrentOffering() async {
    if (!_configured) return null;
    try {
      final offerings = await Purchases.getOfferings();
      return offerings.current;
    } catch (e) {
      debugPrint('[PurchasesService] getOfferings() failed: $e');
      return null;
    }
  }

  /// Fetches a single store product by its Play Console product ID — used
  /// for the supporter tiers, which are one-time non-consumable purchases
  /// outside the offering/package model.
  Future<StoreProduct?> getProduct(String productId) async {
    if (!_configured) return null;
    try {
      final products = await Purchases.getProducts([productId]);
      if (products.isEmpty) return null;
      return products.first;
    } catch (e) {
      debugPrint('[PurchasesService] getProducts() failed: $e');
      return null;
    }
  }

  /// Runs the real store purchase flow for [package]. Returns the resulting
  /// CustomerInfo on success, or null on failure/user cancellation.
  Future<CustomerInfo?> purchasePackage(Package package) async {
    if (!_configured) return null;
    try {
      final result = await Purchases.purchase(PurchaseParams.package(package));
      return result.customerInfo;
    } on PurchasesErrorCode catch (e) {
      debugPrint('[PurchasesService] purchasePackage() error: $e');
      return null;
    } catch (e) {
      debugPrint('[PurchasesService] purchasePackage() failed: $e');
      return null;
    }
  }

  /// Runs the real store purchase flow for a standalone [product] (used for
  /// the supporter tiers, purchased outside the offering/package model).
  Future<CustomerInfo?> purchaseProduct(StoreProduct product) async {
    if (!_configured) return null;
    try {
      final result = await Purchases.purchase(
        PurchaseParams.storeProduct(product),
      );
      return result.customerInfo;
    } on PurchasesErrorCode catch (e) {
      debugPrint('[PurchasesService] purchaseProduct() error: $e');
      return null;
    } catch (e) {
      debugPrint('[PurchasesService] purchaseProduct() failed: $e');
      return null;
    }
  }

  Future<CustomerInfo?> restorePurchases() async {
    if (!_configured) return null;
    try {
      return await Purchases.restorePurchases();
    } catch (e) {
      debugPrint('[PurchasesService] restorePurchases() failed: $e');
      return null;
    }
  }

  /// Checks whether the signed-in RevenueCat user has an active entitlement
  /// named [entitlementId]. Never returns true without a verified
  /// CustomerInfo from RevenueCat — there is no simulated/local success path.
  Future<bool> hasActiveEntitlement(String entitlementId) async {
    if (!_configured) return false;
    try {
      final info = await Purchases.getCustomerInfo();
      return info.entitlements.active.containsKey(entitlementId);
    } catch (e) {
      debugPrint('[PurchasesService] getCustomerInfo() failed: $e');
      return false;
    }
  }

  /// Binds the RevenueCat user identity to the app's own user id (Firebase
  /// UID / installation id) so entitlements follow the account across
  /// devices, matching the identity model used for Firestore.
  Future<void> logIn(String appUserId) async {
    if (!_configured || appUserId.isEmpty) return;
    try {
      await Purchases.logIn(appUserId);
    } catch (e) {
      debugPrint('[PurchasesService] logIn() failed: $e');
    }
  }
}
