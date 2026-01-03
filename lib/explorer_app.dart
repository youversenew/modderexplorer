import 'dart:io';
import 'package:flutter/cupertino.dart';
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
  final FocusNode _keyboardFocus = FocusNode(); // Klaviatura uchun

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
    // Ilova ochilganda klaviatura fokusini olish
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

  // --- ACTIONS ---

  void _handleContextMenu(TapDownDetails details, {String? filePath}) {
    final isFile = filePath != null;
    if (isFile && !_controller.selectedPaths.contains(filePath)) {
      _controller.selectFile(filePath!, multiSelect: false);
    }

    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final position = RelativeRect.fromRect(
      Rect.fromPoints(details.globalPosition, details.globalPosition),
      Offset.zero & overlay.size,
    );

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
                  items: isFile
                      ? _getFileMenuOptions(filePath!)
                      : _getBgMenuOptions(),
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
        label: "Open",
        icon: CupertinoIcons.arrow_up_right_square,
        onTap: () => _controller.openFile(path),
      ),
      ContextMenuItem(
        label: "Open With...",
        icon: CupertinoIcons.square_arrow_right,
        onTap: () => _controller.openWith(path),
      ),
      ContextMenuItem.divider(),
      ContextMenuItem(
        label: "Copy",
        icon: CupertinoIcons.doc_on_doc,
        shortcut: "Ctrl+C",
        onTap: () => _controller.copyToClipboard(),
      ),
      ContextMenuItem(
        label: "Cut",
        icon: CupertinoIcons.scissors,
        shortcut: "Ctrl+X",
        onTap: () => _controller.copyToClipboard(isCut: true),
      ),
      ContextMenuItem(
        label: "Create Shortcut",
        icon: CupertinoIcons.link,
        onTap: () => _controller.createShortcut(path),
      ),
      ContextMenuItem.divider(),
      ContextMenuItem(
        label: "Rename",
        icon: CupertinoIcons.pencil,
        shortcut: "F2",
        onTap: () => MacosDialogs.showInput(context, "Rename File",
            (val) => _controller.renameEntity(path, val)),
      ),
      ContextMenuItem(
        label: "Delete",
        icon: CupertinoIcons.trash,
        shortcut: "Del",
        onTap: _controller.deleteSelected,
      ),
    ];
  }

  List<ContextMenuItem> _getBgMenuOptions() {
    return [
      ContextMenuItem(
        label: "New Folder",
        icon: CupertinoIcons.folder_badge_plus,
        onTap: () => MacosDialogs.showInput(
            context, "New Folder Name", (val) => _controller.createFolder(val)),
      ),
      ContextMenuItem.divider(),
      ContextMenuItem(
        label: "Paste",
        icon: CupertinoIcons.doc_on_clipboard,
        shortcut: "Ctrl+V",
        onTap: _controller.hasClipboard ? _controller.pasteFromClipboard : null,
      ),
      ContextMenuItem(
        label: "Select All",
        icon: CupertinoIcons.checkmark_rectangle,
        shortcut: "Ctrl+A",
        onTap: () {
          for (var f in _controller.files) {
            _controller.selectFile(f.path, multiSelect: true);
          }
        },
      ),
      ContextMenuItem(
        label: "Refresh",
        icon: CupertinoIcons.refresh,
        shortcut: "F5",
        onTap: _controller.refresh,
      ),
    ];
  }

  // --- KEYBOARD HANDLING ---
  void _handleKey(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.delete) {
        _controller.deleteSelected();
      } else if (event.isControlPressed &&
          event.logicalKey == LogicalKeyboardKey.keyA) {
        for (var f in _controller.files) {
          _controller.selectFile(f.path, multiSelect: true);
        }
      } else if (event.isControlPressed &&
          event.logicalKey == LogicalKeyboardKey.keyC) {
        _controller.copyToClipboard();
      } else if (event.isControlPressed &&
          event.logicalKey == LogicalKeyboardKey.keyV) {
        _controller.pasteFromClipboard();
      } else if (event.isControlPressed &&
          event.logicalKey == LogicalKeyboardKey.keyX) {
        _controller.copyToClipboard(isCut: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Fallback background
      body: RawKeyboardListener(
        focusNode: _keyboardFocus,
        onKey: _handleKey,
        child: Stack(
          children: [
            // 1. BACKGROUND WALLPAPER (MacOS Abstract)
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF2E0F45), // Deep Purple
                      Color(0xFF0F1E45), // Deep Blue
                      Color(0xFF000000), // Black
                    ],
                  ),
                ),
              ),
            ),

            // 2. MAIN LAYOUT
            Row(
              children: [
                // --- SIDEBAR ---
                MacosGlassBox(
                  width: 240,
                  tint: MacosTheme.sidebarBg,
                  blur: 50,
                  borderRadius: 0, // Left side square
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 14, bottom: 20),
                        child: MacosTrafficLights(),
                      ),
                      _sidebarHeader("Favorites"),
                      ..._controller.quickAccessPaths.entries
                          .map((e) => MacosSidebarItem(
                                label: e.key,
                                icon: _getIconForPath(e.key),
                                isSelected: _controller.currentPath == e.value,
                                onTap: () => _controller.navigateTo(e.value),
                              )),
                      const SizedBox(height: 20),
                      _sidebarHeader("Locations"),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _controller.drives.length,
                          itemBuilder: (context, index) {
                            final drive = _controller.drives[index];
                            return MacosSidebarItem(
                              label: drive,
                              icon: CupertinoIcons.device_laptop,
                              isSelected:
                                  _controller.currentPath.startsWith(drive) &&
                                      _controller.currentPath.length < 5,
                              onTap: () => _controller.navigateTo(drive),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // --- MAIN CONTENT ---
                Expanded(
                  child: Column(
                    children: [
                      // TOOLBAR
                      Container(
                        height: 52,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        color: Colors.transparent,
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: _controller.canGoBack
                                  ? _controller.goBack
                                  : null,
                              icon: const Icon(CupertinoIcons.back, size: 20),
                              color: _controller.canGoBack
                                  ? Colors.white
                                  : Colors.white24,
                              splashRadius: 20,
                            ),
                            IconButton(
                              onPressed: _controller.canGoForward
                                  ? _controller.goForward
                                  : null,
                              icon:
                                  const Icon(CupertinoIcons.forward, size: 20),
                              color: _controller.canGoForward
                                  ? Colors.white
                                  : Colors.white24,
                              splashRadius: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              _controller.currentPath.split('\\').last.isEmpty
                                  ? "My Computer"
                                  : _controller.currentPath.split('\\').last,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                            const Spacer(),
                            // SPOTLIGHT SEARCH
                            SpotlightSearchBar(
                              onChanged: _controller.search,
                            ),
                          ],
                        ),
                      ),

                      // FILE GRID AREA
                      Expanded(
                        child: MacosGlassBox(
                          margin: const EdgeInsets.fromLTRB(0, 0, 10, 10),
                          tint: MacosTheme.contentBg,
                          blur: 40,
                          borderRadius: MacosTheme.radiusL,
                          child: GestureDetector(
                            onSecondaryTapDown: (d) => _handleContextMenu(
                                d), // Empty space right click
                            child: Stack(
                              children: [
                                if (_controller.isLoading)
                                  const Center(
                                      child: CupertinoActivityIndicator(
                                          color: Colors.white, radius: 15)),

                                if (!_controller.isLoading)
                                  GridView.builder(
                                    padding: const EdgeInsets.all(20),
                                    gridDelegate:
                                        const SliverGridDelegateWithMaxCrossAxisExtent(
                                      maxCrossAxisExtent: 130,
                                      childAspectRatio: 0.85,
                                      crossAxisSpacing: 15,
                                      mainAxisSpacing: 15,
                                    ),
                                    itemCount: _controller.files.length,
                                    itemBuilder: (context, index) {
                                      final entity = _controller.files[index];
                                      final name = entity.uri.pathSegments
                                          .lastWhere((e) => e.isNotEmpty);
                                      final isDir = entity is Directory;

                                      return Draggable<String>(
                                        data: entity.path,
                                        feedback: Material(
                                          color: Colors.transparent,
                                          child: Opacity(
                                            opacity: 0.7,
                                            child: Icon(
                                              isDir
                                                  ? CupertinoIcons.folder_solid
                                                  : CupertinoIcons.doc_fill,
                                              size: 60,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        child: DragTarget<String>(
                                          onAccept: (droppedPath) =>
                                              _controller.moveEntity(
                                                  droppedPath, entity.path),
                                          builder: (context, candidateData,
                                              rejectedData) {
                                            return MacosFileCard(
                                              name: name,
                                              isDirectory: isDir,
                                              size: ExplorerController
                                                  .getFileSize(entity),
                                              isSelected: _controller
                                                  .selectedPaths
                                                  .contains(entity.path),
                                              onTap: () {
                                                final isMulti = HardwareKeyboard
                                                    .instance.isControlPressed;
                                                _controller.selectFile(
                                                    entity.path,
                                                    multiSelect: isMulti);
                                              },
                                              onDoubleTap: () {
                                                if (isDir) {
                                                  _controller
                                                      .navigateTo(entity.path);
                                                } else {
                                                  _controller
                                                      .openFile(entity.path);
                                                }
                                              },
                                              onContextTap: () {
                                                // Context menu handling is complex here,
                                                // usually we need global position.
                                                // For simplicity, user right clicks and we assume current mouse pos.
                                                // Implemented via Listener in wrapping widget usually,
                                                // but for individual item:
                                              },
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  ),

                                // Status Message Overlay (Copy/Paste notification)
                                if (_controller.statusMessage != null)
                                  Positioned(
                                    bottom: 20,
                                    right: 20,
                                    child: MacosGlassBox(
                                      tint: MacosTheme.accent.withOpacity(0.8),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      borderRadius: 20,
                                      child: Text(
                                        _controller.statusMessage!,
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 12),
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

  Widget _sidebarHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 8, top: 10),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white30,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  IconData _getIconForPath(String key) {
    switch (key) {
      case 'Desktop':
        return CupertinoIcons.desktopcomputer;
      case 'Documents':
        return CupertinoIcons.doc_text;
      case 'Downloads':
        return CupertinoIcons.arrow_down_circle;
      case 'Music':
        return CupertinoIcons.music_note_2;
      case 'Pictures':
        return CupertinoIcons.photo;
      default:
        return CupertinoIcons.folder;
    }
  }
}
