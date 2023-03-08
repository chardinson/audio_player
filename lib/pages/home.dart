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
  List<Song> songs = [];
  TextEditingController textEditingController = TextEditingController();

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
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          Column(
            children: [
              createHeader(),
              ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: songs.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      ListTile(
                        leading:
                            const CircleAvatar(child: Icon(Icons.music_note)),
                        onTap: () {
                          navigateToPlayer(songs[index]);
                        },
                        title: Text(songs[index].name),
                      ),
                      const Divider(
                        thickness: 1,
                        indent: 24,
                        endIndent: 24,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          player()
        ],
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
      title: const Text('Music'),
      actions: [
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
                        TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel')),
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              navigateToPlayer(
                                  Song(const Uuid().v4(), 'Radio', radioUrl));
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

  void navigateToPlayer(Song song) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Player(
                  songToPlay: song,
                  songs: songs,
                ))).then((value) {
      AudioPlayer().play(DeviceFileSource(
          songs.firstWhere((element) => element.id == value).path));
    });
  }

  void pickFiles() {
    Utils.pickSongs().then((songs) {
      List<Song> s = List.from(songs);
      s.addAll(songs);
      s.addAll(songs);
      s.addAll(songs);
      s.addAll(songs);
      setState(() => this.songs = s);
    });
  }

  player() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(
              children: [
                const Image(
                  image: NetworkImage(
                      'https://img.freepik.com/free-vector/musical-notes-frame-with-text-space_1017-32857.jpg'),
                  height: 60,
                  width: 40,
                ),
                const SizedBox(
                  width: 8,
                ),
                Column(
                  children: const [
                    Text('Descender - 2015'),
                    Text('Case & Point'),
                  ],
                ),
              ],
            ),
            Row(
              children: const [
                Icon(Icons.radio),
                SizedBox(width: 6),
                Icon(Icons.favorite),
                SizedBox(width: 6),
                Icon(Icons.play_arrow)
              ],
            )
          ]),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: LinearProgressIndicator(
              value: 0.1,
            ),
          )
        ],
      ),
    );
  }
}
