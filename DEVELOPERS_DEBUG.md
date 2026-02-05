# Roamly Developer Guide & Product Overview

*Last Updated: 2026-02-02*

Welcome to the Roamly project! This document serves as a "Brain Dump" of the current state of the application, designed to help new developers (and you in the future) understand how everything works under the hood.

---

## 1. Product Overview
**Roamly** is a travel discovery app that helps users find and mark "hidden gems" and interesting spots.
- **Core Functionality**: View spots on a map, add new spots, and track your current location.
- **Design Philosophy**: Simple, clean, and community-focused (simulated for now).

---

## 2. Project Structure
The project follows a **Feature-First** architecture. Code is organized by what it *does* (features) rather than what it *is* (screens, widgets).

### Directory Map (`lib/`)
- **`core/`**: Utilities shared across the entire app.
  - `constants/`: App-wide strings and configs.
  - `services/`: Data providers. **Crucial**: `LocationService` lives here.
  - `themes/`: Colors and styling.
- **`features/`**: The main functional areas.
  - `home/`: The main map interface (`HomeScreen`) and widgets (`AddSpotDialog`).
  - `debug/`: Developer tools (`DebugScreen`).
  - `auth/`: Login/Splash screens (currently basic).
- **`models/`**: Data classes (Blueprints for data).
  - `LocationModel`: Defines what a "Spot" looks like (lat, lng, name, type, etc.).

---

## 3. How It Works (The "Meat")

### A. The Map & Home Screen
- **Files**: `lib/features/home/screens/home_screen.dart`
- **Logic**:
  - Uses `flutter_map` to render OpenStreetMap tiles.
  - **State**: Holds a list of `LocationModel` (spots) and the user's current location (`_currentPosition`).
  - **Interaction**:
    - **Tapping a Marker**: Opens a bottom sheet with details.
    - **My Location Button**: Uses `geolocator` to find you and center the map. **Visual**: Adds a blue dot marker.
    - **Startup Behavior**: Automatically requests permissions and centers on the user's location with zoom level **19.0**.

### B. Adding a New Spot
- **Files**: `lib/features/home/widgets/add_spot_dialog.dart`
- **Workflow**:
  1. User clicks the `+` Floating Action Button.
  2. Map center coordinates are passed to the dialog.
  3. User enters Name, Description, Type (Dropdown), and Rating.
  4. **Validation Logic** (in `LocationService`):
     - The app calculates the distance to *all other spots*.
     - **Constraint**: You cannot add a spot within **2km** of an existing one.
  5. If valid, the spot is added to the in-memory list and the map updates.

### C. Data Storage
- **Current Status**: **Firebase Firestore (Integrated)**.
- **File**: `lib/core/services/location_service.dart`
- **Details**:
  - Uses `cloud_firestore` to read/write spots to the `locations` collection.
  - Data **persists** across restarts.
  - `addLocation()` performs a client-side proximity check (downloads spots, checks distance, then uploads).

### D. Navigation
- **Drawer**: The primary navigation hub (`AppDrawer` in `home_screen.dart`).
- **Developer Options**: A hidden menu in the drawer that leads to the `DebugScreen`.
- **Routing**: Currently uses simple `Navigator.push` for direct screen transitions.

---

## 4. Developer Tools
We have added a custom **Debug Screen** to help with development.
- **Access**: Open Drawer -> Tap "Developer Options".
- **Capabilities**:
  - View raw GPS coordinates, altitude, and speed.
  - Check Location Permission status.
  - View device info (placeholder).

---

## 5. Recent Change Log (Significant Updates)

### [2026-02-02] Location & UX Overhaul
- **Added `geolocator`**: Replaced stubbed location logic with real GPS data.
- **User Marker**: Added the "Blue Dot" to the map to show user position.
- **Radius Update**: Changed the minimum distance between spots from **5km** to **2km**.
- **Add Spot UI**:
  - Added "Location Type" dropdown (Generated, Scenic, Favorite, Visited).
  - Improved styling with proper icons and spacing.
  - Added new types to `LocationModel`.
- **Debug Screen**: Created `lib/features/debug/` to expose internal app state.
- **Map UX**:
  - **Auto-Center**: App now immediately locks onto user location on startup.
  - **Zoom Level**: Increased default zoom to **19.0** (Street Level) when locating user.

