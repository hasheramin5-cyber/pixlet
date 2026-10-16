import 'package:flutter/material.dart';
import '../models/project_metadata.dart';
import '../models/pixel_canvas_data.dart';
import '../services/storage_service.dart';
import '../widgets/project_card.dart';
import '../widgets/new_project_dialog.dart';
import 'studio_screen.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<ProjectMetadata> _projects = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    setState(() => _isLoading = true);
    final list = await StorageService.loadProjects();
    if (mounted) {
      setState(() {
        _projects = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _openStudio(ProjectMetadata project) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => StudioScreen(project: project),
      ),
    );
    _loadProjects();
  }

  Future<void> _createNewProject() async {
    final result = await showDialog<NewProjectResult>(
      context: context,
      builder: (ctx) => const NewProjectDialog(),
    );

    if (result != null) {
      final now = DateTime.now();
      final newCanvas = PixelCanvasData(width: result.size, height: result.size);
      final newProj = ProjectMetadata(
        id: 'proj_${now.millisecondsSinceEpoch}',
        name: result.name,
        width: result.size,
        height: result.size,
        createdAt: now,
        modifiedAt: now,
        pixels: newCanvas.toList(),
      );

      await StorageService.saveProject(newProj);
      await _openStudio(newProj);
    }
  }

  void _renameProject(ProjectMetadata project) {
    final controller = TextEditingController(text: project.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFFCFAF6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFE8E4DA)),
        ),
        title: const Text(
          'Rename Artwork',
          style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF2B2D42)),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE4DFD5)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF8D99AE))),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                await StorageService.renameProject(project.id, newName);
                _loadProjects();
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2B2D42),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteProject(ProjectMetadata project) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFFCFAF6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFE8E4DA)),
        ),
        title: Text(
          'Delete "${project.name}"?',
          style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF2B2D42)),
        ),
        content: const Text(
          'This action cannot be undone. Are you sure you want to remove this artwork?',
          style: TextStyle(color: Color(0xFF4A4E69), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF8D99AE))),
          ),
          ElevatedButton(
            onPressed: () async {
              await StorageService.deleteProject(project.id);
              _loadProjects();
              if (ctx.mounted) Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF004D),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 800
        ? 4
        : (screenWidth > 520 ? 3 : 2);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCFAF6),
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF2B2D42),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.grid_4x4_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PIXLET',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2B2D42),
                    letterSpacing: 1.0,
                  ),
                ),
                Text(
                  'Pixel-Art Studio',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xCC4A4E69),
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          if (_projects.isNotEmpty)
            Center(
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBE6DC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_projects.length} Works',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4A4E69),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF2B2D42),
                strokeWidth: 2.5,
              ),
            )
          : _projects.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadProjects,
                  color: const Color(0xFF2B2D42),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.78,
                    ),
                    itemCount: _projects.length,
                    itemBuilder: (ctx, i) {
                      final project = _projects[i];
                      return ProjectCard(
                        project: project,
                        onTap: () => _openStudio(project),
                        onRename: () => _renameProject(project),
                        onDelete: () => _deleteProject(project),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewProject,
        backgroundColor: const Color(0xFF2B2D42),
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add_rounded, size: 22),
        label: const Text(
          'New Canvas',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFEAE5DA),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.palette_outlined,
                size: 38,
                color: Color(0xFF8D99AE),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Canvases Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2B2D42),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create your first 16×16, 32×32, or 64×64 pixel canvas and start bringing your creations to life.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF8D99AE),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _createNewProject,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create Canvas'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2B2D42),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
