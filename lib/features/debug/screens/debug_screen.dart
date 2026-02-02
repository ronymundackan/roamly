import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:roamly/core/core.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  String _locationStatus = 'Unknown';
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _loadDebugInfo();
  }

  Future<void> _loadDebugInfo() async {
    // Check location
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      LocationPermission permission = await Geolocator.checkPermission();

      setState(() {
        _locationStatus = 'Service: $serviceEnabled, Permission: $permission';
      });

      if (serviceEnabled &&
          (permission == LocationPermission.whileInUse ||
              permission == LocationPermission.always)) {
        final position = await Geolocator.getCurrentPosition();
        setState(() {
          _currentPosition = position;
        });
      }
    } catch (e) {
      setState(() {
        _locationStatus = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Developer Debug')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection('Location Status', [
            Text('Status: $_locationStatus'),
            if (_currentPosition != null) ...[
              const SizedBox(height: 8),
              Text('Lat: ${_currentPosition!.latitude}'),
              Text('Lng: ${_currentPosition!.longitude}'),
              Text('Accuracy: ${_currentPosition!.accuracy}m'),
              Text('Altitude: ${_currentPosition!.altitude}m'),
              Text('Speed: ${_currentPosition!.speed}m/s'),
            ],
          ]),
          const Divider(),
          _buildSection('App Info', [
            const Text('App Name: ${AppConstants.appName}'),
            const Text('Package: com.roamly.roamly'),
            // Add more app info here if needed
          ]),
          const Divider(),
          FilledButton.icon(
            onPressed: _loadDebugInfo,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh Info'),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }
}
