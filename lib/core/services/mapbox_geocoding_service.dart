import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import '../../models/search_result_model.dart';
import '../constants/mapbox_config.dart';

/// Service for Mapbox Geocoding API
/// Provides forward geocoding (address → coordinates) and reverse geocoding
class MapboxGeocodingService {
  // Rate limiting
  DateTime? _lastRequestTime;
  
  /// Session token for autocomplete (reduces costs)
  String? _sessionToken;
  
  /// Forward geocoding: search for locations by query
  /// 
  /// [query] - The search query (e.g., "Federal Bank Kochi")
  /// [proximity] - Optional coordinates to bias results towards
  /// [limit] - Maximum number of results (default: 5)
  /// [useSessionToken] - Use session token for autocomplete (default: true)
  Future<List<SearchResult>> searchLocations(
    String query, {
    LatLng? proximity,
    int limit = 5,
    bool useSessionToken = true,
  }) async {
    if (query.trim().isEmpty) return [];

    try {
      // Rate limiting: wait at least 100ms between requests
      await _enforceRateLimit();

      // Generate or reuse session token
      if (useSessionToken) {
        _sessionToken ??= _generateSessionToken();
      }

      // Build URL
      final encodedQuery = Uri.encodeComponent(query);
      final params = <String, String>{
        'access_token': MapboxConfig.accessToken,
        'limit': limit.toString(),
        'autocomplete': 'true',
        'fuzzyMatch': 'true', // Enable fuzzy matching for typos
      };

      // Add session token if using autocomplete
      if (useSessionToken && _sessionToken != null) {
        params['session_token'] = _sessionToken!;
      }

      // Add proximity bias if provided
      if (proximity != null) {
        params['proximity'] = '${proximity.longitude},${proximity.latitude}';
      }

      final uri = Uri.parse('${MapboxConfig.geocodingApiUrl}/$encodedQuery.json')
          .replace(queryParameters: params);

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final features = data['features'] as List<dynamic>;

        return features.map((feature) {
          return SearchResult.fromMapbox(
            feature as Map<String, dynamic>,
            1.0, // Mapbox returns sorted results, keep original score
          );
        }).toList();
      } else {
        debugPrint('Mapbox Geocoding API error: ${response.statusCode}');
        debugPrint('Response: ${response.body}');
        return [];
      }
    } catch (e) {
      debugPrint('Error searching Mapbox Geocoding: $e');
      return [];
    }
  }

  /// Reverse geocoding: get location details from coordinates
  Future<String?> reverseGeocode(
    double latitude,
    double longitude,
  ) async {
    try {
      await _enforceRateLimit();

      final params = {
        'access_token': MapboxConfig.accessToken,
      };

      final uri = Uri.parse(
        '${MapboxConfig.geocodingApiUrl}/$longitude,$latitude.json',
      ).replace(queryParameters: params);

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final features = data['features'] as List<dynamic>;
        
        if (features.isNotEmpty) {
          return features[0]['place_name'] as String?;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error reverse geocoding: $e');
      return null;
    }
  }

  /// Clear session token (call after user selects a result)
  void clearSessionToken() {
    _sessionToken = null;
  }

  /// Enforce rate limiting (min 100ms between requests)
  Future<void> _enforceRateLimit() async {
    if (_lastRequestTime != null) {
      final elapsed = DateTime.now().difference(_lastRequestTime!);
      const minInterval = Duration(milliseconds: 100);
      
      if (elapsed < minInterval) {
        await Future.delayed(minInterval - elapsed);
      }
    }
    _lastRequestTime = DateTime.now();
  }

  /// Generate a random session token
  String _generateSessionToken() {
    final random = Random();
    return List.generate(
      32,
      (_) => random.nextInt(16).toRadixString(16),
    ).join();
  }
}
