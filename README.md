# Al-Qur'an Digital

A Quran application built with Flutter and Dart, designed to provide a convenient experience for reading the Holy Quran and accessing essential Islamic features.

## Features

- **114 Surahs** — Browse the complete list of Quranic surahs.
- **Quran Reading** — Read Arabic verses with Indonesian translations.
- **Offline Reading** — Access bundled Quran data without an internet connection.
- **Audio Recitation** — Listen to Quran recitations from multiple selected reciters.
- **Audio Playback Controls** — Play individual verses or complete surahs, with playback controls and automatic verse progression.
- **Bookmarks** — Save and revisit specific verses.
- **Last Read** — Continue reading from the previously opened surah.
- **Favorites** — Save favorite surahs for quick access.
- **Prayer Schedule** — Calculate daily prayer times based on the user's location.
- **Location Map** — Display the user's current location on a map.
- **Learning and Additional Pages** — Access other supporting sections of the application.

## Screenshots

Screenshots of the application will be added here.

## Technology Stack

- **Flutter** — UI framework.
- **Dart** — Programming language.
- **Shared Preferences** — Local data persistence.
- **HTTP** — API communication.
- **Just Audio** — Audio playback.
- **Geolocator** — Device location services.
- **Flutter Map** — Interactive map display.
- **LatLong2** — Geographic coordinates.
- **Adhan** — Prayer time calculations.

## Data and Storage

The application uses a combination of local and remote data sources:

- Bundled Quran data stored in `assets/data/`.
- Locally cached surah data for offline access.
- Quran data retrieved from the EQuran API when needed.
- User preferences, bookmarks, favorites, and last-read information stored locally.

## Project Structure

```text
flutter_firstaplication/
├── assets/
│   ├── data/
│   └── images/
├── lib/
│   ├── main.dart
│   ├── halaman_bacaan.dart
│   ├── halaman_bookmark.dart
│   ├── halaman_belajar.dart
│   ├── halaman_jadwal_sholat.dart
│   ├── halaman_lainnya.dart
│   ├── api_quran.dart
│   ├── data_quran_lokal.dart
│   └── data_surah.dart
├── test/
├── pubspec.yaml
└── README.md
```

## Getting Started

### Prerequisites

Make sure you have installed:

- Flutter SDK
- Dart SDK
- Android Studio or Visual Studio Code
- An Android device or emulator

### Installation

1. Clone this repository:

```bash
git clone https://github.com/ginanjar-nom/quran-flutter-app.git
```

2. Navigate to the project directory:

```bash
cd quran-flutter-app
```

3. Install dependencies:

```bash
flutter pub get
```

4. Run the application:

```bash
flutter run
```

## Development Status

This project is actively developed as a personal learning and portfolio project. New features, improvements, and UI refinements are added progressively.

## Author

**Ginanjar Anom Suwito**

GitHub: [ginanjar-nom](https://github.com/ginanjar-nom)
