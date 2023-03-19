import 'package:audio_player/models/song.dart';
import 'package:audio_player/models/station.dart';

import '../models/country.dart';

class Cache {
  static List<Country> countries = [];
  static final Map<String, List<Station>> stations = {};
  static final List<Song> songs = [];
}
