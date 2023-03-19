import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';

import '../enums/fetch_state.dart';
import '../enums/loop_mode.dart';
import '../models/audio.dart';

class CustomAudioPlayer extends AudioPlayer {
  static final CustomAudioPlayer _instance = CustomAudioPlayer._internal();

  factory CustomAudioPlayer() {
    return _instance;
  }

  final StreamController<Audio?> _onCurrentAudioChangedController =
      StreamController.broadcast();
  final StreamController<FetchState> _onFetchDataController =
      StreamController.broadcast();
  final StreamController<Audio> _onAudioSkippedController =
      StreamController.broadcast();

  Stream<Audio?> get onCurrentAudioUpdated =>
      _onCurrentAudioChangedController.stream;
  Stream<FetchState> get onFetchData => _onFetchDataController.stream;
  Stream<Audio> get onAudioSkipped => _onAudioSkippedController.stream;

  bool isShuffleEnabled = false;
  List<Audio> shuffledAudios = [];
  List<Audio> audios = [];
  int position = 0;
  LoopMode loopMode = LoopMode.off;
  FetchState fetchState = FetchState.none;
  Audio? _currentAudio;

  Audio? get currentAudio => _currentAudio;

  bool get isUrlSource => (currentAudio?.path ?? '').startsWith('http');

  set currentAudio(Audio? audio) {
    _currentAudio = audio;
    _onCurrentAudioChangedController.add(audio);
  }

  CustomAudioPlayer._internal() : super(playerId: 'GlobalAudioPlayer') {
    setReleaseMode(ReleaseMode.stop);
    onPlayerComplete.listen((_) {
      if (!isUrlSource && loopMode == LoopMode.all) {
        skip(1);
      }
    });
    onPositionChanged.listen((duration) {
      if (!isUrlSource) {
        position = duration.inSeconds;
      }
    });
  }

  shuffle() {
    List<Audio> listToShuffle = [...audios];
    for (int i = listToShuffle.length - 1; i >= 0; i--) {
      final j = Random().nextInt(i + 1);
      final temp = listToShuffle[i];
      listToShuffle[i] = listToShuffle[j];
      listToShuffle[j] = temp;
    }
    shuffledAudios = listToShuffle;
  }

  skip(int indexToNavigate) async {
    final audios = [...isShuffleEnabled ? shuffledAudios : this.audios];
    final index =
        audios.indexWhere((element) => element.id == currentAudio!.id);
    final length = audios.length;
    final newIndex = ((index + indexToNavigate) % length + length) % length;

    currentAudio = audios[newIndex];
    _onAudioSkippedController.add(currentAudio!);
    await play(DeviceFileSource(currentAudio!.path));
  }

  setLoopMode(LoopMode loopMode) {
    this.loopMode = loopMode;
    switch (loopMode) {
      case LoopMode.off:
        setReleaseMode(ReleaseMode.stop);
        break;
      case LoopMode.one:
        setReleaseMode(ReleaseMode.loop);
        break;
      case LoopMode.all:
        setReleaseMode(ReleaseMode.release);
        break;
    }
  }

  nextLoopMode() {
    final loopModeIndex = (this.loopMode.index + 1) % 3;
    final loopMode = LoopMode.values[loopModeIndex];
    setLoopMode(loopMode);
  }

  @override
  Future<void> play(Source source,
      {double? volume,
      double? balance,
      AudioContext? ctx,
      Duration? position,
      PlayerMode? mode}) async {
    try {
      fetchState = FetchState.loading;
      _onFetchDataController.add(FetchState.loading);
      await super.play(source,
          volume: volume,
          balance: balance,
          ctx: ctx,
          position: position,
          mode: mode);
      fetchState = FetchState.success;
      _onFetchDataController.add(FetchState.success);
    } catch (error) {
      fetchState = FetchState.error;
      _onFetchDataController.addError(error);
    }
  }

  tooglePlay() async {
    if (fetchState == FetchState.error) {
      await release();
      final path = currentAudio!.path;
      Source source = isUrlSource ? UrlSource(path) : DeviceFileSource(path);
      play(source);
    } else if (state == PlayerState.playing) {
      pause();
    } else {
      resume();
    }
  }

  bool toogleShuffle() {
    if (!isShuffleEnabled) {
      shuffle();
    }
    return isShuffleEnabled = !isShuffleEnabled;
  }
}
