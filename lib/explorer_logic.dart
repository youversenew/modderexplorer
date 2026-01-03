import 'dart:io';
import 'dart:async';
import 'dart:collection';
import 'package:flutter/material.dart';

/// ⚙️ EXPLORER LOGIC (FIXED)
/// Contains all methods required by ExplorerApp (selectFile, createFolder, moveEntity).

class ExplorerController extends ChangeNotifier {
  // ---------------------------------------------------------------------------
  // 💾 STATE VARIABLES
  // ---------------------------------------------------------------------------

  String _currentPath = 'C:\\';
  List<FileSystemEntity> _files = [];
  List<FileSystemEntity> _allFiles = [];
  List<String> _drives = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _statusMessage;

  // -- Search --
  String _searchQuery = "";

  // -- Selection & Clipboard --
  final Set<String> _selectedPaths = HashSet<String>();
  List<String> _clipboardFiles = [];
  bool _isCutOperation = false;

  // -- Navigation History --
  List<String> _history = [];
  int _historyIndex = -1;

  // ---------------------------------------------------------------------------
  // 🔌 GETTERS
  // ---------------------------------------------------------------------------

  String get currentPath => _currentPath;
  List<FileSystemEntity> get files => _files;
  List<String> get drives => _drives;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get statusMessage => _statusMessage;
  Set<String> get selectedPaths => _selectedPaths;
  bool get canGoBack => _historyIndex > 0;
  bool get canGoForward => _historyIndex < _history.length - 1;
  bool get hasClipboard => _clipboardFiles.isNotEmpty;

  // ---------------------------------------------------------------------------
  // 🚀 INITIALIZATION
  // ---------------------------------------------------------------------------

  ExplorerController() {
    _loadDrives();
    navigateTo(_getWindowsUserPath('Desktop'));
  }

  // ---------------------------------------------------------------------------
  // 🖱 SELECTION LOGIC (FIXED)
  // ---------------------------------------------------------------------------

  /// ExplorerApp da ishlatiladigan 'selectFile' metodi
  void selectFile(String path, {bool multiSelect = false}) {
    if (!multiSelect) {
      _selectedPaths.clear();
    }

    if (_selectedPaths.contains(path)) {
      // Agar multiSelect bo'lsa, qayta bosganda o'chiramiz
      if (multiSelect) _selectedPaths.remove(path);
    } else {
      _selectedPaths.add(path);
    }
    notifyListeners();
  }

  void selectAll() {
    _selectedPaths.clear();
    for (var f in _files) {
      _selectedPaths.add(f.path);
    }
    notifyListeners();
  }

