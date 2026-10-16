import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/project_metadata.dart';
import '../models/pixel_canvas_data.dart';

class StorageService {
  static const String _projectsKey = 'pixlet_saved_projects_v1';

  static Future<List<ProjectMetadata>> loadProjects() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_projectsKey);
      if (jsonString == null || jsonString.isEmpty) {
        // Seed default starter project if empty
        final initial = _createStarterProjects();
        await saveAllProjects(initial);
        return initial;
      }
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((item) => ProjectMetadata.fromJson(item)).toList();
    } catch (e) {
      debugPrint('Error loading projects: $e');
      return _createStarterProjects();
    }
  }

  static Future<void> saveAllProjects(List<ProjectMetadata> projects) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(projects.map((p) => p.toJson()).toList());
      await prefs.setString(_projectsKey, jsonString);
    } catch (e) {
      debugPrint('Error saving all projects: $e');
    }
  }

  static Future<void> saveProject(ProjectMetadata project) async {
    try {
      final projects = await loadProjects();
      final index = projects.indexWhere((p) => p.id == project.id);
      if (index >= 0) {
        projects[index] = project;
      } else {
        projects.insert(0, project);
      }
      await saveAllProjects(projects);
    } catch (e) {
      debugPrint('Error saving project: $e');
    }
  }

  static Future<void> deleteProject(String id) async {
    try {
      final projects = await loadProjects();
      projects.removeWhere((p) => p.id == id);
      await saveAllProjects(projects);
    } catch (e) {
      debugPrint('Error deleting project: $e');
    }
  }

  static Future<void> renameProject(String id, String newName) async {
    try {
      final projects = await loadProjects();
      final index = projects.indexWhere((p) => p.id == id);
      if (index >= 0) {
        projects[index] = projects[index].copyWith(
          name: newName,
          modifiedAt: DateTime.now(),
        );
        await saveAllProjects(projects);
      }
    } catch (e) {
      debugPrint('Error renaming project: $e');
    }
  }

  static List<ProjectMetadata> _createStarterProjects() {
    // 16x16 Pixel Heart starter
    final heartData = PixelCanvasData(width: 16, height: 16);
    final heartRed = const Color(0xFFFF004D);
    final darkOutline = const Color(0xFF7E2553);
    final highlight = const Color(0xFFFF77A8);

    // Cute retro 16x16 Heart
    const heartCoords = [
      // Left lobe
      PointInt(4, 3), PointInt(5, 3),
      PointInt(3, 4), PointInt(4, 4), PointInt(5, 4), PointInt(6, 4),
      // Right lobe
      PointInt(10, 3), PointInt(11, 3),
      PointInt(9, 4), PointInt(10, 4), PointInt(11, 4), PointInt(12, 4),
      // Mid body
      PointInt(2, 5), PointInt(3, 5), PointInt(4, 5), PointInt(5, 5), PointInt(6, 5), PointInt(7, 5), PointInt(8, 5), PointInt(9, 5), PointInt(10, 5), PointInt(11, 5), PointInt(12, 5), PointInt(13, 5),
      PointInt(2, 6), PointInt(3, 6), PointInt(4, 6), PointInt(5, 6), PointInt(6, 6), PointInt(7, 6), PointInt(8, 6), PointInt(9, 6), PointInt(10, 6), PointInt(11, 6), PointInt(12, 6), PointInt(13, 6),
      PointInt(2, 7), PointInt(3, 7), PointInt(4, 7), PointInt(5, 7), PointInt(6, 7), PointInt(7, 7), PointInt(8, 7), PointInt(9, 7), PointInt(10, 7), PointInt(11, 7), PointInt(12, 7), PointInt(13, 7),
      // Lower taper
      PointInt(3, 8), PointInt(4, 8), PointInt(5, 8), PointInt(6, 8), PointInt(7, 8), PointInt(8, 8), PointInt(9, 8), PointInt(10, 8), PointInt(11, 8), PointInt(12, 8),
      PointInt(4, 9), PointInt(5, 9), PointInt(6, 9), PointInt(7, 9), PointInt(8, 9), PointInt(9, 9), PointInt(10, 9), PointInt(11, 9),
      PointInt(5, 10), PointInt(6, 10), PointInt(7, 10), PointInt(8, 10), PointInt(9, 10), PointInt(10, 10),
      PointInt(6, 11), PointInt(7, 11), PointInt(8, 11), PointInt(9, 11),
      PointInt(7, 12), PointInt(8, 12),
    ];

    for (final pt in heartCoords) {
      heartData.setPixel(pt.x, pt.y, heartRed);
    }
    // Highlight sparkles
    heartData.setPixel(4, 4, highlight);
    heartData.setPixel(5, 4, highlight);
    heartData.setPixel(4, 5, highlight);

    // Cute Golden Potion 16x16 starter
    final potionData = PixelCanvasData(width: 16, height: 16);
    final gold = const Color(0xFFFFEC27);
    final orange = const Color(0xFFFFA300);
    final cork = const Color(0xFFAB5236);
    final glass = const Color(0xFFC2C3C7);

    // Cork
    potionData.setPixel(7, 3, cork);
    potionData.setPixel(8, 3, cork);
    // Neck
    potionData.setPixel(7, 4, glass);
    potionData.setPixel(8, 4, glass);
    // Flask Body
    for (int y = 5; y <= 11; y++) {
      int minX = 7 - (y - 4);
      int maxX = 8 + (y - 4);
      if (minX < 4) minX = 4;
      if (maxX > 11) maxX = 11;
      for (int x = minX; x <= maxX; x++) {
        if (x == minX || x == maxX || y == 11) {
          potionData.setPixel(x, y, glass);
        } else {
          potionData.setPixel(x, y, y >= 8 ? orange : gold);
        }
      }
    }
    potionData.setPixel(6, 7, const Color(0xFFFFFFFF));

    final now = DateTime.now();

    return [
      ProjectMetadata(
        id: 'starter_heart_16',
        name: 'Retro 8-Bit Heart',
        width: 16,
        height: 16,
        createdAt: now.subtract(const Duration(minutes: 10)),
        modifiedAt: now.subtract(const Duration(minutes: 5)),
        pixels: heartData.toList(),
      ),
      ProjectMetadata(
        id: 'starter_potion_16',
        name: 'Golden Elixir',
        width: 16,
        height: 16,
        createdAt: now.subtract(const Duration(minutes: 20)),
        modifiedAt: now.subtract(const Duration(minutes: 12)),
        pixels: potionData.toList(),
      ),
    ];
  }
}
