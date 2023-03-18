import 'package:audio_player/api.dart';
import 'package:audio_player/pages/station_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../global_enums.dart';
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
  List<Country> _countries = [];
  FetchState _fetchState = FetchState.none;

  set fetchState(value) {
    if (mounted) {
      setState(() {});
    }
    _fetchState = value;
  }

  get fetchState => _fetchState;

  get body {
    Widget body = ListView.builder(
      shrinkWrap: true,
      itemCount: _countries.length,
      itemBuilder: (context, index) {
        Country country = _countries[index];
        return Column(
          children: [
            ListTile(
              leading: CircleAvatar(
                  child: Image.asset(
                country.imageUrl!,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image),
              )),
              title: Text(country.name),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StationPage(country.isoCode),
                  )),
            ),
            _countries.length - 1 == index
                ? const SizedBox()
                : const Divider(thickness: 1, indent: 16, endIndent: 16)
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
            onPressed: fetchCountries,
          )),
        ),
      );
    }
    return body;
  }

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
        body: body);
  }

  handleSearch(String searchTerm) {
    final countries = Cache.countries
        .where((country) =>
            RegExp(searchTerm, caseSensitive: false).hasMatch(country.name))
        .toList();
    setState(() => _countries = countries);
  }

  Future<void> fetchCountries() async {
    FetchState previousFetchState = fetchState;
    try {
      fetchState = FetchState.loading;
      if (previousFetchState == FetchState.error) {
        await Future.delayed(const Duration(seconds: 1));
      }
      _countries = await Api.getCountries();
      fetchState = FetchState.success;
    } catch (e) {
      fetchState = FetchState.error;
    }
  }
}