  void clearSelection() {
    _selectedPaths.clear();
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // 📂 FILE OPERATIONS (CRUD - FIXED)
  // ---------------------------------------------------------------------------

  /// ExplorerApp da ishlatiladigan 'createFolder' metodi
  Future<void> createFolder(String folderName) async {
    try {
      if (folderName.isEmpty) return;
      final newPath = '$_currentPath\\$folderName';
      final dir = Directory(newPath);
      if (!await dir.exists()) {
        await dir.create();
        _showStatus("Folder created: $folderName");
        refresh();
      } else {
        _showError("Folder already exists.");
      }
    } catch (e) {
      _showError("Failed to create folder: $e");
    }
  }

  Future<void> renameEntity(String oldPath, String newName) async {
    try {
      final entity = FileSystemEntity.isDirectorySync(oldPath)
          ? Directory(oldPath)
          : File(oldPath);

      final parent = FileSystemEntity.parentOf(oldPath);
      final newPath = '$parent\\$newName';

      await entity.rename(newPath);
      _showStatus("Renamed to $newName");
      refresh();
    } catch (e) {
      _showError("Rename failed. File might be in use.");
    }
  }

  Future<void> deleteSelected() async {
    if (_selectedPaths.isEmpty) return;

    int count = 0;
    for (final path in _selectedPaths) {
      try {
        final entity = FileSystemEntity.isDirectorySync(path)
            ? Directory(path)
            : File(path);

        if (await entity.exists()) {
          await entity.delete(recursive: true);
          count++;
        }
      } catch (e) {
        print("Delete error: $e");
      }
    }
    _selectedPaths.clear();
    _showStatus("$count items deleted.");
    refresh();
  }

  // ---------------------------------------------------------------------------
  // 🖐 DRAG & DROP LOGIC (FIXED)
  // ---------------------------------------------------------------------------

  /// ExplorerApp da ishlatiladigan 'moveEntity' metodi (Drag & Drop uchun)
  Future<void> moveEntity(String srcPath, String destFolderPath) async {
    try {
      final fileName = srcPath.split('\\').last;

      // Agar manzil papka bo'lmasa (fayl ustiga tashlansa), uni parent papkasiga ko'chiramiz
      // Lekin bizning UI da DragTarget faqat Folder yoki FileCard.
      // Ehtiyot chorasi sifatida manzilni tekshiramiz:
      String targetDir = destFolderPath;
      if (FileSystemEntity.isFileSync(destFolderPath)) {
        // Fayl ustiga tashlansa, shu fayl turgan papkaga ko'chirish kerakmi?
        // Hozircha faqat papkaga ruxsat beramiz.
        return;
      }

      final destPath = '$targetDir\\$fileName';

      if (srcPath == destPath) return; // O'z joyiga tashlansa

      final entity = FileSystemEntity.isDirectorySync(srcPath)
          ? Directory(srcPath)
          : File(srcPath);

      await entity.rename(destPath);
      _showStatus("Moved to $targetDir");
      refresh();
    } catch (e) {
      _showError("Move failed: $e");
    }
  }

  // ---------------------------------------------------------------------------
  // 🔍 NAVIGATION & SEARCH
  // ---------------------------------------------------------------------------

  Future<void> navigateTo(String path, {bool addToHistory = true}) async {
    final dir = Directory(path);
    if (!await dir.exists()) {
      _showError("Path not found: $path");
      return;
    }

    _isLoading = true;
    _searchQuery = "";
    _selectedPaths.clear();
    notifyListeners();

    try {
      final List<FileSystemEntity> entities = [];
      await for (final entity in dir.list(followLinks: false)) {
        entities.add(entity);
      }

      _sortEntities(entities);

      _allFiles = entities;
      _files = entities;
      _currentPath = path;

      if (addToHistory) {
        if (_historyIndex < _history.length - 1) {
          _history = _history.sublist(0, _historyIndex + 1);
        }
        _history.add(path);
        _historyIndex = _history.length - 1;
      }
    } catch (e) {
      _showError("Access Denied.");
      _files = [];
      _allFiles = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void search(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _files = List.from(_allFiles);
    } else {
      _files = _allFiles.where((entity) {
        final name = entity.uri.pathSegments
            .lastWhere((e) => e.isNotEmpty)
            .toLowerCase();
        return name.contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }

  void refresh() => navigateTo(_currentPath, addToHistory: false);

  void goBack() {
    if (canGoBack) {
      _historyIndex--;
      navigateTo(_history[_historyIndex], addToHistory: false);
    }
  }

  void goForward() {
    if (canGoForward) {
      _historyIndex++;
      navigateTo(_history[_historyIndex], addToHistory: false);
    }
  }

  // ---------------------------------------------------------------------------
  // ✂️ CLIPBOARD
  // ---------------------------------------------------------------------------

  void copyToClipboard({bool isCut = false}) {
    if (_selectedPaths.isEmpty) return;
    _clipboardFiles = List.from(_selectedPaths);
    _isCutOperation = isCut;
    _showStatus(isCut
        ? "Cut ${_clipboardFiles.length} items"
        : "Copied ${_clipboardFiles.length} items");
    notifyListeners();
  }

  Future<void> pasteFromClipboard() async {
    if (_clipboardFiles.isEmpty) return;
    for (final srcPath in _clipboardFiles) {
      try {
        final fileName = srcPath.split('\\').last;
        final destPath = '$_currentPath\\$fileName';
        if (srcPath == destPath) continue;

        final entity = FileSystemEntity.isDirectorySync(srcPath)
            ? Directory(srcPath)
            : File(srcPath);

        if (_isCutOperation) {
          await entity.rename(destPath);
        } else {
          if (entity is File) {
            await entity.copy(destPath);
          }
        }
      } catch (e) {
        _showError("Paste error: $e");
      }
    }
    if (_isCutOperation) _clipboardFiles.clear();
    refresh();
  }

  // ---------------------------------------------------------------------------
  // 🚀 ACTIONS (Open, Shortcut)
  // ---------------------------------------------------------------------------

  void openFile(String path) {
    if (FileSystemEntity.isDirectorySync(path)) {
      navigateTo(path);
    } else {
      Process.run('explorer', [path]);
    }
  }

  void openWith(String path) {
    Process.run('rundll32.exe', ['shell32.dll,OpenAs_RunDLL', path]);
  }

  Future<void> createShortcut(String targetPath) async {
    try {
      final name = targetPath.split('\\').last;
      final batFile = File('$_currentPath\\Shortcut to $name.bat');
      await batFile.writeAsString('@echo off\nstart "" "$targetPath"');
      _showStatus("Shortcut created");
      refresh();
    } catch (e) {
      _showError("Shortcut failed: $e");
    }
  }

  // ---------------------------------------------------------------------------
  // 🛠 UTILS
  // ---------------------------------------------------------------------------

  Future<void> _loadDrives() async {
    try {
      final result = await Process.run('wmic', ['logicaldisk', 'get', 'name']);
      if (result.exitCode == 0) {
        final lines = result.stdout
            .toString()
            .split('\n')
            .where((l) => l.contains(':'))
            .map((l) => l.trim())
            .where((l) => l.length == 2)
            .map((l) => '$l\\')
            .toList();
        _drives = lines;
      }
    } catch (_) {
      _drives = ['C:\\', 'D:\\'];
    }
    notifyListeners();
  }

  void _sortEntities(List<FileSystemEntity> list) {
    list.sort((a, b) {
      bool aIsDir = a is Directory;
      bool bIsDir = b is Directory;
      if (aIsDir && !bIsDir) return -1;
      if (!aIsDir && bIsDir) return 1;
      return a.path.toLowerCase().compareTo(b.path.toLowerCase());
    });
  }

  static String getFileSize(FileSystemEntity entity) {
    if (entity is File) {
      try {
        final bytes = entity.lengthSync();
        if (bytes <= 0) return "0 B";
        const suffixes = ["B", "KB", "MB", "GB", "TB"];
        var i = (bytes > 0) ? (bytes.toString().length - 1) ~/ 3 : 0;
        if (i >= suffixes.length) i = suffixes.length - 1;
        double value = bytes / (1 << (10 * i));
        return "${value.toStringAsFixed(1)} ${suffixes[i]}";
      } catch (e) {
        return "";
      }
    }
    return "";
  }

  String _getWindowsUserPath(String folderName) {
    final env = Platform.environment;
    return '${env['USERPROFILE'] ?? 'C:\\'}\\$folderName';
  }

  Map<String, String> get quickAccessPaths => {
        'Desktop': _getWindowsUserPath('Desktop'),
        'Documents': _getWindowsUserPath('Documents'),
        'Downloads': _getWindowsUserPath('Downloads'),
        'Pictures': _getWindowsUserPath('Pictures'),
        'Music': _getWindowsUserPath('Music'),
      };

  void _showError(String msg) {
    _errorMessage = msg;
    notifyListeners();
    Timer(const Duration(seconds: 3), () {
      _errorMessage = null;
      notifyListeners();
    });
  }

  void _showStatus(String msg) {
    _statusMessage = msg;
    notifyListeners();
    Timer(const Duration(seconds: 2), () {
      _statusMessage = null;
      notifyListeners();
    });
  }
}
