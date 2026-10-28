# Noor — Quran Companion

An Android-first, responsive Quran study companion built with React, Vite, and Capacitor.

## Features
- Surah catalog covering all 114 Surahs.
- Search and filters for read/listened progress.
- Local progress tracking, bookmarks, and personal verse notes.
- Local audio library with per-Surah uploads, playback speed, seek, and saved playback position.
- Reading view supports Arabic, Roman Urdu, Urdu script, and English text when a verified JSON translation dataset is imported.
- Local backup export/import.
- Emerald green and cream responsive UI with dark mode.

## Run locally
```bash
npm install
npm run dev
```

## Android project
Install Android Studio and the Android SDK, then run:
```bash
npm install @capacitor/android
npm run android:add
npm run android:sync
npm run android:open
```
In Android Studio, sync Gradle and use Build → Build Bundle(s) / APK(s) → Build APK(s). This repo contains source/configuration; no prebuilt or signed APK is committed.

## Translation dataset
For accuracy, this project does not bundle an unverified Quran text/translation corpus. Import a properly verified dataset with appropriate rights and attribution.

Expected format:
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
Keys under `verses` are Surah numbers and their nested keys are verse numbers.

## Limitations
- Audio files are attached manually per Surah; no bulk folder import yet.
- Background audio/lock-screen controls require a native audio service/plugin and device testing.
- Data is local to the browser/app profile. Export backups. Optional cloud accounts require a backend and authentication.
