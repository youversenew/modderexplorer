import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// 🍎 MACOS GLASS UI SYSTEM
/// Native MacOS Sequoia & Finder aesthetic without external plugins.

class MacosTheme {
  // -- System Colors --
  static const Color background = Color(0xFF000000); // Pure Dark
  static const Color canvasColor = Color(0xFF1E1E1E);
  static const Color accent = Color(0xFF007AFF); // System Blue
  static const Color selection = Color(0xFF0058D0); // Darker Blue for selection

  // -- Glass Layers --
  static const Color sidebarBg = Color(0xCC2C2C2C); // High opacity sidebar
  static const Color contentBg = Color(0xCC181818); // Main content
  static const Color glassBorder = Color(0x1FFFFFFF);

  // -- Text --
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF98989D); // Apple Gray

  // -- Dimensions --
  static const double radiusS = 6.0;
  static const double radiusM = 10.0;
  static const double radiusL = 14.0;
}

// -----------------------------------------------------------------------------
// 🧱 GLASS CORE (Acrylic Effect)
// -----------------------------------------------------------------------------

class MacosGlassBox extends StatelessWidget {
  final Widget child;
  final double? width, height;
  final EdgeInsets padding, margin;
  final double borderRadius;
  final double blur;
  final Color tint;
  final Border? border;
  final VoidCallback? onTap;

  const MacosGlassBox({
    Key? key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(0),
    this.margin = EdgeInsets.zero,
    this.borderRadius = MacosTheme.radiusM,
    this.blur = 25.0,
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
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: tint,
            borderRadius: BorderRadius.circular(borderRadius),
            border: border ??
                Border.all(color: Colors.white.withOpacity(0.08), width: 0.5),
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
        child: GestureDetector(
          onTap: onTap,
          child: MouseRegion(cursor: SystemMouseCursors.click, child: box),
        ),
      );
    }
    return Padding(padding: margin, child: box);
  }
}

// -----------------------------------------------------------------------------
// 🔍 SPOTLIGHT SEARCH UI
// -----------------------------------------------------------------------------

class SpotlightSearchBar extends StatefulWidget {
  final ValueChanged<String> onChanged;
  const SpotlightSearchBar({Key? key, required this.onChanged})
      : super(key: key);

  @override
  State<SpotlightSearchBar> createState() => _SpotlightSearchBarState();
}

class _SpotlightSearchBarState extends State<SpotlightSearchBar> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: _isFocused ? 400 : 250, // Expands when clicked
        height: 36,
        decoration: BoxDecoration(
          color: _isFocused ? const Color(0xFF3A3A3C) : const Color(0xFF2C2C2E),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _isFocused
                ? MacosTheme.accent.withOpacity(0.5)
                : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: _isFocused
              ? [
                  BoxShadow(
                      color: MacosTheme.accent.withOpacity(0.2), blurRadius: 15)
                ]
              : [],
        ),
        child: Row(
          children: [
            const SizedBox(width: 10),
            Icon(CupertinoIcons.search,
                color: MacosTheme.textSecondary, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                focusNode: _focusNode,
                onChanged: widget.onChanged,
                style: const TextStyle(
                    color: MacosTheme.textPrimary,
                    fontSize: 13,
                    fontFamily: '.SF Pro Text'),
                cursorColor: MacosTheme.accent,
                decoration: const InputDecoration(
                  hintText: "Spotlight Search",
                  hintStyle: TextStyle(color: Colors.white24),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(bottom: 12),
                ),
              ),
            ),
            if (_isFocused) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text("ESC",
                    style: TextStyle(
                        color: Colors.white54,
                        fontSize: 9,
                        fontWeight: FontWeight.bold)),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 📁 FINDER GRID ITEM (MacOS Style)
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
    // Selection style in Finder is a darker rounded rect background + white text
    final bool active = widget.isSelected;

    return GestureDetector(
      onTap: widget.onTap,
      onDoubleTap: widget.onDoubleTap,
      onSecondaryTap: widget.onContextTap, // Right click
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Container(
          decoration: BoxDecoration(
            color: active
                ? MacosTheme.selection.withOpacity(0.4)
                : (_isHovered
                    ? Colors.white.withOpacity(0.05)
                    : Colors.transparent),
            borderRadius: BorderRadius.circular(MacosTheme.radiusM),
            border: active
                ? Border.all(
                    color: MacosTheme.accent.withOpacity(0.6), width: 1)
                : Border.all(color: Colors.transparent),
          ),
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. Icon (Rich 3D feel)
              _buildMacosIcon(widget.isDirectory, widget.name),
              const SizedBox(height: 8),

              // 2. Text Label
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
    // Simulating MacOS icons with colors and gradients
    if (isDir) {
      return Icon(
        CupertinoIcons.folder_solid,
        size: 52,
        color: Color(0xFF1CB5E0), // MacOS Blue Folder color
      );
    }

    final ext = name.split('.').last.toLowerCase();
    IconData icon;
    Color color;

    switch (ext) {
      case 'png':
      case 'jpg':
      case 'jpeg':
        icon = CupertinoIcons.photo;
        color:
        Colors.purpleAccent;
        break;
      case 'pdf':
        icon = CupertinoIcons.doc_text_fill;
        color:
        Colors.redAccent;
        break;
      case 'mp3':
      case 'wav':
        icon = CupertinoIcons.music_note_2;
        color:
        Colors.pinkAccent;
        break;
      case 'mp4':
      case 'mov':
        icon = CupertinoIcons.film;
        color:
        Colors.orangeAccent;
        break;
      case 'zip':
      case 'rar':
        icon = CupertinoIcons.archivebox_fill;
        color:
        Colors.yellow;
        break;
      case 'exe':
      case 'app':
        icon = CupertinoIcons.app_badge_fill;
        color:
        Colors.white70;
        break;
      default:
        icon = CupertinoIcons.doc_fill;
        color:
        Colors.grey;
    }

    return Icon(icon, size: 48, color: Colors.grey);
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
        _circle(const Color(0xFFFF5F57)), // Close (Red)
        const SizedBox(width: 8),
        _circle(const Color(0xFFFEBC2E)), // Minimize (Yellow)
        const SizedBox(width: 8),
        _circle(const Color(0xFF28C840)), // Maximize (Green)
      ],
    );
  }

  Widget _circle(Color color) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 📋 CONTEXT MENU (Custom Dialog)
