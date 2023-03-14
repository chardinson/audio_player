import 'dart:async';

import 'package:audio_player/api.dart';
import 'package:audio_player/pages/station_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
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

enum FetchState { none, loading, success, error }

class _CountryPageState extends State<CountryPage> {
  List<Country> _countries = [];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult>
      _onConnectivityChangedSubscription;
  ScaffoldFeatureController? _scaffoldFeatureController;

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
                  child: CachedNetworkImage(
                imageUrl: country.imageUrl!,
                placeholder: (context, url) =>
                    SpinKitDoubleBounce(color: Theme.of(context).primaryColor),
                errorWidget: (context, url, error) => const Icon(Icons.error),
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
      ));
    } else if (_fetchState == FetchState.error) {
      body = const Center(child: Icon(Icons.error));
    }
    return body;
  }

  @override
  void initState() {
    super.initState();
    fetchCountries();

    _connectivity.checkConnectivity().then(resolveConnectivityStatus);

    _onConnectivityChangedSubscription =
        _connectivity.onConnectivityChanged.listen(resolveConnectivityStatus);
  }

  void resolveConnectivityStatus(connectivityResult) {
    if (connectivityResult == ConnectivityResult.wifi ||
        connectivityResult == ConnectivityResult.mobile) {
      _scaffoldFeatureController?.close();
      if (_fetchState == FetchState.error) {
        fetchCountries();
      }
    } else if (connectivityResult == ConnectivityResult.none) {
      _scaffoldFeatureController =
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Sin conexión', textAlign: TextAlign.center),
        duration: Duration(days: 1),
      ));
    }
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
      body: body,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _onConnectivityChangedSubscription.cancel();
  }

  handleSearch(String searchTerm) {
    final countries = Cache.countries
        .where((country) =>
            RegExp(searchTerm, caseSensitive: false).hasMatch(country.name))
        .toList();
    setState(() => _countries = countries);
  }

  void fetchCountries() async {
    try {
      fetchState = FetchState.loading;
      _countries = await Api.getCountries();
      fetchState = FetchState.success;
    } catch (e) {
      fetchState = FetchState.error;
    }
  }
}
