import 'package:flutter/material.dart';
import 'package:roamly/core/core.dart';
import 'package:roamly/models/models.dart';

/// My Trips screen showing past trips, starred trips, and visited places
class MyTripsScreen extends StatefulWidget {
  const MyTripsScreen({super.key});

  @override
  State<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends State<MyTripsScreen> {
  // Dummy data for demonstration
  late List<TripModel> pastTrips;
  late List<TripModel> starredTrips;
  late List<LocationModel> visitedPlaces;

  @override
  void initState() {
    super.initState();
    _initializeDummyData();
  }

  void _initializeDummyData() {
    // Past Trips
    pastTrips = [
      TripModel(
        id: '1',
        ownerId: 'user1',
        title: 'Summer Vacation 2023',
        description: 'Amazing beach trip with friends',
        locations: [
          LocationModel(
            name: 'Goa Beach',
            latitude: 15.2993,
            longitude: 73.8243,
            address: 'Goa, India',
            type: LocationType.scenic,
          ),
        ],
        startDate: DateTime(2023, 6, 1),
        endDate: DateTime(2023, 6, 15),
        status: TripStatus.completed,
        isFavorite: false,
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
        updatedAt: DateTime.now().subtract(const Duration(days: 365)),
      ),
      TripModel(
        id: '2',
        ownerId: 'user1',
        title: 'Mountain Trekking',
        description: 'Hiking adventure in the Himalayas',
        locations: [
          LocationModel(
            name: 'Manali',
            latitude: 32.2396,
            longitude: 77.1887,
            address: 'Himachal Pradesh, India',
            type: LocationType.adventure,
          ),
        ],
        startDate: DateTime(2023, 9, 10),
        endDate: DateTime(2023, 9, 20),
        status: TripStatus.completed,
        isFavorite: false,
        createdAt: DateTime.now().subtract(const Duration(days: 300)),
        updatedAt: DateTime.now().subtract(const Duration(days: 300)),
      ),
      TripModel(
        id: '3',
        ownerId: 'user1',
        title: 'City Exploration',
        description: 'Weekend getaway to the capital',
        locations: [
          LocationModel(
            name: 'Delhi',
            latitude: 28.6139,
            longitude: 77.2090,
            address: 'New Delhi, India',
            type: LocationType.cultural,
          ),
        ],
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 3),
        status: TripStatus.completed,
        isFavorite: false,
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        updatedAt: DateTime.now().subtract(const Duration(days: 60)),
      ),
    ];

    // Starred Trips
    starredTrips = [
      TripModel(
        id: '4',
        ownerId: 'user1',
        title: 'Europe Grand Tour',
        description: 'Dream trip across Europe',
        locations: [
          LocationModel(
            name: 'Paris',
            latitude: 48.8566,
            longitude: 2.3522,
            address: 'France',
            type: LocationType.cultural,
          ),
        ],
        startDate: DateTime(2024, 5, 1),
        endDate: DateTime(2024, 6, 15),
        status: TripStatus.planned,
        isFavorite: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      TripModel(
        id: '5',
        ownerId: 'user1',
        title: 'Southeast Asia Adventure',
        description: 'Backpacking through Thailand and Vietnam',
        locations: [
          LocationModel(
            name: 'Bangkok',
            latitude: 13.7563,
            longitude: 100.5018,
            address: 'Thailand',
            type: LocationType.adventure,
          ),
        ],
        startDate: DateTime(2024, 7, 1),
        endDate: DateTime(2024, 8, 31),
        status: TripStatus.planned,
        isFavorite: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      TripModel(
        id: '6',
        ownerId: 'user1',
        title: 'Japan Cherry Blossoms',
        description: 'Spring festival experience in Japan',
        locations: [
          LocationModel(
            name: 'Tokyo',
            latitude: 35.6762,
            longitude: 139.6503,
            address: 'Japan',
            type: LocationType.cultural,
          ),
        ],
        startDate: DateTime(2025, 3, 15),
        endDate: DateTime(2025, 4, 15),
        status: TripStatus.planned,
        isFavorite: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    // Visited Places
    visitedPlaces = [
      LocationModel(
        id: 'p1',
        name: 'Taj Mahal',
        description: 'Monument of love',
        latitude: 27.1751,
        longitude: 78.0421,
        address: 'Agra, India',
        type: LocationType.cultural,
      ),
      LocationModel(
        id: 'p2',
        name: 'Gateway of India',
        description: 'Historic monument',
        latitude: 18.9220,
        longitude: 72.8347,
        address: 'Mumbai, India',
        type: LocationType.poi,
      ),
      LocationModel(
        id: 'p3',
        name: 'Mysore Palace',
        description: 'Royal palace',
        latitude: 12.3051,
        longitude: 76.6551,
        address: 'Mysore, India',
        type: LocationType.cultural,
      ),
      LocationModel(
        id: 'p4',
        name: 'Hawa Mahal',
        description: 'Palace of winds',
        latitude: 26.9250,
        longitude: 75.8250,
        address: 'Jaipur, India',
        type: LocationType.poi,
      ),
      LocationModel(
        id: 'p5',
        name: 'Elia Beach',
        description: 'Beautiful beach',
        latitude: 15.2828,
        longitude: 73.8305,
        address: 'Goa, India',
        type: LocationType.scenic,
      ),
      LocationModel(
        id: 'p6',
        name: 'Varanasi Ghats',
        description: 'Sacred spiritual site',
        latitude: 25.3201,
        longitude: 83.0112,
        address: 'Varanasi, India',
        type: LocationType.cultural,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Trips'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Past Trips Section
              _buildSectionHeader('Past Trips'),
              if (pastTrips.isEmpty)
                _buildEmptyState('No past trips yet', Icons.travel_explore_outlined)
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: pastTrips.length,
                  itemBuilder: (context, index) {
                    return TripCard(trip: pastTrips[index]);
                  },
                ),

              const SizedBox(height: 32),

              // Starred Trips Section
              _buildSectionHeader('Starred Trips'),
              if (starredTrips.isEmpty)
                _buildEmptyState('No starred trips yet', Icons.star_outline)
              else
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
                  child: Row(
                    children: List.generate(
                      starredTrips.length,
                      (index) => Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: StarredTripCard(trip: starredTrips[index]),
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 32),

              // Visited Places Section
              _buildSectionHeader('Visited Places'),
              if (visitedPlaces.isEmpty)
                _buildEmptyState('No visited places yet', Icons.location_on_outlined)
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: visitedPlaces.length,
                    itemBuilder: (context, index) {
                      return VisitedPlaceTile(place: visitedPlaces[index]);
                    },
                  ),
                ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: 32,
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              icon,
              size: 56,
              color: AppTheme.textHint,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textHint,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card widget for displaying past trips in a list
class TripCard extends StatelessWidget {
  final TripModel trip;

  const TripCard({required this.trip, super.key});

  String _formatDateRange() {
    final startDate = _formatDate(trip.startDate);
    if (trip.endDate != null) {
      final endDate = _formatDate(trip.endDate!);
      return '$startDate - $endDate';
    }
    return startDate;
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_monthName(date.month)} ${date.year}';
  }

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final primaryLocation = trip.locations.isNotEmpty 
        ? trip.locations.first.name 
        : 'No location';

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: 8,
      ),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                trip.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      primaryLocation,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _formatDateRange(),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textHint,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Card widget for displaying starred/favorite trips horizontally
class StarredTripCard extends StatelessWidget {
  final TripModel trip;

  const StarredTripCard({required this.trip, super.key});

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
      ),
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.secondaryColor.withAlpha((0.15 * 255).round()),
              AppTheme.backgroundColor,
            ],
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Header with star icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    trip.title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(
                  Icons.star,
                  size: 18,
                  color: AppTheme.accentColor,
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Image placeholder
            Container(
              height: 80,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppTheme.dividerColor,
              ),
              child: Icon(
                Icons.landscape_outlined,
                color: AppTheme.textSecondary,
                size: 32,
              ),
            ),
            const SizedBox(height: 8),
            // Date
            Text(
              _formatDate(trip.startDate),
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tile widget for displaying visited places in a grid
class VisitedPlaceTile extends StatelessWidget {
  final LocationModel place;

  const VisitedPlaceTile({required this.place, super.key});

  IconData _getLocationIcon() {
    switch (place.type) {
      case LocationType.restaurant:
        return Icons.restaurant_outlined;
      case LocationType.cafe:
        return Icons.local_cafe_outlined;
      case LocationType.scenic:
        return Icons.landscape_outlined;
      case LocationType.adventure:
        return Icons.hiking_outlined;
      case LocationType.cultural:
        return Icons.museum_outlined;
      case LocationType.hiddenGem:
        return Icons.diamond_outlined;
      case LocationType.campsite:
        return Icons.home_outlined;
      case LocationType.restStop:
        return Icons.local_parking_outlined;
      default:
        return Icons.location_on_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor.withAlpha((0.08 * 255).round()),
              AppTheme.backgroundColor,
            ],
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppTheme.dividerColor,
              ),
              child: Icon(
                _getLocationIcon(),
                size: 40,
                color: AppTheme.secondaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              place.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  size: 12,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    place.address ?? 'Unknown location',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textHint,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
