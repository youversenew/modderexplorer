import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'explorer_app.dart';
import 'explorer_ui.dart';

void main() {
  // Tizim UI ranglarini sozlash (Status bar va Navigation bar)
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(const MacosFinderApp());
}

class MacosFinderApp extends StatelessWidget {
  const MacosFinderApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Taskbar va Oyna sarlavhasi
      title: 'Finder', 
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      
      // MacOS Dark Theme Sozlamalari
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: MacosTheme.background,
        primaryColor: MacosTheme.accent,
        fontFamily: 'Segoe UI', // Windowsda toza ko'rinish uchun standart shrift
        
        // Tooltips (Sichqoncha borganda chiquvchi yozuvlar)
        tooltipTheme: TooltipThemeData(
          decoration: BoxDecoration(
            color: const Color(0xE6202020),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.white12),
          ),
          textStyle: const TextStyle(color: Colors.white, fontSize: 12),
        ),

        // Scrollbar (MacOS kabi ingichka va suzuvchi)
        scrollbarTheme: ScrollbarThemeData(
          thumbColor: MaterialStateProperty.all(Colors.white24),
          trackColor: MaterialStateProperty.all(Colors.transparent),
          thickness: MaterialStateProperty.all(6),
          radius: const Radius.circular(10),
          minThumbLength: 50,
          interactive: true,
        ),

        // Text Selection (Ko'k rang)
        textSelectionTheme: const TextSelectionThemeData(
          selectionColor: MacosTheme.selection,
          selectionHandleColor: MacosTheme.accent,
          cursorColor: MacosTheme.textPrimary,
        ),
        
        colorScheme: const ColorScheme.dark(
          primary: MacosTheme.accent,
          background: MacosTheme.background,
          surface: MacosTheme.sidebarBg,
        ),
      ),
      
      home: const ExplorerApp(),
    );
  }
}
