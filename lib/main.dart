import 'package:audio_player/pages/song_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: const SongPage(),
    theme: ThemeData(useMaterial3: true),
    debugShowCheckedModeBanner: false,
  ));
}