// -----------------------------------------------------------------------------

class MacosContextMenu extends StatelessWidget {
  final List<ContextMenuItem> items;
  const MacosContextMenu({Key? key, required this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MacosGlassBox(
      width: 200,
      blur: 40,
      tint: const Color(0xCC252525), // Very Dark Grey
      borderRadius: 10,
      padding: const EdgeInsets.symmetric(vertical: 6),
      border: Border.all(color: Colors.white24, width: 0.5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: items.map((item) {
          if (item.isDivider) {
            return const Divider(
                color: Colors.white12, height: 10, thickness: 1);
          }
          return InkWell(
            onTap: () {
              Navigator.pop(context);
              item.onTap?.call();
            },
            hoverColor: MacosTheme.accent, // Blue highlight on hover
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  if (item.icon != null) ...[
                    Icon(item.icon, size: 16, color: Colors.white),
                    const SizedBox(width: 10),
                  ],
                  Text(item.label ?? "",
                      style:
                          const TextStyle(color: Colors.white, fontSize: 13)),
                  const Spacer(),
                  if (item.shortcut != null)
                    Text(item.shortcut!,
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 11)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class ContextMenuItem {
  final String? label;
  final IconData? icon;
  final String? shortcut;
  final VoidCallback? onTap;
  final bool isDivider;

  ContextMenuItem(
      {this.label,
      this.icon,
      this.shortcut,
      this.onTap,
      this.isDivider = false});
  static ContextMenuItem divider() => ContextMenuItem(isDivider: true);
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
            color: isSelected
                ? Colors.white.withOpacity(0.12)
                : Colors.transparent, // Mac style active
            borderRadius: BorderRadius.circular(6),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? MacosTheme.accent
                    : const Color(0xFFB0B0B5), // Blue if active, Gray otherwise
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFFD0D0D0),
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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
// 💬 DIALOGS (Alerts)
// -----------------------------------------------------------------------------

class MacosDialogs {
  static void showInput(
      BuildContext context, String title, Function(String) onConfirm) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: MacosGlassBox(
          width: 320,
          blur: 30,
          tint: const Color(0xEE2A2A2A),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(CupertinoIcons.pencil_outline,
                  size: 40, color: Colors.white70),
              const SizedBox(height: 15),
              Text(title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              CupertinoTextField(
                controller: controller,
                style: const TextStyle(color: Colors.white),
                cursorColor: MacosTheme.accent,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white12),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel",
                        style: TextStyle(color: Colors.white54)),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MacosTheme.accent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      onConfirm(controller.text);
                      Navigator.pop(context);
                    },
                    child:
                        const Text("OK", style: TextStyle(color: Colors.white)),
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
