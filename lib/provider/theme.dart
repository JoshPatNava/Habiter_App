import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  int _currentThemeSetting = 0;
  ThemeData _currentTheme = themeBlue;

  ThemeData get currentTheme => _currentTheme;
  int get currentThemeSetting => _currentThemeSetting;

  ThemeProvider() {
    _loadTheme();
  }

  void changeTheme(int themeSetting) async {
    _currentThemeSetting = themeSetting;
    _currentTheme = themes[themeSetting]!;
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt("current_theme", themeSetting);
  }

  void _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? themeSetting = prefs.getInt("current_theme");
    if (themeSetting != null) {
      _currentThemeSetting = themeSetting;
      _currentTheme = themes[themeSetting]!;
      notifyListeners;
    }
  }
}

final Map<int, ThemeData> themes = {
  0 : themeBlue,
  1 : themeDark,
};

final ThemeData themeBlue = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: Color(0xff7886c7),
  bottomAppBarTheme: BottomAppBarThemeData(
    color: Color(0xffffeaea),
    shape: const CircularNotchedRectangle(),
    elevation: 10.0,
    shadowColor: Colors.black,
  ),
  textTheme: TextTheme(
    headlineLarge: GoogleFonts.openSans(fontSize: 32, color: Color(0xff1a1d3f), fontWeight: FontWeight.w600),
    headlineMedium: GoogleFonts.openSans(fontSize: 28, color: Color(0xff1a1d3f), fontWeight: FontWeight.w600),
    titleLarge: GoogleFonts.openSans(fontSize: 22, color: Color(0xff1a1d3f), fontWeight: FontWeight.w600),
    titleMedium: GoogleFonts.openSans(fontSize: 16, color: Color(0xff1a1d3f), fontWeight: FontWeight.w600),
    labelLarge: GoogleFonts.openSans(fontSize: 14, color: Color(0xff1a1d3f), fontWeight: FontWeight.w600),
    labelMedium: GoogleFonts.openSans(fontSize: 12, color: Color(0xff1a1d3f), fontWeight: FontWeight.w600),
  ),
  iconButtonTheme: IconButtonThemeData(
    style: ButtonStyle(
      iconColor: WidgetStateProperty.all(Color(0xff2d336b)),
    )
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Colors.redAccent,
    foregroundColor: Color(0xfffff8f8),
  ),
  colorScheme: ColorScheme(
    brightness: Brightness.light, 
    primary: Color(0xffffeaea), 
    onPrimary: Color(0xff2d336b), 
    secondary: Colors.redAccent, 
    onSecondary: Color(0xfffff8f8),
    tertiary: Color(0xfffff8f8),
    error: Colors.red, 
    onError: Colors.white, 
    surface: Color(0xff7886c7),
    surfaceContainer: Color(0xfffff2f2),
    surfaceContainerHigh: Colors.green,
    surfaceContainerHighest: Colors.white,
    surfaceContainerLow: Colors.blueAccent,
    surfaceContainerLowest: Colors.redAccent,
    onSurface: Color(0xff191970),
    outline: Color(0xff1a1d3f),
  ),
);

final ThemeData themeDark = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: Color(0xff151515),
  bottomAppBarTheme: BottomAppBarThemeData(
    color: Color(0xff221c27),
    shape: const CircularNotchedRectangle(),
    elevation: 10.0,
    shadowColor: Colors.black,
  ),
  textTheme: TextTheme(
    headlineLarge: GoogleFonts.openSans(fontSize: 32, color: Color(0xffeaddff), fontWeight: FontWeight.w600),
    headlineMedium: GoogleFonts.openSans(fontSize: 28, color: Color(0xffeaddff), fontWeight: FontWeight.w600),
    titleLarge: GoogleFonts.openSans(fontSize: 22, color: Color(0xffeaddff), fontWeight: FontWeight.w600),
    titleMedium: GoogleFonts.openSans(fontSize: 16, color: Color(0xffeaddff), fontWeight: FontWeight.w600),
    labelLarge: GoogleFonts.openSans(fontSize: 14, color: Color(0xffeaddff), fontWeight: FontWeight.w600),
    labelMedium: GoogleFonts.openSans(fontSize: 12, color: Color(0xffeaddff), fontWeight: FontWeight.w600),
  ),
  iconButtonTheme: IconButtonThemeData(
    style: ButtonStyle(
      iconColor: WidgetStateProperty.all(Color(0xffcac4d0)),
    )
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Color(0xff4e388b),
    foregroundColor: Color(0xffeaddff),
  ),
  colorScheme: ColorScheme(
    brightness: Brightness.dark, 
    primary: Color(0xff221c27), 
    onPrimary: Color(0xffeaddff),
    secondary: Color(0xff4e388b), 
    onSecondary: Color(0xffeaddff),
    tertiary: Color(0xff140e20),
    error: Colors.red, 
    onError: Colors.white, 
    surface: Color(0xff151515),
    surfaceContainer: Color(0xff221c27),
    surfaceContainerHigh: Color(0xff204620),
    surfaceContainerHighest: Color(0xffeaddff),
    surfaceContainerLow: Color(0xff000080),
    surfaceContainerLowest: Color(0xff990000),
    onSurface: Color(0xff191970),
    outline: Color(0xffeaddff),
  ),
);