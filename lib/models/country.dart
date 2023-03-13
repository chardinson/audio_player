class Country implements Comparable<Country> {
  final String name;
  final String isoCode;
  final int stationCount;
  String? imageUrl;

  Country(this.name, this.isoCode, this.stationCount, this.imageUrl);

  Country.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        isoCode = json['iso_3166_1'],
        stationCount = json['stationcount'];

  @override
  int compareTo(Country country) {
    return name.compareTo(country.name);
  }
}
