import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:roamly/models/companion_request_model.dart';
import 'package:flutter/foundation.dart';

class RequestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Send a companion request
  Future<void> sendRequest(String receiverId, String receiverName) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final requestRef = _firestore.collection('requests').doc();
    final request = CompanionRequest(
      id: requestRef.id,
      senderId: currentUser.uid,
      receiverId: receiverId,
      senderName:
          currentUser.displayName ?? 'Unknown', // Ideally fetch from profile
      senderEmail: currentUser.email ?? '',
      status: RequestStatus.pending,
      timestamp: DateTime.now(),
    );

    // Fetch actual sender name from profile ensuring we have the correct one
    final senderDoc = await _firestore
        .collection('users')
        .doc(currentUser.uid)
        .get();
    final senderName =
        senderDoc.data()?['name'] ?? currentUser.displayName ?? 'Unknown';

    await requestRef.set({
      ...request.toMap(),
      'senderName': senderName, // Update with correct name
    });
  }

  // Accept a request
  Future<void> acceptRequest(CompanionRequest request) async {
    try {
      final batch = _firestore.batch();

      // Update request status
      final requestRef = _firestore.collection('requests').doc(request.id);
      batch.update(requestRef, {'status': 'accepted'});

      // Add each other to connectedUserIds
      final senderRef = _firestore.collection('users').doc(request.senderId);
      final receiverRef = _firestore
          .collection('users')
          .doc(request.receiverId);

      batch.update(senderRef, {
        'connectedUserIds': FieldValue.arrayUnion([request.receiverId]),
      });
      batch.update(receiverRef, {
        'connectedUserIds': FieldValue.arrayUnion([request.senderId]),
      });

      await batch.commit();
    } catch (e) {
      debugPrint('Error accepting request: $e');
      rethrow;
    }
  }

  // Reject a request
  Future<void> rejectRequest(String requestId) async {
    try {
      await _firestore.collection('requests').doc(requestId).update({
        'status': 'rejected',
      });
    } catch (e) {
      debugPrint('Error rejecting request: $e');
      rethrow;
    }
  }

  // Stream of incoming requests
  Stream<List<CompanionRequest>> getIncomingRequests() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value([]);

    return _firestore
        .collection('requests')
        .where('receiverId', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CompanionRequest.fromMap(doc.data()))
              .toList(),
        );
  }

  // Function to check if a request has already been sent
  Future<bool> hasSentRequest(String receiverId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;

    final result = await _firestore
        .collection('requests')
        .where('senderId', isEqualTo: uid)
        .where('receiverId', isEqualTo: receiverId)
        // We might want to allow re-sending if rejected, but for now check if any pending/accepted exists
        .where('status', whereIn: ['pending', 'accepted'])
        .get();

    return result.docs.isNotEmpty;
  }
}
