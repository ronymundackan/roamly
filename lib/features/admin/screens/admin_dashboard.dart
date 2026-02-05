import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:latlong2/latlong.dart';
import 'package:roamly/core/core.dart';
import 'package:roamly/core/services/location_service.dart';
import 'package:roamly/models/location_model.dart';
import 'package:roamly/features/shared/widgets/spot_map_picker.dart';
import 'package:roamly/features/home/widgets/add_spot_dialog.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final _locationService = LocationService();
  List<LocationModel> _pendingLocations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPendingLocations();
  }

  Future<void> _loadPendingLocations() async {
    setState(() => _isLoading = true);
    final locs = await _locationService.getPendingLocations();
    setState(() {
      _pendingLocations = locs;
      _isLoading = false;
    });
  }

  Future<void> _approveLocation(String id) async {
    await _locationService.updateLocationStatus(id, 'approved');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Spot Approved!'), backgroundColor: Colors.green),
    );
    _loadPendingLocations();
  }

  Future<void> _rejectLocation(String id) async {
    await _locationService.deleteLocation(id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Spot Rejected (Deleted)'), backgroundColor: Colors.red),
    );
    _loadPendingLocations();
  }

  Future<void> _handleAddSpot() async {
    // Show map picker to select location
    final LatLng? selectedLocation = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        builder: (context) => const SpotMapPicker(),
      ),
    );

    if (selectedLocation == null || !mounted) return;

    // Show dialog to enter spot details
    final LocationModel? newLocation = await showDialog<LocationModel>(
      context: context,
      builder: (context) => AddSpotDialog(
        currentLat: selectedLocation.latitude,
        currentLng: selectedLocation.longitude,
      ),
    );

    if (newLocation != null) {
      // Admin adds spots directly as approved
      final error = await _locationService.addLocationAsAdmin(newLocation);
      if (!mounted) return;

      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Spot added successfully and approved!'),
            backgroundColor: Colors.green,
          ),
        );
        // Reload pending list (though admin spots go directly to approved)
        _loadPendingLocations();
      }
    }
  }

  Future<void> _handleLogout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pendingLocations.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
                      SizedBox(height: 16),
                      Text('No pending approvals!'),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _pendingLocations.length,
                  itemBuilder: (context, index) {
                    final loc = _pendingLocations[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Chip(
                                  label: Text(loc.type.name.toUpperCase()),
                                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                                  labelStyle: const TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  'Rating: ${loc.rating}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              loc.name,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              loc.description ?? 'No description',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[700],
                                  ),
                            ),
                            const SizedBox(height: 8),
                             Text(
                              'Location: ${loc.latitude.toStringAsFixed(4)}, ${loc.longitude.toStringAsFixed(4)}',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  onPressed: () => _rejectLocation(loc.id!),
                                  icon: const Icon(Icons.close, color: Colors.red),
                                  label: const Text('Reject', style: TextStyle(color: Colors.red)),
                                ),
                                const SizedBox(width: 8),
                                FilledButton.icon(
                                  onPressed: () => _approveLocation(loc.id!),
                                  icon: const Icon(Icons.check),
                                  label: const Text('Approve'),
                                  style: FilledButton.styleFrom(backgroundColor: Colors.green),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _handleAddSpot,
        icon: const Icon(Icons.add_location_alt),
        label: const Text('Add New Spot'),
        tooltip: 'Add a new spot at any location',
      ),
    );
  }
}
