import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apexflow/profile/application/friends_state.dart';

void main() {
  group('FriendsState Controller Tests', () {
    test(
      'initialization results in empty friends list if database is empty',
      () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final friends = container.read(friendsStateProvider);

        // Since db is mocked in test environment to InMemoryDbService,
        // it should instantly hydrate and start with empty list.
        expect(friends, isEmpty);
      },
    );

    test(
      'addFriendByTag generates a new profile and appends it to state',
      () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final controller = container.read(friendsStateProvider.notifier);

        // Starts empty
        expect(container.read(friendsStateProvider).length, equals(0));

        // Add a new friend by a known valid tag
        final result = await controller.addFriendByTag('@can_rider', true);

        expect(result, isTrue);
        final updatedList = container.read(friendsStateProvider);
        expect(updatedList.length, equals(1));
        expect(updatedList.first.riderTag, equals('@can_rider'));
      },
    );

    test('addFriendByTag rejects unknown tags', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final controller = container.read(friendsStateProvider.notifier);

      expect(container.read(friendsStateProvider).length, equals(0));

      // Try to add with an unknown tag
      final result = await controller.addFriendByTag(
        '@nonexistent_user_xyz',
        true,
      );

      expect(result, isFalse);
      expect(
        container.read(friendsStateProvider).length,
        equals(0),
      ); // No change
    });

    test('removeFriend removes a friend from the list by stable ID', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final controller = container.read(friendsStateProvider.notifier);

      // Pre-add a friend to remove
      await controller.addFriendByTag('@hakan_adventure', true);
      final listWithFriend = container.read(friendsStateProvider);
      expect(listWithFriend.length, equals(1));
      final stableId = listWithFriend.first.stableId;

      // Remove the friend
      await controller.removeFriend(stableId);

      final updatedList = container.read(friendsStateProvider);
      expect(updatedList.length, equals(0));
      expect(updatedList.any((f) => f.stableId == stableId), isFalse);
    });
  });
}
