import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:roamly/models/user_profile_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Retrieve the current user's profile
  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists) {
        return UserProfile.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user profile: $e');
      return null;
    }
  }

  // Stream current user profile
  Stream<UserProfile?> getUserStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return UserProfile.fromMap(doc.data()!);
      }
      return null;
    });
  }

  // Update user's location and discoverability status
  Future<void> updateUserLocation(
    Position position,
    bool isDiscoverable,
  ) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      await _firestore.collection('users').doc(uid).update({
        'location': {
          'latitude': position.latitude,
          'longitude': position.longitude,
          'timestamp': Timestamp.now(),
        },
        'isDiscoverable': isDiscoverable,
      });
    } catch (e) {
      debugPrint('Error updating user location: $e');
    }
  }

  // Get stream of nearby discoverable users
  // Note: This is a client-side filter for demonstration.
  // For production with many users, use GeoFlutterFire or similar.
  Stream<List<UserProfile>> getNearbyUsers() {
    return _firestore
        .collection('users')
        .where('isDiscoverable', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          final currentUid = _auth.currentUser?.uid;
          return snapshot.docs
              .map((doc) => UserProfile.fromMap(doc.data()))
              .where((user) => user.uid != currentUid && user.location != null)
              .toList();
        });
  }

  // Search users by name or email (only discoverable ones)
  Future<List<UserProfile>> searchUsers(String query) async {
    if (query.isEmpty) return [];

    try {
      final result = await _firestore
          .collection('users')
          .where('isDiscoverable', isEqualTo: true)
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .get();

      return result.docs.map((doc) => UserProfile.fromMap(doc.data())).toList();
    } catch (e) {
      debugPrint('Error searching users: $e');
      return [];
    }
  }

  // Fetch multiple users by their IDs
  Future<List<UserProfile>> getUsers(List<String> uids) async {
    if (uids.isEmpty) return [];

    try {
      // Firestore 'where in' supports up to 10 items.
      // For production app, you'd chunk this. For now assuming < 10 connected users.
      if (uids.length > 10) {
        debugPrint(
          'Warning: getUsers called with >10 UIDs. Only fetching first 10.',
        );
        uids = uids.take(10).toList();
      }

      final result = await _firestore
          .collection('users')
          .where('uid', whereIn: uids)
          .get();

      return result.docs.map((doc) => UserProfile.fromMap(doc.data())).toList();
    } catch (e) {
      debugPrint('Error fetching users: $e');
      return [];
    }
  }
}
