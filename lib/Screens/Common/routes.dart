import 'package:fiesta/Screens/Home/home.dart';
import 'package:fiesta/Screens/Library/downloads.dart';
import 'package:fiesta/Screens/Library/nowplaying.dart';
import 'package:fiesta/Screens/Library/playlists.dart';
import 'package:fiesta/Screens/Library/recent.dart';
import 'package:fiesta/Screens/Login/auth.dart';
import 'package:fiesta/Screens/Settings/new_settings_page.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

Widget initialFuntion() {
  return Hive.box('settings').get('userId') != null ? HomePage() : AuthScreen();
}

final Map<String, Widget Function(BuildContext)> namedRoutes = {
  '/': (context) => initialFuntion(),
  '/home': (context) => HomePage(),
  '/setting': (context) => const NewSettingsPage(),
  '/playlists': (context) => PlaylistScreen(),
  '/nowplaying': (context) => NowPlaying(),
  '/recent': (context) => RecentlyPlayed(),
  '/downloads': (context) => const Downloads(),
};
