/// App-wide constants for Roamly
class AppConstants {
  // Prevent instantiation
  AppConstants._();

  // App Info
  static const String appName = 'Roamly';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Connect. Explore. Discover.';

  // Firebase Collections (for future use)
  static const String usersCollection = 'users';
  static const String tripsCollection = 'trips';
  static const String locationsCollection = 'locations';
  static const String messagesCollection = 'messages';

  // Map Settings (OpenStreetMap via flutter_map)
  static const double defaultLatitude = 28.6139;  // New Delhi
  static const double defaultLongitude = 77.2090;
  static const double defaultZoom = 12.0;
  static const double minZoom = 3.0;
  static const double maxZoom = 18.0;

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 12.0;
  static const int splashDuration = 2; // seconds

  // Validation
  static const int minPasswordLength = 6;
  static const int maxBioLength = 150;
  static const int maxUsernameLength = 30;
}
