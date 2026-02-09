import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:roamly/core/services/user_service.dart';
import 'package:roamly/core/services/request_service.dart';
import 'package:roamly/models/user_profile_model.dart';
import 'package:roamly/features/companions/screens/requests_screen.dart';

class FindCompanionScreen extends StatefulWidget {
  const FindCompanionScreen({super.key});

  @override
  State<FindCompanionScreen> createState() => _FindCompanionScreenState();
}

class _FindCompanionScreenState extends State<FindCompanionScreen> {
  final UserService _userService = UserService();
  final RequestService _requestService = RequestService();
  final MapController _mapController = MapController();

  bool _isMapView = true;
  bool _isDiscoverable = false;
  Position? _currentPosition;
  List<UserProfile> _nearbyUsers = [];
  List<UserProfile> _searchResults = [];
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  StreamSubscription<List<UserProfile>>? _usersSubscription;

  @override
  void initState() {
    super.initState();
    _checkLocationAndPermissions();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _usersSubscription?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    // Ideally we get the current user ID globally or passed in
    // For now assuming we can fetch it via FirebaseAuth in UserService internally
    // or we fetch the profile to see current discoverable state
    // This is a simplified version
  }

  Future<void> _checkLocationAndPermissions() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
      });

      // Initial map center
      if (_mapController.mapEventStream.isBroadcast) {
        _mapController.move(
          LatLng(position.latitude, position.longitude),
          13.0,
        );
      }

      // Start listening to nearby users
      _listenToNearbyUsers();

      // Update my location if discoverable
      if (_isDiscoverable) {
        _userService.updateUserLocation(position, true);
      }
    } catch (e) {
      debugPrint("Error getting location: $e");
    }
  }

  void _listenToNearbyUsers() {
    _usersSubscription = _userService.getNearbyUsers().listen((users) {
      if (mounted) {
        setState(() {
          _nearbyUsers = users;
        });
      }
    });
  }

  Future<void> _toggleDiscoverable(bool value) async {
    setState(() {
      _isDiscoverable = value;
    });
    if (_currentPosition != null) {
      await _userService.updateUserLocation(_currentPosition!, value);
    }
  }

  void _onSearchChanged(String query) async {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    final results = await _userService.searchUsers(query);
    setState(() {
      _searchResults = results;
    });
  }

  void _sendRequest(UserProfile user) async {
    try {
      bool alreadySent = await _requestService.hasSentRequest(user.uid);
      if (alreadySent) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request already sent or connected')),
        );
        return;
      }

      await _requestService.sendRequest(user.uid, user.name);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Request sent to ${user.name}')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to send request: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Companion'),
        actions: [
          IconButton(
            icon: Icon(_isMapView ? Icons.list : Icons.map),
            onPressed: () {
              setState(() {
                _isMapView = !_isMapView;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RequestsScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Discoverable Toggle
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search travelers...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: _onSearchChanged,
                ),
                SwitchListTile(
                  title: const Text('Make me discoverable'),
                  value: _isDiscoverable,
                  onChanged: _toggleDiscoverable,
                ),
              ],
            ),
          ),
          Expanded(
            child: _isSearching && _searchResults.isNotEmpty
                ? _buildUserList(_searchResults)
                : _isSearching
                ? const Center(child: Text('No users found'))
                : _isMapView
                ? _buildMap()
                : _buildUserList(_nearbyUsers),
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    if (_currentPosition == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: LatLng(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        ),
        initialZoom: 13.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.roamly.roamly',
        ),
        MarkerLayer(
          markers: [
            // My Location
            Marker(
              point: LatLng(
                _currentPosition!.latitude,
                _currentPosition!.longitude,
              ),
              width: 50,
              height: 50,
              child: const Icon(
                Icons.my_location,
                color: Colors.blue,
                size: 40,
              ),
            ),
            // Nearby Users
            ..._nearbyUsers.map((user) {
              if (user.location == null) return null;
              return Marker(
                point: LatLng(
                  user.location!['latitude'],
                  user.location!['longitude'],
                ),
                width: 60,
                height: 60,
                child: GestureDetector(
                  onTap: () => _showUserDialog(user),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.person_pin_circle,
                        color: Colors.red,
                        size: 40,
                      ),
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          backgroundColor: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            }).whereType<Marker>(),
          ],
        ),
      ],
    );
  }

  Widget _buildUserList(List<UserProfile> users) {
    if (users.isEmpty) {
      return const Center(child: Text('No travelers nearby'));
    }
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(child: Text(user.name[0].toUpperCase())),
            title: Text(user.name),
            subtitle: Text(user.email), // Don't show phone unless connected
            trailing: IconButton(
              icon: const Icon(Icons.person_add),
              onPressed: () => _sendRequest(user),
            ),
          ),
        );
      },
    );
  }

  void _showUserDialog(UserProfile user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user.name),
        content: Text('Send a connection request to share contact details?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _sendRequest(user);
            },
            child: const Text('Connect'),
          ),
        ],
      ),
    );
  }
}
