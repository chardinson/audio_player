import 'dart:convert';

import 'package:http/http.dart';

import 'cache.dart';
import '../models/country.dart';
import '../models/station.dart';

class Api {
  static final _client = Client();
  static const _radioBrowserDomain = 'de1.api.radio-browser.info';

  static Future<List<Country>> getCountries([bool reload = false]) async {
    late List<Country> countries = Cache.countries;
    if (reload || Cache.countries.isEmpty) {
      Uri uri = Uri.https(_radioBrowserDomain, 'json/countries');
      final response = await _client.get(uri);

      countries = jsonDecode(response.body).map<Country>((e) {
        Country country = Country.fromJson(e);
        country.imageUrl =
            'assets/images/country_flags/size_56x42/${country.isoCode.toLowerCase()}.png';
        return country;
      }).toList();
      countries.sort();
      Cache.countries = countries;
    }
    return [...countries];
  }

  static Future<List<Station>> getStations(String countryIsoCode,
      [bool reload = false]) async {
    final isoCode = countryIsoCode;
    List<Station> stations = [];
    if (!reload && Cache.stations.containsKey(isoCode)) {
      stations = Cache.stations[isoCode]!;
    } else {
      Uri uri = Uri.https(
          _radioBrowserDomain, 'json/stations/bycountrycodeexact/$isoCode');
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
