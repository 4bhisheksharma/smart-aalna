import 'dart:convert';
import 'dart:typed_data';

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
  final String notes;
  final Uint8List imageData;

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
    required this.notes,
    required this.imageData,
  });

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
      'notes': notes,
      'imageData': base64Encode(imageData),
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
      notes: map['notes'] ?? '',
      imageData: base64Decode(map['imageData']),
    );
  }

  String toJson() => json.encode(toMap());

  factory ClothingItem.fromJson(String source) =>
      ClothingItem.fromMap(json.decode(source));
}
