# LeetCode Heatmap Android Widget

A Flutter application that fetches a user's LeetCode submission history and renders it as a native Android Home Screen widget.

## 🚀 Getting Started

Follow these simple steps to run the application on your device.

### 1. Clone the Repository
Open your terminal and clone the project:
```bash
git clone https://github.com/Dikshant005/Leet_code_widget
cd leet_code_widget
```

### 2. Install Dependencies
Download the required Flutter packages:
```bash
flutter pub get
```
### 3. Configure Your Username
To display your own LeetCode stats, you need to update the username in the main file.

1. Open `lib/main.dart`.
2. Scroll to the `MyApp` class inside the `build` method.
3. Locate the `LeetCodeHeatMapWidget` and change the string:

```dart
// lib/main.dart

home: const Scaffold(
  body: SafeArea(
    child: Center(
      // Change "krish_Agarwal-" to your LeetCode username
      child: LeetCodeHeatMapWidget(username: "YOUR_USERNAME_HERE"), 
    ),
  ),
),
```
### 4. Run the App
Connect your Android device (or start an emulator) and run:

```bash
flutter run
```
---

## 🛠 Project Challenges & Solutions

During the development of this widget, several technical challenges were encountered. Here is how they were resolved:

### 1. Widget Image Not Fetching ("Image not on disk")
**The Problem:**
Even though the Flutter app was running, the Android widget remained empty or displayed errors in Logcat stating that the image file path was `null` or the file did not exist.

**The Solution:**
* **Path Synchronization:** We moved away from guessing directory paths in Kotlin. Instead, we used `HomeWidget.saveWidgetData` in Flutter to save the **absolute path** of the generated image.
* **Kotlin Update:** We updated `LeetCodeWidgetProvider.kt` to read this exact path string from `SharedPreferences` instead of looking in hardcoded folders.
* **Trigger Logic:** We added a `WidgetsBinding.instance.addPostFrameCallback` inside the Flutter app. This ensures the widget update is triggered **immediately** after the API data is successfully fetched, rather than waiting for a manual refresh.

### 2. Widget Overflow (99,850 Pixel Overflow)
**The Problem:**
When generating the snapshot for the widget in the background, the app crashed with `RenderFlex overflowed by 99850 pixels`. This happened because the background rendering engine has an effectively infinite height, and standard Flutter widgets like `Scaffold` or `Column` (without constraints) tried to expand to fill it.

**The Solution:**
* **Constraint Management:** We removed `Scaffold` and `MaterialApp` from the widget generation code (`StaticHeatMap`) as they are designed for full-screen apps.
* **Fixed Size:** We wrapped the entire layout in a `SizedBox(width: 300, height: 150)` and used a `FittedBox`. This forces the content to scale down to fit the specific box size, preventing it from trying to expand indefinitely into the void.

---

## 📦 Tech Stack
* **Flutter:** UI and Business Logic.
* **Home Widget:** Plugin for bridging Flutter and Android Widgets.
* **GraphQL:** Used to communicate with the LeetCode API.
* **Kotlin:** Used for the native Android Broadcast Receiver to update the widget image.