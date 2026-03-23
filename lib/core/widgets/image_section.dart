import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:smart_aalna/core/widgets/app_button.dart';

class AddClothesImageSection extends StatelessWidget {
  final Uint8List? imageBytes;
  final bool isProcessing;
  final VoidCallback onUploadTap;
  final bool hasOriginalAvailable;
  final bool showingOriginal;
  final VoidCallback? onToggleBg;

  const AddClothesImageSection({
    super.key,
    required this.imageBytes,
    required this.isProcessing,
    required this.onUploadTap,
    this.hasOriginalAvailable = false,
    this.showingOriginal = false,
    this.onToggleBg,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imageBytes != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF3F3F3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE1E1E1)),
              ),
              child: isProcessing
                  ? const Center(child: CircularProgressIndicator())
                  : hasImage
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(imageBytes!, fit: BoxFit.cover),
                    )
                  : const Center(child: Text('Upload image')),
            ),
          ),
          const SizedBox(height: 12),
          AppButton(
            label: hasImage ? 'Replace Image' : 'Upload Image',
            onPressed: onUploadTap,
          ),
          if (hasOriginalAvailable) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onToggleBg,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Theme.of(context).primaryColor),
                ),
                child: Text(
                  showingOriginal
                      ? 'Remove Background'
                      : 'Undo Background Removal',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
