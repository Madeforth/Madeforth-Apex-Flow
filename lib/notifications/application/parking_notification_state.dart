import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:apexflow/settings/application/user_profile_state.dart';

final parkingNotificationStreamProvider = StreamProvider<Map<String, dynamic>?>(
  (ref) {
    final profile = ref.watch(userProfileProvider);
    final tag = profile.riderTag.toLowerCase();

    if (tag.isEmpty) {
      return const Stream.empty();
    }

    return FirebaseFirestore.instance
        .collection('parking_notifications')
        .where('vehicleId', isEqualTo: tag)
        .where('read', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return null;
          // Sort in-memory by timestamp descending to avoid needing a Firestore composite index
          final docs = List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(snapshot.docs);
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
  },
);

class ParkingNotificationNotifier extends StateNotifier<void> {
  ParkingNotificationNotifier(this.ref) : super(null);

  final Ref ref;

  Future<void> replyToNotification(String docId, String replyText) async {
    final profile = ref.read(userProfileProvider);
    final tag = profile.riderTag.toLowerCase();

    if (tag.isEmpty) return;

    // 1. Update the notification as read so the popup closes
    await FirebaseFirestore.instance
        .collection('parking_notifications')
        .doc(docId)
        .update({'read': true});

    // 2. Write the reply to the rider's public tag so the web app shows it
    await FirebaseFirestore.instance.collection('rider_tags').doc(tag).set({
      'driverNote': replyText,
    }, SetOptions(merge: true));
  }
}

final parkingNotificationProvider =
    StateNotifierProvider<ParkingNotificationNotifier, void>((ref) {
      return ParkingNotificationNotifier(ref);
    });
