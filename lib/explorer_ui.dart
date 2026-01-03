import 'dart:ui';
import 'package:flutter/material.dart';

/// 🍎 MACOS UI SYSTEM (Material Icons Edition)
/// A high-fidelity MacOS Finder replica using standard Flutter components.

class MacosTheme {
  // -- Colors --
  static const Color background = Color(0xFF1E1E1E); // Main dark background
  static const Color sidebarBg = Color(0xCC252526);  // Translucent sidebar
  static const Color contentBg = Color(0xB31E1E1E);  // Translucent content area
  
  static const Color accent = Color(0xFF007AFF);     // System Blue
  static const Color selection = Color(0xFF0058D0);  // Deep Blue for selection
  
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF98989D); // Apple Gray
  
  static const Color glassBorder = Color(0x1FFFFFFF); // Thin white border
  
  // -- Dimensions --
  static const double radiusS = 6.0;
  static const double radiusM = 10.0;
  static const double radiusL = 14.0;
}

// -----------------------------------------------------------------------------
// 🧱 GLASS CORE (Acrylic Blur Effect)
// -----------------------------------------------------------------------------

class MacosGlassBox extends StatelessWidget {
  final Widget child;
  final double? width, height;
  final EdgeInsets padding, margin;
  final double borderRadius, blur;
  final Color tint;
  final Border? border;
  final VoidCallback? onTap;

  const MacosGlassBox({
    Key? key,
    required this.child,
    this.width, this.height,
    this.padding = EdgeInsets.zero,
    this.margin = EdgeInsets.zero,
    this.borderRadius = MacosTheme.radiusM,
    this.blur = 30.0,
    this.tint = Colors.black26,
    this.border,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget box = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width, height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: tint,
            borderRadius: BorderRadius.circular(borderRadius),
            border: border ?? Border.all(color: Colors.white.withOpacity(0.08), width: 0.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return Padding(
        padding: margin,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: box,
        ),
      );
    }
    return Padding(padding: margin, child: box);
  }
}

// -----------------------------------------------------------------------------
// 🔍 SPOTLIGHT SEARCH BAR
// -----------------------------------------------------------------------------

class SpotlightSearchBar extends StatefulWidget {
  final ValueChanged<String> onChanged;
  const SpotlightSearchBar({Key? key, required this.onChanged}) : super(key: key);

  @override
  State<SpotlightSearchBar> createState() => _SpotlightSearchBarState();
}

