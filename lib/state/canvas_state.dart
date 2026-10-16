import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/pixel_canvas_data.dart';
import '../models/project_metadata.dart';
import '../models/tool_type.dart';
import '../models/color_palette.dart';
import '../services/storage_service.dart';

class CanvasState extends ChangeNotifier {
  static const int maxHistorySteps = 30;
  static const int maxRecentColors = 12;

  late ProjectMetadata _currentProject;
  late PixelCanvasData _canvasData;

  ToolType _currentTool = ToolType.pencil;
  Color _selectedColor = const Color(0xFFFF004D); // Vibrant coral red
  bool _showGrid = true;
  bool _isDirty = false;

  PaletteCollection _activePalette = PredefinedPalettes.pico8;
  final List<Color> _recentColors = [
    const Color(0xFFFF004D),
    const Color(0xFFFFEC27),
    const Color(0xFF00E436),
    const Color(0xFF29ADFF),
    const Color(0xFF000000),
    const Color(0xFFFFF1E8),
  ];

  final List<PixelCanvasData> _undoStack = [];
  final List<PixelCanvasData> _redoStack = [];

  bool _isStrokeInProgress = false;
  PixelCanvasData? _strokeInitialSnapshot;

  CanvasState({ProjectMetadata? initialProject}) {
    if (initialProject != null) {
      loadProject(initialProject);
    } else {
      _initNewCanvas(name: 'Untitled 16x16', width: 16, height: 16);
    }
  }

  // Getters
  ProjectMetadata get currentProject => _currentProject;
  PixelCanvasData get canvasData => _canvasData;
  ToolType get currentTool => _currentTool;
  Color get selectedColor => _selectedColor;
  bool get showGrid => _showGrid;
  bool get isDirty => _isDirty;
  PaletteCollection get activePalette => _activePalette;
  List<Color> get recentColors => List.unmodifiable(_recentColors);
  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;
  int get canvasWidth => _canvasData.width;
  int get canvasHeight => _canvasData.height;

  void _initNewCanvas({
    required String name,
    required int width,
    required int height,
  }) {
    _canvasData = PixelCanvasData(width: width, height: height);
    final now = DateTime.now();
    _currentProject = ProjectMetadata(
      id: 'proj_${now.millisecondsSinceEpoch}',
      name: name,
      width: width,
      height: height,
      createdAt: now,
      modifiedAt: now,
      pixels: _canvasData.toList(),
    );
    _undoStack.clear();
    _redoStack.clear();
    _isDirty = false;
    _isStrokeInProgress = false;
  }

  void loadProject(ProjectMetadata project) {
    _currentProject = project;
    _canvasData = PixelCanvasData(
      width: project.width,
      height: project.height,
      initialPixels: project.pixels,
    );
    _undoStack.clear();
    _redoStack.clear();
    _isDirty = false;
    _isStrokeInProgress = false;
    notifyListeners();
  }

  void newProject({
    required String name,
    required int width,
    required int height,
  }) {
    _initNewCanvas(name: name, width: width, height: height);
    notifyListeners();
  }

  void setTool(ToolType tool) {
    if (_currentTool == tool) return;
    _currentTool = tool;
    HapticFeedback.selectionClick();
    notifyListeners();
  }

  void setColor(Color color) {
    if (_selectedColor.value == color.value) return;
    _selectedColor = color;
    _addToRecentColors(color);
    HapticFeedback.selectionClick();
    notifyListeners();
  }

  void setActivePalette(PaletteCollection palette) {
    _activePalette = palette;
    notifyListeners();
  }

  void toggleGrid() {
    _showGrid = !_showGrid;
    HapticFeedback.selectionClick();
    notifyListeners();
  }

  void _addToRecentColors(Color color) {
    _recentColors.removeWhere((c) => c.value == color.value);
    _recentColors.insert(0, color);
    if (_recentColors.length > maxRecentColors) {
      _recentColors.removeLast();
    }
  }

