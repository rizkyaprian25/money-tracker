import 'package:flutter/material.dart';

/// Domain entity untuk Category — lepas dari Drift generated `Category`.
/// Mapping: `lib/database/tables/categories.dart:3-10`
class CategoryEntity {
  final int id;
  final String name;
  final String type; // income | expense
  final String color; // hex e.g. #24389C
  final String icon; // material icon name
  final DateTime createdAt;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.type,
    required this.color,
    required this.icon,
    required this.createdAt,
  });

  bool get isIncome => type == 'income';
  bool get isExpense => type == 'expense';

  Color get colorValue {
    try {
      return Color(int.parse(color.replaceAll('#', 'FF'), radix: 16));
    } catch (_) {
      return const Color(0xFF757684);
    }
  }

  CategoryEntity copyWith({
    int? id,
    String? name,
    String? type,
    String? color,
    String? icon,
    DateTime? createdAt,
  }) =>
      CategoryEntity(
        id: id ?? this.id,
        name: name ?? this.name,
        type: type ?? this.type,
        color: color ?? this.color,
        icon: icon ?? this.icon,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryEntity && other.id == id && other.name == name && other.type == type;

  @override
  int get hashCode => Object.hash(id, name, type);
}
