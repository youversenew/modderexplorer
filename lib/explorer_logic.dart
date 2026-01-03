import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';

/// ⚙️ EXPLORER LOGIC
/// Fayl tizimi operatsiyalarini va navigatsiya holatini boshqaradi.

class ExplorerController extends ChangeNotifier {
  // -- State --
  String _currentPath = 'C:\\';
  List<FileSystemEntity> _files = [];
  List<String> _drives = [];
  bool _isLoading = false;
  String? _errorMessage;

  // -- Navigation History --
  List<String> _history = [];
  int _historyIndex = -1;

  // -- Getters --
  String get currentPath => _currentPath;
  List<FileSystemEntity> get files => _files;
  List<String> get drives => _drives;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get canGoBack => _historyIndex > 0;
  bool get canGoForward => _historyIndex < _history.length - 1;

  // -- Initialization --
  ExplorerController() {
    _loadDrives();
    navigateTo(_getWindowsUserPath('Desktop')); // Start at Desktop
  }

  /// Windows drayverlarini (C:, D: ...) aniqlash uchun WMIC buyrug'idan foydalanamiz
  Future<void> _loadDrives() async {
    try {
      final result = await Process.run('wmic', ['logicaldisk', 'get', 'name']);
      if (result.exitCode == 0) {
        final output = result.stdout.toString();
        // Output example: "Name\nC:\n D:\n"
        final lines = output
            .split('\n')
            .where((l) => l.contains(':'))
            .map((l) => l.trim())
            .toList();

        // Remove header "Name" if present and duplicates
        _drives = lines.where((l) => l.length == 2).map((l) => '$l\\').toList();
        notifyListeners();
      }
    } catch (e) {
      // Fallback: Agar wmic ishlamasa, standart C va D ni qo'shamiz
      _drives = ['C:\\', 'D:\\'];
      notifyListeners();
    }
  }

  /// Asosiy navigatsiya funksiyasi
  Future<void> navigateTo(String path, {bool addToHistory = true}) async {
    // 1. Path validatsiyasi
    final dir = Directory(path);
    if (!await dir.exists()) {
      _showError("Directory not found: $path");
      return;
    }

    // 2. State yangilash (Loading)
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 3. Fayllarni o'qish (Async)
      // Tizim papkalarida (System Volume Info) ruxsat xatosi bo'lishi mumkin
      final List<FileSystemEntity> entities = [];

      await for (final entity in dir.list(followLinks: false)) {
        entities.add(entity);
      }

      // 4. Tartiblash: Papkalar birinchi, keyin fayllar. Hammasi alifbo bo'yicha.
      entities.sort((a, b) {
        bool aIsDir = a is Directory;
        bool bIsDir = b is Directory;

        if (aIsDir && !bIsDir) return -1;
        if (!aIsDir && bIsDir) return 1;
        return a.path.toLowerCase().compareTo(b.path.toLowerCase());
      });

      // 5. Muvaffaqiyatli yuklash
      _files = entities;
      _currentPath = path;

      // History boshqaruvi
      if (addToHistory) {
        if (_historyIndex < _history.length - 1) {
          // Agar o'rtada bo'lib yangi joyga kirsak, oldinga yo'l o'chadi
          _history = _history.sublist(0, _historyIndex + 1);
        }
        _history.add(path);
        _historyIndex = _history.length - 1;
      }
    } catch (e) {
      // Ruxsat yo'q yoki tizim xatosi
      _showError("Access Denied: $e");
      // Fayl ro'yxatini bo'shatmaymiz, eski ro'yxat qolishi mumkin yoki bo'shatamiz
      _files = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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

  void refresh() {
    navigateTo(_currentPath, addToHistory: false);
  }

  void goToParent() {
    final parent = Directory(_currentPath).parent;
    if (parent.path != _currentPath) {
      navigateTo(parent.path);
    }
  }

  // -- Helpers --

  void _showError(String msg) {
    _errorMessage = msg;
    notifyListeners();
    // Xabarni 3 soniyadan keyin o'chirish
    Timer(const Duration(seconds: 3), () {
      _errorMessage = null;
      notifyListeners();
    });
  }

  /// Fayl hajmini o'qish uchun yordamchi
  static String formatSize(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    var i = (bytes > 0)
        ? (bytes.toString().length - 1) ~/ 3
        : 0; // Log10 approximation
    // i ni array chegarasida ushlab turamiz
    if (i >= suffixes.length) i = suffixes.length - 1;

    double value = bytes / (1 << (10 * i)); // 1024^i
    return "${value.toStringAsFixed(1)} ${suffixes[i]}";
  }

  /// Fayl hajmini olish (faqat File uchun, Directory uchun hisoblash qimmatga tushadi)
  static String getFileSize(FileSystemEntity entity) {
    if (entity is File) {
      try {
        return formatSize(entity.lengthSync());
      } catch (e) {
        return "?";
      }
    }
    return ""; // Papkalar hajmini ko'rsatmaymiz (tezlik uchun)
  }

  /// Windows maxsus papkalarini topish (Documents, Downloads, etc.)
  String _getWindowsUserPath(String folderName) {
    final envVars = Platform.environment;
    final userProfile = envVars['USERPROFILE'];
    if (userProfile != null) {
      return '$userProfile\\$folderName';
    }
    return 'C:\\'; // Fallback
  }

  // Quick Access uchun map
  Map<String, String> get quickAccessPaths => {
        'Desktop': _getWindowsUserPath('Desktop'),
        'Documents': _getWindowsUserPath('Documents'),
        'Downloads': _getWindowsUserPath('Downloads'),
        'Music': _getWindowsUserPath('Music'),
        'Pictures': _getWindowsUserPath('Pictures'),
      };
}
