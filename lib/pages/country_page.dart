import 'package:audio_player/api.dart';
import 'package:audio_player/pages/station_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../models/cache.dart';
import '../models/country.dart';
import '../utils.dart';
import '../widgets/custom_app_bar.dart';
import 'song_page.dart';

class CountryPage extends StatefulWidget {
  const CountryPage({super.key});

  @override
  State<CountryPage> createState() => _CountryPageState();
}

class _CountryPageState extends State<CountryPage> {
  List<Country> countries = [];
  bool isFetchingData = true;
  bool errorFetchingCountries = false;

  @override
  void initState() {
    super.initState();
    fetchCountries();
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
          IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SongPage(),
                  ));
            },
            icon: const Icon(Icons.library_music),
            tooltip: 'Pick Music',
          ),
        ],
      ),
      body: isFetchingData
          ? Center(
              child: SpinKitSpinningLines(
              color: Theme.of(context).primaryColor,
              lineWidth: 6,
              size: 180,
            ))
          : ListView.builder(
              shrinkWrap: true,
              itemCount: countries.length,
              itemBuilder: (context, index) {
                Country country = countries[index];
                return Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                          child: CachedNetworkImage(
                        imageUrl: country.imageUrl!,
                        placeholder: (context, url) => SpinKitDoubleBounce(
                            color: Theme.of(context).primaryColor),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      )),
                      title: Text(country.name),
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StationPage(country.isoCode),
                          )),
                    ),
                    countries.length - 1 == index
                        ? const SizedBox()
                        : const Divider(thickness: 1, indent: 16, endIndent: 16)
                  ],
                );
              },
            ),
    );
  }

  handleSearch(String searchTerm) {
    final countries = Cache.countries
        .where((country) =>
            RegExp(searchTerm, caseSensitive: false).hasMatch(country.name))
        .toList();
    setState(() => this.countries = countries);
  }

  void fetchCountries() async {
    try {
      countries = await Api.getCountries();
    } catch (e) {
      errorFetchingCountries = true;
    } finally {
      if (mounted) {
        setState(() => isFetchingData = false);
      }
    }
  }
}
