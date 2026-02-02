import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:roamly/core/core.dart';
import 'package:roamly/core/services/location_service.dart';
import 'package:roamly/models/location_model.dart';
import 'package:geolocator/geolocator.dart';
import '../widgets/add_spot_dialog.dart';
import '../../debug/screens/debug_screen.dart';

/// Home screen with map view and mark spot feature
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _locationService = LocationService();
  final _mapController = MapController();
  List<LocationModel> _locations = [];
  final LatLng _center = const LatLng(12.9716, 77.5946); // Default: Bangalore
  LatLng? _currentPosition;

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    final locs = await _locationService.getLocations();
    setState(() {
      _locations = locs;
    });
  }

  Future<void> _handleLocationButton() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location services are disabled.')),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location permissions are permanently denied, we cannot request permissions.',
            ),
          ),
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
      _mapController.move(LatLng(position.latitude, position.longitude), 15);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error getting location: $e')));
    }
  }

  Future<void> _handleAddSpot() async {
    // Current map center as default for new spot
    final currentCenter = _mapController.camera.center;

    final LocationModel? newLocation = await showDialog<LocationModel>(
      context: context,
      builder: (context) => AddSpotDialog(
        currentLat: currentCenter.latitude,
        currentLng: currentCenter.longitude,
      ),
    );

    if (newLocation != null) {
      final error = await _locationService.addLocation(newLocation);
      if (!mounted) return;

      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Spot added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        _loadLocations();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Implement notifications
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(initialCenter: _center, initialZoom: 13.0),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.roamly.roamly',
              ),
              MarkerLayer(
                markers: _locations.map((loc) {
                  return Marker(
                    point: LatLng(loc.latitude, loc.longitude),
                    width: 40,
                    height: 40,
                    child: GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (ctx) =>
                              _LocationDetailsSheet(location: loc),
                        );
                      },
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (_currentPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentPosition!,
                      width: 20,
                      height: 20,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue.withOpacity(0.3),
                          border: Border.all(color: Colors.blue, width: 2),
                        ),
                        child: const Center(
                          child: CircleAvatar(
                            radius: 6,
                            backgroundColor: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          // Quick action FAB
          Positioned(
            right: 16,
            bottom: 100,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: 'location',
                  onPressed: _handleLocationButton,
                  backgroundColor: AppTheme.surfaceColor,
                  child: const Icon(
                    Icons.my_location,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 12),
                FloatingActionButton(
                  heroTag: 'add',
                  onPressed: _handleAddSpot,
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Trips',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.forum_outlined),
            activeIcon: Icon(Icons.forum),
            label: 'Community',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _LocationDetailsSheet extends StatelessWidget {
  final LocationModel location;

  const _LocationDetailsSheet({required this.location});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(location.name, style: Theme.of(context).textTheme.headlineSmall),
          if (location.rating != null)
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 20),
                Text(location.rating.toString()),
              ],
            ),
          const SizedBox(height: 8),
          Text(location.description ?? 'No description'),
          const SizedBox(height: 16),
          if (location.imageUrl != null)
            Image.network(
              location.imageUrl!,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const SizedBox(),
            ),
        ],
      ),
    );
  }
}

/// App drawer for navigation
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryColor, AppTheme.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 32,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Welcome, Traveler!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  AppConstants.appTagline,
                  style: TextStyle(
                    color: Colors.white.withAlpha((0.8 * 255).round()),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Home'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.route_outlined),
            title: const Text('My Trips'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to trips
            },
          ),
          ListTile(
            leading: const Icon(Icons.people_outline),
            title: const Text('Find Companions'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to find companions
            },
          ),
          ListTile(
            leading: const Icon(Icons.star_outline),
            title: const Text('Hidden Gems'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to hidden gems
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help & Feedback'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to help
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.developer_mode),
            title: const Text('Developer Options'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DebugScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