class _SpotlightSearchBarState extends State<SpotlightSearchBar> {
  bool _isFocused = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: _isFocused ? 300 : 200,
      height: 32,
      decoration: BoxDecoration(
        color: _isFocused ? const Color(0xFF3A3A3C) : const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _isFocused ? MacosTheme.accent.withOpacity(0.5) : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),
          const Icon(Icons.search_rounded, color: MacosTheme.textSecondary, size: 18),
          const SizedBox(width: 6),
          Expanded(
            child: TextField(
              focusNode: _focusNode,
              onChanged: widget.onChanged,
              style: const TextStyle(color: MacosTheme.textPrimary, fontSize: 13),
              cursorColor: MacosTheme.accent,
              decoration: const InputDecoration(
                hintText: "Search",
                hintStyle: TextStyle(color: Colors.white24),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.only(bottom: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 📁 MACOS FILE CARD (Grid Item)
// -----------------------------------------------------------------------------

class MacosFileCard extends StatefulWidget {
  final String name;
  final String? size;
  final bool isDirectory;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDoubleTap;
  final VoidCallback onContextTap;

  const MacosFileCard({
    Key? key,
    required this.name,
    this.size,
    required this.isDirectory,
    required this.isSelected,
    required this.onTap,
    required this.onDoubleTap,
    required this.onContextTap,
  }) : super(key: key);

  @override
  State<MacosFileCard> createState() => _MacosFileCardState();
}

class _MacosFileCardState extends State<MacosFileCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool active = widget.isSelected;
    
    // Background color logic: Blue if selected, subtle grey if hovered, transparent otherwise
    final Color bgColor = active 
        ? MacosTheme.selection.withOpacity(0.4) 
        : (_isHovered ? Colors.white.withOpacity(0.08) : Colors.transparent);
        
    final Color borderColor = active 
        ? MacosTheme.accent.withOpacity(0.5) 
        : Colors.transparent;

    return GestureDetector(
      onTap: widget.onTap,
      onDoubleTap: widget.onDoubleTap,
      onSecondaryTap: widget.onContextTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(MacosTheme.radiusM),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon Layer
              _buildMacosIcon(widget.isDirectory, widget.name),
              const SizedBox(height: 8),
              
              // Text Layer
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: active ? MacosTheme.selection : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  widget.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: MacosTheme.textPrimary,
                    fontSize: 12,
                    height: 1.1,
                  ),
                ),
              ),
              
              // Size Layer (Only for files)
              if (!widget.isDirectory && widget.size != null) ...[
                const SizedBox(height: 4),
                Text(
                  widget.size!,
                  style: TextStyle(
                    color: active ? Colors.white70 : MacosTheme.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMacosIcon(bool isDir, String name) {
    // If it's a directory, use the Mac-style Blue Folder
    if (isDir) {
      return const Icon(
        Icons.folder_rounded,
        size: 56,
        color: Color(0xFF5AB6F8), // Mac Folder Blue
      );
    }
    
    final ext = name.split('.').last.toLowerCase();
    IconData icon;
    Color color;

    // File Type Mapping (Using Material Icons only)
    switch (ext) {
      case 'png': case 'jpg': case 'jpeg': case 'gif':
        icon = Icons.image_rounded; color: Colors.purpleAccent; break;
      case 'pdf': 
        icon = Icons.picture_as_pdf_rounded; color: Colors.redAccent; break;
      case 'mp3': case 'wav': 
        icon = Icons.music_note_rounded; color: Colors.pinkAccent; break;
      case 'mp4': case 'mov': case 'avi':
        icon = Icons.movie_rounded; color: Colors.orangeAccent; break;
      case 'zip': case 'rar': case '7z':
        icon = Icons.folder_zip_rounded; color: Colors.yellow; break;
      case 'exe': case 'bat': case 'msi':
        icon = Icons.window_rounded; color: Colors.blueGrey; break;
      case 'txt': case 'md': case 'json':
        icon = Icons.description_rounded; color: Colors.white70; break;
      case 'dart': case 'py': case 'js': case 'html':
        icon = Icons.code_rounded; color: Colors.greenAccent; break;
      default:
        icon = Icons.insert_drive_file_rounded; color: Colors.grey;
    }

    return Icon(icon, size: 48, color: color);
  }
}

// -----------------------------------------------------------------------------
// 🪟 WINDOW CONTROLS (Traffic Lights)
// -----------------------------------------------------------------------------

class MacosTrafficLights extends StatelessWidget {
  const MacosTrafficLights({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _circle(const Color(0xFFFF5F57)), // Red (Close)
        const SizedBox(width: 8),
        _circle(const Color(0xFFFEBC2E)), // Yellow (Minimize)
        const SizedBox(width: 8),
        _circle(const Color(0xFF28C840)), // Green (Maximize)
      ],
    );
  }

  Widget _circle(Color color) {
    return Container(
      width: 12, height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 🧊 SIDEBAR ITEM
// -----------------------------------------------------------------------------

class MacosSidebarItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const MacosSidebarItem({
    Key? key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? Colors.white.withOpacity(0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(
                icon, 
                size: 18, 
                color: isSelected ? MacosTheme.accent : const Color(0xFFB0B0B5),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFFD0D0D0),
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 📋 CONTEXT MENU & MODELS
// -----------------------------------------------------------------------------

class MacosContextMenu extends StatelessWidget {
  final List<ContextMenuItem> items;
  const MacosContextMenu({Key? key, required this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MacosGlassBox(
      width: 220,
      blur: 40,
      tint: const Color(0xE6202020), // Highly opaque dark
      borderRadius: 10,
      padding: const EdgeInsets.symmetric(vertical: 6),
      border: Border.all(color: Colors.white24, width: 0.5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items.map((item) {
          if (item.isDivider) {
            return const Divider(color: Colors.white12, height: 10, thickness: 1);
          }
          return InkWell(
            onTap: () {
              Navigator.pop(context);
              item.onTap?.call();
            },
            hoverColor: MacosTheme.accent,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                children: [
                  if (item.icon != null) ...[
                    Icon(item.icon, size: 16, color: Colors.white),
                    const SizedBox(width: 10),
                  ],
                  Text(item.label ?? "", style: const TextStyle(color: Colors.white, fontSize: 13)),
                  const Spacer(),
                  if (item.shortcut != null)
                    Text(item.shortcut!, style: const TextStyle(color: Colors.white38, fontSize: 11)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Helper Model for Context Menu Items
class ContextMenuItem {
  final String? label;
  final IconData? icon;
  final String? shortcut;
  final VoidCallback? onTap;
  final bool isDivider;

  ContextMenuItem({
    this.label, 
    this.icon, 
    this.shortcut, 
    this.onTap, 
    this.isDivider = false
  });

  static ContextMenuItem divider() => ContextMenuItem(isDivider: true);
}

// -----------------------------------------------------------------------------
// 💬 DIALOGS (Alerts & Inputs)
// -----------------------------------------------------------------------------

class MacosDialogs {
  static void showInput(BuildContext context, String title, Function(String) onConfirm) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: MacosGlassBox(
          width: 320,
          blur: 30,
          tint: const Color(0xFF2A2A2A).withOpacity(0.9),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.edit_note_rounded, size: 40, color: Colors.white70),
              const SizedBox(height: 15),
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              TextField(
                controller: controller,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                cursorColor: MacosTheme.accent,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.black26,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onSubmitted: (val) {
                  onConfirm(val);
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel", style: TextStyle(color: Colors.white54)),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MacosTheme.accent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      onConfirm(controller.text);
                      Navigator.pop(context);
                    },
                    child: const Text("OK", style: TextStyle(color: Colors.white)),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
