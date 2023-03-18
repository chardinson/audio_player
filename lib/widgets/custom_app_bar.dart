import 'dart:async';

import 'package:flutter/material.dart';

class CustomAppBar extends AppBar {
  CustomAppBar(
      {super.key,
      required this.onSearch,
      this.onToggleSearch,
      this.customActions,
      this.searchBarController});
  final Function(String searchTerm) onSearch;
  final Function(bool isSearchVisible)? onToggleSearch;
  final SearchBarController? searchBarController;
  final List<Widget>? customActions;

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  TextEditingController textEditingController = TextEditingController();
  final _controller = TextEditingController();
  bool _showSearch = false;
  bool _showBackButton = false;

  void _toggleSearch() {
    final showSearch = !_showSearch;
    if (widget.onToggleSearch != null) {
      Function.apply(widget.onToggleSearch!, [showSearch]);
    }
      _controller.clear();
    setState(() {
      _showSearch = showSearch;
      _showBackButton = !_showBackButton;
    });
  }

  String get radioUrl {
    return textEditingController.text.isEmpty
        ? 'https://26423.live.streamtheworld.com/LOS40_MEXICO_SC'
        : textEditingController.text;
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => widget.onSearch(_controller.text));
    widget.searchBarController?.callback = _toggleSearch;
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: _showSearch
          ? TextFormField(
              autofocus: true,
              controller: _controller,
              decoration: InputDecoration(
                border: InputBorder.none,
                suffixIcon: IconButton(
                  onPressed: _controller.clear,
                  icon: const Icon(Icons.clear),
                ),
              ),
            )
          : const Text('RocanLovers'),
      leading: _showSearch
          ? IconButton(
              onPressed: _toggleSearch,
              icon: const Icon(Icons.arrow_back),
            )
          : null,
      actions: _showSearch
          ? null
          : [
              IconButton(
                  onPressed: _toggleSearch, icon: const Icon(Icons.search)),
              ...?widget.customActions
            ],
    );
  }
}

class SearchBarController {
  ControllerCallback? callback;

  toggleSearchBar() => callback?.call();
}
