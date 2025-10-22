import 'package:flutter/material.dart';

/// Search bar widget
class HomeSearchBar extends StatelessWidget {
  final ValueChanged<String>? onSearch;

  const HomeSearchBar({super.key, this.onSearch});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search groups...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        onChanged: onSearch,
      ),
    );
  }
}
