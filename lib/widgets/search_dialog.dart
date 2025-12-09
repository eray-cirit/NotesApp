import 'package:flutter/material.dart';

class SearchDialog extends StatefulWidget {
  final String? initialQuery;
  final String hintText;

  const SearchDialog({
    super.key,
    this.initialQuery,
    this.hintText = 'Ara...',
  });

  @override
  State<SearchDialog> createState() => _SearchDialogState();

  static Future<String?> show({
    required BuildContext context,
    String? initialQuery,
    String? hintText,
  }) async {
    return await showDialog<String>(
      context: context,
      builder: (context) => SearchDialog(
        initialQuery: initialQuery,
        hintText: hintText ?? 'Ara...',
      ),
    );
  }
}

class _SearchDialogState extends State<SearchDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(
            Icons.search,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Ara',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(
          hintText: widget.hintText,
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _controller.clear();
                    });
                  },
                )
              : null,
        ),
        onChanged: (_) => setState(() {}),
        onSubmitted: (value) {
          Navigator.pop(context, value.trim());
        },
        textCapitalization: TextCapitalization.words,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, ''),
          child: const Text('Temizle'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: const Text('Ara'),
        ),
      ],
    );
  }
}
