import '../../domain/entities/emergency_contact.dart';
import '../../domain/repositories/emergency_contact_repository.dart';
import '../datasources/emergency_contact_remote_data_source.dart';

class EmergencyContactRepositoryImpl implements EmergencyContactRepository {
  final EmergencyContactRemoteDataSource remoteDataSource;

  EmergencyContactRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> saveEmergencyContact(EmergencyContact contact) async {
    await remoteDataSource.saveEmergencyContact(contact);
  }

  @override
  Future<void> updateEmergencyContact(EmergencyContact contact) async {
    await remoteDataSource.updateEmergencyContact(contact);
  }

  @override
  Future<void> deleteEmergencyContact(String userId) async {
    await remoteDataSource.deleteEmergencyContact(userId);
  }

  @override
  Future<EmergencyContact?> getEmergencyContact(String userId) async {
    return await remoteDataSource.getEmergencyContact(userId);
  }
}