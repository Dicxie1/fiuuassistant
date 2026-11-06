import '../entities/emergency_contact.dart';

abstract class EmergencyContactRepository {
  Future<void> saveEmergencyContact(EmergencyContact contact);
  Future<void> updateEmergencyContact(EmergencyContact contact);
  Future<void> deleteEmergencyContact(String userId);
  Future<EmergencyContact?> getEmergencyContact(String userId);
}