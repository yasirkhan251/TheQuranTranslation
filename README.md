# Noor — Quran Companion

An Android-first Quran study companion built with React, Vite, and Capacitor, with a responsive emerald-green and cream interface.

## Run the web development version

Install Node.js LTS, then run:

```bash
npm install
npm run dev
```

Open the localhost URL printed by Vite.

## Android app project

Install Android Studio and its Android SDK first, then run in the project folder:

```bash
npm install
npx cap add android
npm run build
npx cap sync android
npx cap open android
```

Once Android Studio opens, allow Gradle to sync. Connect an Android phone with USB debugging enabled or launch an emulator, then press **Run**. To generate a local APK use **Build → Build Bundle(s) / APK(s) → Build APK(s)**. This repository contains source code and Android packaging configuration; it does not contain a prebuilt or signed APK.

## Features in this prototype

- Searchable catalog for all 114 Surahs, with Arabic names and verse counts.
- Reading/listening progress, personal verse notes, and bookmarks.
- Per-Surah local audio uploads with seek, playback speed, and saved playback position.
- Reader controls for Arabic, Roman Urdu, Urdu script, and English translation display.
- Import translations as JSON, and export/restore local user-data backups.
- Responsive mobile UI, light/dark mode, local browser storage and IndexedDB audio storage.

## Translation dataset format

For Quranic accuracy, full verse text and translations are not bundled. Import a verified dataset that you are licensed to use and ensure verse alignment, spelling, and attribution have been reviewed.

```json
{
  "verses": {
    "1": {
      "1": {
        "arabic": "verified Arabic text",
        "roman": "Roman Urdu text",
        "urdu": "اردو ترجمہ",
        "english": "English translation"
      }
    }
  }
}
```

The outer keys are Surah numbers and nested keys are verse numbers.

## Current limitations

- Audio is attached one Surah at a time; bulk import is not implemented yet.
- Background playback, notification controls, and Android lock-screen controls need a native audio service/plugin and real-device testing.
- Notes/progress are local to this app/browser profile. Export backups before clearing app/browser data or changing devices.
- Optional account and cloud sync require a secure backend and authentication.
