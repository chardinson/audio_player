import 'package:audio_player/widgets/url_input.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'custom_audio_player.dart';
import '../models/song.dart';

class Utils {
  static final AudioPlayer audioPlayer =
      AudioPlayer(playerId: 'AudioPlayerLoader');

  static String formatTime(int seconds) {
    final time = '${Duration(seconds: seconds)}'.split('.')[0];
    return seconds >= 3600 ? time : time.replaceFirst('0:', '');
  }

  static Future<List<Song>> pickSongs() async {
    List<Song> songs = [];
    final regExp = RegExp(r'\.[^.]*$');

    final filePickerResult = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: true,
    );
    for (final platformFile in (filePickerResult?.files ?? [])) {
      final name = platformFile.name.replaceFirst(regExp, '');
      final path = platformFile.path!;
      await audioPlayer.setSourceDeviceFile(path);
      final duration = await audioPlayer.getDuration();
      songs.add(Song(
        id: const Uuid().v4(),
        name: name,
        path: path,
        duration: duration!.inSeconds,
      ));
    }
    return songs;
  }

  static showUrlInput(BuildContext context) async {
    final Song? song = await showDialog(
      context: context,
      builder: (context) => const UrlInput(),
    );
    if (song != null) {
      final CustomAudioPlayer audioPlayer = CustomAudioPlayer();
      audioPlayer.currentAudio = song;
      audioPlayer.play(UrlSource(song.path));
    }
  }
}
