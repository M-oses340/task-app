import 'dart:convert';
import 'dart:ui';

import 'package:frontend/core/constants/utils.dart';

class TaskModel {
  final String id;
  final String uid;
  final String title;
  final Color color;
  final String description;
  final DateTime createdAt; // Stored as UTC
  final DateTime updatedAt; // Stored as UTC
  final DateTime dueAt;     // Stored as UTC
  final int isSynced;

  TaskModel({
    required this.id,
    required this.uid,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.dueAt,
    required this.color,
    required this.isSynced,
  });

  TaskModel copyWith({
    String? id,
    String? uid,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? dueAt,
    Color? color,
    int? isSynced,
  }) {
    return TaskModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dueAt: dueAt ?? this.dueAt,
      color: color ?? this.color,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  // Always send timestamps as UTC with 'Z'
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'uid': uid,
      'title': title,
      'description': description,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'updatedAt': updatedAt.toUtc().toIso8601String(),
      'dueAt': dueAt.toUtc().toIso8601String(),
      'hexColor': rgbToHex(color),
      'isSynced': isSynced,
    };
  }

  // Helper: ensure string is parsed as UTC
  static DateTime _parseUtc(String value) {
    if (value.isEmpty) return DateTime.now().toUtc();

    // If backend forgot to append Z, force UTC interpretation
    if (!value.endsWith('Z') && !value.toUpperCase().contains('+')) {
      return DateTime.parse("${value}Z").toUtc();
    }

    return DateTime.parse(value).toUtc();
  }

  // Always keep internal values in UTC
  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] ?? '',
      uid: map['uid'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      createdAt: _parseUtc(map['createdAt']),
      updatedAt: _parseUtc(map['updatedAt']),
      dueAt: _parseUtc(map['dueAt']),
      color: hexToRgb(map['hexColor']),
      isSynced: map['isSynced'] ?? 1,
    );
  }

  String toJson() => json.encode(toMap());

  factory TaskModel.fromJson(String source) =>
      TaskModel.fromMap(json.decode(source));

  // UI Helpers: Convert UTC → Local for display
  DateTime get localCreatedAt => createdAt.toLocal();
  DateTime get localUpdatedAt => updatedAt.toLocal();
  DateTime get localDueAt => dueAt.toLocal();

  @override
  String toString() {
    return 'TaskModel(id: $id, uid: $uid, title: $title, description: $description, createdAt: $createdAt, updatedAt: $updatedAt, dueAt: $dueAt, color: $color, isSynced: $isSynced)';
  }

  @override
  bool operator ==(covariant TaskModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.uid == uid &&
        other.title == title &&
        other.description == description &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.dueAt == dueAt &&
        other.color == color &&
        other.isSynced == isSynced;
  }

  @override
  int get hashCode {
    return id.hashCode ^
    uid.hashCode ^
    title.hashCode ^
    description.hashCode ^
    createdAt.hashCode ^
    updatedAt.hashCode ^
    dueAt.hashCode ^
    color.hashCode ^
    isSynced.hashCode;
  }
}
