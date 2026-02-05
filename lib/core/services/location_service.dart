import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../models/location_model.dart';

class LocationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'locations';

  // Fetch ONLY approved locations for the home screen
  Future<List<LocationModel>> getLocations() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('status', isEqualTo: 'approved')
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Ensure ID is set from document ID
        return LocationModel.fromMap(data);
      }).toList();
    } catch (e) {
      // Simple error logging
      debugPrint('Error fetching locations: $e');
      return [];
    }
  }
  
  // Fetch PENDING locations for Admin Dashboard
  Future<List<LocationModel>> getPendingLocations() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('status', isEqualTo: 'pending')
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return LocationModel.fromMap(data);
      }).toList();
    } catch (e) {
      debugPrint('Error fetching pending locations: $e');
      return [];
    }
  }

  // Admin Action: Approve or Reject (Delete) use updateStatus('approved') or delete
  Future<void> updateLocationStatus(String id, String status) async {
    await _firestore.collection(_collection).doc(id).update({'status': status});
  }

  Future<void> deleteLocation(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  Future<String?> addLocation(LocationModel newLocation) async {
    try {
      // Add to Firestore
      // We create a map but ensure 'id' is removed so Firestore generates one
      final data = newLocation.toMap();
      data.remove('id');
      // Force status to pending for new user submissions
      data['status'] = 'pending'; 
      
      // Ensure createdAt is set if not present
      if (data['createdAt'] == null) {
        data['createdAt'] = FieldValue.serverTimestamp();
      }

      await _firestore.collection(_collection).add(data);
      return null; // Success
    } catch (e) {
      return 'Failed to add location: $e';
    }
  }

  // Admin method to add location directly as approved
  Future<String?> addLocationAsAdmin(LocationModel newLocation) async {
    try {
      final data = newLocation.toMap();
      data.remove('id');
      // Admin-added spots are immediately approved
      data['status'] = 'approved';
      
      if (data['createdAt'] == null) {
        data['createdAt'] = FieldValue.serverTimestamp();
      }

      await _firestore.collection(_collection).add(data);
      return null; // Success
    } catch (e) {
      return 'Failed to add location: $e';
    }
  }
}
