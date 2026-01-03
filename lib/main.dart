import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'explorer_app.dart';
import 'explorer_ui.dart';

void main() {
  // Tizim UI overlaylarini sozlash (Status bar va navigation bar ranglari)
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
  ));

  runApp(const MacosFileManager());
}

class MacosFileManager extends StatelessWidget {
  const MacosFileManager({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finder X',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,

      // Ilova uchun Dark Theme (MacOS Style)
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: MacosTheme.background,
        primaryColor: MacosTheme.accent,
        fontFamily: 'Segoe UI', // Windowsda toza ko'rinish uchun

        // Context Menu va Dialoglar uchun style
        dialogBackgroundColor: Colors.transparent,

        // Scrollbar MacOS kabi ingichka
        scrollbarTheme: ScrollbarThemeData(
          thumbColor: MaterialStateProperty.all(Colors.white24),
          thickness: MaterialStateProperty.all(6),
          radius: const Radius.circular(10),
          minThumbLength: 50,
        ),

        colorScheme: const ColorScheme.dark(
          primary: MacosTheme.accent,
          background: MacosTheme.background,
          surface: MacosTheme.canvasColor,
        ),

        // Text Selection Color (MacOS Blue)
        textSelectionTheme: const TextSelectionThemeData(
          selectionColor: MacosTheme.selection,
          selectionHandleColor: MacosTheme.accent,
        ),
      ),

      home: const ExplorerApp(),
    );
  }
}
