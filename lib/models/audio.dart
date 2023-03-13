class Audio {
  String? id;
  String name;
  String path;
  int? duration;
  String? thumbnail;
  String? homePage;

  Audio(
      {this.id,
      this.name = '',
      required this.path,
      this.duration,
      this.thumbnail,
      this.homePage});
}
