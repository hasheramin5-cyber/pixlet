# Pixlet

Pixlet is an offline-first pixel art studio application built with Flutter and Dart. It provides a grid canvas for creating, editing, managing, and exporting pixel art on mobile and desktop platforms.

## Features

- **Canvas Resolutions**: Create 16x16, 32x32, or 64x64 pixel grids.
- **Drawing Tools**:
  - Pencil: Tap or drag to draw individual pixels.
  - Eraser: Reset pixels to transparent.
  - Flood Fill: Breadth-first search (BFS) fill for contiguous areas.
  - Eyedropper: Sample color values directly from the canvas.
  - Pan & Zoom: Viewport navigation with controls for center/reset, zoom in/out, and grid overlay toggle.
- **Gesture Handling**: Supports single-finger drawing and multi-touch pinch-to-zoom and pan via `InteractiveViewer` to avoid drawing conflicts.
- **Color Palettes**:
  - Predefined palettes: PICO-8 Classics, GameBoy DMG, Cyberpunk Neon, Pastel Studio, and Earth & Clay.
  - Custom Color Studio dialog with HSV sliders, hex string input, and live comparison.
  - Recent color history tracking up to 12 swatches.
- **History & Canvas Control**:
  - Snapshot-based undo and redo up to 30 steps.
  - Clear canvas with confirmation prompt.
- **Local Persistence**:
  - Offline storage using `shared_preferences` with serialized JSON.
  - Project gallery with live thumbnail rendering, dimensions, and relative timestamps.
  - Project renaming, deletion, and auto-save on navigation.
  - Built-in starter artworks on first launch.
- **Export & Sharing**:
  - Native PNG generation via `dart:ui` with nearest-neighbor sampling.
  - Export scale options: 1x (native), 8x, 16x, and 32x.
  - Transparent background toggle.
  - Native platform sharing via `share_plus` and `path_provider`.

## Project Structure

- `lib/models/`: Pixel grid array (`PixelCanvasData`), tool types (`ToolType`), color palettes (`PaletteCollection`), and project metadata (`ProjectMetadata`).
- `lib/painters/`: Custom painters for nearest-neighbor canvas rendering, checkerboard background, and gallery thumbnails.
- `lib/services/`: Local persistence (`StorageService`) and PNG encoding and sharing (`ExportService`).
- `lib/state/`: Canvas state and history management (`CanvasState`).
- `lib/widgets/`: Viewport, tool bar, palette bar, project card, and modal dialogs.
- `lib/screens/`: Studio workspace (`StudioScreen`) and project gallery (`GalleryScreen`).

## Prerequisites

- Flutter SDK 3.0.0 or higher (Dart SDK `>=3.0.0 <4.0.0`).
- Target device, simulator/emulator, or desktop build environment.

## Getting Started

1. Open the project root directory.
2. If platform folders (`android/`, `ios/`, `windows/`, etc.) are not present, generate platform scaffolding:
   ```bash
   flutter create .
   ```
3. Fetch dependencies:
   ```bash
   flutter pub get
   ```
4. Run the application:
   ```bash
   flutter run
   ```

## Project Status

Core MVP implementation complete. All drawing tools, palette management, undo/redo history, local storage, and PNG export pipelines are implemented in `lib/`.
