/// Mapbox configuration and API keys
class MapboxConfig {
  /// Mapbox public access token
  static const String accessToken = 
      'pk.eyJ1Ijoicm9ueW11bmRhY2thbCIsImEiOiJjbWxleHA3NGMxbzNmM2RxdXRmaHR3ZWJjIn0.pGYdeRQ198FLfTlghD2J_A';

  /// Mapbox tile URL templates for different styles
  /// Using @2x tiles (512px) which work better with flutter_map
  /// Streets style - clean, readable map
  static String get streetStyleUrl =>
      'https://api.mapbox.com/styles/v1/mapbox/streets-v12/tiles/256/{z}/{x}/{y}@2x?access_token=$accessToken';

  /// Satellite streets style - satellite imagery with labels
  static String get satelliteStyleUrl =>
      'https://api.mapbox.com/styles/v1/mapbox/satellite-streets-v12/tiles/256/{z}/{x}/{y}@2x?access_token=$accessToken';

  /// Outdoors style - optimized for outdoor activities
  static String get outdoorsStyleUrl =>
      'https://api.mapbox.com/styles/v1/mapbox/outdoors-v12/tiles/256/{z}/{x}/{y}@2x?access_token=$accessToken';

  /// Mapbox Geocoding API base URL
  static const String geocodingApiUrl =
      'https://api.mapbox.com/geocoding/v5/mapbox.places';

  /// Attribution text (required by Mapbox TOS)
  static const String attribution = '© Mapbox © OpenStreetMap';
}
