import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:marquee/marquee.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../helpers/custom_audio_player.dart';
import '../helpers/fetch_state.dart';
import '../models/station.dart';

class RadioPlayerPage extends StatefulWidget {
  const RadioPlayerPage({super.key});

  @override
  State<RadioPlayerPage> createState() => _RadioPlayerPageState();
}

class _RadioPlayerPageState extends State<RadioPlayerPage> {
  final CustomAudioPlayer _audioPlayer = CustomAudioPlayer();
  late StreamSubscription<PlayerState> _onPlayerStateChangedSubscription;
  late StreamSubscription<FetchState> _onFetchDataSubscription;
  late Map<String, Station> stations;

  get playIcon {
    Widget widget = const Icon(Icons.play_arrow);
    final fetchState = _audioPlayer.fetchState;
    final playerState = _audioPlayer.state;
    if (fetchState == FetchState.error) {
      widget = const Icon(Icons.sync);
    } else if (playerState == PlayerState.playing) {
      widget = const Icon(Icons.pause);
    }
    return widget;
  }

  @override
  void initState() {
    super.initState();

    _onPlayerStateChangedSubscription =
        _audioPlayer.onPlayerStateChanged.listen((playerState) {
      setState(() {});
    });
    _onFetchDataSubscription = _audioPlayer.onFetchData
        .listen((_) => setState(() {}), onError: (_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(useMaterial3: true),
      home: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Flexible(
              child: FractionallySizedBox(
                heightFactor: 0.6,
                widthFactor: 0.8,
                child: Column(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          showDialog<String>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: const Text('Ir a la página:'),
                              content: Text(_audioPlayer.currentAudio!.name),
                              actions: <Widget>[
                                OutlinedButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancelar'),
                                ),
                                FilledButton(
                                  onPressed: () async {
                                    String url =
                                        _audioPlayer.currentAudio?.homePage! ??
                                            _audioPlayer.currentAudio!.path;
                                    final uri = Uri.parse(url);
                                    if (await canLaunchUrl(uri)) {
                                      launchUrl(uri)
                                          .then((_) => Navigator.pop(context));
                                    } else {
                                      throw 'Could not launch $url';
                                    }
                                  },
                                  child: const Text('Continuar'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Image.network(
                          _audioPlayer.currentAudio?.thumbnail ?? '',
                          errorBuilder: (context, error, stackTrace) =>
                              FittedBox(
                            child: Icon(
                              Icons.radio,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 20,
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Marquee(
                        blankSpace: 100,
                        text: _audioPlayer.currentAudio!.name,
                        style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                    tooltip: 'Compartir',
                    onPressed: () => Share.share(
                        _audioPlayer.currentAudio!.homePage!,
                        subject: 'Escucha esta radio'),
                    color: Theme.of(context).primaryColor,
                    iconSize: 24,
                    icon: const Icon(Icons.share)),
                IconButton(
                  color: Theme.of(context).primaryColor,
                  onPressed: _audioPlayer.audios.length == 1
                      ? null
                      : () {
                          _audioPlayer.skip(-1);
                          setState(() {});
                        },
                  icon: const Icon(Icons.skip_previous),
                ),
                _audioPlayer.fetchState == FetchState.loading
                    ? SpinKitRipple(color: Theme.of(context).primaryColor)
                    : IconButton(
                        onPressed: _audioPlayer.tooglePlay,
                        color: Theme.of(context).primaryColor,
                        iconSize: 34,
                        icon: playIcon),
                IconButton(
                  color: Theme.of(context).primaryColor,
                  onPressed: _audioPlayer.audios.length == 1
                      ? null
                      : () {
                          _audioPlayer.skip(1);
                          setState(() {});
                        },
                  icon: const Icon(Icons.skip_next),
                ),
                IconButton(
                    tooltip: 'Abrir en el página',
                    onPressed: () async {
                      String url = _audioPlayer.currentAudio!.homePage!;
                      final uri = Uri.parse(url);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      } else {
                        throw 'Could not launch $url';
                      }
                    },
                    color: Theme.of(context).primaryColor,
                    iconSize: 24,
                    icon: const Icon(Icons.open_in_new))
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _onPlayerStateChangedSubscription.cancel();
    _onFetchDataSubscription.cancel();
  }
}
