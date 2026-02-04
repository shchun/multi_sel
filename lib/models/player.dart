import 'package:flutter/material.dart';

class Player {
  final String id;
  final Offset position;
  final Color color;
  final DateTime joinTime;
  bool isActive;

  Player({
    required this.id,
    required this.position,
    required this.color,
    required this.joinTime,
    this.isActive = true,
  });

  Player copyWith({
    String? id,
    Offset? position,
    Color? color,
    DateTime? joinTime,
    bool? isActive,
  }) {
    return Player(
      id: id ?? this.id,
      position: position ?? this.position,
      color: color ?? this.color,
      joinTime: joinTime ?? this.joinTime,
      isActive: isActive ?? this.isActive,
    );
  }
}
