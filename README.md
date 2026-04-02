# Flutter Signage Media Player
This Flutter app displays a loop of images and videos (digital signage). It cycles through a provided JSON list of media, showing each item for 10 seconds.

## ▶️ How to Run the Project

1. Clone the repository:

```
git clone https://github.com/0rizwan/Signage-Media-Player.git
cd signage_media_player
```

2. Install dependencies:

```
flutter pub get
```

3. Run the application:

```
- On a device or emulator: `flutter run`  
- To build an APK: `flutter build apk --release` (APK will be in `build/app/outputs/flutter-apk/app-release.apk`)

```

---

## 📌 Assumptions Made

* The provided JSON content is valid and accessible
* All media URLs (images/videos) are reachable over the internet
* The device has an active internet connection
* Each media item is displayed strictly for 10 seconds, regardless of video length
* No user interaction is required (app runs automatically in a loop)
* In case of media loading failure, the app safely skips rendering without crashing
