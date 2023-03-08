import 'package:audio_player/models/song.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../utils.dart';

class Player extends StatefulWidget {
  const Player({super.key, required this.songToPlay, required this.songs});
  final Song songToPlay;
  final List<Song> songs;

  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  AudioPlayer audioPlayer = AudioPlayer();
  late List<Song> songs;
  late Song selectedSong;
  bool isShuffleEnabled = false;
  bool isUpdatingSeek = false;
  int repeatIconCode = 0;
  int seek = 0;
  int length = 0;

  bool get isHttpResource {
    return Utils.isPathHttpUrl(selectedSong.path);
  }

  IconData get repeatIcon {
    IconData repeatIcon = Icons.repeat;
    if (repeatIconCode == 1) {
      repeatIcon = Icons.repeat_one;
    } else if (repeatIconCode == 2) {
      repeatIcon = Icons.repeat_on;
    }
    return repeatIcon;
  }

  @override
  void initState() {
    super.initState();
    selectedSong = widget.songToPlay;
    songs = List.from(widget.songs);

    audioPlayer.onPositionChanged.listen((duration) {
      if (!isUpdatingSeek && !isHttpResource) {
        setState(() => seek = duration.inSeconds);
      }
    });
    audioPlayer.onPlayerComplete.listen((_) {
      if (repeatIconCode == 2) {
        skipToSong(1);
      }
    });
    audioPlayer.onDurationChanged.listen((duration) {
      setState(() => length = duration.inSeconds);
    });
    audioPlayer.onPlayerStateChanged.listen((playerState) => setState(() {}));

    playSong();
  }

  handleRepeatIconClick() async {
    final code = ++repeatIconCode % 3;
    if (code == 0) {
      await audioPlayer.setReleaseMode(ReleaseMode.stop);
    } else if (code == 1) {
      await audioPlayer.setReleaseMode(ReleaseMode.loop);
    } else if (code == 2) {
      await audioPlayer.setReleaseMode(ReleaseMode.release);
    }
    setState(() => repeatIconCode = code);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () async {
                await audioPlayer.setReleaseMode(ReleaseMode.release);
                audioPlayer
                    .release()
                    .then((value) => Navigator.pop(context, selectedSong.id));
              },
              icon: const Icon(Icons.keyboard_arrow_down)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black,
        ),
        body: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Text(selectedSong.name)],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 22),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(Utils.formatTime(seek.toInt())),
                        Expanded(
                          child: Slider(
                            min: 0,
                            max: length.toDouble(),
                            value: seek.toDouble(),
                            onChangeStart: (value) => isUpdatingSeek = true,
                            onChangeEnd: (value) {
                              isUpdatingSeek = false;
                              audioPlayer
                                  .seek(Duration(seconds: value.toInt()));
                            },
                            onChanged: isHttpResource
                                ? null
                                : (value) {
                                    setState(() => seek = value.toInt());
                                  },
                          ),
                        ),
                        Text(Utils.formatTime(length)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Container(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: isHttpResource ? null : handleRepeatIconClick,
                    icon: Icon(repeatIcon),
                  ),
                  IconButton(
                    onPressed: isHttpResource ? null : () => skipToSong(-1),
                    icon: const Icon(Icons.skip_previous),
                  ),
                  IconButton(
                      onPressed: playSong,
                      icon: Icon(audioPlayer.state == PlayerState.playing
                          ? Icons.pause
                          : Icons.play_arrow)),
                  IconButton(
                    onPressed: isHttpResource ? null : () => skipToSong(1),
                    icon: const Icon(Icons.skip_next),
                  ),
                  IconButton(
                    onPressed: isHttpResource
                        ? null
                        : () {
                            shuffleSongs();
                            setState(
                                () => isShuffleEnabled = !isShuffleEnabled);
                          },
                    icon: Icon(
                        isShuffleEnabled ? Icons.shuffle_on : Icons.shuffle),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            )
          ],
        ),
      ),
    );
  }

  skipToSong(int newIndex) async {
    final song = Utils.getSong(songs, selectedSong.id, newIndex);
    audioPlayer.play(DeviceFileSource(song.path));
  }

  playSong() async {
    if (audioPlayer.state == PlayerState.completed ||
        audioPlayer.state == PlayerState.stopped) {
      audioPlayer.play(DeviceFileSource(selectedSong.path));
    } else if (audioPlayer.state == PlayerState.paused) {
      audioPlayer.resume();
    } else if (audioPlayer.state == PlayerState.playing) {
      audioPlayer.pause();
    }
  }

  shuffleSongs() {
    songs = isShuffleEnabled ? List.from(widget.songs) : Utils.shuffle(songs);
  }
}
