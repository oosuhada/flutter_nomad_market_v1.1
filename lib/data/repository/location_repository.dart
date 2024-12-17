// location_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/location_model.dart';
import 'firebase_repository.dart';

class LocationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveLocation(String userId, LocationModel location) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'preferences.homeAddress': location.address,
        'location': {
          'latitude': location.latitude,
          'longitude': location.longitude,
        }
      });
    } catch (e) {
      print('Location 저장 오류: $e');
      throw e;
    }
  }

  Future<LocationModel?> getLocation(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return null;

      final data = doc.data();
      if (data == null) return null;

      return LocationModel(
        address: data['preferences']['homeAddress'],
        latitude: data['location']?['latitude'],
        longitude: data['location']?['longitude'],
      );
    } catch (e) {
      print('Location 조회 오류: $e');
      return null;
    }
  }
}
