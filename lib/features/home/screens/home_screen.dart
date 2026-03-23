import 'package:flutter/material.dart';
import 'package:smart_aalna/core/storage/local_storage.dart';
import 'package:smart_aalna/core/widgets/welcome_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _localStorage = LocalStorage();
  String _userName = 'Rame';

  @override
  void initState() {
    super.initState();
    _loadUserName();
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
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                    child: Row(
                      children: [
                        Text(
                          'Smart आल्ना',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF111111),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x1F115E59),
                                offset: Offset(0, 8),
                                blurRadius: 18,
                                spreadRadius: -8,
                              ),
                            ],
                          ),
                          child: IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.notifications_none_rounded),
                            color: const Color(0xFF111111),
                            tooltip: 'Notifications',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: WelcomeCard(
                      userName: _userName,
                      message:
                          'Today is 27°C. Your top match is a linen shirt + chinos.',
                      onTap: _showNameEditor,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
                    child: Text(
                      'Quick Actions',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF151515),
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverGrid.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.35,
                    children: const [
                      _ActionTile(
                        icon: Icons.checkroom_rounded,
                        label: 'Build Outfit',
                        accent: Color(0xFF181818),
                      ),
                      _ActionTile(
                        icon: Icons.wb_sunny_rounded,
                        label: 'Weather Match',
                        accent: Color(0xFF232323),
                      ),
                      _ActionTile(
                        icon: Icons.style_rounded,
                        label: 'Closet Planner',
                        accent: Color(0xFF2D2D2D),
                      ),
                      _ActionTile(
                        icon: Icons.psychology_alt_rounded,
                        label: 'AI Stylist',
                        accent: Color(0xFF0F0F0F),
                      ),
                    ],
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x1F115E59),
                            offset: Offset(0, 14),
                            blurRadius: 24,
                            spreadRadius: -12,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: colors.primary.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              Icons.workspace_premium_rounded,
                              color: colors.primary,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Today\'s Best Outfit',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF151515),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Sky blue oxford + beige chinos + white sneakers. Comfort score: 94%.',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: const Color(0xFF444444),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
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
              color: const Color(0xFF000000).withOpacity(0.05),
            ),
          ),
          Positioned(
            top: 220,
            left: -64,
            child: _BlurOrb(
              size: 170,
              color: const Color(0xFF000000).withOpacity(0.04),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color accent;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withOpacity(0.2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x16000000),
            offset: Offset(0, 12),
            blurRadius: 20,
            spreadRadius: -12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accent, size: 22),
          ),
          const Spacer(),
          Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF191919),
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
