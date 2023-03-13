import 'dart:math';

import 'package:audio_player/pages/player.dart';
import 'package:audio_player/models/song.dart';
import 'package:audio_player/utils.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import 'package:uuid/uuid.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Song> pickedSongs = [];
  List<Song> songs = [];
  AudioPlayer audioPlayer = AudioPlayer(playerId: 'CHARDIN');
  Song? selectedSong;
  int seek = 0;
  TextEditingController textEditingController = TextEditingController();
  String get currentSongName {
    return selectedSong?.name ?? 'Name not found';
  }

  final _controller = TextEditingController();
  bool _showSearch = false;
  bool _showBackButton = false;

  void _toggleSearch() {
    setState(() {
      _showSearch = !_showSearch;
      _showBackButton = !_showBackButton;
    });
  }

  void _goBack() {
    setState(() {
      _showSearch = false;
      _showBackButton = false;
      _controller.text = '';
    });
  }

  get isSongSelected {
    return selectedSong != null;
  }

  @override
  void initState() {
    super.initState();
    audioPlayer.onPositionChanged.listen((duration) {
      if (!isHttpResource) {
        setState(() => seek = duration.inSeconds);
      }
    });
    audioPlayer.onPlayerStateChanged.listen((playerState) => setState(() {}));

    _controller.addListener(() {
      setState(() {
        songs = Utils.filterSongs(pickedSongs, _controller.text);
      });
    });
  }

  bool get isHttpResource {
    return Utils.isPathHttpUrl(selectedSong?.path ?? '');
  }

  String get radioUrl {
    return textEditingController.text.isEmpty
        ? 'https://26423.live.streamtheworld.com/LOS40_MEXICO_SC'
        : textEditingController.text;
  }

  void playRandomSong() {
    if (songs.isNotEmpty) {
      final randomIndex = Random().nextInt(songs.length);
      navigateToPlayer(songs[randomIndex]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: generateAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                createHeader(),
                Flexible(
                  child: ListView.builder(
                    itemCount: songs.length,
                    itemBuilder: (context, index) {
                      final song = songs[index];
                      final isSelected = song.id == selectedSong?.id;
                      return Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                                child: Icon(isSelected
                                    ? Icons.play_arrow
                                    : Icons.music_note)),
                            onTap: () async {
                              await audioPlayer
                                  .play(DeviceFileSource(song.path));
                              setState(() => selectedSong = song);
                            },
                            title: Text(
                              song.name,
                              style: TextStyle(
                                  color:
                                      isSelected ? Colors.green : Colors.black),
                            ),
                            trailing:
                                Text(Utils.formatTime(song.duration ?? 0)),
                          ),
                          const Divider(
                            thickness: 1,
                            indent: 16,
                            endIndent: 16,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: InkWell(
        onTap: navigateToPlayer,
        child: BottomAppBar(
          child: Row(
            children: [
              CircleAvatar(
                child: Icon(isHttpResource ? Icons.radio : Icons.music_note),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          child: Text(currentSongName),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                if (audioPlayer.state == PlayerState.playing) {
                                  audioPlayer.pause();
                                } else {
                                  audioPlayer.resume();
                                }
                              },
                              icon: Icon(
                                  audioPlayer.state == PlayerState.playing
                                      ? Icons.pause
                                      : Icons.play_arrow),
                            ),
                            IconButton(
                                onPressed: playRandomSong,
                                icon: const Icon(Icons.skip_next))
                          ],
                        ),
                      ],
                    ),
                    isHttpResource
                        ? Container()
                        : LinearProgressIndicator(
                            value: (seek / (selectedSong?.duration ?? 1)),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Align createHeader() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          '${songs.length} number of songs',
        ),
      ),
    );
  }

  AppBar generateAppBar(BuildContext context) {
    return AppBar(
      title: _showSearch
          ? TextFormField(
              autofocus: true,
              controller: _controller,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                      onPressed: _controller.clear,
                      icon: const Icon(Icons.clear))),
            )
          : const Text('My App'),
      leading: _showBackButton
          ? IconButton(
              onPressed: _goBack,
              icon: const Icon(Icons.arrow_back),
            )
          : null,
      actions: _showSearch
          ? null
          : [
              IconButton(
                  onPressed: (_toggleSearch), icon: const Icon(Icons.search)),
              IconButton(
                onPressed: () {
                  showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (context) => AlertDialog(
                            title: const Text('Set your url'),
                            content: SingleChildScrollView(
                              child: TextField(
                                controller: textEditingController,
                              ),
                            ),
                            actions: [
                              OutlinedButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel')),
                              FilledButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    navigateToPlayer(Song(
                                        const Uuid().v4(), 'Radio', radioUrl));
                                  },
                                  child: const Text('Play')),
                            ],
                          ));
                },
                icon: const Icon(Icons.radio),
                tooltip: 'Url',
              ),
              IconButton(
                onPressed: pickFiles,
                icon: const Icon(Icons.library_music),
                tooltip: 'Pick Music',
              ),
            ],
    );
  }

  void navigateToPlayer([Song? song]) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Player(
                  songToPlay: song ?? selectedSong!,
                  songs: songs,
                )));
    setState(() {
      selectedSong = result['selectedSong'];
      audioPlayer = result['audioPlayer'];
    });
  }

  void pickFiles() {
    Utils.pickSongs().then((songs) {
      setState(() {
        pickedSongs = songs;
        this.songs = List.from(songs);
      });
    });
  }
}
