import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/emergency_contact.dart';

class EmergencyContactRemoteDataSource {
  final FirebaseFirestore _firestore;

  EmergencyContactRemoteDataSource(this._firestore);

  Future<void> saveEmergencyContact(EmergencyContact contact) async {
    await _firestore.collection('emergency_contacts').doc(contact.userId).set(contact.toMap(),
    );
  }

  Future<void> updateEmergencyContact(EmergencyContact contact) async {
    await _firestore
        .collection('emergency_contacts')
        .doc(contact.userId)
        .update(contact.toMap());
  }

  Future<void> deleteEmergencyContact(String userId) async {
    await _firestore.collection('emergency_contacts').doc(userId).delete();
  }

  Future<EmergencyContact?> getEmergencyContact(String userId) async {
    if (userId.isEmpty) return null;
    try{
      final doc = await _firestore
        .collection('emergency_contacts')
        .doc(userId)
        .get(const GetOptions(source: Source.serverAndCache));
    if (doc.exists) {
      return EmergencyContact.fromMap(doc.data()!, doc.id);
    } else {
      return null;
    }
    } catch (e) {
      try{
        final doc = await _firestore
        .collection('emergency_contacts')
        .doc(userId)
        .get(const GetOptions(source: Source.cache));
      if (doc.exists) {
          return EmergencyContact.fromMap(doc.data()!, doc.id);
        }
      } catch (cacheError) {
        print('Error fetching emergency contact from cache: $cacheError');
      }
    }
    return null;
  }
}
