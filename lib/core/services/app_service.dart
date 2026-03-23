import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:smart_aalna/features/home/model/clothing_item.dart';
import 'package:smart_aalna/core/utils/app_utils.dart';

class AppService {
  final String _openRouterUrl = 'https://openrouter.ai/api/v1/chat/completions';

  Future<OutfitSuggestion?> getOutfitSuggestion(
    List<ClothingItem> clothes, {
    String query = 'What should I wear today?',
  }) async {
    if (clothes.isEmpty && query == 'What should I wear today?') return null;

    final apiKey = dotenv.env['APIKEY'];
    if (apiKey == null || apiKey.isEmpty) return null;

    final availableClothes = clothes.where((c) => !c.inLaundry).toList();

    final clothesListStr = availableClothes.isEmpty
        ? 'No clothes in wardrobe.'
        : availableClothes
              .map(
                (c) =>
                    'ID: ${c.id}, Type: ${c.type}, Category: ${c.category}, Season: ${c.season}, Occasion: ${c.occasion}, Color: #${(c.colorValue & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}',
              )
              .join('\n');

    final systemPrompt =
        '''
${AppUtils.systemPrompt}
You are a helpful AI stylist. The user may ask for suggestions on what to wear for a specific occasion.
Please recommend items they have in their wardrobe. Analyze the item colors (provided as hex codes) to ensure good color matching and coordination in your suggested outfits.
If appropriate, you can also suggest 1-2 new items they don't have yet (as a "cherry on top" suggestion) in your text message, explicitly mentioning how the new color/piece fits the styling.
Always return your response in purely JSON format:
{
  "message": "Your styling advice explaining the color synergy and outfit vibe, plus any new item suggestions to buy.",
  "items": ["id_1", "id_2"]
}

Available wardrobe items (Excluding items currently in the laundry):
$clothesListStr
''';

    try {
      final response = await http.post(
        Uri.parse(_openRouterUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
          'HTTP-Referer': 'https://smartaalna.com',
          'X-Title': 'Smart Aalna',
        },
        body: json.encode({
          'model': 'nvidia/nemotron-3-nano-30b-a3b:free',
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': query},
          ],
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final content = data['choices'][0]['message']['content']
            .toString()
            .trim();

        // Sometimes AI wraps in markdown anyway
        final cleanContent = content
            .replaceAll('```json', '')
            .replaceAll('```', '')
            .trim();
        final result = json.decode(cleanContent);

        return OutfitSuggestion(
          message: result['message'] ?? 'Here is your outfit!',
          itemIds: List<String>.from(result['items'] ?? []),
        );
      }
    } catch (e) {
      debugPrint('AI Error: $e');
    }
    return null;
  }
}

class OutfitSuggestion {
  final String message;
  final List<String> itemIds;

  OutfitSuggestion({required this.message, required this.itemIds});
}
