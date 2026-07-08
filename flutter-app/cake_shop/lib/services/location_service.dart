import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Requests permission and GPS only when the user taps "Use current location".
  static Future<String> getCurrentAddress() async {
    try {
      return await _getCurrentAddressImpl();
    } on MissingPluginException {
      throw Exception(
        'Location plugin not loaded. Stop the app completely, then run:\n'
        'flutter clean && flutter pub get && flutter run',
      );
    }
  }

  static Future<String> _getCurrentAddressImpl() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw Exception(
        'Location permission denied. Allow access when prompted, or enter your address manually.',
      );
    }
    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      throw Exception(
        'Location permission blocked. Enable it in Settings, then tap current location again.',
      );
    }

    var enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      await Geolocator.openLocationSettings();
      await Future<void>.delayed(const Duration(milliseconds: 800));
      enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        throw Exception(
          'Turn on location (GPS) in settings, then tap current location again.',
        );
      }
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 15),
      ),
    );

    final places = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    if (places.isEmpty) {
      throw Exception('Could not resolve address from GPS. Try manual entry.');
    }

    final p = places.first;
    final parts = [
      if (p.name != null && p.name!.isNotEmpty) p.name,
      if (p.street != null && p.street!.isNotEmpty) p.street,
      if (p.subLocality != null && p.subLocality!.isNotEmpty) p.subLocality,
      if (p.locality != null && p.locality!.isNotEmpty) p.locality,
      if (p.administrativeArea != null && p.administrativeArea!.isNotEmpty) p.administrativeArea,
      if (p.postalCode != null && p.postalCode!.isNotEmpty) p.postalCode,
    ].whereType<String>().toList();

    final unique = <String>[];
    for (final part in parts) {
      if (!unique.contains(part)) unique.add(part);
    }
    if (unique.isEmpty) {
      throw Exception('Could not build address from GPS. Try manual entry.');
    }
    return unique.join(', ');
  }

  static String shortLabelFromAddress(String address) {
    final parts = address.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    if (parts.length >= 2) return 'Current location · ${parts[parts.length - 2]}';
    if (parts.isNotEmpty) return 'Current location · ${parts.last}';
    return 'Current location';
  }
}
