import 'dart:io';
import 'package:flutter/material.dart';
import 'package:smart_aalna/core/storage/local_storage.dart';
import 'package:smart_aalna/core/widgets/app_button.dart';
import 'package:smart_aalna/core/widgets/welcome_card.dart';
import 'package:smart_aalna/core/services/app_service.dart';
import 'package:smart_aalna/features/home/model/clothing_item.dart';
import 'package:smart_aalna/core/widgets/shimmer_skeleton.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _localStorage = LocalStorage();
  final _appService = AppService();
  String _userName = 'User';

  bool _isLoadingOutfit = true;
  String _aiMessage = '';
  List<ClothingItem> _suggestedItems = [];

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadData();
    LocalStorage.clothesUpdateNotifier.addListener(_loadData);
    LocalStorage.userNameNotifier.addListener(_onUserNameChanged);
  }

  void _onUserNameChanged() {
    if (mounted) {
      setState(() {
        _userName = LocalStorage.userNameNotifier.value.isNotEmpty
            ? LocalStorage.userNameNotifier.value
            : 'User';
      });
    }
  }

  @override
  void dispose() {
    LocalStorage.clothesUpdateNotifier.removeListener(_loadData);
    LocalStorage.userNameNotifier.removeListener(_onUserNameChanged);
    super.dispose();
  }

  Future<void> _loadData({bool reshuffle = false}) async {
    setState(() {
      _isLoadingOutfit = true;
    });

    final clothes = await _localStorage.getClothes();

    if (!mounted) return;

    if (clothes.isNotEmpty) {
      if (!reshuffle) {
        final savedOutfit = await _localStorage.getDailyOutfit();
        if (savedOutfit != null) {
          if (mounted) {
            setState(() {
              _aiMessage = savedOutfit['message'];
              final itemIds = List<String>.from(savedOutfit['items']);
              _suggestedItems = clothes
                  .where((c) => itemIds.contains(c.id))
                  .toList();
              // In case items were deleted, we ensure we have to reshuffle if Empty.
              _isLoadingOutfit = false;
            });
            // If the saved items are still valid in DB, we use them.
            if (_suggestedItems.isNotEmpty) {
              return;
            }
          }
        }
      }

      final query = reshuffle
          ? 'Suggest a completely DIFFERENT outfit from before. Make sure it is a new combination of clothes.'
          : 'What should I wear today?';

      final suggestion = await _appService.getOutfitSuggestion(
        clothes,
        query: query,
      );

      if (mounted && suggestion != null) {
        await _localStorage.saveDailyOutfit(
          suggestion.message,
          suggestion.itemIds,
        );
        setState(() {
          _aiMessage = suggestion.message;
          _suggestedItems = clothes
              .where((c) => suggestion.itemIds.contains(c.id))
              .toList();
          _isLoadingOutfit = false;
        });
      } else {
        if (mounted) {
          setState(() {
            _isLoadingOutfit = false;
            _aiMessage = 'Could not generate suggestion at this time.';
          });
        }
      }
    } else {
      setState(() {
        _isLoadingOutfit = false;
        _aiMessage = 'Add some clothes to your wardrobe first!';
      });
    }
  }

  Future<void> _loadUserName() async {
    final savedName = await _localStorage.getHomeUserName();

    if (!mounted || savedName == null || savedName.trim().isEmpty) {
      return;
    }

    setState(() {
      _userName = savedName.trim();
    });
  }

  Future<void> _saveUserName(String name) async {
    final cleanedName = name.trim();
    if (cleanedName.isEmpty) {
      return;
    }

    await _localStorage.setHomeUserName(cleanedName);

    if (!mounted) {
      return;
    }

    setState(() {
      _userName = cleanedName;
    });
  }

  Future<void> _showNameEditor() async {
    var draftName = _userName;

    final updatedName = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Update your name'),
          content: TextFormField(
            initialValue: _userName,
            autofocus: true,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(hintText: 'Enter your name'),
            onChanged: (value) {
              draftName = value;
            },
            onFieldSubmitted: (_) {
              Navigator.of(dialogContext).pop(draftName);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(draftName);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (!mounted || updatedName == null) {
      return;
    }

    await _saveUserName(updatedName);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),

      body: Stack(
        children: [
          const _HomeBackground(),
          SafeArea(
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
                      Row(
                        children: [
                          Image.asset(
                            'assets/smart-aalna-logo-bw.png',
                            width: 36,
                            height: 36,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Smart आल्ना',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF111111),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isCompact ? 10 : 12),
                      WelcomeCard(
                        userName: _userName,
                        message: 'Here is your outfit suggestion for today.',
                        onTap: _showNameEditor,
                      ),
                      SizedBox(height: isCompact ? 12 : 16),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(isCompact ? 16 : 22),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x1A000000),
                                offset: Offset(0, 14),
                                blurRadius: 24,
                                spreadRadius: -12,
                              ),
                            ],
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: colors.primary.withAlpha(20),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Icon(
                                        Icons.workspace_premium_rounded,
                                        color: colors.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Today\'s Outfit',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.titleLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFF151515),
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: isCompact ? 14 : 20),
                                if (_isLoadingOutfit)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: 120,
                                        child: ListView.separated(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: 3,
                                          separatorBuilder: (_, __) =>
                                              const SizedBox(width: 12),
                                          itemBuilder: (_, __) => Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: const [
                                              ShimmerSkeleton(
                                                width: 100,
                                                height: 100,
                                              ),
                                              SizedBox(height: 8),
                                              ShimmerSkeleton(
                                                width: 80,
                                                height: 12,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: isCompact ? 14 : 20),
                                      const ShimmerSkeleton(
                                        width: double.infinity,
                                        height: 80,
                                        borderRadius: 18,
                                      ),
                                    ],
                                  )
                                else ...[
                                  if (_suggestedItems.isNotEmpty)
                                    SizedBox(
                                      height: 160,
                                      child: ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: _suggestedItems.length,
                                        separatorBuilder: (context, index) =>
                                            const SizedBox(width: 12),
                                        itemBuilder: (context, index) {
                                          final item = _suggestedItems[index];
                                          return Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                width: 100,
                                                height: 100,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  color: Colors.grey[200],
                                                  image: DecorationImage(
                                                    image: FileImage(
                                                      File(item.imagePath),
                                                    ),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              SizedBox(
                                                width: 100,
                                                child: Text(
                                                  item.type,
                                                  maxLines: 2,
                                                  textAlign: TextAlign.center,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: theme
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: const Color(
                                                          0xFF222222,
                                                        ),
                                                      ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                  SizedBox(height: isCompact ? 14 : 20),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(18),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF7F7F7),
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: const Color(0xFFEBEBEB),
                                      ),
                                    ),
                                    child: Text(
                                      _aiMessage,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: const Color(0xFF3F3F3F),
                                            height: 1.4,
                                          ),
                                    ),
                                  ),
                                ],
                                SizedBox(height: isCompact ? 12 : 14),
                                AppButton(
                                  onPressed: _isLoadingOutfit
                                      ? () {}
                                      : () => _loadData(reshuffle: true),
                                  label: 'Reshuffle My Outfit',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeBackground extends StatelessWidget {
  const _HomeBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF1F1F1), Color(0xFFF7F7F7), Color(0xFFFFFFFF)],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -70,
            right: -50,
            child: _BlurOrb(
              size: 210,
              color: const Color(0xFF000000).withAlpha(10),
            ),
          ),
          Positioned(
            top: 220,
            left: -64,
            child: _BlurOrb(
              size: 170,
              color: const Color(0xFF000000).withAlpha(10),
            ),
          ),
        ],
      ),
    );
  }
}

class _BlurOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _BlurOrb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}
