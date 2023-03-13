import 'package:audio_player/models/audio.dart';

class Station extends Audio implements Comparable<Station> {
  String countryCode;
  String state;

  Station(
      {required super.path, required this.countryCode, required this.state});

  Station.fromJson(Map<String, dynamic> json)
      : countryCode = json['countrycode'],
        state = json['state'],
        super(
            id: json['stationuuid'],
            name: json['name'],
            path: json['url'],
            homePage: json['homepage'],
            thumbnail: json['favicon']);

  @override
  int compareTo(Station station) {
    return station.name.compareTo(station.name);
  }
}
