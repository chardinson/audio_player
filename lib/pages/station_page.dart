import 'dart:async';

import 'package:audio_player/custom_audio_player.dart';
import 'package:audio_player/models/cache.dart';
import 'package:audio_player/pages/radio_player_page.dart';
import 'package:audio_player/utils.dart';
import 'package:audio_player/widgets/compact_player_controller.dart';
import 'package:audio_player/widgets/custom_app_bar.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../api.dart';
import '../global_enums.dart';
import '../models/audio.dart';
import '../models/station.dart';

class StationPage extends StatefulWidget {
  const StationPage(this.countryIsoCode, {super.key});
  final String countryIsoCode;

  @override
  State<StationPage> createState() => _StationPageState();
}

class _StationPageState extends State<StationPage> {
  final CustomAudioPlayer _audioPlayer = CustomAudioPlayer();
  final SearchBarController searchBarController = SearchBarController();
  late StreamSubscription<Audio> _onAudioSkippedSubscription;
  late StreamSubscription<PlayerState> _onPlayerStateChangedSubscription;
  List<Station> _stations = [];
  FetchState _fetchState = FetchState.none;
  bool _isSearchVisible = false;

  set fetchState(value) {
    if (mounted) {
      setState(() {});
    }
    _fetchState = value;
  }

  get fetchState => _fetchState;

  get body {
    Widget body = ListView.builder(
      itemCount: _stations.length,
      itemBuilder: (context, index) {
        Station station = _stations[index];
        final isSelected = station.id == _audioPlayer.currentAudio?.id;
        return Column(
          children: [
            ListTile(
              leading: CircleAvatar(
                  child: isSelected
                      ? const Icon(Icons.play_arrow)
                      : Image.network(
                          station.thumbnail!,
                          errorBuilder: (context, error, stackTrace) =>
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
                _audioPlayer.audios = _stations;
                setState(() {
                  _audioPlayer.currentAudio = station;
                });
                _audioPlayer.play(UrlSource(station.path));
              },
            ),
          ],
        );
      },
    );
    if (_fetchState == FetchState.loading) {
      body = Center(
        child: SpinKitSpinningLines(
          color: Theme.of(context).primaryColor,
          lineWidth: 6,
          size: 180,
        ),
      );
    } else if (_fetchState == FetchState.error) {
      body = Center(
        child: FractionallySizedBox(
          widthFactor: 0.3,
          heightFactor: 0.2,
          child: FittedBox(
              child: IconButton(
            icon: const Icon(Icons.sync_problem),
            onPressed: fetchStations,
          )),
        ),
      );
    }
    return body;
  }

  @override
  void initState() {
    super.initState();
    fetchStations();

    _onAudioSkippedSubscription =
        _audioPlayer.onAudioSkipped.listen((_) => setState(() {}));
    _onPlayerStateChangedSubscription =
        _audioPlayer.onPlayerStateChanged.listen((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (_isSearchVisible) {
          searchBarController.toggleSearchBar();
          setState(() => _isSearchVisible = false);

          return Future(() => false);
        }
        return Future(() => true);
      },
      child: Scaffold(
        appBar: CustomAppBar(
          onSearch: handleSearch,
          searchBarController: searchBarController,
          onToggleSearch: (isSearchVisible) =>
              _isSearchVisible = isSearchVisible,
          customActions: [
            IconButton(
              onPressed: () => Utils.showUrlInput(context),
              icon: const Icon(Icons.link),
              tooltip: 'Set url',
            ),
          ],
        ),
        body: body,
        bottomNavigationBar: _audioPlayer.currentAudio == null
            ? const SizedBox()
            : CompactPlayerController(
                onTap: _audioPlayer.isUrlSource
                    ? () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RadioPlayerPage()))
                    : null),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _onAudioSkippedSubscription.cancel();
    _onPlayerStateChangedSubscription.cancel();
  }

  handleSearch(String searchTerm) {
    setState(() {
      _stations = Cache.stations[widget.countryIsoCode]!
          .where((station) =>
              RegExp(searchTerm, caseSensitive: false).hasMatch(station.name) ||
              RegExp(searchTerm, caseSensitive: false).hasMatch(station.state))
          .toList();
    });
  }

  void fetchStations() async {
    FetchState previousFetchState = fetchState;
    try {
      fetchState = FetchState.loading;
      if (previousFetchState == FetchState.error) {
        await Future.delayed(const Duration(seconds: 1));
      }
      _stations = await Api.getStations(widget.countryIsoCode);
      fetchState = FetchState.success;
    } catch (e) {
      fetchState = FetchState.error;
    }
  }
}
