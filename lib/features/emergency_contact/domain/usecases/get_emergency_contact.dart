import '../entities/emergency_contact.dart';
import '../repositories/emergency_contact_repository.dart';
class GetEmergencyContact {
  final EmergencyContactRepository repository;

  GetEmergencyContact(this.repository);

  Future<EmergencyContact?> call(String userId) async {
    return await repository.getEmergencyContact(userId);
  }
}