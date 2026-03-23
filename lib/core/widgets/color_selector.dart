import 'package:flutter/material.dart';

class AddClothesColorSelector extends StatelessWidget {
  final Color selectedColor;
  final VoidCallback onPickColor;
  final VoidCallback onPickFromImage;

  const AddClothesColorSelector({
    super.key,
    required this.selectedColor,
    required this.onPickColor,
    required this.onPickFromImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: selectedColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton(
                  onPressed: onPickColor,
                  child: const Text('Color picker'),
                ),
                OutlinedButton(
                  onPressed: onPickFromImage,
                  child: const Text('Pick from image'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
