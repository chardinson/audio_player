import 'package:audio_player/models/audio.dart';

class Song extends Audio {
  Song(
      {super.id,
      super.name,
      required super.path,
      super.duration,
      super.homePage,
      super.thumbnail});
}
