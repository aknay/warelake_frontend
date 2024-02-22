# Warelake: Inventory Organizer

[![made-with-flutter](https://img.shields.io/badge/Made%20with-Flutter-1f425f.svg)](https://flutter.dev/)
![GitHub Release](https://img.shields.io/github/v/release/aknay/warelake_frontend)

#### Mobile Apps
[<img src="resources/images/google-play-badge.png" height="50">](https://play.google.com/store/apps/details?id=io.maker.warelake)

<p align="center">
    <img src="screenshots/flutter_01.png" alt="Items" width="200"/>
    <img src="screenshots/flutter_02.png" alt="Item Group" width="200"/>
    <img src="screenshots/flutter_03.png" alt="Drawer" width="200"/>
    <img src="screenshots/flutter_04.png" alt="Stock Transaction" width="200"/>
</p>


# To run build runner
- `dart run build_runner build`

# To generate icon
- `dart run flutter_launcher_icons`

# To build app for release
- `flutter build appbundle`

# To take screenshot of the screen
- `flutter screenshot`

## List flutter and run it
- `flutter emulators`
- `flutter emulators --launch <emulator id>`
- `flutter run`

# To remove emulator lock
- `rm ~/.android/avd/Pixel_6_API_34.avd/*.lock`

# How to generate firebase_options.dart
- https://stackoverflow.com/a/70405060 

# How to generate keystore.jks
- `keytool -genkey -v -keystore keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias <Alias Key>`
- paste `keystore.jks` at the folder android/app