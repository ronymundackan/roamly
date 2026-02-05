# 📘 Roamly Developer Log - Phase 1 (Week 1)
## Environment & Foundation Setup

**Date:** January 30-31, 2026  
**Goal:** Set up the development environment and project skeleton  
**Difficulty Level:** 🟢 Beginner

---

## 🎯 What We Built This Week

A complete Flutter project foundation with:
- Clean folder structure (architecture)
- App theme (colors & styling)
- Data models (how we represent users, trips, locations)
- Basic screens (splash & home)

---

## 📂 Understanding the Folder Structure

```
lib/
├── core/           ← App-wide stuff (used everywhere)
├── features/       ← Each screen/feature lives here
├── models/         ← Data structures (blueprints for data)
├── providers/      ← State management (remembering things)
└── services/       ← Talking to databases/APIs
```

### Why This Structure? (Separation of Concerns)

Imagine a restaurant:
- **Chef** (Services) → Prepares food (fetches/saves data)
- **Waiter** (Providers) → Carries food between kitchen and tables (manages state)
- **Menu** (Models) → Describes what food looks like (data structure)
- **Dining Area** (Features/UI) → Where customers eat (what users see)

If the chef is sick, you can replace them without redesigning the dining area!

**In code terms:**
```dart
// BAD ❌ - UI directly talks to database
class ProfileScreen {
  void save() {
    firebase.collection('users').add(data); // UI shouldn't know about Firebase!
  }
}

// GOOD ✅ - UI talks to service
class ProfileScreen {
  void save() {
    userService.saveProfile(data); // UI just says "save this"
  }
}
```

---

## 🎨 Files Created & Explained

### 1. `lib/core/constants/app_constants.dart`

**What it does:** Stores values that don't change and are used throughout the app.

**Why we need it:** Instead of writing `"users"` everywhere (and risking typos), we write it once:

```dart
// Without constants (BAD) ❌
firebase.collection("users");  // Line 45
firebase.collection("Users");  // Line 102 - Oops, capital U! Bug!

// With constants (GOOD) ✅
firebase.collection(AppConstants.usersCollection); // Always correct!
```

**Key values we defined:**
| Constant | Value | Purpose |
|----------|-------|---------|
| `appName` | "Roamly" | Show in app bar, splash screen |
| `defaultLatitude/Longitude` | New Delhi coords | Where map centers initially |
| `defaultPadding` | 16.0 | Consistent spacing in UI |
| `minPasswordLength` | 6 | For validation later |

---

### 2. `lib/core/themes/app_theme.dart`

**What it does:** Defines all colors, button styles, and visual appearance.

**Why we need it:** Consistency! Every button, card, and text looks the same.

**The Color Palette:**
```
Primary: #FF6B35 (Sunset Orange) 🧡 → Main action buttons, highlights
Secondary: #2EC4B6 (Teal) 💚 → Secondary actions, exploration feel
Accent: #FFD166 (Golden) 💛 → Warnings, special highlights
Error: #EF476F (Coral Red) ❤️ → Errors, delete actions
```

**How themes work in Flutter:**
```dart
// In main.dart
MaterialApp(
  theme: AppTheme.lightTheme,    // ← Day mode
  darkTheme: AppTheme.darkTheme, // ← Night mode
  themeMode: ThemeMode.system,   // ← Follows phone settings
)

// Now EVERY widget automatically gets themed!
ElevatedButton(...) // Automatically orange with white text
```

