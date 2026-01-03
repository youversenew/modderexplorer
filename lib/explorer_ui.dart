import 'dart:ui';
import 'package:flutter/material.dart';

/// 🎨 MODDER UI DESIGN SYSTEM
/// A Windows 11/12 inspired Dark Glass theme.

class ModderTheme {
  // -- Colors --
  static const Color background = Color(0xFF0F0F0F); // Deep dark background
  static const Color surface = Color(0xFF1E1E1E); // Fallback surface
  static const Color accent = Color(0xFF60CDFF); // Windows 11 Blue/Cyan
  static const Color danger = Color(0xFFFF453A);

  // -- Glass Colors (with Opacity) --
  static const Color glassLow = Color(0x1AFFFFFF); // Subtle 10%
  static const Color glassMedium = Color(0x26FFFFFF); // Medium 15%
  static const Color glassHigh = Color(0x40FFFFFF); // High 25%
  static const Color glassBorder = Color(0x1FFFFFFF); // Thin border

  // -- Text Colors --
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFAAAAAA);

  // -- Dimensions --
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
}

// -----------------------------------------------------------------------------
// 🧱 CORE WIDGETS (Glassmorphism)
// -----------------------------------------------------------------------------

/// A container that applies a BackdropFilter (Blur) + Semi-transparent gradient.
class GlassBox extends StatelessWidget {
  final Widget child;
  final double width;
  final double? height;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final double borderRadius;
  final Color tint;
  final double blur;
  final Border? border;
  final VoidCallback? onTap;

  const GlassBox({
    Key? key,
    required this.child,
    this.width = double.infinity,
    this.height,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.borderRadius = ModderTheme.radiusM,
    this.tint = ModderTheme.glassLow,
    this.blur = 20.0,
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
          decoration: BoxDecoration(
            color: tint,
            borderRadius: BorderRadius.circular(borderRadius),
            border:
                border ?? Border.all(color: ModderTheme.glassBorder, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 15,
                spreadRadius: -5,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: padding,
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return Padding(
        padding: margin,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(borderRadius),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(borderRadius),
            hoverColor: ModderTheme.accent.withOpacity(0.1),
            splashColor: ModderTheme.accent.withOpacity(0.2),
            child: box,
          ),
        ),
      );
    }

    return Padding(padding: margin, child: box);
  }
}

// -----------------------------------------------------------------------------
// 📂 FILE & FOLDER WIDGETS
// -----------------------------------------------------------------------------

/// Visual representation of a File or Folder in Grid View
class FileGridItem extends StatefulWidget {
  final String name;
  final String? size;
  final bool isDirectory;
  final VoidCallback onTap;
  final bool isSelected;

  const FileGridItem({
    Key? key,
    required this.name,
    this.size,
    required this.isDirectory,
    required this.onTap,
    this.isSelected = false,
  }) : super(key: key);

  @override
  State<FileGridItem> createState() => _FileGridItemState();
}

