import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';

import 'models/song.dart';

class Utils {
  static bool isPathHttpUrl(String path) {
    return path.startsWith('http');
  }

  static shuffle(List<dynamic> list) {
    List<dynamic> listToShuffle = List.from(list);
    for (int i = listToShuffle.length - 1; i > 0; i--) {
      final j = Random().nextInt(i + 1);
      final temp = listToShuffle[i];
      listToShuffle[i] = listToShuffle[j];
      listToShuffle[j] = temp;
    }
    return listToShuffle;
  }

  static Song getSong(
      List<dynamic> elements, String elementId, int indexToNavigate) {
    final index = elements.indexWhere((song) => song.id == elementId);
    final length = elements.length;

    return elements[((index + indexToNavigate) % length + length) % length];
  }

  static String formatTime(int seconds) {
    final time = '${Duration(seconds: seconds)}'.split('.')[0];
    return seconds >= 3600 ? time : time.replaceFirst('0:', '');
  }

  static Future<List<Song>> pickSongs() async {
    final filePickerResult = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: true,
    );

    return (filePickerResult?.files ?? [])
        .map((platformFile) => Song(
            const Uuid().v4(),
            platformFile.name.replaceFirst(RegExp(r'\.[^.]*$'), ''),
            platformFile.path!))
        .toList();
  }
}
