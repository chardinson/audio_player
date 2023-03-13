import 'package:audio_player/models/song.dart';
import 'package:flutter/material.dart';

class UrlInput extends StatefulWidget {
  const UrlInput({super.key});

  @override
  State<UrlInput> createState() => _UrlInputState();
}

class _UrlInputState extends State<UrlInput> {
  final _form = GlobalKey<FormState>();
  final defaultSong = Song(
      name: 'Los 40',
      path: 'https://26423.live.streamtheworld.com/LOS40_MEXICO_SC');
  TextEditingController nameController = TextEditingController();
  TextEditingController urlController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ingrese su URL', textAlign: TextAlign.center),
      content: SingleChildScrollView(
        child: Form(
          key: _form,
          child: Column(
            children: [
              TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Nombre (opcional)',
                    hintText: defaultSong.name,
                  )),
              TextFormField(
                autofocus: true,
                controller: urlController,
                decoration: InputDecoration(
                  labelText: 'URL',
                  hintText: defaultSong.path,
                ),
                validator: (value) {
                  if ((value != null && value.isNotEmpty) &&
                      Uri.tryParse(value)!.host.isEmpty) {
                    return 'Ingrese una URL valida';
                  }
                  return null;
                },
              )
            ],
          ),
        ),
      ),
      actions: [
        OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar')),
        FilledButton(
            onPressed: () {
              final songName = nameController.text.isEmpty
                  ? 'Cancion Personalizada'
                  : nameController.text;
              final song = urlController.text.isEmpty
                  ? defaultSong
                  : Song(name: songName, path: urlController.text);
              if (_form.currentState!.validate()) {
                Navigator.pop(context, song);
              }
            },
            child: const Text('Reproducir')),
      ],
    );
  }
}
