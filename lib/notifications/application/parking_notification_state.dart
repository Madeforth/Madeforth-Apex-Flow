import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:apexflow/settings/application/user_profile_state.dart';

class ParkingNotificationState {
  const ParkingNotificationState({
    this.dismissedIds = const <String>{},
    this.error,
  });

  final Set<String> dismissedIds;
  final String? error;

  ParkingNotificationState copyWith({
    Set<String>? dismissedIds,
    String? error,
    bool clearError = false,
  }) {
    return ParkingNotificationState(
      dismissedIds: dismissedIds ?? this.dismissedIds,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

final parkingNotificationStreamProvider = StreamProvider<Map<String, dynamic>?>((
  ref,
) {
  final profile = ref.watch(userProfileProvider);
  final tag = profile.riderTag.toLowerCase();
  final dismissedIds = ref.watch(
    parkingNotificationProvider.select((s) => s.dismissedIds),
  );

  if (tag.isEmpty) {
    return const Stream.empty();
  }

  return FirebaseFirestore.instance
      .collection('parking_notifications')
      .where('vehicleId', isEqualTo: tag)
      .where('read', isEqualTo: false)
      .snapshots()
      .map((snapshot) {
        // Sort in-memory by timestamp descending to avoid needing a Firestore composite index
        final docs = List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(
          snapshot.docs,
        )..removeWhere((doc) => dismissedIds.contains(doc.id));
        if (docs.isEmpty) return null;
        docs.sort((a, b) {
          final aTime = a.data()['timestamp'] as Timestamp?;
          final bTime = b.data()['timestamp'] as Timestamp?;
          if (aTime == null && bTime == null) return 0;
          if (aTime == null) return 1;
          if (bTime == null) return -1;
          return bTime.compareTo(aTime);
        });
        final doc = docs.first;
        final data = doc.data();
        data['id'] = doc.id; // Store document ID for updating later
        return data;
      });
});

class ParkingNotificationNotifier
    extends StateNotifier<ParkingNotificationState> {
  ParkingNotificationNotifier(this.ref)
    : super(const ParkingNotificationState());

  final Ref ref;

  Future<void> replyToNotification(String docId, String replyText) async {
    final profile = ref.read(userProfileProvider);
    final tag = profile.riderTag.toLowerCase();

    if (tag.isEmpty) return;

    try {
      // 1. Update the notification as read so the popup closes
      await FirebaseFirestore.instance
          .collection('parking_notifications')
          .doc(docId)
          .update({'read': true});

      // 2. Write the reply to the rider's public tag so the web app shows it
      await FirebaseFirestore.instance.collection('rider_tags').doc(tag).set({
        'driverNote': replyText,
        'driverNoteAtIso': DateTime.now().toUtc().toIso8601String(),
      }, SetOptions(merge: true));

      state = state.copyWith(clearError: true);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Hides a notification locally without marking it read in Firestore —
  /// lets the user escape the blocking overlay (e.g. while offline) without
  /// losing the underlying unread record.
  void dismissLocally(String docId) {
    state = state.copyWith(dismissedIds: {...state.dismissedIds, docId});
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final parkingNotificationProvider =
    StateNotifierProvider<
      ParkingNotificationNotifier,
      ParkingNotificationState
    >((ref) {
      return ParkingNotificationNotifier(ref);
    });
