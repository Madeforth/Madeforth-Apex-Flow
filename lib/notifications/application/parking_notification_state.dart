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
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return null;
          final doc = snapshot.docs.first;
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
