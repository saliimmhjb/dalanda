import 'package:flutter/material.dart';

class Meeting {
  final int? id;
  final String title, type, time, status;
  final Color color;

  Meeting({
    this.id,
    required this.title,
    required this.type,
    required this.time,
    required this.color,
    required this.status,
  });

  factory Meeting.fromJson(Map<String, dynamic> json) {
    // Default color logic
    Color flutterColor = const Color(0xFFB84CFF);
    try {
      if (json['color_hex'] != null && json['color_hex'].toString().isNotEmpty) {
        String hexColor = json['color_hex'].toString().replaceAll('#', '');
        if (hexColor.length == 6) {
          flutterColor = Color(int.parse("FF$hexColor", radix: 16));
        }
      }
    } catch (e) {
      print("Color parsing error: $e");
    }

    return Meeting(
      id: json['id'],
      title: json['title'] ?? 'No Title',
      type: json['type'] ?? 'General',
      time: json['time'] ?? 'TBD',
      status: json['status'] ?? 'Approved',
      color: flutterColor,
    );
  }
}