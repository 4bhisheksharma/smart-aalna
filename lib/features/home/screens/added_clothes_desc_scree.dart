import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_background_remover/image_background_remover.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:ui' as ui;
import 'package:smart_aalna/features/home/model/clothing_item.dart';
import 'package:smart_aalna/core/storage/local_storage.dart';
import 'package:smart_aalna/core/widgets/app_button.dart';

class AddedClothesDescScree extends StatefulWidget {
  final ClothingItem item;

  const AddedClothesDescScree({super.key, required this.item});

  @override
  State<AddedClothesDescScree> createState() => _AddedClothesDescScreeState();
}

class _AddedClothesDescScreeState extends State<AddedClothesDescScree> {
  late String _selectedCategory;
  late String _selectedType;
  late String _selectedSize;
  late String _selectedOccasion;
  late String _selectedSeason;
  late String _selectedPattern;
  late bool _isFavorite;
  late TextEditingController _notesController;

  final ImagePicker _picker = ImagePicker();
  Uint8List? _newImageBytes;
  Uint8List? _originalImageBytes;
  Uint8List? _removedBgImageBytes;
  bool _showingOriginal = false;
  bool _isProcessingImage = false;

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

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.item.category;
    _selectedType = widget.item.type;
    _selectedSize = widget.item.size;
    _selectedOccasion = widget.item.occasion;
    _selectedSeason = widget.item.season;
    _selectedPattern = widget.item.pattern;
    _isFavorite = widget.item.isFavorite;
    _notesController = TextEditingController(text: widget.item.notes);

    if (!_occasions.contains(_selectedOccasion)) {
      _selectedOccasion = 'Other';
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _onCategoryChanged(String? category) {
    if (category == null) return;
    final types = _categoryTypes[category]!;
    setState(() {
      _selectedCategory = category;
      _selectedType = types.first;
    });
  }

  Future<void> _updateCloth() async {
    String finalImagePath = widget.item.imagePath;

    if (_newImageBytes != null) {
      final directory = await getApplicationDocumentsDirectory();
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final imagePath = '${directory.path}/cloth_$id.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(_newImageBytes!);
      finalImagePath = imagePath;
    }

    final newItem = ClothingItem(
      id: widget.item.id,
      category: _selectedCategory,
      type: _selectedType,
      colorValue: widget.item.colorValue,
      size: _selectedSize,
      occasion: _selectedOccasion,
      season: _selectedSeason,
      pattern: _selectedPattern,
      isFavorite: _isFavorite,
      notes: _notesController.text.trim(),
      imagePath: finalImagePath,
    );

    // To update, delete old and add new
    await LocalStorage().deleteCloth(widget.item.id);
    await LocalStorage().saveCloth(newItem);

    // Delete old image only if we saved a new one
    if (_newImageBytes != null && widget.item.imagePath != finalImagePath) {
      try {
        final oldFile = File(widget.item.imagePath);
        if (await oldFile.exists()) {
          await oldFile.delete();
        }
      } catch (e) {
        debugPrint('Error deleting old image file: $e');
      }
    }

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Clothing updated.')));
    Navigator.of(context).pop();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final file = await _picker.pickImage(source: source, imageQuality: 92);
      if (file == null) return;

      setState(() => _isProcessingImage = true);

      final bytes = await file.readAsBytes();
      final removedBgImage = await BackgroundRemover.instance.removeBg(bytes);
      final byteData = await removedBgImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
      final pngBytes = byteData?.buffer.asUint8List();
      removedBgImage.dispose();

      if (!mounted) return;

      setState(() {
        _originalImageBytes = bytes;
        _removedBgImageBytes = pngBytes ?? bytes;
        _newImageBytes = _removedBgImageBytes;
        _showingOriginal = false;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not process selected image.')),
      );
    } finally {
      if (mounted) setState(() => _isProcessingImage = false);
    }
  }

  Future<void> _showImageSourcePicker() async {
    await showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a picture'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _viewFullImage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: InteractiveViewer(
              child: _newImageBytes != null
                  ? Image.memory(_newImageBytes!)
                  : Image.file(File(widget.item.imagePath)),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        title: const Text(
          'Edit Clothing',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_isProcessingImage)
              const SizedBox(
                height: 250,
                child: Center(child: CircularProgressIndicator()),
              )
            else
              GestureDetector(
                onTap: _viewFullImage,
                child: Stack(
                  children: [
                    Container(
                      height: 250,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Color(
                          widget.item.colorValue,
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _newImageBytes != null
                          ? Image.memory(_newImageBytes!, fit: BoxFit.contain)
                          : Image.file(
                              File(widget.item.imagePath),
                              fit: BoxFit.contain,
                            ),
                    ),
                    Positioned(
                      right: 8,
                      bottom: 8,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.fullscreen,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _showImageSourcePicker,
                    icon: const Icon(Icons.image),
                    label: const Text('Change Image'),
                  ),
                ),
                if (_originalImageBytes != null &&
                    _removedBgImageBytes != null) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Theme.of(context).primaryColor),
                      ),
                      onPressed: () {
                        setState(() {
                          _showingOriginal = !_showingOriginal;
                          _newImageBytes = _showingOriginal
                              ? _originalImageBytes
                              : _removedBgImageBytes;
                        });
                      },
                      child: Text(
                        _showingOriginal ? 'Remove BG' : 'Undo BG Removal',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 24),
            _buildDropdown(
              'Category',
              _selectedCategory,
              _categoryTypes.keys.toList(),
              _onCategoryChanged,
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              'Type',
              _selectedType,
              _categoryTypes[_selectedCategory]!,
              (v) => setState(() => _selectedType = v!),
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              'Size',
              _selectedSize,
              _sizes,
              (v) => setState(() => _selectedSize = v!),
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              'Occasion',
              _selectedOccasion,
              _occasions,
              (v) => setState(() => _selectedOccasion = v!),
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              'Season',
              _selectedSeason,
              _seasons,
              (v) => setState(() => _selectedSeason = v!),
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              'Pattern',
              _selectedPattern,
              _patterns,
              (v) => setState(() => _selectedPattern = v!),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text(
                'Favorite',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              value: _isFavorite,
              onChanged: (val) => setState(() => _isFavorite = val),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            AppButton(label: 'Save Changes', onPressed: _updateCloth),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
      ),
      value: value,
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
    );
  }
}
