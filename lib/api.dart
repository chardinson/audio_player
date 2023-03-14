import 'dart:convert';

import 'package:http/http.dart';

import 'models/cache.dart';
import 'models/country.dart';
import 'models/station.dart';

class Api {
  static final _client = Client();

  static Future<List<Country>> getCountries() async {
    late List<Country> countries = Cache.countries;
    if (Cache.countries.isEmpty) {
      Uri uri = Uri.https('de1.api.radio-browser.info', 'json/countries');
      final response = await _client.get(uri);

      countries = jsonDecode(response.body).map<Country>((e) {
        Country country = Country.fromJson(e);
        country.imageUrl = 'https://countryflagsapi.com/png/${country.isoCode}';
        return country;
      }).toList();
      countries.sort();
      // Cache.countries = countries;
    }
    return [...countries];
  }

  static Future<List<Station>> getStations(String countryIsoCode) async {
    final isoCode = countryIsoCode;
    List<Station> stations = [];
    if (Cache.stations.containsKey(isoCode)) {
      stations = Cache.stations[isoCode]!;
    } else {
      Uri uri = Uri.https('de1.api.radio-browser.info',
          'json/stations/bycountrycodeexact/$isoCode');
      final response = await _client.get(uri);

      stations = jsonDecode(response.body)
          .map<Station>((e) => Station.fromJson(e))
          .toList();
      stations.sort();
      Cache.stations[isoCode] = stations;
    }
    return [...stations];
  }
}
