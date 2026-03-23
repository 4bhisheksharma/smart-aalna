import 'dart:convert';

class ClothingItem {
  final String id;
  final String category;
  final String type;
  final int colorValue;
  final String size;
  final String occasion;
  final String season;
  final String pattern;
  final bool isFavorite;
  final bool inLaundry;
  final String notes;
  final String imagePath;

  ClothingItem({
    required this.id,
    required this.category,
    required this.type,
    required this.colorValue,
    required this.size,
    required this.occasion,
    required this.season,
    required this.pattern,
    required this.isFavorite,
    this.inLaundry = false,
    required this.notes,
    required this.imagePath,
  });

  ClothingItem copyWith({
    String? id,
    String? category,
    String? type,
    int? colorValue,
    String? size,
    String? occasion,
    String? season,
    String? pattern,
    bool? isFavorite,
    bool? inLaundry,
    String? notes,
    String? imagePath,
  }) {
    return ClothingItem(
      id: id ?? this.id,
      category: category ?? this.category,
      type: type ?? this.type,
      colorValue: colorValue ?? this.colorValue,
      size: size ?? this.size,
      occasion: occasion ?? this.occasion,
      season: season ?? this.season,
      pattern: pattern ?? this.pattern,
      isFavorite: isFavorite ?? this.isFavorite,
      inLaundry: inLaundry ?? this.inLaundry,
      notes: notes ?? this.notes,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'type': type,
      'colorValue': colorValue,
      'size': size,
      'occasion': occasion,
      'season': season,
      'pattern': pattern,
      'isFavorite': isFavorite,
      'inLaundry': inLaundry,
      'notes': notes,
      'imagePath': imagePath,
    };
  }

  factory ClothingItem.fromMap(Map<String, dynamic> map) {
    return ClothingItem(
      id: map['id'],
      category: map['category'],
      type: map['type'],
      colorValue: map['colorValue'],
      size: map['size'],
      occasion: map['occasion'],
      season: map['season'],
      pattern: map['pattern'],
      isFavorite: map['isFavorite'] ?? false,
      inLaundry: map['inLaundry'] ?? false,
      notes: map['notes'] ?? '',
      imagePath: map['imagePath'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory ClothingItem.fromJson(String source) =>
      ClothingItem.fromMap(json.decode(source));
}
