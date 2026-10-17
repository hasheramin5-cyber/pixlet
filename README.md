# Pixlet

<p align="center">
  <img src="assets/branding/pixlet - b.png" alt="Pixlet logo" width="120">
</p>

<p align="center">
  <strong>A pixel-art studio for creating, editing, and exporting pixel art.</strong>
  <br>
  Built with Flutter and Dart.
</p>

<p align="center">
  <a href="https://github.com/hasheramin5-cyber/pixlet/releases/latest">Download for Android</a>
  ·
  <a href="https://github.com/hasheramin5-cyber/pixlet">Source Code</a>
</p>

---

## Overview

Pixlet is an offline-first pixel-art editor designed to make creating and managing pixel artwork simple. Draw on a customizable grid, explore color palettes, manage projects locally, and export artwork as PNG files.

## Features

- **Pixel Canvas** — Create artwork on 16×16, 32×32, and 64×64 grids.
- **Drawing Tools** — Pencil, eraser, flood fill, and eyedropper.
- **Canvas Navigation** — Pan, zoom, and toggle the grid overlay.
- **Color Studio** — Built-in palettes, custom HSV/hex colors, and recent colors.
- **Undo & Redo** — Revert or restore recent edits.
- **Project Gallery** — Save, rename, browse, and delete projects locally.
- **PNG Export** — Export at multiple scales with optional transparency.
- **Sharing** — Share exported artwork using your device's native sharing interface.

## Download

Get the latest Android APK from [GitHub Releases](https://github.com/hasheramin5-cyber/pixlet/releases/latest).

1. Download the APK to your Android device.
2. Open the downloaded file.
3. Allow installation from that source if Android requests permission.
4. Install and launch Pixlet.

## Run Locally

**Requirements:** Flutter SDK and Dart SDK.

```bash
git clone https://github.com/hasheramin5-cyber/pixlet.git
cd pixlet
flutter pub get
flutter run
```

## Tech Stack

- **Flutter** — Cross-platform UI framework
- **Dart** — Application logic
- **Shared Preferences** — Local project persistence
- **Path Provider** — File-system path access
- **Share Plus** — Native sharing integration

## Project Structure

```text
lib/
├── models/      # Canvas data, tools, palettes, metadata
├── painters/    # Canvas and thumbnail rendering
├── screens/     # Studio and project gallery
├── services/    # Storage and PNG export
├── state/       # Canvas state and edit history
└── widgets/     # Reusable UI components
```

## Project Status

The initial Android release is available. Pixlet is an actively developed project.

---

**Pixlet** · Built with Flutter and Dart.
