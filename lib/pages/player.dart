import 'package:audio_player/models/song.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../audio_player.dart';
import '../utils.dart';

class Player extends StatefulWidget {
  const Player({super.key, required this.songToPlay, required this.songs});
  final Song songToPlay;
  final List<Song> songs;

  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  CustomAudioPlayer audioPlayer = CustomAudioPlayer();
  late List<Song> songs;
  late Song selectedSong;
  bool isShuffleEnabled = false;
  bool isUpdatingSeek = false;
  int repeatState = 0;
  int seek = 0;

  bool get isHttpResource {
    return Utils.isPathHttpUrl(selectedSong.path);
  }

  IconData get repeatIcon {
    IconData repeatIcon = Icons.repeat;
    if (repeatState == 1) {
      repeatIcon = Icons.repeat_one;
    } else if (repeatState == 2) {
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
      if (!isUpdatingSeek && !isHttpResource && mounted) {
        setState(() => seek = duration.inSeconds);
      }
    });
    audioPlayer.onPlayerComplete.listen((_) {
      if (repeatState == 2 && mounted) {
        skipToSong(1);
      }
    });
    audioPlayer.onPlayerStateChanged.listen((playerState) {
      if (mounted) {
        setState(() {});
      }
    });

    playSong();
  }

  void handleRepeatIconClick() async {
    final code = (repeatState + 1) % 3;
    if (code == 0) {
      await audioPlayer.setReleaseMode(ReleaseMode.stop);
    } else if (code == 1) {
      await audioPlayer.setReleaseMode(ReleaseMode.loop);
    } else if (code == 2) {
      await audioPlayer.setReleaseMode(ReleaseMode.release);
    }
    setState(() => repeatState = code);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context,
                    {"selectedSong": selectedSong, "audioPlayer": audioPlayer});
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
                            max: selectedSong.duration?.toDouble() ?? 0,
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
                        Text(Utils.formatTime(selectedSong.duration ?? 0)),
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
    // final song = Utils.getSong(songs, selectedSong.id, newIndex);
    // audioPlayer.play(DeviceFileSource(song.path));
    audioPlayer.skip(1);
  }

  void playSong() async {
    if (audioPlayer.state == PlayerState.playing) {
      audioPlayer.pause();
    } else {
      await audioPlayer.play(DeviceFileSource(selectedSong.path));
    }
    setState(() {});
  }

  shuffleSongs() {
    songs = isShuffleEnabled ? List.from(widget.songs) : Utils.shuffle(songs);
  }
}