### [2026-02-03] Firebase & Fixes
- **Firebase Integration**:
  - Integrated `firebase_core` and `cloud_firestore`.
  - Replaced in-memory storage with real database persistence.
- **"Add Spot" UX Fix**:
  - Logic updated to force a GPS fetch when clicking "Add Spot" if the location is unknown.
  - **Prioritization**: Defaults to User GPS -> Fallback to Map Center.
  - Added SnackBar feedback ("Using Current GPS Location" vs "Using Map Center").

### [2026-02-05] Admin Dashboard & Auth
- **Authentication**: Added Firebase Email/Password Login.
- **Moderation Workflow**:
  - **New Spots**: Saved as `status: 'pending'`. Hidden from Home Screen.
  - **Admin Dashboard**: New screen to view pending spots.
  - **Approval**: Admins (`admin@roamly.com`) can approve or reject spots.
  - **Home Screen**: Filters to show ONLY `status: 'approved'`.

---

## 6. Future Roadmap (Notes for Self)
- **Persistence**: Hook up `LocationService` to a local database (Hive/SQLite) or Firebase so spots match survives restarts.
- **Search**: Implement the search bar logic in `HomeScreen`.
- **Trips**: Build out the "My Trips" feature stubbed in the navigation bar.

---

## 7. Detailed Codebase Walkthrough (File by File)

Here is a breakdown of every important file in the `lib/` folder and what it actually does.

### `lib/core/` (The Foundation)
Shared tools used everywhere in the app.

- **`constants/app_constants.dart`**
  - **What it is**: The "settings file" for hardcoded values.
  - **Key Variables**:
    - `splashDuration`: How long the intro lasts (2 seconds).
    - `defaultLatitude/Longitude`: Where the map starts if we don't know the user's location (New Delhi).
    - `appName`: "Roamly".

- **`services/location_service.dart`**
  - **What it is**: The "Fake Backend". In a real app, this would talk to a server.
  - **Key Functions**:
    - `getLocations()`: Returns the list of spots. Simulates a 0.5s network delay.
    - `addLocation()`: THE BRAIN. It checks if a new spot is valid (e.g., is it >2km from others?) before adding it.

- **`themes/app_theme.dart`**
  - **What it is**: The Style Guide.
  - **Details**: Defines the "Orange & Teal" color palette (`primaryColor`, `secondaryColor`). It tells the app what buttons, text fields, and app bars should look like globally.

### `lib/features/` (The Screens)
Organized by "Feature" (Auth, Home, Debug) instead of "Screen Type".

#### Auth Feature (`features/auth/`)
- **`screens/splash_screen.dart`**
  - **What it is**: The first thing you see.
  - **How it works**: Uses an `AnimationController` to fade in the logo. After 2 seconds, it automatically calls `Navigator.pushReplacementNamed('/home')` to swap itself with the Home Screen.

#### Home Feature (`features/home/`)
- **`screens/home_screen.dart`**
  - **What it is**: The Main Screen.
  - **Key Components**:
    - `FlutterMap`: The interactive map widget.
    - `MarkerLayer`: Draws the red pins (Spots) and the blue dot (User).
    - `FloatingActionButton`: The buttons in the bottom right (Location & Add).
    - `AppDrawer`: The side menu (Hamburger menu).

- **`widgets/add_spot_dialog.dart`**
  - **What it is**: The popup form when you click "+".
  - **Key Logic**: It captures the Name/Description/Rating, validates that they aren't empty, and captures the *current center of the map* as the spot's location.

#### Debug Feature (`features/debug/`)
- **`screens/debug_screen.dart`**
  - **What it is**: A secret screen for us developers.
  - **Why**: Helps debug GPS issues by showing raw sensor data that regular users don't need to see.

### `lib/models/` (The Blueprints)
- **`location_model.dart`**
  - **What it is**: Defines what a "Spot" is.
  - **Properties**: `name`, `latitude`, `longitude`, `type` (Enum: Favorite, Generated, etc.), `rating`.
  - **Usage**: Throughout the app, we pass around `LocationModel` objects instead of loose variables like `string name`.
