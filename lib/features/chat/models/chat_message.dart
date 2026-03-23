
import 'package:smart_aalna/features/home/model/clothing_item.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final List<ClothingItem>? suggestedItems;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.suggestedItems,
  });
}

