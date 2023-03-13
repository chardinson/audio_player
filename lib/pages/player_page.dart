import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

import '../custom_audio_player.dart';
import '../utils.dart';

class PlayerPage extends StatefulWidget {
  const PlayerPage({super.key});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  final CustomAudioPlayer _audioPlayer = CustomAudioPlayer();
  late StreamSubscription<PlayerState> _onPlayerStateChangedSubscription;
  late StreamSubscription<Duration> _onPositionChangedSubscription;
  bool _isChangingSlider = false;
  int _sliderPosition = 0;

  int get _seek => _isChangingSlider ? _sliderPosition : _audioPlayer.position;

  double get _sliderMaxValue {
    return max(
        _audioPlayer.currentAudio!.duration?.toDouble() ?? 0, _seek.toDouble());
  }

  @override
  void initState() {
    super.initState();

    _onPositionChangedSubscription =
        _audioPlayer.onPositionChanged.listen((duration) {
      if (!_isChangingSlider) {
        setState(() {});
      }
    });
    _onPlayerStateChangedSubscription =
        _audioPlayer.onPlayerStateChanged.listen((playerState) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(useMaterial3: true),
      home: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: FractionallySizedBox(
                      heightFactor: 0.65,
                      widthFactor: 0.8,
                      child: Column(
                        children: [
                          Expanded(
                            child: CachedNetworkImage(
                              imageUrl:
                                  _audioPlayer.currentAudio?.thumbnail ?? '',
                              errorWidget: (context, url, error) => FittedBox(
                                child: Icon(
                                  Icons.play_circle,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            height: 20,
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: _audioPlayer.state == PlayerState.playing
                                ? Marquee(
                                    blankSpace: 100,
                                    text: _audioPlayer.currentAudio!.name,
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.bold),
                                  )
                                : Text(
                                    _audioPlayer.currentAudio!.name,
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
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 22),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          Utils.formatTime(_seek.toInt()),
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        Expanded(
                          child: Slider(
                            min: 0,
                            max: _sliderMaxValue,
                            value: _seek.toDouble(),
                            onChangeStart: (value) => _isChangingSlider = true,
                            onChangeEnd: (value) {
                              _isChangingSlider = false;
                              _audioPlayer
                                  .seek(Duration(seconds: value.toInt()));
                            },
                            onChanged: (value) {
                              setState(() => _sliderPosition = value.toInt());
                            },
                          ),
                        ),
                        Text(
                          Utils.formatTime(
                              _audioPlayer.currentAudio!.duration ?? 0),
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
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
                    color: Theme.of(context).primaryColor,
                    onPressed: () {
                      setState(() => _audioPlayer.nextLoopMode());
                    },
                    icon: Icon(_audioPlayer.loopMode == LoopMode.off
                        ? Icons.repeat
                        : Icons.repeat_one),
                    selectedIcon: const Icon(Icons.repeat_on),
                    isSelected: _audioPlayer.loopMode == LoopMode.all,
                  ),
                  IconButton(
                    color: Theme.of(context).primaryColor,
                    onPressed: _audioPlayer.audios.length == 1
                        ? null
                        : () => _audioPlayer.skip(-1),
                    icon: const Icon(Icons.skip_previous),
                  ),
                  IconButton(
                      onPressed: () => _audioPlayer.tooglePlay(),
                      color: Theme.of(context).primaryColor,
                      iconSize: 34,
                      icon: Icon(_audioPlayer.state == PlayerState.playing
                          ? Icons.pause
                          : Icons.play_arrow)),
                  IconButton(
                    color: Theme.of(context).primaryColor,
                    onPressed: _audioPlayer.audios.length == 1
                        ? null
                        : () => _audioPlayer.skip(1),
                    icon: const Icon(Icons.skip_next),
                  ),
                  IconButton(
                    color: Theme.of(context).primaryColor,
                    onPressed: _audioPlayer.audios.length == 1
                        ? null
                        : () {
                            setState(() => _audioPlayer.toogleShuffle());
                          },
                    icon: const Icon(Icons.shuffle),
                    selectedIcon: const Icon(Icons.shuffle_on),
                    isSelected: _audioPlayer.isShuffleEnabled,
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

  @override
  void dispose() {
    super.dispose();
    _onPlayerStateChangedSubscription.cancel();
    _onPositionChangedSubscription.cancel();
  }
}