**Light vs Dark Theme:**
- Light: White backgrounds, dark text
- Dark: Deep blue backgrounds (#1A1A2E), light text

---

### 3. `lib/models/user_model.dart`

**What it does:** Defines what a "User" looks like in our app.

**Think of it as a form:**
```
┌─────────────────────────────────┐
│ User Profile Form               │
├─────────────────────────────────┤
│ ID: [auto-generated]            │
│ Email: [required]               │
│ Display Name: [optional]        │
│ Bio: [optional, max 150 chars]  │
│ Interests: [list of strings]    │
│ Is Online: [yes/no]             │
└─────────────────────────────────┘
```

**Key methods explained:**

```dart
// 1. fromMap() - Convert Firebase data → Dart object
// When Firebase gives us: {"email": "john@example.com", "displayName": "John"}
UserModel.fromMap(firebaseData, odocId) // → UserModel object we can use

// 2. toMap() - Convert Dart object → Firebase data
// When saving to Firebase:
user.toMap() // → {"email": "john@example.com", "displayName": "John"}

// 3. copyWith() - Create modified copy (immutability)
// Instead of: user.displayName = "New Name" (mutating = BAD)
// We do: newUser = user.copyWith(displayName: "New Name") (GOOD)
```

**Why `copyWith`?** Flutter works best with immutable data (data that doesn't change). Instead of modifying existing objects, we create new ones with the changes.

---

### 4. `lib/models/trip_model.dart`

**What it does:** Represents a travel itinerary/journey.

**Structure:**
```dart
TripModel(
  id: "trip123",
  ownerId: "user456",        // Who created this trip
  title: "Goa Beach Trip",
  locations: [...],          // List of places to visit
  startDate: DateTime(...),
  status: TripStatus.planned, // planned → active → completed
  isPublic: true,            // Can others see this trip?
  companionIds: ["user789"], // Friends joining
)
```

**The TripStatus enum:**
```dart
enum TripStatus {
  planned,    // 📋 Just planning
  active,     // 🚗 Currently on this trip
  completed,  // ✅ Trip finished
  cancelled,  // ❌ Trip cancelled
}
```

---

### 5. `lib/models/location_model.dart`

**What it does:** Represents a place/point of interest.

**This is core to Roamly's "hidden gems" feature!**

```dart
LocationModel(
  name: "Secret Waterfall",
  latitude: 15.2993,
  longitude: 74.1240,
  type: LocationType.hiddenGem,  // ← Community-discovered!
  tags: ["waterfall", "swimming", "peaceful"],
  addedBy: "user123",
  likesCount: 42,
)
```

**Location Types:**
| Type | Icon Idea | Description |
|------|-----------|-------------|
| `poi` | 📍 | Generic point of interest |
| `restaurant` | 🍽️ | Eating places |
| `cafe` | ☕ | Coffee shops |
| `scenic` | 🏞️ | Beautiful views |
| `hiddenGem` | 💎 | Community secrets! |
| `campsite` | ⛺ | Camping spots |

---

### 6. `lib/features/auth/screens/splash_screen.dart`

**What it does:** The first screen users see when opening the app.

**Animation breakdown:**
```dart
// 1. Fade in (0% → 60% of animation time)
_fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)

// 2. Scale up with bounce (0% → 60% of animation time)
_scaleAnimation = Tween<double>(begin: 0.8, end: 1.0)
  ..curve: Curves.easeOutBack // ← The "bounce" effect!

// 3. After 2 seconds, navigate to home
Future.delayed(Duration(seconds: 2), () {
  Navigator.pushReplacementNamed(context, '/home');
});
```

**What's `pushReplacementNamed`?**
- `push` → Add new screen on top (can go back)
- `pushReplacement` → Replace current screen (can't go back to splash)

---

### 7. `lib/features/home/screens/home_screen.dart`

**What it does:** Main screen with map placeholder and navigation.

**Components:**

```
┌─────────────────────────────────┐
│ [≡]     Roamly     [🔍] [🔔]   │ ← AppBar
├─────────────────────────────────┤
│                                 │
│         🗺️ Map View            │ ← Will be flutter_map
│       (placeholder)             │
│                                 │
│                         [📍]    │ ← FAB: My location
│                         [➕]    │ ← FAB: Add location
├─────────────────────────────────┤
│ 🧭 Explore │ 🗺️ Trips │ 💬 │ 👤 │ ← Bottom Nav
└─────────────────────────────────┘
```

**The Drawer (side menu):**
```dart
Drawer(
  child: ListView(
    children: [
      DrawerHeader(...),        // User avatar + welcome
      ListTile(title: "Home"),
      ListTile(title: "My Trips"),
      ListTile(title: "Find Companions"),
      ListTile(title: "Hidden Gems"),
      Divider(),
      ListTile(title: "Settings"),
    ],
  ),
)
```

---

### 8. `lib/main.dart`

**What it does:** The app's entry point - where everything starts.

```dart
void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Prepare Flutter engine
  runApp(const RoamlyApp());                 // Start the app!
}
```

**Route setup (navigation):**
```dart
routes: {
  '/': (context) => SplashScreen(),      // Starting point
  '/home': (context) => HomeScreen(),    // Main screen
  // Future routes:
  // '/login': (context) => LoginScreen(),
  // '/profile': (context) => ProfileScreen(),
}

// To navigate: Navigator.pushNamed(context, '/home')
```

---

## 🔧 Common Patterns Used

### 1. The Barrel Export Pattern
```dart
// lib/models/models.dart
export 'user_model.dart';
export 'trip_model.dart';
export 'location_model.dart';

// Now instead of 3 imports:
import 'models/user_model.dart';
import 'models/trip_model.dart';
import 'models/location_model.dart';

// Just one import:
import 'package:roamly/models/models.dart';
```

### 2. Private Constructor Pattern
```dart
class AppConstants {
  AppConstants._(); // Private constructor
  
  static const String appName = 'Roamly';
}

// This prevents: 
// var x = AppConstants(); // ❌ Error! Can't instantiate
// Only use: AppConstants.appName // ✅ Access static values
```

### 3. The `const` Keyword
```dart
// Without const - Creates new object every rebuild
child: Text('Hello')

// With const - Reuses same object (better performance)
child: const Text('Hello')
```

---

## 🐛 Issues We Fixed

### Issue 1: Import Path Errors
**Problem:** `../../core/core.dart` didn't resolve correctly from deep folders.

**Solution:** Use package imports instead:
```dart
// Before (relative - fragile)
import '../../core/core.dart';

// After (package - robust)
import 'package:roamly/core/core.dart';
```

### Issue 2: CardTheme vs CardThemeData
**Problem:** Flutter API changed - `cardTheme` now expects `CardThemeData`.

**Solution:**
```dart
// Before
cardTheme: CardTheme(...)  // Old API

// After  
cardTheme: CardThemeData(...) // New API
```

**Lesson:** Always run `flutter analyze` to catch these issues!

---

## 🧪 How to Test

```bash
# Check for code issues
flutter analyze

# Run the app
flutter run

# Run tests
flutter test
```

---

## 📝 Key Takeaways for Beginners

1. **Structure matters** - Good folder organization = easier maintenance
2. **Constants prevent typos** - Define once, use everywhere
3. **Themes = consistency** - One place to control all styling
4. **Models = blueprints** - Define data shape before using it
5. **Separation of concerns** - UI, logic, and data should be separate
6. **Use `flutter analyze`** - Catches bugs before runtime

---

## 🔮 What's Next (Phase 2)

- [ ] Add Firebase to the project
- [ ] Create login/register screens
- [ ] Integrate actual map (flutter_map + OpenStreetMap)
- [ ] Set up Provider for state management

---

*Happy coding! Remember: Every expert was once a beginner. 🚀*
