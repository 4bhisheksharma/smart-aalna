import 'package:flutter/material.dart';

class AddClothesScreen extends StatefulWidget {
  const AddClothesScreen({super.key});

  @override
  State<AddClothesScreen> createState() => _AddClothesScreenState();
}

class _AddClothesScreenState extends State<AddClothesScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Add Clothes in Smart आल्ना',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF111111),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x1A000000),
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
                  SizedBox(height: isCompact ? 16 : 24),
                  const Expanded(
                    child: Center(child: Text('Add Clothes Screen')),
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
