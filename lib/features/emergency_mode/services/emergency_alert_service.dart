import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class EmergencyAlertService {
  static Future<bool> requestBackgroundLocationPermission() async {
    if (kIsWeb) return false;

    var foregroundPermission = await Permission.locationWhenInUse.status;
    if (!foregroundPermission.isGranted) {
      foregroundPermission = await Permission.locationWhenInUse.request();
    }
    if (!foregroundPermission.isGranted) return false;

    var backgroundPermission = await Permission.locationAlways.status;
    if (!backgroundPermission.isGranted) {
      backgroundPermission = await Permission.locationAlways.request();
    }
    return backgroundPermission.isGranted;
  }

  static Future<void> sendCurrentLocation() async {
    final permission = await Geolocator.checkPermission();
    if (permission != LocationPermission.always) {
      throw StateError(
        'El permiso de ubicación en segundo plano no está habilitado.',
      );
    }

    if (!await Geolocator.isLocationServiceEnabled()) {
      throw StateError('La ubicación del dispositivo está desactivada.');
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 20),
      ),
    );

    final callable = FirebaseFunctions.instanceFor(
      region: 'us-central1',
    ).httpsCallable('sendEmergencyLocation');
    final result = await callable.call({
      'latitude': position.latitude,
      'longitude': position.longitude,
    });

    if (result.data is! Map || result.data['sent'] != true) {
      throw StateError('El proveedor no confirmó el envío del SMS.');
    }
  }
}