  void _pushUndoSnapshot(PixelCanvasData snapshot) {
    _undoStack.add(snapshot);
    if (_undoStack.length > maxHistorySteps) {
      _undoStack.removeAt(0);
    }
    _redoStack.clear();
    _isDirty = true;
  }

  // Pointer gesture handlers
  void handlePointerDown(int x, int y) {
    if (!_canvasData.isWithinBounds(x, y)) return;

    if (_currentTool == ToolType.pan) {
      return; // Pan handled by viewport
    }

    if (_currentTool == ToolType.eyedropper) {
      final sampled = _canvasData.getPixel(x, y);
      if (sampled.alpha > 0) {
        setColor(sampled);
        setTool(ToolType.pencil);
      }
      return;
    }

    if (_currentTool == ToolType.bucket) {
      final snapshot = _canvasData.clone();
      final changed = _canvasData.floodFill(x, y, _selectedColor);
      if (changed) {
        _pushUndoSnapshot(snapshot);
        HapticFeedback.lightImpact();
        notifyListeners();
      }
      return;
    }

    // Pencil or Eraser
    _isStrokeInProgress = true;
    _strokeInitialSnapshot = _canvasData.clone();
    _applyPaint(x, y);
  }

  void handlePointerMove(int x, int y) {
    if (!_isStrokeInProgress) return;
    if (_currentTool != ToolType.pencil && _currentTool != ToolType.eraser) return;
    _applyPaint(x, y);
  }

  void handlePointerUp() {
    if (!_isStrokeInProgress) return;
    _isStrokeInProgress = false;

    if (_strokeInitialSnapshot != null) {
      // Check if anything actually changed during the stroke
      bool changed = false;
      final currentList = _canvasData.rawPixels;
      final initialList = _strokeInitialSnapshot!.rawPixels;
      for (int i = 0; i < currentList.length; i++) {
        if (currentList[i] != initialList[i]) {
          changed = true;
          break;
        }
      }

      if (changed) {
        _pushUndoSnapshot(_strokeInitialSnapshot!);
        _isDirty = true;
      }
      _strokeInitialSnapshot = null;
    }
    notifyListeners();
  }

  void _applyPaint(int x, int y) {
    if (!_canvasData.isWithinBounds(x, y)) return;

    bool changed = false;
    if (_currentTool == ToolType.pencil) {
      changed = _canvasData.setPixel(x, y, _selectedColor);
    } else if (_currentTool == ToolType.eraser) {
      changed = _canvasData.erasePixel(x, y);
    }

    if (changed) {
      notifyListeners();
    }
  }

  void undo() {
    if (!canUndo) return;
    final current = _canvasData.clone();
    _redoStack.add(current);
    final previous = _undoStack.removeLast();
    _canvasData = previous;
    _isDirty = true;
    HapticFeedback.lightImpact();
    notifyListeners();
  }

  void redo() {
    if (!canRedo) return;
    final current = _canvasData.clone();
    _undoStack.add(current);
    final next = _redoStack.removeLast();
    _canvasData = next;
    _isDirty = true;
    HapticFeedback.lightImpact();
    notifyListeners();
  }

  void clearCanvas() {
    if (!_canvasData.hasContent()) return;
    final snapshot = _canvasData.clone();
    _pushUndoSnapshot(snapshot);
    _canvasData.clear();
    _isDirty = true;
    HapticFeedback.mediumImpact();
    notifyListeners();
  }

  Future<void> saveCurrentProject() async {
    final now = DateTime.now();
    _currentProject = _currentProject.copyWith(
      modifiedAt: now,
      pixels: _canvasData.toList(),
    );
    await StorageService.saveProject(_currentProject);
    _isDirty = false;
    HapticFeedback.lightImpact();
    notifyListeners();
  }

  void renameCurrentProject(String newName) {
    _currentProject = _currentProject.copyWith(
      name: newName,
      modifiedAt: DateTime.now(),
    );
    _isDirty = true;
    notifyListeners();
  }
}
