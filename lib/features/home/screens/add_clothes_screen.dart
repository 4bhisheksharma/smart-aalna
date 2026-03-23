import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_background_remover/image_background_remover.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';

import 'dart:async';
import 'dart:ui' as ui;

import 'package:smart_aalna/core/widgets/app_button.dart';
import 'package:smart_aalna/core/widgets/add_clothes_header.dart';
import 'package:smart_aalna/core/widgets/color_selector.dart';
import 'package:smart_aalna/core/widgets/image_section.dart';
import 'package:smart_aalna/core/widgets/section_title.dart';
import 'package:smart_aalna/features/home/model/clothing_item.dart';
import 'package:smart_aalna/core/storage/local_storage.dart';

class AddClothesScreen extends StatefulWidget {
  const AddClothesScreen({super.key});

  @override
  State<AddClothesScreen> createState() => _AddClothesScreenState();
}

class _AddClothesScreenState extends State<AddClothesScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _pluginErrorShown = false;

  static const List<String> _sizes = ['VS', 'S', 'M', 'L', 'XL', 'XXL'];
  static const List<String> _occasions = [
    'Casual',
    'Formal',
    'Party',
    'Sports',
    'Other',
  ];
  static const List<String> _seasons = ['Summer', 'Winter', 'All-season'];
  static const List<String> _patterns = [
    'Plain',
    'Striped',
    'Checked',
    'Printed',
  ];
  static const Map<String, List<String>> _categoryTypes = {
    'Top': ['Shirt', 'T-shirt', 'Hoodie'],
    'Bottom': ['Jeans', 'Pants'],
    'Outerwear': ['Jacket', 'Coat'],
    'Footwear': ['Shoes'],
  };

  Uint8List? _originalImageBytes;
  Uint8List? _processedImageBytes;
  bool _isProcessingImage = false;

  String _selectedCategory = 'Top';
  String _selectedType = 'Shirt';
  Color _selectedColor = const Color(0xFF2C2C2C);
  String _selectedSize = 'M';
  String _selectedOccasion = 'Casual';
  String _selectedSeason = 'All-season';
  String _selectedPattern = 'Plain';
  bool _isFavorite = false;

  final TextEditingController _otherOccasionController =
      TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    unawaited(_initializeBackgroundRemover());
    unawaited(_restoreLostImageData());
  }

  @override
  void dispose() {
    _otherOccasionController.dispose();
    _notesController.dispose();
    unawaited(BackgroundRemover.instance.dispose());
    super.dispose();
  }

  Future<void> _initializeBackgroundRemover() async {
    try {
      await BackgroundRemover.instance.initializeOrt();
    } on MissingPluginException {
      _showPluginRestartHint();
    } on PlatformException {
      _showPluginRestartHint();
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Background remover initialization failed.'),
        ),
      );
    }
  }

  Future<void> _restoreLostImageData() async {
    try {
      final response = await _picker.retrieveLostData();
      if (response.isEmpty ||
          response.files == null ||
          response.files!.isEmpty) {
        return;
      }
      await _processPickedFile(response.files!.first);
    } on MissingPluginException {
      _showPluginRestartHint();
    } on PlatformException {
      _showPluginRestartHint();
    }
  }

  Future<void> _showImageSourcePicker() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Upload from device'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Take photo'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final file = await _picker.pickImage(source: source, imageQuality: 92);
      if (file == null) {
        return;
      }
      await _processPickedFile(file);
    } on MissingPluginException {
      _showPluginRestartHint();
    } on PlatformException {
      _showPluginRestartHint();
    }
  }

  void _showPluginRestartHint() {
    if (!mounted || _pluginErrorShown) {
      return;
    }

    _pluginErrorShown = true;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Native plugin channel is not ready. Please stop the app and run again.',
        ),
      ),
    );
  }

  Future<void> _processPickedFile(XFile file) async {
    setState(() {
      _isProcessingImage = true;
    });

    try {
      final bytes = await file.readAsBytes();
      final removedBgImage = await BackgroundRemover.instance.removeBg(bytes);
      final pngBytes = await _uiImageToPngBytes(removedBgImage);
      removedBgImage.dispose();

      if (!mounted) {
        return;
      }

      setState(() {
        _originalImageBytes = bytes;
        _processedImageBytes = pngBytes ?? bytes;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not process selected image.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingImage = false;
        });
      }
    }
  }

  Future<Uint8List?> _uiImageToPngBytes(ui.Image image) async {
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  Future<void> _openColorPicker() async {
    var tempColor = _selectedColor;
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pick color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: tempColor,
              onColorChanged: (color) {
                tempColor = color;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                setState(() {
                  _selectedColor = tempColor;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickColorFromImage() async {
    final bytes = _originalImageBytes ?? _processedImageBytes;
    if (bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upload image first to pick color.')),
      );
      return;
    }

    try {
      final image = await _decodeImageFromBytes(bytes);
      final byteData = await image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );
      if (byteData == null) {
        return;
      }

      final centerX = image.width ~/ 2;
      final centerY = image.height ~/ 2;
      final index = (centerY * image.width + centerX) * 4;
      final data = byteData.buffer.asUint8List();
      if (index + 3 >= data.length) {
        return;
      }

      setState(() {
        _selectedColor = Color.fromARGB(
          data[index + 3],
          data[index],
          data[index + 1],
          data[index + 2],
        );
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not extract color from image.')),
      );
    }
  }

  Future<ui.Image> _decodeImageFromBytes(Uint8List bytes) {
    final completer = Completer<ui.Image>();
    ui.decodeImageFromList(bytes, completer.complete);
    return completer.future;
  }

  void _onCategoryChanged(String? category) {
    if (category == null) {
      return;
    }
    final types = _categoryTypes[category]!;
    setState(() {
      _selectedCategory = category;
      _selectedType = types.first;
    });
  }

  Future<void> _saveCloth() async {
    final occasion = _selectedOccasion == 'Other'
        ? _otherOccasionController.text.trim()
        : _selectedOccasion;

    if (_processedImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload an image first.')),
      );
      return;
    }

    if (occasion.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter occasion.')));
      return;
    }

    final notes = _notesController.text.trim();

    final item = ClothingItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      category: _selectedCategory,
      type: _selectedType,
      colorValue: _selectedColor.toARGB32(),
      size: _selectedSize,
      occasion: occasion,
      season: _selectedSeason,
      pattern: _selectedPattern,
      isFavorite: _isFavorite,
      notes: notes,
      imageData: _processedImageBytes!,
    );

    await LocalStorage().saveCloth(item);

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Clothing item saved.')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 380;

            return Padding(
              padding: EdgeInsets.fromLTRB(
                isCompact ? 14 : 20,
                isCompact ? 12 : 16,
                isCompact ? 14 : 20,
                20,
              ),
              child: Column(
                children: [
                  const AddClothesHeader(title: 'Add Clothes in Smart आल्ना'),
                  SizedBox(height: isCompact ? 16 : 24),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AddClothesImageSection(
                            imageBytes: _processedImageBytes,
                            isProcessing: _isProcessingImage,
                            onUploadTap: _showImageSourcePicker,
                          ),
                          const SizedBox(height: 16),
                          const AddClothesSectionTitle(title: 'Category'),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _selectedCategory,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            items: _categoryTypes.keys
                                .map(
                                  (category) => DropdownMenuItem<String>(
                                    value: category,
                                    child: Text(category),
                                  ),
                                )
                                .toList(),
                            onChanged: _onCategoryChanged,
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: _selectedType,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Type',
                            ),
                            items: _categoryTypes[_selectedCategory]!
                                .map(
                                  (type) => DropdownMenuItem<String>(
                                    value: type,
                                    child: Text(type),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value == null) {
                                return;
                              }
                              setState(() {
                                _selectedType = value;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          const AddClothesSectionTitle(title: 'Color'),
                          const SizedBox(height: 8),
                          AddClothesColorSelector(
                            selectedColor: _selectedColor,
                            onPickColor: _openColorPicker,
                            onPickFromImage: _pickColorFromImage,
                          ),
                          const SizedBox(height: 16),
                          const AddClothesSectionTitle(title: 'Size'),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _selectedSize,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            items: _sizes
                                .map(
                                  (size) => DropdownMenuItem<String>(
                                    value: size,
                                    child: Text(size),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value == null) {
                                return;
                              }
                              setState(() {
                                _selectedSize = value;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          const AddClothesSectionTitle(title: 'Occasion'),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _selectedOccasion,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            items: _occasions
                                .map(
                                  (occasion) => DropdownMenuItem<String>(
                                    value: occasion,
                                    child: Text(occasion),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value == null) {
                                return;
                              }
                              setState(() {
                                _selectedOccasion = value;
                              });
                            },
                          ),
                          if (_selectedOccasion == 'Other') ...[
                            const SizedBox(height: 12),
                            TextField(
                              controller: _otherOccasionController,
                              decoration: const InputDecoration(
                                labelText: 'Custom occasion',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          const AddClothesSectionTitle(title: 'Season'),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _selectedSeason,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            items: _seasons
                                .map(
                                  (season) => DropdownMenuItem<String>(
                                    value: season,
                                    child: Text(season),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value == null) {
                                return;
                              }
                              setState(() {
                                _selectedSeason = value;
                              });
                            },
                          ),
                          const SizedBox(height: 8),
                          SwitchListTile(
                            value: _isFavorite,
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Favorite ❤️'),
                            onChanged: (value) {
                              setState(() {
                                _isFavorite = value;
                              });
                            },
                          ),
                          ExpansionTile(
                            tilePadding: EdgeInsets.zero,
                            title: const Text('Advanced'),
                            childrenPadding: const EdgeInsets.only(bottom: 8),
                            children: [
                              DropdownButtonFormField<String>(
                                value: _selectedPattern,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Pattern',
                                ),
                                items: _patterns
                                    .map(
                                      (pattern) => DropdownMenuItem<String>(
                                        value: pattern,
                                        child: Text(pattern),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  if (value == null) {
                                    return;
                                  }
                                  setState(() {
                                    _selectedPattern = value;
                                  });
                                },
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _notesController,
                                maxLines: 2,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Notes (optional)',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          AppButton(label: 'Save', onPressed: _saveCloth),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
