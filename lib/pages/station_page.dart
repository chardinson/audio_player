import 'dart:async';

import 'package:audio_player/custom_audio_player.dart';
import 'package:audio_player/models/cache.dart';
import 'package:audio_player/pages/radio_player_page.dart';
import 'package:audio_player/utils.dart';
import 'package:audio_player/widgets/compact_player_controller.dart';
import 'package:audio_player/widgets/custom_app_bar.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../api.dart';
import '../models/station.dart';

class StationPage extends StatefulWidget {
  const StationPage(this.countryIsoCode, {super.key});
  final String countryIsoCode;

  @override
  State<StationPage> createState() => _StationPageState();
}

class _StationPageState extends State<StationPage> {
  final CustomAudioPlayer _audioPlayer = CustomAudioPlayer();
  bool isFetchingStations = true;
  List<Station> stations = [];

  late StreamSubscription<PlayerState> _onPlayerStateChangedSubscription;

  @override
  void initState() {
    super.initState();
    Api.getStations(widget.countryIsoCode).then((stations) {
      this.stations = stations;
    }).whenComplete(() {
      if (mounted) {
        setState(() => isFetchingStations = false);
      }
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
            onPressed: () => Utils.showUrlInput(context),
            icon: const Icon(Icons.link),
            tooltip: 'Set url',
          ),
        ],
      ),
      body: isFetchingStations
          ? Center(
              child: SpinKitSpinningLines(
              color: Theme.of(context).primaryColor,
              lineWidth: 6,
              size: 180,
            ))
          : ListView.builder(
              itemCount: stations.length,
              itemBuilder: (context, index) {
                Station station = stations[index];
                final isSelected = station.id == _audioPlayer.currentAudio?.id;
                return Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                          child: isSelected
                              ? const Icon(Icons.play_arrow)
                              : CachedNetworkImage(
                                  imageUrl: station.thumbnail!,
                                  placeholder: (context, url) =>
                                      SpinKitDoubleBounce(
                                          color:
                                              Theme.of(context).primaryColor),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.radio),
                                )),
                      title: Text(station.name,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : Colors.black)),
                      subtitle: Text(station.state,
                          style: TextStyle(
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : Colors.black)),
                      onTap: () {
                        _audioPlayer.audios = stations;
                        setState(() {
                          _audioPlayer.currentAudio = station;
                        });
                        _audioPlayer.play(UrlSource(station.path));
                      },
                    ),
                  ],
                );
              },
            ),
      bottomNavigationBar: _audioPlayer.currentAudio == null
          ? const SizedBox()
          : CompactPlayerController(
              onTap: _audioPlayer.isUrlSource
                  ? () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RadioPlayerPage()))
                  : null),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _onPlayerStateChangedSubscription.cancel();
  }

  handleSearch(String searchTerm) {
    setState(() {
      stations = Cache.stations[widget.countryIsoCode]!
          .where((station) =>
              RegExp(searchTerm, caseSensitive: false).hasMatch(station.name) ||
              RegExp(searchTerm, caseSensitive: false).hasMatch(station.state))
          .toList();
    });
  }
}
