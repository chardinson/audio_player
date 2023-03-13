import 'dart:async';

import 'package:audio_player/models/audio.dart';
import 'package:audio_player/models/cache.dart';
import 'package:audio_player/pages/country_page.dart';
import 'package:audio_player/pages/player_page.dart';
import 'package:audio_player/utils.dart';
import 'package:audio_player/widgets/compact_player_controller.dart';
import 'package:audio_player/widgets/custom_app_bar.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../custom_audio_player.dart';

class SongPage extends StatefulWidget {
  const SongPage({super.key});

  @override
  State<SongPage> createState() => _SongPageState();
}

class _SongPageState extends State<SongPage> {
  List<Audio> _songs = [];
  final CustomAudioPlayer _audioPlayer = CustomAudioPlayer();
  late StreamSubscription<Duration> _onPositionChangedSubscription;
  late StreamSubscription<PlayerState> _onPlayerStateChangedSubscription;

  @override
  void initState() {
    super.initState();
    _songs = [...Cache.songs];
    _onPositionChangedSubscription =
        _audioPlayer.onPositionChanged.listen((duration) {
      setState(() {});
    });
    _onPlayerStateChangedSubscription =
        _audioPlayer.onPlayerStateChanged.listen((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        onSearch: handleSearch,
        customActions: [
          IconButton(
            onPressed: handlePickSongs,
            icon: const Icon(Icons.library_add),
            tooltip: 'Pick songs',
          ),
          IconButton(
            onPressed: goToCountryPage,
            icon: const Icon(Icons.radio),
            tooltip: 'Radio',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                createHeader(),
                Flexible(
                  child: ListView.builder(
                    itemCount: _songs.length,
                    itemBuilder: (context, index) {
                      final song = _songs[index];
                      final isSelected =
                          song.id == _audioPlayer.currentAudio?.id;
                      return Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                                child: Icon(isSelected
                                    ? Icons.play_arrow
                                    : Icons.music_note)),
                            onTap: () {
                              _audioPlayer.audios = Cache.songs;
                              if (mounted) {
                                setState(
                                    () => _audioPlayer.currentAudio = song);
                              }
                              _audioPlayer.play(DeviceFileSource(song.path));
                            },
                            title: Text(
                              song.name,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: isSelected
                                      ? Theme.of(context).primaryColor
                                      : Colors.black),
                            ),
                            trailing: Text(
                              Utils.formatTime(song.duration ?? 0),
                              style: TextStyle(
                                  color: isSelected
                                      ? Theme.of(context).primaryColor
                                      : Colors.black),
                            ),
                          ),
                          _songs.length - 1 == index
                              ? const SizedBox()
                              : const Divider(
                                  thickness: 1, indent: 16, endIndent: 16)
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
      bottomNavigationBar: _audioPlayer.currentAudio == null
          ? const SizedBox()
          : CompactPlayerController(
              onTap: _audioPlayer.isUrlSource
                  ? null
                  : () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PlayerPage()))),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _onPlayerStateChangedSubscription.cancel();
    _onPositionChangedSubscription.cancel();
  }

  Align createHeader() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          '${_songs.length} canciones agregadas',
        ),
      ),
    );
  }

  handlePickSongs() async {
    final songs = await Utils.pickSongs();
    setState(() {
      Cache.songs.addAll(songs);
      _audioPlayer.audios = [...Cache.songs];
      _songs = [...Cache.songs];
    });
  }

  handleSearch(String searchTerm) {
    setState(() {
      _songs = _audioPlayer.audios
          .where((audio) =>
              RegExp(searchTerm, caseSensitive: false).hasMatch(audio.name))
          .toList();
    });
  }

  goToCountryPage() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const CountryPage(),
        ));
  }
}
