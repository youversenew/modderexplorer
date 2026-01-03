import 'dart:io';
import 'package:flutter/material.dart';
import 'explorer_ui.dart';
import 'explorer_logic.dart';

class ExplorerApp extends StatefulWidget {
  const ExplorerApp({Key? key}) : super(key: key);

  @override
  State<ExplorerApp> createState() => _ExplorerAppState();
}

class _ExplorerAppState extends State<ExplorerApp> {
  // Logic Controller
  final ExplorerController _controller = ExplorerController();

  // View Mode: true = Grid, false = List
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    // Logicdagi o'zgarishlarni eshitib turish
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Faylni ochish (Windows default dasturi bilan)
  void _openFile(String path) {
    if (Platform.isWindows) {
      Process.run('explorer', [path]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModderTheme.background,
      body: Stack(
        children: [
          // Background Image or Gradient (Optional depth effect)
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0F0F0F), Color(0xFF1A1A1A)],
                ),
              ),
            ),
          ),

          Row(
            children: [
              // -------------------------
              // 1. SIDEBAR (Glass)
              // -------------------------
              GlassBox(
                width: 260,
                margin: const EdgeInsets.all(10),
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                tint: ModderTheme.glassLow,
                blur: 30,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // App Logo / Title
                    Padding(
                      padding: const EdgeInsets.only(left: 12, bottom: 20),
                      child: Row(
                        children: const [
                          Icon(Icons.folder_special_rounded,
                              color: ModderTheme.accent, size: 28),
                          SizedBox(width: 10),
                          Text(
                            "Modder File",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Quick Access Section
                    _buildSectionHeader("Quick Access"),
                    ..._controller.quickAccessPaths.entries.map((entry) {
                      return FileListItem(
                        name: entry.key,
                        isDirectory: true,
                        isSelected: _controller.currentPath == entry.value,
                        customIcon: _getQuickIcon(entry.key),
                        onTap: () => _controller.navigateTo(entry.value),
                      );
                    }),

                    const SizedBox(height: 20),

                    // Drives Section
                    _buildSectionHeader("Drives"),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _controller.drives.length,
                        itemBuilder: (context, index) {
                          final drive = _controller.drives[index];
                          return FileListItem(
                            name: drive,
                            isDirectory: true,
                            customIcon: Icons.storage_rounded,
                            isSelected:
                                _controller.currentPath.startsWith(drive) &&
                                    _controller.currentPath.length == 3,
                            onTap: () => _controller.navigateTo(drive),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // -------------------------
              // 2. MAIN CONTENT AREA
              // -------------------------
              Expanded(
                child: Column(
                  children: [
                    // TOP BAR
                    Container(
                      height: 80,
                      padding: const EdgeInsets.fromLTRB(0, 20, 20, 10),
                      child: Row(
                        children: [
                          // Navigation Buttons
                          IconButton(
                            onPressed: _controller.canGoBack
                                ? _controller.goBack
                                : null,
                            icon: Icon(Icons.arrow_back_ios_new_rounded,
                                color: _controller.canGoBack
                                    ? Colors.white
                                    : Colors.white24,
                                size: 18),
                          ),
                          IconButton(
                            onPressed: _controller.canGoForward
                                ? _controller.goForward
                                : null,
                            icon: Icon(Icons.arrow_forward_ios_rounded,
                                color: _controller.canGoForward
                                    ? Colors.white
                                    : Colors.white24,
                                size: 18),
                          ),
                          IconButton(
                            onPressed: _controller.goToParent,
                            icon: const Icon(Icons.arrow_upward_rounded,
                                color: Colors.white70, size: 20),
                          ),

                          const SizedBox(width: 10),

                          // Address Bar
                          Expanded(
                            child: ModernAddressBar(
                              path: _controller.currentPath,
                              onSubmitted: (value) =>
                                  _controller.navigateTo(value),
                            ),
                          ),

                          const SizedBox(width: 15),

                          // View Toggle
                          IconButton(
                            onPressed: () =>
                                setState(() => _isGridView = !_isGridView),
                            icon: Icon(
                              _isGridView
                                  ? Icons.grid_view_rounded
                                  : Icons.view_list_rounded,
                              color: ModderTheme.accent,
                            ),
                            tooltip: "Switch View",
                          ),

                          // Search Box
                          ModernSearchBox(onChanged: (val) {
                            // Search logic implementation would go here (filtering _controller.files)
                            // For minimal requirements, we just keep the UI ready.
                          }),
                        ],
                      ),
                    ),

                    // FILE GRID / LIST
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(right: 10, bottom: 10),
                        decoration: BoxDecoration(
                          color: ModderTheme.glassLow,
                          borderRadius:
                              BorderRadius.circular(ModderTheme.radiusM),
                          border: Border.all(color: ModderTheme.glassBorder),
                        ),
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(ModderTheme.radiusM),
                          child: Stack(
                            children: [
                              // Loading Indicator
                              if (_controller.isLoading)
                                const Center(
                                    child: CircularProgressIndicator(
                                        color: ModderTheme.accent)),

                              // Error Message
                              if (_controller.errorMessage != null)
                                Positioned(
                                  bottom: 20,
                                  left: 20,
                                  right: 20,
                                  child: GlassBox(
                                    tint: ModderTheme.danger.withOpacity(0.2),
                                    child: Text(
                                      _controller.errorMessage!,
                                      style: const TextStyle(
                                          color: ModderTheme.danger),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),

                              // Content
                              if (!_controller.isLoading)
                                _isGridView ? _buildGrid() : _buildList(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Grid View Implementation
  Widget _buildGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 140, // Item width
        childAspectRatio: 0.8, // Ratio
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _controller.files.length,
      itemBuilder: (context, index) {
        final entity = _controller.files[index];
        final name = entity.uri.pathSegments.lastWhere((e) => e.isNotEmpty);
        final isDir = entity is Directory;

        return FileGridItem(
          name: name,
          isDirectory: isDir,
          size: ExplorerController.getFileSize(entity),
          onTap: () {
            if (isDir) {
              _controller.navigateTo(entity.path);
            } else {
              _openFile(entity.path);
            }
          },
        );
      },
    );
  }

  // List View Implementation
  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: _controller.files.length,
      itemBuilder: (context, index) {
        final entity = _controller.files[index];
        final name = entity.uri.pathSegments.lastWhere((e) => e.isNotEmpty);
        final isDir = entity is Directory;

        return FileListItem(
          name: name,
          isDirectory: isDir,
          onTap: () {
            if (isDir) {
              _controller.navigateTo(entity.path);
            } else {
              _openFile(entity.path);
            }
          },
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 8, top: 10),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Colors.white38,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  IconData _getQuickIcon(String key) {
    switch (key) {
      case 'Desktop':
        return Icons.desktop_windows_rounded;
      case 'Documents':
        return Icons.article_rounded;
      case 'Downloads':
        return Icons.download_rounded;
      case 'Pictures':
        return Icons.image_rounded;
      case 'Music':
        return Icons.music_note_rounded;
      default:
        return Icons.folder_rounded;
    }
  }
}
