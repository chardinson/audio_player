import 'dart:async';

import 'package:audio_player/helpers/custom_audio_player.dart';
import 'package:audio_player/models/audio.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../helpers/fetch_state.dart';

class CompactPlayerController extends StatefulWidget {
  const CompactPlayerController({super.key, this.onTap});
  final Function()? onTap;

  @override
  State<CompactPlayerController> createState() =>
      _CompactPlayerControllerState();
}

class _CompactPlayerControllerState extends State<CompactPlayerController> {
  final CustomAudioPlayer _audioPlayer = CustomAudioPlayer();
  late StreamSubscription<PlayerState> _onPlayerStateChangedSubscription;
  late StreamSubscription<Audio?> _onCurrentSongUpdatedSubscription;
  late StreamSubscription<FetchState> _onFetchDataSubscription;

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
        _audioPlayer.onPlayerStateChanged.listen((_) => setState(() {}));
    _onCurrentSongUpdatedSubscription =
        _audioPlayer.onCurrentAudioUpdated.listen((_) => setState(() {}));
    _onFetchDataSubscription = _audioPlayer.onFetchData
        .listen((_) => setState(() {}), onError: (_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: BottomAppBar(
        child: Row(
          children: [
            CircleAvatar(
              child: Image.network(
                _audioPlayer.currentAudio?.thumbnail ?? '',
                errorBuilder: (context, error, stackTrace) =>
                    _audioPlayer.isUrlSource
                        ? const Icon(Icons.radio)
                        : const Icon(Icons.music_note),
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                            child: Text(
                          _audioPlayer.currentAudio?.name ?? '',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: _audioPlayer.fetchState == FetchState.error
                                  ? Colors.redAccent
                                  : Theme.of(context).primaryColor),
                        )),
                        Row(
                          children: [
                            _audioPlayer.fetchState == FetchState.loading
                                ? SpinKitRipple(
                                    color: Theme.of(context).primaryColor)
                                : IconButton(
                                    onPressed: () => _audioPlayer.tooglePlay(),
                                    color: Theme.of(context).primaryColor,
                                    icon: playIcon,
                                  ),
                            IconButton(
                                onPressed: _audioPlayer.audios.length == 1
                                    ? null
                                    : () async {
                                        _audioPlayer.skip(1);
                                        setState(() {});
                                      },
                                color: Theme.of(context).primaryColor,
                                icon: const Icon(Icons.skip_next))
                          ],
                        ),
                      ],
                    ),
                  ),
                  _audioPlayer.isUrlSource
                      ? Container()
                      : LinearProgressIndicator(
                          value: (_audioPlayer.position /
                              (_audioPlayer.currentAudio?.duration ?? 1)),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _onCurrentSongUpdatedSubscription.cancel();
    _onFetchDataSubscription.cancel();
    _onPlayerStateChangedSubscription.cancel();
  }
}
