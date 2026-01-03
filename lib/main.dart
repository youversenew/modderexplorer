import 'package:flutter/material.dart';
import 'explorer_app.dart';
import 'explorer_ui.dart';

void main() {
  runApp(const ModderFileManager());
}

class ModderFileManager extends StatelessWidget {
  const ModderFileManager({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Modder File Explorer',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,

      // Ilova uchun Dark Theme sozlamalari
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: ModderTheme.background,
        primaryColor: ModderTheme.accent,
        fontFamily: 'Segoe UI', // Windows uchun standart shrift
        useMaterial3: true,

        // Scrollbarlar Windows style'da ingichka bo'lishi uchun
        scrollbarTheme: ScrollbarThemeData(
          thumbColor:
              MaterialStateProperty.all(ModderTheme.accent.withOpacity(0.5)),
          thickness: MaterialStateProperty.all(4),
          radius: const Radius.circular(10),
        ),

        colorScheme: const ColorScheme.dark(
          primary: ModderTheme.accent,
          background: ModderTheme.background,
          surface: ModderTheme.surface,
        ),
      ),

      home: const ExplorerApp(),
    );
  }
}
