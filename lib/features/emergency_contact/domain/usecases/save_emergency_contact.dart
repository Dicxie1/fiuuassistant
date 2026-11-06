import '../entities/emergency_contact.dart';
import '../repositories/emergency_contact_repository.dart';


class SaveEmergencyContact {
  final EmergencyContactRepository repository;

  SaveEmergencyContact(this.repository);

  Future<void> call(EmergencyContact contact) async {
    await repository.saveEmergencyContact(contact);
  }
}