import 'package:apexflow/settings/application/user_profile_state.dart';
import 'package:apexflow/core/storage/apex_kv_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Rider Style Features & Profile Frame Tests', () {
    test(
      'Hydration correctly reads selectedFrameIndex and avatarIndex from SharedPreferences',
      () async {
        SharedPreferences.setMockInitialValues({
          'profile.name': 'Zeynep Rider',
          'profile.selected_frame_index': '2', // Mystic Halo frame
          'profile.avatar_index': '11', // Aesthetic Cat Helmet
        });
        await ApexKvStore.init(useFallback: true);

        final container = ProviderContainer();
        addTearDown(container.dispose);

        // Hydrate state
        container.read(userProfileProvider);
        await Future<void>.delayed(const Duration(milliseconds: 100));

        final profile = container.read(userProfileProvider);
        expect(profile.name, 'Zeynep Rider');
        expect(profile.selectedFrameIndex, 2);
        expect(profile.avatarIndex, 11);
      },
    );

    test(
      'updateProfile successfully updates selectedFrameIndex and persists it',
      () async {
        SharedPreferences.setMockInitialValues({});
        await ApexKvStore.init(useFallback: true);

        final container = ProviderContainer();
        addTearDown(container.dispose);

        final controller = container.read(userProfileProvider.notifier);
        await Future<void>.delayed(const Duration(milliseconds: 100));

        // Verify defaults
        expect(container.read(userProfileProvider).selectedFrameIndex, 0);

        // Update profile frame to Kraliçe Tacı (1)
        final success = await controller.updateProfile(
          name: 'Zeynep',
          phoneNumber: '+90 555 555 5555',
          bloodType: 'A Rh(+)',
          emergencyContactName: 'Baha',
          emergencyContactPhone: '+90 555 555 5556',
          selectedFrameIndex: 1,
          avatarIndex: 10,
        );

        expect(success, isTrue);

        final updatedProfile = container.read(userProfileProvider);
        expect(updatedProfile.selectedFrameIndex, 1);
        expect(updatedProfile.avatarIndex, 10);

        // Check SharedPreferences persistence
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('profile.selected_frame_index'), '1');
        expect(prefs.getString('profile.avatar_index'), '10');
      },
    );

    test(
      'friend visibility preferences are independent and persisted',
      () async {
        SharedPreferences.setMockInitialValues({});
        await ApexKvStore.init(useFallback: true);

        final container = ProviderContainer();
        addTearDown(container.dispose);
        final controller = container.read(userProfileProvider.notifier);
        await Future<void>.delayed(const Duration(milliseconds: 100));

        final success = await controller.updateFriendVisibility(
          shareBloodType: true,
          sharePhone: false,
          shareEmergency: true,
          shareLicensePlate: true,
        );

        expect(success, isTrue);
        final profile = container.read(userProfileProvider);
        expect(profile.shareBloodType, isTrue);
        expect(profile.sharePhone, isFalse);
        expect(profile.shareEmergency, isTrue);
        expect(profile.shareLicensePlate, isTrue);

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getBool('profile.share_blood_type'), isTrue);
        expect(prefs.getBool('profile.share_phone'), isFalse);
        expect(prefs.getBool('profile.share_emergency'), isTrue);
        expect(prefs.getBool('profile.share_license_plate'), isTrue);
      },
    );
  });
}
