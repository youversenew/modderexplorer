import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Keyboard events
import 'explorer_ui.dart';
import 'explorer_logic.dart';

class ExplorerApp extends StatefulWidget {
  const ExplorerApp({Key? key}) : super(key: key);

  @override
  State<ExplorerApp> createState() => _ExplorerAppState();
}

class _ExplorerAppState extends State<ExplorerApp> {
  final ExplorerController _controller = ExplorerController();
  final FocusNode _keyboardFocus = FocusNode(); 

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
    // Ilova ochilishi bilan klaviatura fokusini olish
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _keyboardFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _keyboardFocus.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // 🖱 CONTEXT MENU LOGIC
  // ---------------------------------------------------------------------------

  void _handleContextMenu(TapDownDetails details, {String? filePath}) {
    final isFile = filePath != null;
    
    // Agar fayl bo'lsa va tanlanmagan bo'lsa, uni tanlab qo'yamiz
    if (isFile && !_controller.selectedPaths.contains(filePath)) {
      _controller.selectFile(filePath!, multiSelect: false);
    }

    // Custom Glass Menu chiqarish
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Dismiss",
      barrierColor: Colors.transparent,
      pageBuilder: (_, __, ___) {
        return Stack(
          children: [
            Positioned(
              top: details.globalPosition.dy,
              left: details.globalPosition.dx,
              child: Material(
                color: Colors.transparent,
                child: MacosContextMenu(
                  items: isFile ? _getFileMenuOptions(filePath!) : _getBgMenuOptions(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<ContextMenuItem> _getFileMenuOptions(String path) {
    return [
      ContextMenuItem(
        label: "Open", icon: Icons.open_in_new_rounded,
        onTap: () => _controller.openFile(path),
      ),
      ContextMenuItem(
        label: "Open With...", icon: Icons.app_registration_rounded,
        onTap: () => _controller.openWith(path),
      ),
      ContextMenuItem.divider(),
      ContextMenuItem(
        label: "Copy", icon: Icons.copy_rounded, shortcut: "Ctrl+C",
        onTap: () => _controller.copyToClipboard(),
      ),
      ContextMenuItem(
        label: "Cut", icon: Icons.content_cut_rounded, shortcut: "Ctrl+X",
        onTap: () => _controller.copyToClipboard(isCut: true),
      ),
      ContextMenuItem(
        label: "Create Shortcut", icon: Icons.link_rounded,
        onTap: () => _controller.createShortcut(path),
      ),
      ContextMenuItem.divider(),
      ContextMenuItem(
        label: "Rename", icon: Icons.edit_rounded, shortcut: "F2",
        onTap: () => MacosDialogs.showInput(context, "Rename File", (val) => _controller.renameEntity(path, val)),
      ),
      ContextMenuItem(
        label: "Move to Trash", icon: Icons.delete_outline_rounded, shortcut: "Del",
        onTap: _controller.deleteSelected,
      ),
    ];
  }

  List<ContextMenuItem> _getBgMenuOptions() {
    return [
      ContextMenuItem(
        label: "New Folder", icon: Icons.create_new_folder_rounded,
        onTap: () => MacosDialogs.showInput(context, "New Folder Name", (val) => _controller.createFolder(val)),
      ),
      ContextMenuItem.divider(),
      ContextMenuItem(
        label: "Paste", icon: Icons.content_paste_rounded, shortcut: "Ctrl+V",
        onTap: _controller.hasClipboard ? _controller.pasteFromClipboard : null,
      ),
      ContextMenuItem(
        label: "Select All", icon: Icons.select_all_rounded, shortcut: "Ctrl+A",
        onTap: _controller.selectAll,
      ),
      ContextMenuItem(
        label: "Refresh", icon: Icons.refresh_rounded, shortcut: "F5",
        onTap: _controller.refresh,
      ),
    ];
  }

  // ---------------------------------------------------------------------------
  // ⌨️ KEYBOARD EVENTS
  // ---------------------------------------------------------------------------
  void _handleKey(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.delete) {
        _controller.deleteSelected();
      } else if (event.isControlPressed && event.logicalKey == LogicalKeyboardKey.keyA) {
        _controller.selectAll();
      } else if (event.isControlPressed && event.logicalKey == LogicalKeyboardKey.keyC) {
        _controller.copyToClipboard();
      } else if (event.isControlPressed && event.logicalKey == LogicalKeyboardKey.keyV) {
        _controller.pasteFromClipboard();
      } else if (event.isControlPressed && event.logicalKey == LogicalKeyboardKey.keyX) {
        _controller.copyToClipboard(isCut: true);
      } else if (event.logicalKey == LogicalKeyboardKey.f5) {
        _controller.refresh();
      }
    }
  }

  // ---------------------------------------------------------------------------
  // 🖥 UI BUILD
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: RawKeyboardListener(
        focusNode: _keyboardFocus,
        onKey: _handleKey,
        autofocus: true,
        child: Stack(
          children: [
            // 1. BACKGROUND WALLPAPER (MacOS Monterey Abstract Style)
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF352A47), // Dark Purple
                      Color(0xFF1D1729), // Deep Dark
                      Color(0xFF131313), // Almost Black
                    ],
                    stops: [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),

            // 2. MAIN LAYOUT (Sidebar + Content)
            Row(
              children: [
                // --- SIDEBAR (Glass Panel) ---
                MacosGlassBox(
                  width: 250,
                  tint: MacosTheme.sidebarBg,
                  blur: 50,
                  borderRadius: 0, // Left side full height
                  padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Traffic Lights (Window Controls)
                      const SizedBox(height: 18),
                      const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: MacosTrafficLights(),
                      ),
                      const SizedBox(height: 30),
                      
                      // Favorites Section
                      _sidebarHeader("Favorites"),
                      ..._controller.quickAccessPaths.entries.map((e) => MacosSidebarItem(
                        label: e.key,
                        icon: _getIconForPath(e.key),
                        isSelected: _controller.currentPath == e.value,
                        onTap: () => _controller.navigateTo(e.value),
                      )),

                      const SizedBox(height: 20),
                      
                      // Locations/Drives Section
                      _sidebarHeader("Locations"),
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: _controller.drives.length,
                          itemBuilder: (context, index) {
                            final drive = _controller.drives[index];
                            return MacosSidebarItem(
                              label: drive,
                              icon: Icons.computer_rounded, // Drive icon
                              isSelected: _controller.currentPath.startsWith(drive) && _controller.currentPath.length < 5,
                              onTap: () => _controller.navigateTo(drive),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // --- MAIN CONTENT AREA ---
                Expanded(
                  child: Column(
                    children: [
                      // TOP TOOLBAR (Navigation + Title + Search)
                      Container(
                        height: 55,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            // Back / Forward Buttons
                            IconButton(
                              onPressed: _controller.canGoBack ? _controller.goBack : null,
                              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                              color: _controller.canGoBack ? Colors.white : Colors.white24,
                              splashRadius: 20,
                              tooltip: "Back",
                            ),
                            IconButton(
                              onPressed: _controller.canGoForward ? _controller.goForward : null,
                              icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                              color: _controller.canGoForward ? Colors.white : Colors.white24,
                              splashRadius: 20,
                              tooltip: "Forward",
                            ),
                            
                            const SizedBox(width: 15),
                            
                            // Current Folder Title (MacOS Style Breadcrumb)
                            Icon(
                              _controller.currentPath == "C:\\" ? Icons.computer : Icons.folder_open_rounded,
                              color: Colors.white70, 
                              size: 20
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _controller.currentPath.split('\\').last.isEmpty 
                                  ? "My Computer" 
                                  : _controller.currentPath.split('\\').last,
                              style: const TextStyle(
                                color: Colors.white, 
                                fontWeight: FontWeight.bold, 
                                fontSize: 16
                              ),
                            ),
                            
                            const Spacer(),
                            
                            // Spotlight Search
                            SpotlightSearchBar(
                              onChanged: _controller.search,
                            ),
                          ],
                        ),
                      ),

                      // FILE GRID
                      Expanded(
                        child: MacosGlassBox(
                          margin: const EdgeInsets.fromLTRB(0, 0, 10, 10), // Right/Bottom margin
                          tint: MacosTheme.contentBg,
                          blur: 40,
                          borderRadius: MacosTheme.radiusL,
                          child: GestureDetector(
                            // Right click on empty space
                            onSecondaryTapDown: (d) => _handleContextMenu(d), 
                            child: Stack(
                              children: [
                                // Loading Indicator
                                if (_controller.isLoading)
                                  const Center(child: CircularProgressIndicator(color: Colors.white)),

                                // Files Grid
                                if (!_controller.isLoading)
                                  GridView.builder(
                                    padding: const EdgeInsets.all(20),
                                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                      maxCrossAxisExtent: 130, // Item width
                                      childAspectRatio: 0.85,  // Ratio
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 16,
                                    ),
                                    itemCount: _controller.files.length,
                                    itemBuilder: (context, index) {
                                      final entity = _controller.files[index];
                                      final name = entity.uri.pathSegments.lastWhere((e) => e.isNotEmpty);
                                      final isDir = entity is Directory;
                                      final path = entity.path;

                                      // Draggable Support
                                      return Draggable<String>(
                                        data: path,
                                        feedback: Material(
                                          color: Colors.transparent,
                                          child: Opacity(
                                            opacity: 0.7,
                                            child: Icon(
                                              isDir ? Icons.folder_rounded : Icons.insert_drive_file_rounded,
                                              size: 60, color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        child: DragTarget<String>(
                                          onAccept: (droppedPath) => _controller.moveEntity(droppedPath, path),
                                          builder: (context, candidateData, rejectedData) {
                                            return MacosFileCard(
                                              name: name,
                                              isDirectory: isDir,
                                              size: ExplorerController.getFileSize(entity),
                                              isSelected: _controller.selectedPaths.contains(path),
                                              onTap: () {
                                                // Ctrl key logic for Multi-Select
                                                final isMulti = HardwareKeyboard.instance.isControlPressed;
                                                _controller.selectFile(path, multiSelect: isMulti);
                                              },
                                              onDoubleTap: () {
                                                if (isDir) {
                                                  _controller.navigateTo(path);
                                                } else {
                                                  _controller.openFile(path);
                                                }
                                              },
                                              onContextTap: () {
                                                // We need tap position for context menu, 
                                                // but GestureDetector on Card doesn't give global pos easily 
                                                // in this structure without a wrapper.
                                                // For now, users can right click empty space or use keyboard 'Menu' key conceptually.
                                                // A simple workaround:
                                                final RenderBox box = context.findRenderObject() as RenderBox;
                                                final Offset position = box.localToGlobal(Offset.zero);
                                                final center = position + Offset(box.size.width/2, box.size.height/2);
                                                
                                                _handleContextMenu(
                                                  TapDownDetails(globalPosition: center), 
                                                  filePath: path
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  ),

                                // Status Message (Copy/Paste notification)
                                if (_controller.statusMessage != null)
                                  Positioned(
                                    bottom: 20, right: 20,
                                    child: MacosGlassBox(
                                      tint: MacosTheme.accent.withOpacity(0.9),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      borderRadius: 20,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.info_outline_rounded, color: Colors.white, size: 16),
                                          const SizedBox(width: 8),
                                          Text(
                                            _controller.statusMessage!,
                                            style: const TextStyle(color: Colors.white, fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
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
      ),
    );
  }

  // --- HELPERS ---

  Widget _sidebarHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 14, bottom: 8, top: 10),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Colors.white30,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  IconData _getIconForPath(String key) {
    switch (key) {
      case 'Desktop': return Icons.desktop_mac_rounded;
      case 'Documents': return Icons.article_rounded;
      case 'Downloads': return Icons.download_rounded;
      case 'Music': return Icons.music_note_rounded;
      case 'Pictures': return Icons.image_rounded;
      default: return Icons.folder_rounded;
    }
  }
}
