import 'package:latlong2/latlong.dart';
import '../../models/location_model.dart';

class LocationService {
  // Mock data
  final List<LocationModel> _locations = [
    LocationModel(
      id: '1',
      name: 'Hidden Waterfall',
      description: 'A beautiful secluded waterfall.',
      latitude: 12.9716,
      longitude: 77.5946,
      type: LocationType.generated,
      rating: 4.8,
      likesCount: 12,
    ),
    LocationModel(
      id: '2',
      name: 'Sunset Point',
      description: 'Best view for sunset.',
      latitude: 12.9800,
      longitude: 77.6000,
      type: LocationType.scenic,
      rating: 4.5,
      likesCount: 5,
    ),
  ];

  Future<List<LocationModel>> getLocations() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return _locations;
  }

  Future<String?> addLocation(LocationModel newLocation) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    final newPos = LatLng(newLocation.latitude, newLocation.longitude);
    const distance = Distance();

    for (final loc in _locations) {
      final existingPos = LatLng(loc.latitude, loc.longitude);
      final km = distance.as(LengthUnit.Kilometer, newPos, existingPos);

      if (km < 2.0) {
        return 'Too close to an existing spot "${loc.name}" (within 2km)';
      }
    }

    _locations.add(newLocation);
    return null; // Success
  }
}
