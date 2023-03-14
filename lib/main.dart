import 'package:audio_player/pages/country_page.dart';
import 'package:audio_player/pages/song_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    // home: const SongPage(),
    home: CountryPage(),
    theme: ThemeData(useMaterial3: true),
    debugShowCheckedModeBanner: false,
  ));
}
