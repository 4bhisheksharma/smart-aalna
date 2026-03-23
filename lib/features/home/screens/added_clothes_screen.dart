import 'dart:io';
import 'package:flutter/material.dart';
import 'package:smart_aalna/features/home/model/clothing_item.dart';
import 'package:smart_aalna/core/storage/local_storage.dart';
import 'package:smart_aalna/core/widgets/shimmer_skeleton.dart';

class AddedClothesScreen extends StatefulWidget {
  const AddedClothesScreen({super.key});

  @override
  State<AddedClothesScreen> createState() => _AddedClothesScreenState();
}

class _AddedClothesScreenState extends State<AddedClothesScreen> {
  final _localStorage = LocalStorage();
  List<ClothingItem> _clothes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClothes();
    LocalStorage.clothesUpdateNotifier.addListener(_loadClothes);
  }

  @override
  void dispose() {
    LocalStorage.clothesUpdateNotifier.removeListener(_loadClothes);
    super.dispose();
  }

  Future<void> _loadClothes() async {
    final clothes = await _localStorage.getClothes();
    if (mounted) {
      setState(() {
        _clothes = clothes;
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteCloth(ClothingItem item) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Clothing'),
          content: const Text('Are you sure you want to remove this item?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(iconColor: Colors.red),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await _localStorage.deleteCloth(item.id);
      try {
        final file = File(item.imagePath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        debugPrint('Error deleting image file: $e');
      }
      _loadClothes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        title: const Text(
          'Added Clothes in आल्ना',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: _isLoading
          ? GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemCount: 6,
              itemBuilder: (context, index) {
                return const ShimmerSkeleton(
                  width: double.infinity,
                  height: double.infinity,
                  borderRadius: 24,
                );
              },
            )
          : _clothes.isEmpty
          ? const Center(child: Text('No clothes added yet.'))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemCount: _clothes.length,
              itemBuilder: (context, index) {
                final item = _clothes[index];
                return _ClothingCard(
                  item: item,
                  onDelete: () => _deleteCloth(item),
                  onToggleLaundry: () async {
                    final updatedItem = item.copyWith(
                      inLaundry: !item.inLaundry,
                    );
                    await _localStorage.updateCloth(updatedItem);
                    _loadClothes();
                  },
                  onTap: () {
                    Navigator.of(context)
                        .pushNamed('/added-clothes-desc', arguments: item)
                        .then((_) {
                          _loadClothes(); // Refresh items if they were updated
                        });
                  },
                );
              },
            ),
    );
  }
}

class _ClothingCard extends StatelessWidget {
  final ClothingItem item;
  final VoidCallback onDelete;
  final VoidCallback onTap;
  final VoidCallback onToggleLaundry;

  const _ClothingCard({
    required this.item,
    required this.onDelete,
    required this.onTap,
    required this.onToggleLaundry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            offset: Offset(0, 8),
            blurRadius: 16,
            spreadRadius: -4,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onDelete,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: Color(item.colorValue).withValues(alpha: 0.1),
                    child: Image.file(
                      File(item.imagePath),
                      fit: BoxFit.contain,
                    ),
                  ),
                  if (item.inLaundry)
                    Container(
                      color: Colors.white.withAlpha(150),
                      child: const Center(
                        child: Text(
                          'Washing...',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 4,
                    left: 4,
                    child: IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      color: Colors.black54,
                      onPressed: onDelete,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: item.isFavorite ? 36 : 4,
                    child: IconButton(
                      icon: Icon(
                        item.inLaundry
                            ? Icons.local_laundry_service
                            : Icons.local_laundry_service_outlined,
                        size: 20,
                      ),
                      color: item.inLaundry
                          ? Colors.blueAccent
                          : Colors.black54,
                      onPressed: onToggleLaundry,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                  if (item.isFavorite)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: IconButton(
                        icon: const Icon(Icons.favorite, size: 20),
                        color: Colors.redAccent,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {},
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.type,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(item.colorValue),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.category} • ${item.size}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.occasion,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