class _FileGridItemState extends State<FileGridItem>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool active = widget.isSelected || _isHovered;
    final Color bgTint = active ? ModderTheme.glassMedium : Colors.transparent;
    final Color borderTint = widget.isSelected
        ? ModderTheme.accent.withOpacity(0.5)
        : (active ? ModderTheme.glassHigh : Colors.transparent);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: bgTint,
            borderRadius: BorderRadius.circular(ModderTheme.radiusM),
            border: Border.all(color: borderTint, width: 1.5),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon Layer
              Icon(
                FileIconHelper.getIcon(widget.isDirectory, widget.name),
                size: 48,
                color: FileIconHelper.getColor(widget.isDirectory, widget.name),
              ),
              const SizedBox(height: 12),
              // Text Layer
              Text(
                widget.name,
                style: const TextStyle(
                  color: ModderTheme.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  overflow: TextOverflow.ellipsis,
                ),
                maxLines: 2,
                textAlign: TextAlign.center,
              ),
              if (widget.size != null && !widget.isDirectory) ...[
                const SizedBox(height: 4),
                Text(
                  widget.size!,
                  style: const TextStyle(
                    color: ModderTheme.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}

/// Visual representation of a File or Folder in List/Sidebar View
class FileListItem extends StatelessWidget {
  final String name;
  final bool isDirectory;
  final VoidCallback onTap;
  final bool isSelected;
  final IconData? customIcon;

  const FileListItem({
    Key? key,
    required this.name,
    required this.isDirectory,
    required this.onTap,
    this.isSelected = false,
    this.customIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isSelected ? ModderTheme.glassMedium : Colors.transparent,
        borderRadius: BorderRadius.circular(ModderTheme.radiusS),
        border: isSelected
            ? Border.all(color: ModderTheme.glassBorder)
            : Border.all(color: Colors.transparent),
      ),
      child: ListTile(
        onTap: onTap,
        dense: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ModderTheme.radiusS)),
        hoverColor: ModderTheme.glassLow,
        leading: Icon(
          customIcon ?? FileIconHelper.getIcon(isDirectory, name),
          color: customIcon != null
              ? ModderTheme.accent
              : FileIconHelper.getColor(isDirectory, name),
          size: 20,
        ),
        title: Text(
          name,
          style: TextStyle(
            color: isSelected ? ModderTheme.accent : ModderTheme.textPrimary,
            fontSize: 13,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 🛠 UTILITIES
// -----------------------------------------------------------------------------

class FileIconHelper {
  static IconData getIcon(bool isDirectory, String name) {
    if (isDirectory) return Icons.folder_rounded;

    final ext = name.split('.').last.toLowerCase();
    switch (ext) {
      case 'png':
      case 'jpg':
      case 'jpeg':
      case 'gif':
        return Icons.image_rounded;
      case 'mp4':
      case 'mov':
      case 'avi':
        return Icons.movie_rounded;
      case 'mp3':
      case 'wav':
        return Icons.music_note_rounded;
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'txt':
      case 'md':
      case 'json':
      case 'dart':
        return Icons.description_rounded;
      case 'exe':
      case 'bat':
        return Icons.terminal_rounded;
      case 'zip':
      case 'rar':
        return Icons.folder_zip_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  static Color getColor(bool isDirectory, String name) {
    if (isDirectory) return const Color(0xFFFFD54F); // Windows Yellow

    final ext = name.split('.').last.toLowerCase();
    switch (ext) {
      case 'png':
      case 'jpg':
        return Colors.purpleAccent;
      case 'mp4':
        return Colors.redAccent;
      case 'pdf':
        return Colors.red;
      case 'dart':
        return Colors.blueAccent;
      case 'exe':
        return ModderTheme.accent;
      case 'zip':
        return Colors.orangeAccent;
      default:
        return ModderTheme.textSecondary;
    }
  }
}

// -----------------------------------------------------------------------------
// ⌨️ INPUTS & BUTTONS
// -----------------------------------------------------------------------------

class ModernAddressBar extends StatelessWidget {
  final String path;
  final ValueChanged<String> onSubmitted;

  const ModernAddressBar({
    Key? key,
    required this.path,
    required this.onSubmitted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: path);
    return GlassBox(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      borderRadius: ModderTheme.radiusS,
      blur: 10,
      tint: Colors.black12,
      child: Row(
        children: [
          const Icon(Icons.computer, color: ModderTheme.accent, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onSubmitted: onSubmitted,
              style:
                  const TextStyle(color: ModderTheme.textPrimary, fontSize: 13),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.only(bottom: 4),
              ),
              cursorColor: ModderTheme.accent,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.refresh_rounded,
              color: ModderTheme.textSecondary, size: 16),
        ],
      ),
    );
  }
}

class ModernSearchBox extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const ModernSearchBox({Key? key, required this.onChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GlassBox(
      height: 40,
      width: 250,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      borderRadius: ModderTheme.radiusS,
      blur: 10,
      tint: Colors.black12,
      child: TextField(
        onChanged: onChanged,
        style: const TextStyle(color: ModderTheme.textPrimary, fontSize: 13),
        decoration: const InputDecoration(
          hintText: "Search",
          hintStyle: TextStyle(color: Colors.white30),
          border: InputBorder.none,
          icon: Icon(Icons.search_rounded, color: Colors.white54, size: 18),
          isDense: true,
          contentPadding: EdgeInsets.only(bottom: 2),
        ),
        cursorColor: ModderTheme.accent,
      ),
    );
  }
}
