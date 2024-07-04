curl -v -X DELETE "http://localhost:8070/emulator/v1/projects/warelakeapp/databases/(default)/documents"
flutter test test/populate_data/tiny_populate_data.dart 
flutter emulators --launch flutter_emulator
flutter run