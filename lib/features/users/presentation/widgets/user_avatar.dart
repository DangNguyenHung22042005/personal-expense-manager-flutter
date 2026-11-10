import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    required this.name,
    required this.imageValue,
    this.radius = 26,
    super.key,
  });

  final String name;
  final String imageValue;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final image = _imageProvider(imageValue);
    return CircleAvatar(
      radius: radius,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      foregroundImage: image,
      child: Text(
        _initials(name),
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w800,
          fontSize: radius * .62,
        ),
      ),
    );
  }

  ImageProvider<Object>? _imageProvider(String value) {
    if (value.isEmpty) return null;
    if (value.startsWith('data:image/')) {
      final commaIndex = value.indexOf(',');
      if (commaIndex == -1) return null;
      try {
        final Uint8List bytes = base64Decode(value.substring(commaIndex + 1));
        return MemoryImage(bytes);
      } on FormatException {
        return null;
      }
    }
    final uri = Uri.tryParse(value);
    if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
      return NetworkImage(value);
    }
    return null;
  }

  String _initials(String value) {
    final words = value.trim().split(RegExp(r'\s+'));
    if (words.isEmpty || words.first.isEmpty) return '?';
    if (words.length == 1) return words.first[0].toUpperCase();
    return '${words.first[0]}${words.last[0]}'.toUpperCase();
  }
}
